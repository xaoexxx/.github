import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/exx_service.dart';

class CreateHouseDialog extends StatefulWidget {
  const CreateHouseDialog({super.key});

  @override
  State<CreateHouseDialog> createState() => _CreateHouseDialogState();
}

class _CreateHouseDialogState extends State<CreateHouseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ownerController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _ownerController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createHouse() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<ExxService>();
      await service.createHouse(
        _ownerController.text,
        name: _nameController.text.isEmpty ? null : _nameController.text,
      );
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ House created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🏠 Create New House'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _ownerController,
              decoration: const InputDecoration(
                labelText: 'Owner Name *',
                hintText: 'Enter owner name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Owner name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'House Name (optional)',
                hintText: 'e.g., Alice\'s Dev House',
                prefixIcon: Icon(Icons.home),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This house will store all your EV CLI data, logs, and runs.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _createHouse,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
