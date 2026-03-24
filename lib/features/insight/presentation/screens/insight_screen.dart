import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../domain/entities/trend_log_entity.dart';
import '../providers/insight_provider.dart';

class InsightScreen extends ConsumerWidget {
  const InsightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: InsightCategory.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('트렌드 인사이트'),
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: '뉴스'),
              Tab(text: '주식'),
              Tab(text: '논문'),
            ],
          ),
        ),
        body: TabBarView(
          children: InsightCategory.values
              .map((cat) => _InsightList(category: cat))
              .toList(),
        ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      ),
    );
  }
}

class _InsightList extends ConsumerWidget {
  const _InsightList({required this.category});

  final InsightCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(trendLogsForCategoryProvider(category));
    final marksAsync = ref.watch(bookmarkedTrendIdsProvider);

    return logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(trendLogsForCategoryProvider(category)),
                child: const Text('다시 불러오기'),
              ),
            ],
          ),
        ),
      ),
      data: (logs) {
        final bookmarked = marksAsync.valueOrNull ?? <String>{};

        if (logs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                '아직 이 카테고리에 수집된 트렌드가 없습니다.\n(n8n → Supabase 파이프라인을 연결하면 여기에 표시됩니다)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, height: 1.4),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(trendLogsForCategoryProvider(category));
            ref.invalidate(bookmarkedTrendIdsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: logs.length,
            itemBuilder: (ctx, i) {
              final log = logs[i];
              final isMarked = bookmarked.contains(log.id);
              return _TrendLogCard(
                log: log,
                isBookmarked: isMarked,
                onOpenSource: () => _openUrl(ctx, log.sourceUrl),
                onToggleBookmark: () =>
                    _toggleBookmark(ctx, ref, log.id, isMarked),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openUrl(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('원문 링크가 없습니다.')),
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크 형식이 올바르지 않습니다.')),
      );
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('브라우저를 열 수 없습니다.')),
      );
    }
  }

  Future<void> _toggleBookmark(
    BuildContext context,
    WidgetRef ref,
    String trendLogId,
    bool currentlyBookmarked,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final usecase = ref.read(toggleTrendBookmarkUsecaseProvider);
    final result = await usecase.execute(
      userId: user.id,
      trendLogId: trendLogId,
      currentlyBookmarked: currentlyBookmarked,
    );
    result.fold(
      (f) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(f.message)),
          );
        }
      },
      (_) => ref.invalidate(bookmarkedTrendIdsProvider),
    );
  }
}

class _TrendLogCard extends StatelessWidget {
  const _TrendLogCard({
    required this.log,
    required this.isBookmarked,
    required this.onOpenSource,
    required this.onToggleBookmark,
  });

  final TrendLogEntity log;
  final bool isBookmarked;
  final VoidCallback onOpenSource;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subtitle = StringBuffer();
    if (log.sourceName != null && log.sourceName!.isNotEmpty) {
      subtitle.write(log.sourceName);
    }
    if (log.publishedAt != null) {
      if (subtitle.isNotEmpty) subtitle.write(' · ');
      subtitle.write(_formatDate(log.publishedAt!));
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onOpenSource,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 1.25,
                      ),
                    ),
                    if (log.summary != null && log.summary!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        log.summary!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.35,
                        ),
                      ),
                    ],
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle.toString(),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                    if (log.relevanceTags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: log.relevanceTags
                            .take(6)
                            .map(
                              (t) => Chip(
                                label: Text(t, style: const TextStyle(fontSize: 11)),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: scheme.primaryContainer.withValues(alpha: 0.35),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleBookmark,
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? scheme.primary : null,
                ),
                tooltip: isBookmarked ? '북마크 해제' : '북마크',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    return '${local.year}.${local.month.toString().padLeft(2, '0')}.${local.day.toString().padLeft(2, '0')}';
  }
}
