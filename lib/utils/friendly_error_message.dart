import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum FriendlyErrorType {
  network,
  auth,
  permission,
  duplicated,
  server,
  unknown,
}

class FriendlyErrorMessage {
  final FriendlyErrorType type;
  final String message;
  FriendlyErrorMessage({required this.type, required this.message});

  // 사용자에게 보여줄 메시지만 반환
  static String of(Object error) => resolve(error).message;

  static FriendlyErrorMessage resolve(Object error) {
    final extracted = _extractExceptionMessage(error);

    //로그인 오류
    if (error is AuthException) {
      return FriendlyErrorMessage(
        type: FriendlyErrorType.auth,
        message: _authMessage(error),
      );
    }
    //DB 처리 오류
    if (error is PostgrestException) {
      return _postgrestMessage(error);
    }

    if (extracted != null && extracted.isNotEmpty) {
      return FriendlyErrorMessage(
        type: FriendlyErrorType.unknown,
        message: extracted,
      );
    }

    if (_isNetworkError(error)) {
      return FriendlyErrorMessage(
        type: FriendlyErrorType.network,
        message: '네트워크 연결을 확인해주세요.',
      ); //리로드 필요.
    }

    if (error is FormatException) {
      return FriendlyErrorMessage(
        type: FriendlyErrorType.unknown,
        message: '입력 형식이 올바르지 않아요. 값을 다시 확인해주세요.',
      );
    }

    return FriendlyErrorMessage(
      type: FriendlyErrorType.unknown,
      message: '데이터를 불러오는 중 오류가 발생하였습니다.\n잠시 후 다시 시도해주세요.',
    );
  }

  static bool _isNetworkError(Object error) {
    if (error is TimeoutException) return true;
    if (error is SocketException) return true;

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

  static String? _extractExceptionMessage(Object error) {
    final text = error.toString();
    const prefix = 'Exception: ';
    if (text.startsWith(prefix)) {
      final msg = text.substring(prefix.length).trim();
      // 개발자가 의도적으로 던진(사용자에게 보여도 되는) 메시지만 통과시키고,
      // 기술적인 메시지는 숨긴다.
      if (_looksUserFacing(msg)) return msg;
    }
    return null;
  }

  static bool _looksUserFacing(String message) {
    if (message.isEmpty) return false;

    // 한글이 포함되면 대체로 사용자 메시지로 간주
    final hasKorean = RegExp(r'[ㄱ-ㅎ가-힣]').hasMatch(message);
    if (hasKorean) return true;

    // 영어/기술 메시지로 보이는 흔한 패턴은 제외
    final lower = message.toLowerCase();
    if (lower.contains('stack trace') ||
        lower.contains('null') ||
        lower.contains('type ') ||
        lower.contains('nosuchelement') ||
        lower.contains('formatexception')) {
      return false;
    }

    return false;
  }

  static String _authMessage(AuthException e) {
    final lower = e.message.toLowerCase();

    // Supabase가 주는 영문 문구를 > 한국어로 변경
    if (lower.contains('invalid login credentials')) {
      return '로그인 정보가 올바르지 않습니다.';
    }
    if (lower.contains('email not confirmed')) {
      return '이메일 인증이 필요합니다.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('already registered')) {
      return '이미 가입된 계정입니다.';
    }
    if (lower.contains('token') && lower.contains('expired')) {
      return '세션이 만료되었습니다. 다시 로그인해주세요.';
    }
    if (lower.contains('rate limit') || lower.contains('too many requests')) {
      return '요청이 많아 잠시 후 다시 시도해주세요.';
    }

    // 메시지가 이미 한글이면 그대로 사용
    if (RegExp(r'[ㄱ-ㅎ가-힣]').hasMatch(e.message)) {
      return e.message;
    }

    // 그 외에는 너무 기술적일 수 있어 기본 문구로 통일
    return '인증 중 오류가 발생했습니다. 다시 로그인해주세요.';
  }

  static FriendlyErrorMessage _postgrestMessage(PostgrestException e) {
    switch (e.code) {
      case '42501':
        return FriendlyErrorMessage(
          type: FriendlyErrorType.permission,
          message: '사용자 권한이 없습니다.',
        );
      case '23505':
        return FriendlyErrorMessage(
          type: FriendlyErrorType.duplicated,
          message: '이미 존재하는 데이터입니다.',
        );
      default:
        break;
    }

    final lower = e.message.toLowerCase();
    if (lower.contains('jwt') || lower.contains('auth')) {
      return FriendlyErrorMessage(
        type: FriendlyErrorType.auth,
        message: '인증에 실패했습니다. 다시 로그인해주세요.',
      ); // >로그인 페이지로 이동
    }

    final parts = <String>[];
    if (e.message.isNotEmpty) parts.add(e.message);
    final details = e.details?.toString().trim();
    if (details != null && details.isNotEmpty) parts.add(details);
    final hint = e.hint?.toString().trim();
    if (hint != null && hint.isNotEmpty) parts.add(hint);

    // 운영에서는 지나치게 기술적인 정보가 될 수 있어 기본 문구를 유지하되,
    // 개발/테스트에서는 원문을 노출해서 원인 파악이 가능하도록 합니다.
    if (kDebugMode) {
      return FriendlyErrorMessage(
        type: FriendlyErrorType.server,
        message: parts.isEmpty ? e.toString() : parts.join('\n'),
      );
    }

    return FriendlyErrorMessage(
      type: FriendlyErrorType.server,
      message: '서버 처리 중 오류가 발생하였습니다.\n잠시 후 다시 시도해주세요.',
    );
  }
}
