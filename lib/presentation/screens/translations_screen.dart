import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/domain/entities/bible_models.dart';
import 'package:biblesos/presentation/widgets/bible_cover_thumbnail.dart';

class TranslationsScreen extends ConsumerStatefulWidget {
  const TranslationsScreen({super.key});

  @override
  ConsumerState<TranslationsScreen> createState() => _TranslationsScreenState();
}

class _TranslationsScreenState extends ConsumerState<TranslationsScreen> {
  final Set<String> _downloadingAbvs = {};
  final Map<String, double> _downloadProgress = {};

  Future<void> _handleDownload(Translation translation) async {
    setState(() {
      _downloadingAbvs.add(translation.abv);
      _downloadProgress[translation.abv] = 0;
    });

    try {
      final repository = ref.read(bibleRepositoryProvider);
      await repository.downloadTranslation(
        translation.abv,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _downloadProgress[translation.abv] = progress;
            });
          }
        },
      );
      
      // Refresh the downloaded status
      ref.invalidate(downloadedTranslationsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${translation.name} downloaded successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download ${translation.name}: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloadingAbvs.remove(translation.abv);
          _downloadProgress.remove(translation.abv);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationsAsync = ref.watch(translationsProvider);
    final selectedTranslation = ref.watch(selectedTranslationProvider);
    final downloadedAsync = ref.watch(downloadedTranslationsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bible Translations'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Downloaded'),
              Tab(text: 'Translations'),
            ],
          ),
        ),
        body: translationsAsync.when(
          data: (translations) {
            // Sort Sesotho to the top
            final sortedTranslations = List<Translation>.from(translations);
            sortedTranslations.sort((a, b) {
              final aIsSesotho = a.name.toLowerCase().contains('sesotho') || 
                                a.abv.toUpperCase() == 'SOS' || 
                                a.abv.toUpperCase() == 'SESOTHO';
              final bIsSesotho = b.name.toLowerCase().contains('sesotho') || 
                                b.abv.toUpperCase() == 'SOS' || 
                                b.abv.toUpperCase() == 'SESOTHO';
              
              if (aIsSesotho && !bIsSesotho) return -1;
              if (!aIsSesotho && bIsSesotho) return 1;
              return a.name.compareTo(b.name);
            });

            final downloadedSet = downloadedAsync.maybeWhen(
              data: (set) => set,
              orElse: () => <String>{},
            );

            final downloadedTranslations = sortedTranslations
                .where((t) => downloadedSet.contains(t.abv))
                .toList();

            return TabBarView(
              children: [
                _buildTranslationList(
                  context,
                  downloadedTranslations,
                  selectedTranslation,
                  downloadedSet,
                  isDark,
                ),
                _buildTranslationList(
                  context,
                  sortedTranslations,
                  selectedTranslation,
                  downloadedSet,
                  isDark,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load translations from API.', textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('$err', style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(translationsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationList(
    BuildContext context,
    List<Translation> translations,
    Translation selectedTranslation,
    Set<String> downloadedSet,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    
    if (translations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_download_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'No downloaded translations yet',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: translations.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
      itemBuilder: (context, index) {
        final translation = translations[index];
        final isSelected = translation.abv == selectedTranslation.abv;
        final isSesotho = translation.abv.toUpperCase() == 'SOS' || translation.abv.toUpperCase() == 'SESOTHO';
        final isDownloading = _downloadingAbvs.contains(translation.abv);
        final progress = _downloadProgress[translation.abv] ?? 0;
        final isDownloaded = downloadedSet.contains(translation.abv);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: BibleCoverThumbnail(
            abbreviation: translation.abv,
            color: isSesotho ? const Color(0xFF4DB66A) : const Color(0xFF6D4C41),
          ),
          title: Text(
            translation.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 16,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              isSesotho ? 'Lesotho • Default' : 'Public Domain • Free',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
          trailing: isSelected 
              ? Icon(Icons.check_circle, color: theme.primaryColor)
              : isDownloading
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            value: progress > 0 ? progress : null,
                            strokeWidth: 2.5,
                          ),
                        ),
                        if (progress > 0)
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                      ],
                    )
                  : isDownloaded
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.download_for_offline_outlined),
                          color: theme.primaryColor.withOpacity(0.7),
                          onPressed: () => _handleDownload(translation),
                        ),
          onTap: (isDownloaded && !isSelected && !isDownloading) ? () async {
            try {
              await ref.read(selectedTranslationProvider.notifier).set(translation);
              if (mounted) Navigator.pop(context);
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error switching to ${translation.name}: $e'), backgroundColor: Colors.red),
                );
              }
            }
          } : null,
        );
      },
    );
  }
}
