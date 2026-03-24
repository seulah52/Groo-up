import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../garden/presentation/providers/garden_provider.dart';
import '../providers/input_provider.dart';

class InputScreen extends ConsumerStatefulWidget {
  const InputScreen({super.key});
  @override
  ConsumerState<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends ConsumerState<InputScreen> {
  final _titleCtrl = TextEditingController();
  final _categories = ['기술', '비즈니스', '창작', '라이프', '기타'];
  String? _selectedCategory;

  @override
  void dispose() { _titleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final inputState = ref.watch(inputNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('씨앗 심기'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/garden'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('어떤 아이디어인가요?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('한 줄로 표현할수록 좋아요',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 20),
          TextField(
            controller: _titleCtrl, maxLines: 3, maxLength: 100, autofocus: true,
            decoration: InputDecoration(
              hintText: '예: AI로 식물 일기를 자동으로 써주는 앱',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 16),
          const Text('카테고리 (선택)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: _categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return ChoiceChip(
              label: Text(cat), selected: isSelected,
              onSelected: (_) => setState(() =>
                  _selectedCategory = isSelected ? null : cat));
          }).toList()),
          if (inputState.status == InputStatus.error && inputState.errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(inputState.errorMessage!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
          ],
          const Spacer(),
          FilledButton(
            onPressed: inputState.status == InputStatus.loading ? null : _plant,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: inputState.status == InputStatus.loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('씨앗 심기 🌱'),
          ),
          const SizedBox(height: 16),
        ]),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Future<void> _plant() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('아이디어를 입력해주세요')));
      return;
    }
    final success = await ref.read(inputNotifierProvider.notifier)
        .plantSeed(title: title, category: _selectedCategory);
    if (success && mounted) {
      ref.read(gardenNotifierProvider.notifier).refresh();
      context.go('/garden');
    }
  }
}
