// Error mapping tests (§28): raw exceptions → classified AppException.
import 'package:flutter_test/flutter_test.dart';
import 'package:fajr/core/errors/app_error.dart';

void main() {
  const mapper = AppErrorMapper();

  test('network exceptions map to network kind with retry', () {
    final e = mapper.map(Exception('SocketException: connection refused'));
    expect(e.kind, AppErrorKind.network);
    expect(e.retryable, isTrue);
    expect(e.userMessage, contains('الشبكة'));
  });

  test('timeout exceptions map to timeout kind with retry', () {
    final e = mapper.map(Exception('TimeoutException after 30s'));
    expect(e.kind, AppErrorKind.timeout);
    expect(e.retryable, isTrue);
  });

  test('permission errors are not retryable', () {
    final e = mapper.map(Exception('permission denied by user'));
    expect(e.kind, AppErrorKind.permission);
    expect(e.retryable, isFalse);
  });

  test('unknown errors keep the cause for logs but hide it from users', () {
    final raw = Exception('database corruption: table xyz');
    final e = mapper.map(raw);
    expect(e.kind, AppErrorKind.unknown);
    expect(e.retryable, isTrue);
    expect(e.cause, same(raw));
    expect(e.userMessage, isNot(contains('xyz')));
  });

  test('Result wraps success and failure without swallowing errors', () {
    const ok = Result<String>.ok('value');
    const err = Result<String>.err(AppException(
      kind: AppErrorKind.network,
      userMessage: 'خطأ شبكة',
    ));
    expect(ok, isA<Ok<String>>());
    expect((ok as Ok<String>).value, 'value');
    expect(err, isA<Err<String>>());
    expect((err as Err<String>).error.userMessage, 'خطأ شبكة');
  });
}
