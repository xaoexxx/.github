import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class ExxService extends ChangeNotifier {
  late String _dataDir;
  late String _housesFile;
  late String _addonsFile;
  late String _neighborhoodFile;
  
  List<House> _houses = [];
  List<Addon> _addons = [];
  Neighborhood? _neighborhood;
  
  Map<String, AddonType> addonTypes = {};
  
  List<House> get houses => _houses;
  List<Addon> get addons => _addons;
  Neighborhood? get neighborhood => _neighborhood;
  
  ExxService() {
    _initAddonTypes();
    _initStorage();
  }
  
  void _initAddonTypes() {
    addonTypes = {
      'storage': AddonType(
        name: 'Storage Shed',
        description: 'Additional storage for logs, data, and archived conversations',
        provides: ['Extended log retention', 'Archive management', 'Data backup'],
        category: 'utility',
        icon: '📦',
      ),
      'workshop': AddonType(
        name: 'Workshop',
        description: 'Development and build environment for custom scripts',
        provides: ['Script editor', 'Build tools', 'Testing environment'],
        category: 'development',
        icon: '🔧',
      ),
      'greenhouse': AddonType(
        name: 'Greenhouse',
        description: 'Always-on task runner and automation hub',
        provides: ['Scheduled tasks', 'Cron jobs', 'Background processes'],
        category: 'automation',
        icon: '🌱',
      ),
      'barn': AddonType(
        name: 'Server Barn',
        description: 'Host multiple services and applications',
        provides: ['Service hosting', 'Container management', 'Load balancing'],
        category: 'infrastructure',
        icon: '🏛️',
      ),
      'coop': AddonType(
        name: 'Bot Coop',
        description: 'Manage and run multiple bots and agents',
        provides: ['Bot management', 'Agent orchestration', 'AI assistants'],
        category: 'automation',
        icon: '🐔',
      ),
      'marketplace': AddonType(
        name: 'Marketplace',
        description: 'Share and discover addons from other houses',
        provides: ['Addon marketplace', 'Community plugins', 'Shared scripts'],
        category: 'community',
        icon: '🏪',
      ),
      'observatory': AddonType(
        name: 'Observatory',
        description: 'Monitor and visualize your data and metrics',
        provides: ['Dashboard', 'Metrics visualization', 'Alert system'],
        category: 'monitoring',
        icon: '🔭',
      ),
      'library': AddonType(
        name: 'Library',
        description: 'Documentation and knowledge base storage',
        provides: ['Documentation', 'Knowledge base', 'Search system'],
        category: 'utility',
        icon: '📚',
      ),
    };
  }
  
  Future<void> _initStorage() async {
    if (kIsWeb) {
      // For web, use a different approach
      _dataDir = 'web_storage';
      _housesFile = 'houses.json';
      _addonsFile = 'addons.json';
      _neighborhoodFile = 'neighborhood.json';
    } else {
      final directory = await getApplicationDocumentsDirectory();
      _dataDir = '${directory.path}/.ev';
      _housesFile = '$_dataDir/exx-houses.json';
      _addonsFile = '$_dataDir/exx-addons.json';
      _neighborhoodFile = '$_dataDir/exx-neighborhood.json';
      
      // Create directory if it doesn't exist
      await Directory(_dataDir).create(recursive: true);
    }
    
    await loadData();
  }
  
  Future<void> loadData() async {
    try {
      _houses = await _readHouses();
      _addons = await _readAddons();
      _neighborhood = await _readNeighborhood();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }
  
  Future<List<House>> _readHouses() async {
    try {
      if (kIsWeb) {
        // Use localStorage or similar for web
        return [];
      }
      
      final file = File(_housesFile);
      if (!await file.exists()) {
        await file.writeAsString(jsonEncode([]));
        return [];
      }
      
      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((json) => House.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error reading houses: $e');
      return [];
    }
  }
  
  Future<List<Addon>> _readAddons() async {
    try {
      if (kIsWeb) {
        return [];
      }
      
      final file = File(_addonsFile);
      if (!await file.exists()) {
        await file.writeAsString(jsonEncode([]));
        return [];
      }
      
      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((json) => Addon.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error reading addons: $e');
      return [];
    }
  }
  
  Future<Neighborhood> _readNeighborhood() async {
    try {
      if (kIsWeb) {
        return Neighborhood(name: 'Valley Town', houses: [], adjacency: {});
      }
      
      final file = File(_neighborhoodFile);
      if (!await file.exists()) {
        final defaultNeighborhood = Neighborhood(
          name: 'Valley Town',
          houses: [],
          adjacency: {},
        );
        await file.writeAsString(jsonEncode(defaultNeighborhood.toJson()));
        return defaultNeighborhood;
      }
      
      final content = await file.readAsString();
      return Neighborhood.fromJson(jsonDecode(content));
    } catch (e) {
      debugPrint('Error reading neighborhood: $e');
      return Neighborhood(name: 'Valley Town', houses: [], adjacency: {});
    }
  }
  
  Future<void> _writeHouses() async {
    if (kIsWeb) return;
    
    final file = File(_housesFile);
    final jsonList = _houses.map((h) => h.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }
  
  Future<void> _writeAddons() async {
    if (kIsWeb) return;
    
    final file = File(_addonsFile);
    final jsonList = _addons.map((a) => a.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }
  
  Future<void> _writeNeighborhood() async {
    if (kIsWeb || _neighborhood == null) return;
    
    final file = File(_neighborhoodFile);
    await file.writeAsString(jsonEncode(_neighborhood!.toJson()));
  }
  
  String _generateId(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$prefix-${timestamp.toRadixString(36)}';
  }
  
  Future<House> createHouse(String owner, {String? name}) async {
    if (owner.isEmpty) {
      throw Exception('Owner name is required');
    }
    
    final houseId = _generateId('house');
    final timestamp = DateTime.now().toIso8601String();
    
    final house = House(
      id: houseId,
      owner: owner,
      name: name ?? "$owner's House",
      createdAt: timestamp,
      storage: HouseStorage(),
      addons: [],
      stats: HouseStats(
        totalRuns: 0,
        totalMessages: 0,
        lastActive: timestamp,
      ),
      visitors: [],
    );
    
    _houses.add(house);
    await _writeHouses();
    
    // Add to neighborhood
    _neighborhood!.houses.add(houseId);
    _neighborhood!.adjacency[houseId] = [];
    
    // Create adjacency
    final existingHouses = List<String>.from(_neighborhood!.houses);
    existingHouses.removeLast();
    
    if (existingHouses.isNotEmpty) {
      final adjacentCount = existingHouses.length > 2 ? 2 : existingHouses.length;
      for (var i = 0; i < adjacentCount; i++) {
        final adjacentId = existingHouses[existingHouses.length - 1 - i];
        _neighborhood!.adjacency[houseId]!.add(adjacentId);
        
        _neighborhood!.adjacency[adjacentId] ??= [];
        if (!_neighborhood!.adjacency[adjacentId]!.contains(houseId)) {
          _neighborhood!.adjacency[adjacentId]!.add(houseId);
        }
      }
    }
    
    await _writeNeighborhood();
    notifyListeners();
    
    return house;
  }
  
  Future<Addon> buildAddon(String houseId, String addonType) async {
    if (houseId.isEmpty || addonType.isEmpty) {
      throw Exception('House ID and addon type are required');
    }
    
    if (!addonTypes.containsKey(addonType)) {
      throw Exception('Invalid addon type: $addonType');
    }
    
    final houseIndex = _houses.indexWhere((h) => h.id == houseId);
    if (houseIndex == -1) {
      throw Exception('House not found: $houseId');
    }
    
    final typeInfo = addonTypes[addonType]!;
    final addonId = _generateId('addon');
    
    final addon = Addon(
      id: addonId,
      houseId: houseId,
      type: addonType,
      name: typeInfo.name,
      description: typeInfo.description,
      category: typeInfo.category,
      provides: typeInfo.provides,
      icon: typeInfo.icon,
      data: {},
      config: {},
      builtAt: DateTime.now().toIso8601String(),
      active: true,
    );
    
    _addons.add(addon);
    await _writeAddons();
    
    // This is a workaround since House is immutable
    final house = _houses[houseIndex];
    final updatedAddons = List<String>.from(house.addons)..add(addonId);
    _houses[houseIndex] = House(
      id: house.id,
      owner: house.owner,
      name: house.name,
      createdAt: house.createdAt,
      storage: house.storage,
      addons: updatedAddons,
      stats: house.stats,
      visitors: house.visitors,
    );
    await _writeHouses();
    
    notifyListeners();
    return addon;
  }
  
  List<Addon> getHouseAddons(String houseId) {
    return _addons.where((a) => a.houseId == houseId).toList();
  }
  
  List<String> getNeighbors(String houseId) {
    return _neighborhood?.adjacency[houseId] ?? [];
  }
}
