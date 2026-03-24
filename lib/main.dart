import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.hasSupabaseConfig) {
    if (kReleaseMode) {
      throw StateError(
        '릴리스 빌드에는 Supabase dart-define이 필요합니다. '
        '예: flutter build appbundle --dart-define-from-file=.env',
      );
    }
    debugPrint(
      'Supabase 미설정: flutter run --dart-define-from-file=.env 또는 '
      '.vscode/settings.json 의 dart.flutterRunAdditionalArgs 를 확인하세요.',
    );
    runApp(const _MissingSupabaseConfigApp());
    return;
  }

  AppConfig.debugLogSupabaseDefineSummary();

  try {
    await Supabase.initialize(
      url: AppConfig.resolvedSupabaseUrl,
      anonKey: AppConfig.resolvedSupabaseAnonKey,
    );
  } on AuthException catch (e, st) {
    if (kDebugMode) {
      debugPrint('Supabase.initialize AuthException: $e\n$st');
    }
    runApp(_SupabaseInitFailedApp(message: 'Supabase 인증 설정 오류: ${e.message}'));
    return;
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('Supabase.initialize 실패: $e\n$st');
    }
    runApp(_SupabaseInitFailedApp(message: 'Supabase 초기화 실패: $e'));
    return;
  }

  // 초기화 직후 세션: 저장소에서 복원되면 곧 채워질 수 있음(비동기). 가입 직후는 반드시 signUp 응답 session 사용
  if (kDebugMode) {
    final s = Supabase.instance.client.auth.currentSession;
    debugPrint(
      '[main] Supabase.initialize 완료 | 저장소 복원 session=${s != null} '
      'userId=${s?.user.id}',
    );
  }

  runApp(const ProviderScope(child: GrooUpApp()));
}

/// .env / dart-define 없이 실행했을 때 안내 화면
class _MissingSupabaseConfigApp extends StatelessWidget {
  const _MissingSupabaseConfigApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Groo-up 설정')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'SUPABASE_URL / SUPABASE_ANON_KEY 가 빌드에 포함되지 않았습니다.\n\n'
              '.env 는 런타임에 읽는 파일이 아니라, 빌드 시 dart-define으로만 주입됩니다.\n\n'
              '• 터미널: flutter run --dart-define-from-file=.env\n'
              '• Cursor/VS Code: .vscode/settings.json 의 dart.flutterRunAdditionalArgs',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

/// initialize 실패 시 원인 표시 (키/URL 오타·네트워크 등)
class _SupabaseInitFailedApp extends StatelessWidget {
  final String message;
  const _SupabaseInitFailedApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Groo-up — 연결 오류')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SelectableText(
              message,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
