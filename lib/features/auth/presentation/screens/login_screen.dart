import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_brand_logo.dart';
import '../providers/auth_state_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool _isSignUp      = false;

  @override
  void dispose() {
    _emailCtrl.dispose(); _passwordCtrl.dispose(); _usernameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (_, next) {
      if (next.status == AuthStatus.authenticated) context.go('/garden');
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                const Center(child: GrooUpBrandMark(size: 88)),
                const SizedBox(height: 20),
                Text(
                  'Groo-up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.treeGreen,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '아이디어를 나무처럼 키워보세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 48),
                if (_isSignUp) ...[
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: _deco('닉네임'),
                    validator: (v) => (v == null || v.isEmpty) ? '닉네임을 입력해주세요' : null,
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _emailCtrl,
                  decoration: _deco('이메일'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? '올바른 이메일을 입력해주세요' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: _deco('비밀번호'),
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 6) ? '6자 이상 입력해주세요' : null,
                ),
                if (authState.status == AuthStatus.error && authState.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(authState.errorMessage!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: authState.status == AuthStatus.loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: authState.status == AuthStatus.loading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isSignUp ? '회원가입' : '로그인'),
                ),
                if (authState.status == AuthStatus.loading && _isSignUp) ...[
                  const SizedBox(height: 10),
                  Text(
                    '계정 생성 후 프로필을 저장하고 있어요. 완료되면 과수원으로 이동합니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).clearError();
                    setState(() => _isSignUp = !_isSignUp);
                  },
                  child: Text(_isSignUp ? '이미 계정이 있으신가요? 로그인' : '계정이 없으신가요? 회원가입'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _deco(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final n = ref.read(authNotifierProvider.notifier);
    if (_isSignUp) {
      await n.signUp(email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text, username: _usernameCtrl.text.trim());
    } else {
      await n.signIn(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
    }
  }
}
