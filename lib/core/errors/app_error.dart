/// Unified application error hierarchy (§22).
///
/// Every failure is classified, mapped to a user-facing Arabic message,
/// and carries a "retry makes sense" flag. Raw exceptions are never
/// surfaced to the UI.
library core.errors;

enum AppErrorKind {
  network,
  timeout,
  permission,
  database,
  auth,
  validation,
  serviceNotConfigured,
  unknown,
}

/// The single error type crossing layer boundaries.
class AppException implements Exception {
  const AppException({
    required this.kind,
    required this.userMessage,
    this.cause,
    this.retryable = false,
  });

  final AppErrorKind kind;
  /// Safe, localized, user-facing message. No technical details.
  final String userMessage;
  /// Underlying exception for logs (never shown to users).
  final Object? cause;
  final bool retryable;

  @override
  String toString() => 'AppException($kind): $userMessage';
}

/// Maps raw exceptions from any source into [AppException].
class AppErrorMapper {
  const AppErrorMapper();

  AppException map(Object error) {
    final msg = error.toString();
    if (msg.contains('SocketException') || msg.contains('Failed host') ||
        msg.contains('network')) {
      return const AppException(
        kind: AppErrorKind.network,
        userMessage: 'تعذّر الاتصال بالشبكة. تحقق من الإنترنت وحاول مجددًا.',
        retryable: true,
      );
    }
    if (msg.contains('TimeoutException') || msg.contains('timeout')) {
      return const AppException(
        kind: AppErrorKind.timeout,
        userMessage: 'استغرقت العملية وقتًا أطول من المتاح.',
        retryable: true,
      );
    }
    if (msg.contains('permission') || msg.contains('Permission')) {
      return const AppException(
        kind: AppErrorKind.permission,
        userMessage: 'لم يُمنح الإذن المطلوب. يمكنك تفعيله من إعدادات التطبيق.',
      );
    }
    if (msg.contains('auth') || msg.contains('Auth')) {
      return const AppException(
        kind: AppErrorKind.auth,
        userMessage: 'حدث خطأ في المصادقة. أعد تسجيل الدخول وحاول مجددًا.',
      );
    }
    if (msg.contains('validation') || msg.contains('Invalid')) {
      return const AppException(
        kind: AppErrorKind.validation,
        userMessage: 'البيانات المدخلة غير صالحة.',
      );
    }
    return AppException(
      kind: AppErrorKind.unknown,
      userMessage: 'حدث خطأ غير متوقع. حاول مرة أخرى.',
      cause: error,
      retryable: true,
    );
  }
}

/// Result wrapper so widgets never swallow failures silently.
sealed class Result<T> {
  const Result();
  const factory Result.ok(T value) = Ok._;
  const factory Result.err(AppException error) = Err._;
}

final class Ok<T> extends Result<T> {
  const Ok._(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err._(this.error);
  final AppException error;
}
