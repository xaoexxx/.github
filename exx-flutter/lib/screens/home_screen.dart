import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/exx_service.dart';
import '../widgets/house_card.dart';
import '../widgets/create_house_dialog.dart';
import '../widgets/build_addon_dialog.dart';
import '../widgets/addon_types_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ExxService>();
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      '🏠 EXX System',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'House & Addon Management',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Stats Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          icon: Icons.home,
                          label: 'Houses',
                          value: service.houses.length.toString(),
                        ),
                        _StatItem(
                          icon: Icons.extension,
                          label: 'Addons',
                          value: service.addons.length.toString(),
                        ),
                        _StatItem(
                          icon: Icons.location_city,
                          label: 'Neighborhood',
                          value: service.neighborhood?.name ?? 'Valley Town',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tabs: const [
                    Tab(icon: Icon(Icons.home), text: 'Houses'),
                    Tab(icon: Icon(Icons.extension), text: 'Addons'),
                    Tab(icon: Icon(Icons.info), text: 'About'),
                  ],
                ),
              ),
              
              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHousesTab(service),
                    _buildAddonsTab(service),
                    _buildAboutTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(context, service),
    );
  }
  
  Widget _buildHousesTab(ExxService service) {
    if (service.houses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined, size: 80, color: Colors.white.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No houses yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to create your first house',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: service.houses.length,
      itemBuilder: (context, index) {
        final house = service.houses[index];
        final houseAddons = service.getHouseAddons(house.id);
        final neighbors = service.getNeighbors(house.id);
        
        return HouseCard(
          house: house,
          addons: houseAddons,
          neighborIds: neighbors,
          allHouses: service.houses,
        );
      },
    );
  }
  
  Widget _buildAddonsTab(ExxService service) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...service.addonTypes.entries.map((entry) {
          final type = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Text(type.icon, style: const TextStyle(fontSize: 32)),
              title: Text(type.name),
              subtitle: Text(type.description),
              trailing: Chip(
                label: Text(type.category),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => AddonTypesSheet(addonType: type),
                );
              },
            ),
          );
        }).toList(),
      ],
    );
  }
  
  Widget _buildAboutTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              '🏠 EXX System',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Stardew Valley-inspired House & Addon Management',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _aboutSection('Concept', 
              'Your EV CLI IS your house - it stores all your data, logs, and runs. '
              'Expand your house with addons to add functionality (like farm buildings). '
              'Different houses exist in the same neighborhood (like Pokemon villages).'
            ),
            _aboutSection('Philosophy',
              '🏠 Your house = Your EV CLI with all your data\n'
              '🔨 Addons = Expansions that add features\n'
              '🏘️ Neighborhood = Connected houses that can visit each other'
            ),
            _aboutSection('Features',
              '• Create houses for different owners\n'
              '• Build addons to expand functionality\n'
              '• View neighborhood with adjacent houses\n'
              '• Cross-platform: iOS, Android, Web, Desktop'
            ),
            _aboutSection('License', 'MIT License - Free and Open Source'),
            _aboutSection('Author', 'xaoexxx'),
            const SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _aboutSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFAB(BuildContext context, ExxService service) {
    return FloatingActionButton.extended(
      onPressed: () {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height - 200,
            0,
            0,
          ),
          items: [
            PopupMenuItem(
              child: const ListTile(
                leading: Icon(Icons.add_home),
                title: Text('Create House'),
              ),
              onTap: () {
                Future.delayed(Duration.zero, () {
                  showDialog(
                    context: context,
                    builder: (_) => const CreateHouseDialog(),
                  );
                });
              },
            ),
            PopupMenuItem(
              child: const ListTile(
                leading: Icon(Icons.build),
                title: Text('Build Addon'),
              ),
              onTap: () {
                Future.delayed(Duration.zero, () {
                  showDialog(
                    context: context,
                    builder: (_) => const BuildAddonDialog(),
                  );
                });
              },
            ),
          ],
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Create'),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
