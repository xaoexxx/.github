# distutils: language=c++
# cython: language_level=3

"""
EXX System - House & Addon System (Cython Implementation)

High-performance implementation using Cython for speed-critical operations.
"""

import json
import os
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Any
import time

cdef class ExxFarmSystem:
    """
    High-performance EXX system using Cython.
    
    Attributes:
        data_dir (str): Directory for storing data
        houses_file (str): Path to houses JSON file
        addons_file (str): Path to addons JSON file
        neighborhood_file (str): Path to neighborhood JSON file
    """
    
    cdef str data_dir
    cdef str houses_file
    cdef str addons_file
    cdef str neighborhood_file
    cdef dict addon_types
    
    def __init__(self):
        """Initialize the EXX system with data paths."""
        home_dir = str(Path.home())
        self.data_dir = os.path.join(home_dir, '.ev')
        self.houses_file = os.path.join(self.data_dir, 'exx-houses.json')
        self.addons_file = os.path.join(self.data_dir, 'exx-addons.json')
        self.neighborhood_file = os.path.join(self.data_dir, 'exx-neighborhood.json')
        
        self._init_addon_types()
        self.initialize_storage()
    
    cdef void _init_addon_types(self):
        """Initialize addon type definitions."""
        self.addon_types = {
            'storage': {
                'name': 'Storage Shed',
                'description': 'Additional storage for logs, data, and archived conversations',
                'provides': ['Extended log retention', 'Archive management', 'Data backup'],
                'category': 'utility',
                'icon': '📦'
            },
            'workshop': {
                'name': 'Workshop',
                'description': 'Development and build environment for custom scripts',
                'provides': ['Script editor', 'Build tools', 'Testing environment'],
                'category': 'development',
                'icon': '🔧'
            },
            'greenhouse': {
                'name': 'Greenhouse',
                'description': 'Always-on task runner and automation hub',
                'provides': ['Scheduled tasks', 'Cron jobs', 'Background processes'],
                'category': 'automation',
                'icon': '🌱'
            },
            'barn': {
                'name': 'Server Barn',
                'description': 'Host multiple services and applications',
                'provides': ['Service hosting', 'Container management', 'Load balancing'],
                'category': 'infrastructure',
                'icon': '🏛️'
            },
            'coop': {
                'name': 'Bot Coop',
                'description': 'Manage and run multiple bots and agents',
                'provides': ['Bot management', 'Agent orchestration', 'AI assistants'],
                'category': 'automation',
                'icon': '🐔'
            },
            'marketplace': {
                'name': 'Marketplace',
                'description': 'Share and discover addons from other houses',
                'provides': ['Addon marketplace', 'Community plugins', 'Shared scripts'],
                'category': 'community',
                'icon': '🏪'
            },
            'observatory': {
                'name': 'Observatory',
                'description': 'Monitor and visualize your data and metrics',
                'provides': ['Dashboard', 'Metrics visualization', 'Alert system'],
                'category': 'monitoring',
                'icon': '🔭'
            },
            'library': {
                'name': 'Library',
                'description': 'Documentation and knowledge base storage',
                'provides': ['Documentation', 'Knowledge base', 'Search system'],
                'category': 'utility',
                'icon': '📚'
            }
        }
    
    cpdef void initialize_storage(self):
        """Initialize storage directories and files."""
        os.makedirs(self.data_dir, exist_ok=True)
        
        if not os.path.exists(self.houses_file):
            self._write_data(self.houses_file, [])
        
        if not os.path.exists(self.addons_file):
            self._write_data(self.addons_file, [])
        
        if not os.path.exists(self.neighborhood_file):
            self._write_data(self.neighborhood_file, {
                'name': 'Valley Town',
                'houses': [],
                'adjacency': {}
            })
    
    cdef object _read_data(self, str filepath):
        """Read and parse JSON data from file."""
        try:
            with open(filepath, 'r') as f:
                return json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            if 'neighborhood' in filepath:
                return {'name': 'Valley Town', 'houses': [], 'adjacency': {}}
            return []
    
    cdef void _write_data(self, str filepath, object data):
        """Write data to JSON file."""
        with open(filepath, 'w') as f:
            json.dump(data, f, indent=2)
    
    cdef str _generate_id(self, str prefix):
        """Generate unique ID with prefix."""
        timestamp = int(time.time() * 1000)
        return f"{prefix}-{timestamp:x}"
    
    cpdef dict create_house(self, str owner, str name=None):
        """
        Create a new house.
        
        Args:
            owner: Owner name
            name: Optional house name
            
        Returns:
            dict: Created house data
        """
        if not owner:
            raise ValueError("Owner name is required")
        
        houses = self._read_data(self.houses_file)
        neighborhood = self._read_data(self.neighborhood_file)
        
        house_id = self._generate_id('house')
        timestamp = datetime.now().isoformat()
        
        house = {
            'id': house_id,
            'owner': owner,
            'name': name or f"{owner}'s House",
            'createdAt': timestamp,
            'storage': {
                'conversations': [],
                'events': [],
                'nodes': [],
                'logs': []
            },
            'addons': [],
            'stats': {
                'totalRuns': 0,
                'totalMessages': 0,
                'lastActive': timestamp
            },
            'visitors': []
        }
        
        houses.append(house)
        self._write_data(self.houses_file, houses)
        
        # Add to neighborhood
        neighborhood['houses'].append(house_id)
        neighborhood['adjacency'][house_id] = []
        
        # Create adjacency with existing houses
        existing_houses = neighborhood['houses'][:-1]
        if existing_houses:
            adjacent_count = min(2, len(existing_houses))
            for i in range(adjacent_count):
                adjacent_id = existing_houses[-(1 + i)]
                neighborhood['adjacency'][house_id].append(adjacent_id)
                
                if adjacent_id not in neighborhood['adjacency']:
                    neighborhood['adjacency'][adjacent_id] = []
                if house_id not in neighborhood['adjacency'][adjacent_id]:
                    neighborhood['adjacency'][adjacent_id].append(house_id)
        
        self._write_data(self.neighborhood_file, neighborhood)
        
        print(f"\n🏠 Created {house['name']}!")
        print(f"   Owner: {owner}")
        print(f"   House ID: {house_id}")
        print("   This house will store all your EV CLI data, logs, and runs")
        print("   You can expand it with addons for extra functionality!\n")
        
        return house
    
    cpdef dict build_addon(self, str house_id, str addon_type):
        """
        Build an addon for a house.
        
        Args:
            house_id: House ID
            addon_type: Type of addon to build
            
        Returns:
            dict: Created addon data
        """
        if not house_id or not addon_type:
            raise ValueError("House ID and addon type are required")
        
        if addon_type not in self.addon_types:
            raise ValueError(f"Invalid addon type: {addon_type}")
        
        houses = self._read_data(self.houses_file)
        house = next((h for h in houses if h['id'] == house_id), None)
        
        if not house:
            raise ValueError(f"House not found: {house_id}")
        
        addons = self._read_data(self.addons_file)
        type_info = self.addon_types[addon_type]
        
        addon_id = self._generate_id('addon')
        
        addon = {
            'id': addon_id,
            'houseId': house_id,
            'type': addon_type,
            'name': type_info['name'],
            'description': type_info['description'],
            'category': type_info['category'],
            'provides': type_info['provides'],
            'icon': type_info['icon'],
            'data': {},
            'config': {},
            'builtAt': datetime.now().isoformat(),
            'active': True
        }
        
        addons.append(addon)
        self._write_data(self.addons_file, addons)
        
        house['addons'].append(addon_id)
        self._write_data(self.houses_file, houses)
        
        print(f"\n🔨 Built {addon['name']} for {house['name']}!")
        print(f"   Addon ID: {addon_id}")
        print(f"   Category: {addon['category']}")
        print(f"   Provides: {', '.join(addon['provides'])}")
        print(f"\n   Your house is now expanded with {addon['name']}!\n")
        
        return addon
    
    cpdef void list_addon_types(self):
        """List all available addon types."""
        print("\n🔨 Available Addon Types:\n")
        print("=" * 70)
        
        # Group by category
        categories = {}
        for key, type_info in self.addon_types.items():
            category = type_info['category']
            if category not in categories:
                categories[category] = []
            categories[category].append({'key': key, **type_info})
        
        for category in sorted(categories.keys()):
            print(f"\n📁 {category.upper()}")
            for addon in categories[category]:
                print(f"\n   {addon['icon']} {addon['name']} ({addon['key']})")
                print(f"   {addon['description']}")
                print(f"   Provides: {', '.join(addon['provides'])}")
        
        print("\n" + "=" * 70)
        print("\nUse: exx build <houseId> <addonType>\n")
    
    cpdef void show_house(self, str house_id):
        """Show detailed house information."""
        if not house_id:
            raise ValueError("House ID is required")
        
        houses = self._read_data(self.houses_file)
        house = next((h for h in houses if h['id'] == house_id), None)
        
        if not house:
            raise ValueError(f"House not found: {house_id}")
        
        addons = self._read_data(self.addons_file)
        house_addons = [a for a in addons if a['houseId'] == house_id]
        
        print(f"\n🏠 {house['name']}")
        print("=" * 60)
        print(f"Owner: {house['owner']}")
        print(f"ID: {house['id']}")
        print(f"Created: {house['createdAt']}")
        
        print("\n📊 Stats:")
        print(f"   Total Runs: {house['stats']['totalRuns']}")
        print(f"   Total Messages: {house['stats']['totalMessages']}")
        print(f"   Last Active: {house['stats']['lastActive']}")
        
        print("\n💾 Storage:")
        print(f"   Conversations: {len(house['storage']['conversations'])}")
        print(f"   Events: {len(house['storage']['events'])}")
        print(f"   Nodes: {len(house['storage']['nodes'])}")
        print(f"   Logs: {len(house['storage']['logs'])}")
        
        if house_addons:
            print(f"\n🔨 Addons ({len(house_addons)}):")
            for addon in house_addons:
                print(f"\n   {addon['icon']} {addon['name']}")
                print(f"   └─ ID: {addon['id']}")
                print(f"   └─ Category: {addon['category']}")
                print(f"   └─ Provides: {', '.join(addon['provides'])}")
                print(f"   └─ Status: {'✓ Active' if addon['active'] else '✗ Inactive'}")
        else:
            print("\n🔨 No addons yet")
            print("   Add addons to expand functionality!")
            print(f"   Use: exx build {house_id} <addonType>")
        
        print()
    
    cpdef void list_neighborhood(self):
        """List all houses in the neighborhood."""
        neighborhood = self._read_data(self.neighborhood_file)
        houses = self._read_data(self.houses_file)
        addons = self._read_data(self.addons_file)
        
        print(f"\n🏘️  {neighborhood['name']}")
        print("=" * 60)
        
        if not neighborhood['houses']:
            print("No houses in the neighborhood yet.")
            print("\nCreate your first house with: exx create <owner> [name]\n")
            return
        
        for house_id in neighborhood['houses']:
            house = next((h for h in houses if h['id'] == house_id), None)
            if not house:
                continue
            
            print(f"\n🏠 {house['name']}")
            print(f"   Owner: {house['owner']}")
            print(f"   ID: {house['id']}")
            print(f"   Created: {house['createdAt'].split('T')[0]}")
            
            house_addons = [a for a in addons if a['houseId'] == house_id]
            if house_addons:
                addon_names = ', '.join(a['name'] for a in house_addons)
                print(f"   🔨 Addons: {addon_names}")
            else:
                print("   📦 Basic house (no addons yet)")
            
            adjacent = neighborhood['adjacency'].get(house_id, [])
            if adjacent:
                neighbor_names = []
                for adj_id in adjacent:
                    adj_house = next((h for h in houses if h['id'] == adj_id), None)
                    if adj_house:
                        neighbor_names.append(adj_house['owner'])
                if neighbor_names:
                    print(f"   👥 Neighbors: {', '.join(neighbor_names)}")
        
        print("\n" + "=" * 60)
        print(f"Total houses: {len(neighborhood['houses'])}")
        print(f"Total addons: {len(addons)}\n")
    
    cpdef void show_help(self):
        """Show help message."""
        print("""
EXX System - House & Addon Management (Cython Implementation)

CONCEPT:
  Your EV CLI IS your house - it stores all your data, logs, and runs.
  Expand your house with addons to add functionality (like farm buildings).
  Different houses exist in the same neighborhood (like Pokemon villages).

COMMANDS:
  exx create <owner> [name]        Create a new house (EV CLI instance)
  exx build <houseId> <addonType>  Build an addon to expand functionality
  exx addons                       List available addon types
  exx show <houseId>               Show detailed house information
  exx neighborhood                 List all houses in the neighborhood
  exx help                         Show this help

ADDON TYPES:
  storage      - Extended log retention and data backup
  workshop     - Development and build environment
  greenhouse   - Always-on task runner and automation
  barn         - Host multiple services and applications
  coop         - Manage and run multiple bots and agents
  marketplace  - Share and discover addons from others
  observatory  - Monitor and visualize metrics
  library      - Documentation and knowledge base

EXAMPLES:
  exx create Alice "Alice's Dev House"    Create Alice's house
  exx build house-xyz workshop            Add workshop to house-xyz
  exx addons                              See all available addons
  exx show house-xyz                      View house details
  exx neighborhood                        View all houses

PHILOSOPHY:
  🏠 Your house = Your EV CLI with all your data
  🔨 Addons = Expansions that add features
  🏘️  Neighborhood = Connected houses that can visit each other
""")
