import 'dart:async';

class FriendlyErrorMessage {
  static String of(Object error) {
    if (_isNetworkError(error)) {
      return '네트워크 연결이 불안정해요.\n인터넷/VPN/방화벽 설정을 확인한 뒤 다시 시도해주세요.';
    }

    return '데이터를 불러오는 중 오류가 발생했어요.\n잠시 후 다시 시도해주세요.';
  }

  static bool _isNetworkError(Object error) {
    if (error is TimeoutException) return true;

    final text = error.toString().toLowerCase();
    return text.contains('socketexception') ||
        text.contains('clientexception') ||
        text.contains('connection timed out') ||
        text.contains('timed out') ||
        text.contains('failed host lookup') ||
        text.contains('handshake') ||
        text.contains('connection refused') ||
        text.contains('network is unreachable') ||
        text.contains('no address associated with hostname');
  }
}
