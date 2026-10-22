/// Adhkar reader — session progress with counter, undo, day rollover.
library features.adhkar;

import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import 'adhkar_data.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key, required this.state});
  final AppState state;

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  late final TabController _tab;
  late final AppState _state;
  int _currentDhikrIndex = 0;
  Map<String, int> _counts = {};

  @override
  void initState() {
    super.initState();
    _state = widget.state;
    _counts = _state.adhkarProgress?.dailyCounts ?? {};
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = DhikrCategory.values[_tab.index];
    final list = _state.adhkarOf(cat);
    return Scaffold(
      appBar: AppBar(
        title: Text(cat.label),
        bottom: TabBar(
          controller: _tab,
          tabs: DhikrCategory.values.map((c) => Tab(text: c.label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: DhikrCategory.values.map((c) {
          final items = _state.adhkarOf(c);
          if (items.isEmpty) {
            return const Center(child: Text('لا يوجد محتوى لهذا القسم'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) => _dhikrCard(items[i], i),
          );
        }).toList(),
      ),
    );
  }

  Widget _dhikrCard(Dhikr d, int index) {
    final done = _state.adhkarProgress?.completedIds.contains(d.id) ?? false;
    final count = _counts[d.id] ?? 0;
    final total = d.repetition > 0 ? d.repetition : null;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(d.text, style: Theme.of(context).textTheme.bodyLarge),
            if (d.reference != null) ...[
              const SizedBox(height: 8),
              Text(
                d.reference!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.start,
              ),
            ],
            const SizedBox(height: 16),
            if (done)
              OutlinedButton.icon(
                icon: const Icon(Icons.undo, size: 18),
                label: Text('إلغاء التسجيل'),
                onPressed: () async {
                  await _state.undoDhikr(d.id);
                  setState(() {});
                },
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Text(
                      total != null ? '$count / $total' : 'عدد التكرارات: $count',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  FilledButton(
                    onPressed: () async {
                      final c = count + 1;
                      await _state.setDhikrCount(d.id, c);
                      if (total != null && c >= total) {
                        await _state.completeDhikr(d.id);
                      }
                      setState(() {});
                    },
                    child: const Text('عدّ'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'إعادة ضبط',
                    onPressed: () async {
                      await _state.setDhikrCount(d.id, 0);
                      setState(() {});
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
