import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/domain/entities/bible_models.dart';
import 'package:biblesos/presentation/widgets/bible_cover_thumbnail.dart';

class TranslationsScreen extends ConsumerWidget {
  const TranslationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationsAsync = ref.watch(translationsProvider);
    final selectedTranslation = ref.watch(selectedTranslationProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Replace View'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
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

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: sortedTranslations.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
            itemBuilder: (context, index) {
              final translation = sortedTranslations[index];
              final isSelected = translation.abv == selectedTranslation.abv;
              final isSesotho = translation.abv.toUpperCase() == 'SOS' || translation.abv.toUpperCase() == 'SESOTHO';

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
                    : (isSesotho ? null : Icon(Icons.download_for_offline_outlined, color: theme.primaryColor.withOpacity(0.7))),
                onTap: () {
                  ref.read(selectedTranslationProvider.notifier).set(translation);
                  Navigator.pop(context);
                },
              );
            },
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
    );
  }
}
