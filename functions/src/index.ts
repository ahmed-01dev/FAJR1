/**
 * FAJR Cloud Functions — trusted server-side operations (§19).
 *
 * Only operations that MUST NOT run on the client live here:
 *   - team membership changes (prevent forged joins)
 *   - XP/streak grants (prevent self-awarding)
 *   - account deletion with data cleanup
 *   - invite code validation & rotation
 */
import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

/** Join a team via invite code. All validation server-side (§14). */
export const joinTeam = onCall({ cors: true }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "يجب تسجيل الدخول أولًا.");
  }
  const { inviteCode } = request.data as { inviteCode?: string };
  if (typeof inviteCode !== "string" || inviteCode.length !== 8) {
    throw new HttpsError("invalid-argument", "رمز الدعوة غير صالح.");
  }

  // Transaction: atomically check membership + update counts (§19).
  return db.runTransaction(async (tx) => {
    const teamsSnap = await tx.get(
      db.collection("teams").where("inviteCode", "==", inviteCode).limit(1)
    );
    if (teamsSnap.empty) {
      throw new HttpsError("not-found", "لا يوجد فريق بهذا الرمز.");
    }
    const teamRef = teamsSnap.docs[0].ref;
    const team = teamsSnap.docs[0].data();
    const memberRef = teamRef.collection("members").doc(uid);

    const memberSnap = await tx.get(memberRef);
    if (memberSnap.exists) {
      throw new HttpsError("already-exists", "أنت عضو في هذا الفريق بالفعل.");
    }
    if ((team.memberCount ?? 0) >= 50) {
      throw new HttpsError("resource-exhausted", "الفريق مكتمل العدد.");
    }

    tx.create(memberRef, {
      uid,
      displayName: request.auth?.token?.name ?? "",
      joinedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    tx.update(teamRef, {
      memberCount: admin.firestore.FieldValue.increment(1),
    });
    return { teamId: teamRef.id, teamName: team.name as string };
  });
});

/** Leave a team. Server verifies actual membership (§14). */
export const leaveTeam = onCall({ cors: true }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "يجب تسجيل الدخول أولًا.");
  }
  const { teamId } = request.data as { teamId?: string };
  if (typeof teamId !== "string") {
    throw new HttpsError("invalid-argument", "معرف الفريق غير صالح.");
  }
  const teamRef = db.collection("teams").doc(teamId);
  const memberRef = teamRef.collection("members").doc(uid);

  return db.runTransaction(async (tx) => {
    const [teamSnap, memberSnap] = await Promise.all([
      tx.get(teamRef),
      tx.get(memberRef),
    ]);
    if (!teamSnap.exists) {
      throw new HttpsError("not-found", "الفريق غير موجود.");
    }
    if (!memberSnap.exists) {
      throw new HttpsError("failed-precondition", "أنت لست عضوًا في هذا الفريق.");
    }
    const ownerUid = teamSnap.data().ownerId as string;
    if (ownerUid === uid) {
      throw new HttpsError(
        "failed-precondition",
        "منشئ الفريق لا يستطيع مغادرته — انقل الملكية أو احذف الفريق."
      );
    }
    tx.delete(memberRef);
    tx.update(teamRef, {
      memberCount: admin.firestore.FieldValue.increment(-1),
    });
    return { ok: true };
  });
});

/** Delete account with cascade cleanup of all user data (§21). */
export const deleteAccount = onCall({ cors: true }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "يجب تسجيل الدخول أولًا.");
  }
  const batch = db.batch();

  // User-owned docs (§18: document deletion policy).
  batch.delete(db.collection("users").doc(uid));
  batch.delete(db.collection("user_settings").doc(uid));

  // Companion requests in both directions.
  const requestsAsFrom = await db
    .collection("companion_requests")
    .where("fromUid", "==", uid)
    .get();
  const requestsAsTo = await db
    .collection("companion_requests")
    .where("toUid", "==", uid)
    .get();
  [...requestsAsFrom.docs, ...requestsAsTo.docs].forEach((d) =>
    batch.delete(d.ref)
  );

  // Team memberships across all teams.
  const memberships = await db
    .collectionGroup("members")
    .where("uid", "==", uid)
    .get();
  memberships.docs.forEach((d) => {
    batch.delete(d.ref);
    batch.update(d.ref.parent.parent!, {
      memberCount: admin.firestore.FieldValue.increment(-1),
    });
  });

  await batch.commit();
  await admin.auth().deleteUser(uid);
  return { ok: true };
});

/** Grant prayer XP — server-verified self-report (§15). */
export const logPrayerAndGrantXp = onCall({ cors: true }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "يجب تسجيل الدخول أولًا.");
  }
  const { prayerName, date } = request.data as {
    prayerName?: string;
    date?: string;
  };
  const validPrayers = ["fajr", "dhuhr", "asr", "maghrib", "isha"];
  if (!prayerName || !validPrayers.includes(prayerName)) {
    throw new HttpsError("invalid-argument", "اسم الصلاة غير صالح.");
  }
  if (!date || !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
    throw new HttpsError("invalid-argument", "التاريخ غير صالح.");
  }

  // Idempotency: same prayer+day can never count twice (§15).
  const logId = `${uid}_${date}_${prayerName}`;
  const logRef = db.collection("prayer_logs").doc(logId);
  const userRef = db.collection("users").doc(uid);

  return db.runTransaction(async (tx) => {
    const logSnap = await tx.get(logRef);
    if (logSnap.exists) {
      return { alreadyLogged: true, xp: 0 };
    }
    tx.create(logRef, {
      uid,
      prayerName,
      date,
      selfReported: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    tx.update(userRef, {
      xp: admin.firestore.FieldValue.increment(10),
    });
    return { alreadyLogged: false, xp: 10 };
  });
});
