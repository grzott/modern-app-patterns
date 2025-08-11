# Compound Widgets (Flutter)

Goal: Build a component that exposes slots for flexible composition.

## Pattern

- Parent widget defines structure.
- Children fill slots via constructor params or builders.

## Example

```dart
// widgets/card_section.dart
import 'package:flutter/material.dart';

typedef Slot = Widget Function(BuildContext context);

class CardSection extends StatelessWidget {
  final Slot header; final Slot body; final Slot? footer;
  const CardSection({super.key, required this.header, required this.body, this.footer});

  @override Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        header(context), const SizedBox(height: 8),
        body(context), if (footer != null) ...[
          const Divider(), footer!(context)
        ],
      ]),
    ),
  );
}
```

```dart
// usage
CardSection(
  header: (_) => const Text('Todos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  body: (_) => const Text('List goes here'),
  footer: (_) => TextButton(onPressed: () {}, child: const Text('See all')),
)
```

Notes

- For very dynamic slots, prefer builder callbacks over direct widgets to access context.

---

## Sandbox copy map

- Put `widgets/` under `sandboxes/flutter/lib/`.
- Import and render inside sandbox `main.dart` body.
