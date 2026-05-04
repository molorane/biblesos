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

enum PlanScope { wholeBible, selectedBooks }

class _ReadingPlanCreationScreenState extends ConsumerState<ReadingPlanCreationScreen> {
  late TextEditingController _titleController;
  late int _durationDays;
  List<Book> _selectedBooks = [];
  bool _isInitialized = false;
  PlanScope _planScope = PlanScope.wholeBible;
  bool _syncProgress = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingPlan?.title ?? 'My Bible Journey');
    _durationDays = widget.existingPlan != null ? 365 : 90; // Default to 90 days for new plans
    if (widget.existingPlan != null) {
      // Determine scope from existing plan - if all 66 books, probably whole bible
      // But for simplicity, we'll let user change it
    }
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
          final List<Book> ordered = [];
          for (int id in widget.existingPlan!.bookOrder) {
            final book = allBooks.firstWhere((b) => b.id == id, orElse: () => allBooks.first);
            ordered.add(book);
          }
          _selectedBooks = ordered;
          _planScope = ordered.length == allBooks.length ? PlanScope.wholeBible : PlanScope.selectedBooks;
        } else {
          _selectedBooks = List.from(allBooks);
          _planScope = PlanScope.wholeBible;
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Plan Scope', style: theme.textTheme.titleMedium),
                        SegmentedButton<PlanScope>(
                          segments: const [
                            ButtonSegment(value: PlanScope.wholeBible, label: Text('Whole Bible'), icon: Icon(Icons.auto_stories)),
                            ButtonSegment(value: PlanScope.selectedBooks, label: Text('Selected'), icon: Icon(Icons.library_books)),
                          ],
                          selected: {_planScope},
                          onSelectionChanged: (Set<PlanScope> newSelection) {
                            setState(() {
                              _planScope = newSelection.first;
                              if (_planScope == PlanScope.wholeBible) {
                                _selectedBooks = List.from(allBooks);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_planScope == PlanScope.selectedBooks) ...[
                      OutlinedButton.icon(
                        onPressed: () => _showBookPickerDialog(allBooks),
                        icon: const Icon(Icons.add),
                        label: const Text('Select Books'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4DB66A),
                          side: const BorderSide(color: Color(0xFF4DB66A)),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Duration: $_durationDays Days', style: theme.textTheme.titleMedium),
                        Text('~${(_selectedBooks.length * 50 / _durationDays).toStringAsFixed(1)} chapters/day', 
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                    Slider(
                      value: _durationDays.toDouble(),
                      min: 7,
                      max: 1095,
                      divisions: 155,
                      activeColor: const Color(0xFF4DB66A),
                      label: '$_durationDays Days',
                      onChanged: (value) => setState(() => _durationDays = value.toInt()),
                    ),
                    const Divider(height: 32),
                    SwitchListTile(
                      title: const Text('Import Existing Progress'),
                      subtitle: const Text('Mark chapters as read if completed in other plans'),
                      value: _syncProgress,
                      activeColor: const Color(0xFF4DB66A),
                      onChanged: (value) => setState(() => _syncProgress = value),
                    ),
                    const Divider(height: 32),
                    Row(
                      children: [
                        Text('Reading Order', style: theme.textTheme.titleMedium),
                        const Spacer(),
                        const Text('Drag to reorder', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _selectedBooks.isEmpty 
                  ? const Center(child: Text('No books selected'))
                  : ReorderableListView(
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
                          key: ValueKey('book_${_selectedBooks[i].id}'),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF4DB66A).withOpacity(0.1),
                            child: Text('${i + 1}', style: const TextStyle(fontSize: 12, color: Color(0xFF4DB66A), fontWeight: FontWeight.bold)),
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

  void _showBookPickerDialog(List<Book> allBooks) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Select Books', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            if (_selectedBooks.length == allBooks.length) {
                              _selectedBooks = [];
                            } else {
                              _selectedBooks = List.from(allBooks);
                            }
                          });
                          setState(() {});
                        },
                        child: Text(_selectedBooks.length == allBooks.length ? 'Deselect All' : 'Select All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: allBooks.length,
                      itemBuilder: (context, index) {
                        final book = allBooks[index];
                        final isSelected = _selectedBooks.any((b) => b.id == book.id);
                        return CheckboxListTile(
                          title: Text(book.name),
                          value: isSelected,
                          activeColor: const Color(0xFF4DB66A),
                          onChanged: (value) {
                            setModalState(() {
                              if (value == true) {
                                if (!isSelected) _selectedBooks.add(book);
                              } else {
                                _selectedBooks.removeWhere((b) => b.id == book.id);
                              }
                            });
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4DB66A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('DONE'),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _savePlan() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a plan name')));
      return;
    }

    if (_selectedBooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one book')));
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
        syncProgress: _syncProgress,
      );
    }

    if (mounted) {
      Navigator.pop(context); // Close loading
      Navigator.pop(context); // Close creation screen
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reading plan created successfully!')));
    }
  }
}
