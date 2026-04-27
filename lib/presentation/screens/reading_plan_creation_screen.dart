import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biblesos/domain/entities/reading_plan_models.dart';
import 'package:biblesos/presentation/providers/bible_providers.dart';
import 'package:biblesos/presentation/providers/reading_plan_providers.dart';
import 'package:biblesos/domain/entities/bible_models.dart';

class ReadingPlanCreationScreen extends ConsumerStatefulWidget {
  final ReadingPlan? existingPlan;
  const ReadingPlanCreationScreen({super.key, this.existingPlan});

  @override
  ConsumerState<ReadingPlanCreationScreen> createState() => _ReadingPlanCreationScreenState();
}

class _ReadingPlanCreationScreenState extends ConsumerState<ReadingPlanCreationScreen> {
  late TextEditingController _titleController;
  late int _durationDays;
  List<Book> _selectedBooks = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingPlan?.title ?? 'My Bible Journey');
    _durationDays = widget.existingPlan != null ? 365 : 365; // Default for now, could calculate
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _initializeBooks(List<Book> allBooks) {
    if (!_isInitialized && allBooks.isNotEmpty) {
      setState(() {
        if (widget.existingPlan != null) {
          // Reorder allBooks according to existingPlan.bookOrder
          final List<Book> ordered = [];
          for (int id in widget.existingPlan!.bookOrder) {
            final book = allBooks.firstWhere((b) => b.id == id);
            ordered.add(book);
          }
          _selectedBooks = ordered;
        } else {
          _selectedBooks = List.from(allBooks);
        }
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Reading Plan'),
        actions: [
          TextButton(
            onPressed: _savePlan,
            child: const Text('SAVE', style: TextStyle(color: Color(0xFF4DB66A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: booksAsync.when(
        data: (allBooks) {
          _initializeBooks(allBooks);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Plan Name',
                        hintText: 'e.g. 1 Year Bible Plan',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Duration: $_durationDays Days', style: theme.textTheme.titleMedium),
                    Slider(
                      value: _durationDays.toDouble(),
                      min: 30,
                      max: 730,
                      divisions: 14,
                      activeColor: const Color(0xFF4DB66A),
                      label: '$_durationDays Days',
                      onChanged: (value) => setState(() => _durationDays = value.toInt()),
                    ),
                    const Divider(height: 32),
                    Row(
                      children: [
                        Text('Book Order', style: theme.textTheme.titleMedium),
                        const Spacer(),
                        const Text('Drag to reorder', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _selectedBooks.removeAt(oldIndex);
                      _selectedBooks.insert(newIndex, item);
                    });
                  },
                  children: [
                    for (int i = 0; i < _selectedBooks.length; i++)
                      ListTile(
                        key: ValueKey(_selectedBooks[i].id),
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child: Text('${i + 1}', style: const TextStyle(fontSize: 12, color: Colors.black)),
                        ),
                        title: Text(_selectedBooks[i].name),
                        trailing: const Icon(Icons.drag_handle),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _savePlan() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a plan name')));
      return;
    }

    final bookIds = _selectedBooks.map((b) => b.id).toList();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (widget.existingPlan != null) {
      await ref.read(readingPlanControllerProvider.notifier).updatePlan(
        planId: widget.existingPlan!.id,
        title: _titleController.text,
        startDate: widget.existingPlan!.startDate,
        bookOrder: bookIds,
        durationDays: _durationDays,
      );
    } else {
      await ref.read(readingPlanControllerProvider.notifier).createPlan(
        title: _titleController.text,
        startDate: DateTime.now(),
        bookOrder: bookIds,
        durationDays: _durationDays,
      );
    }

    if (mounted) {
      Navigator.pop(context); // Close loading
      Navigator.pop(context); // Close creation screen
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reading plan created successfully!')));
    }
  }
}
