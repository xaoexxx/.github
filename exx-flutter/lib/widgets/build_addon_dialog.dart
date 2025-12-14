import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/exx_service.dart';

class BuildAddonDialog extends StatefulWidget {
  const BuildAddonDialog({super.key});

  @override
  State<BuildAddonDialog> createState() => _BuildAddonDialogState();
}

class _BuildAddonDialogState extends State<BuildAddonDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedHouseId;
  String? _selectedAddonType;
  bool _isLoading = false;

  Future<void> _buildAddon() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<ExxService>();
      await service.buildAddon(_selectedHouseId!, _selectedAddonType!);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Addon built successfully!'),
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
    final service = context.watch<ExxService>();
    
    return AlertDialog(
      title: const Text('🔨 Build Addon'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedHouseId,
              decoration: const InputDecoration(
                labelText: 'Select House *',
                prefixIcon: Icon(Icons.home),
              ),
              items: service.houses.map((house) {
                return DropdownMenuItem(
                  value: house.id,
                  child: Text('${house.name} (${house.owner})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedHouseId = value);
              },
              validator: (value) {
                if (value == null) return 'Please select a house';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedAddonType,
              decoration: const InputDecoration(
                labelText: 'Addon Type *',
                prefixIcon: Icon(Icons.extension),
              ),
              items: service.addonTypes.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Row(
                    children: [
                      Text(entry.value.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(entry.value.name)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedAddonType = value);
              },
              validator: (value) {
                if (value == null) return 'Please select an addon type';
                return null;
              },
            ),
            if (_selectedAddonType != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.addonTypes[_selectedAddonType]!.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.addonTypes[_selectedAddonType]!.description,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _buildAddon,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Build'),
        ),
      ],
    );
  }
}
