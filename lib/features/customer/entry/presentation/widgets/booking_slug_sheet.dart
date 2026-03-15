import 'package:flutter/material.dart';

/// Modal bottom sheet for entering an organization slug to navigate to.
///
/// Calls [onSubmit] with the trimmed slug when the user taps Go or submits
/// the text field. The parent is responsible for performing the navigation.
class BookingSlugSheet extends StatefulWidget {
  const BookingSlugSheet({super.key, required this.onSubmit});

  final void Function(String slug) onSubmit;

  @override
  State<BookingSlugSheet> createState() => _BookingSlugSheetState();
}

class _BookingSlugSheetState extends State<BookingSlugSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final slug = _controller.text.trim();
    if (slug.isEmpty) return;
    Navigator.of(context).pop();
    widget.onSubmit(slug);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter organization slug',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. clinic-123',
              border: OutlineInputBorder(),
              labelText: 'Organization slug',
            ),
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _submit, child: const Text('Go')),
          ),
        ],
      ),
    );
  }
}
