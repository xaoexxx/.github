import 'package:flutter/material.dart';
import '../models/models.dart';

class HouseCard extends StatelessWidget {
  final House house;
  final List<Addon> addons;
  final List<String> neighborIds;
  final List<House> allHouses;
  
  const HouseCard({
    super.key,
    required this.house,
    required this.addons,
    required this.neighborIds,
    required this.allHouses,
  });

  @override
  Widget build(BuildContext context) {
    final neighbors = neighborIds
        .map((id) => allHouses.firstWhere((h) => h.id == id, orElse: () => house))
        .where((h) => h.id != house.id)
        .toList();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: const Icon(Icons.home, size: 40),
        title: Text(
          house.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text('Owner: ${house.owner}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('ID', house.id),
                _buildInfoRow('Created', house.createdAt.split('T')[0]),
                const Divider(height: 24),
                
                // Stats
                const Text(
                  '📊 Stats',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatChip('Runs', house.stats.totalRuns.toString()),
                    _buildStatChip('Messages', house.stats.totalMessages.toString()),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Addons
                const Text(
                  '🔨 Addons',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (addons.isEmpty)
                  const Text('No addons yet', style: TextStyle(color: Colors.grey))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: addons.map((addon) => Chip(
                      avatar: Text(addon.icon),
                      label: Text(addon.name),
                    )).toList(),
                  ),
                const SizedBox(height: 16),
                
                // Neighbors
                if (neighbors.isNotEmpty) ...[
                  const Text(
                    '👥 Neighbors',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: neighbors.map((neighbor) => Chip(
                      avatar: const Icon(Icons.person, size: 16),
                      label: Text(neighbor.owner),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatChip(String label, String value) {
    return Chip(
      label: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
