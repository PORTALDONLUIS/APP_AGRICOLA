import 'package:flutter/material.dart';

class SectionTile extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const SectionTile({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = true,
  });

  @override
  State<SectionTile> createState() => _SectionTileState();
}

class _SectionTileState extends State<SectionTile> {
  late bool expanded;

  @override
  void initState() {
    super.initState();
    expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => expanded = !expanded),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}
