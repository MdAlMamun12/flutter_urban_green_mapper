import 'package:flutter/material.dart';
import 'package:urban_green_mapper/core/widgets/custom_button.dart';

class DeleteAccountDialog extends StatefulWidget {
  final Function(String confirmationText) onDelete;

  const DeleteAccountDialog({
    super.key,
    required this.onDelete,
  });

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _confirmationController = TextEditingController();
  bool _understandConsequences = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Delete Account',
        style: TextStyle(color: Colors.red),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone. This will permanently delete:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildConsequenceItem('Your profile information'),
            _buildConsequenceItem('All your activity reports'),
            _buildConsequenceItem('Your event participation history'),
            _buildConsequenceItem('Your plant adoption records'),
            _buildConsequenceItem('Your impact score and statistics'),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmationController,
              decoration: const InputDecoration(
                labelText: 'Type "DELETE" to confirm',
                hintText: 'DELETE',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _understandConsequences,
                  onChanged: (value) {
                    setState(() {
                      _understandConsequences = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'I understand that all my data will be permanently deleted and this action cannot be undone.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CustomButton(
          onPressed: _canDelete() ? _deleteAccount : null,
          backgroundColor: Colors.red,
          child: const Text('Delete Account'),
        ),
      ],
    );
  }

  Widget _buildConsequenceItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.remove, size: 16, color: Colors.red[700]),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  bool _canDelete() {
    return _confirmationController.text == 'DELETE' && _understandConsequences;
  }

  void _deleteAccount() {
    if (_canDelete()) {
      widget.onDelete(_confirmationController.text);
    }
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }
}