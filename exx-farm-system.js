#!/usr/bin/env node

/**
 * EXX Farm System - Stardew Valley-like farm and house management
 * 
 * Core Concept:
 * - Your EV CLI/messaging app IS your house - it stores all your data, logs, and runs
 * - The house can expand with addons (like farm buildings: barn, coop, greenhouse, etc.)
 * - Each addon provides additional functionality and storage
 * - Different houses exist adjacent to each other in the same scope, like Pokemon villages
 */

const fs = require('fs');
const path = require('path');

class ExxFarmSystem {
  constructor() {
    this.dataDir = path.join(process.env.HOME || process.env.USERPROFILE, '.ev');
    this.housesFile = path.join(this.dataDir, 'exx-houses.json'); // EV CLI is a house
    this.addonsFile = path.join(this.dataDir, 'exx-addons.json');
    this.neighborhoodFile = path.join(this.dataDir, 'exx-neighborhood.json');
    this.initializeStorage();
  }

  initializeStorage() {
    if (!fs.existsSync(this.dataDir)) {
      fs.mkdirSync(this.dataDir, { recursive: true });
    }
    
    if (!fs.existsSync(this.housesFile)) {
      fs.writeFileSync(this.housesFile, JSON.stringify([], null, 2));
    }
    
    if (!fs.existsSync(this.addonsFile)) {
      fs.writeFileSync(this.addonsFile, JSON.stringify([], null, 2));
    }
    
    if (!fs.existsSync(this.neighborhoodFile)) {
      fs.writeFileSync(this.neighborhoodFile, JSON.stringify({
        name: 'Valley Town',
        houses: [],
        adjacency: {}
      }, null, 2));
    }
  }

  readData(file) {
    try {
      return JSON.parse(fs.readFileSync(file, 'utf8'));
    } catch (e) {
      return file.includes('neighborhood') ? { name: 'Valley Town', houses: [], adjacency: {} } : [];
    }
  }

  writeData(file, data) {
    fs.writeFileSync(file, JSON.stringify(data, null, 2));
  }

  // Addon types available (expansions for your house/CLI)
  getAddonTypes() {
    return {
      storage: {
        name: 'Storage Shed',
        description: 'Additional storage for logs, data, and archived conversations',
        provides: ['Extended log retention', 'Archive management', 'Data backup'],
        category: 'utility'
      },
      workshop: {
        name: 'Workshop',
        description: 'Development and build environment for custom scripts',
        provides: ['Script editor', 'Build tools', 'Testing environment'],
        category: 'development'
      },
      greenhouse: {
        name: 'Greenhouse',
        description: 'Always-on task runner and automation hub',
        provides: ['Scheduled tasks', 'Cron jobs', 'Background processes'],
        category: 'automation'
      },
      barn: {
        name: 'Server Barn',
        description: 'Host multiple services and applications',
        provides: ['Service hosting', 'Container management', 'Load balancing'],
        category: 'infrastructure'
      },
      coop: {
        name: 'Bot Coop',
        description: 'Manage and run multiple bots and agents',
        provides: ['Bot management', 'Agent orchestration', 'AI assistants'],
        category: 'automation'
      },
      marketplace: {
        name: 'Marketplace',
        description: 'Share and discover addons from other houses',
        provides: ['Addon marketplace', 'Community plugins', 'Shared scripts'],
        category: 'community'
      },
      observatory: {
        name: 'Observatory',
        description: 'Monitor and visualize your data and metrics',
        provides: ['Dashboard', 'Metrics visualization', 'Alert system'],
        category: 'monitoring'
      },
      library: {
        name: 'Library',
        description: 'Documentation and knowledge base storage',
        provides: ['Documentation', 'Knowledge base', 'Search system'],
        category: 'utility'
      }
    };
  }

  // Create a house (EV CLI instance) for an owner
  createHouse(ownerName, houseName = null) {
    const houses = this.readData(this.housesFile);
    
    const house = {
      id: `house-${Date.now().toString(36)}`,
      owner: ownerName,
      name: houseName || `${ownerName}'s House`,
      createdAt: new Date().toISOString(),
      // Core house functionality (EV CLI storage)
      storage: {
        conversations: [],
        events: [],
        nodes: [],
        logs: []
      },
      // Addons expand functionality
      addons: [],
      // Stats
      stats: {
        totalRuns: 0,
        totalMessages: 0,
        lastActive: new Date().toISOString()
      },
      // Visitors who have connected
      visitors: []
    };

    houses.push(house);
    this.writeData(this.housesFile, houses);
    
    // Add to neighborhood
    this.addToNeighborhood(house.id);
    
    console.log(`\n🏠 Created ${house.name}!`);
    console.log(`   Owner: ${ownerName}`);
    console.log(`   House ID: ${house.id}`);
    console.log(`   This house will store all your EV CLI data, logs, and runs`);
    console.log(`   You can expand it with addons for extra functionality!`);
    
    return house;
  }

  // Build/add an addon to expand house functionality
  buildAddon(houseId, addonType) {
    const houses = this.readData(this.housesFile);
    const addons = this.readData(this.addonsFile);
    const addonTypes = this.getAddonTypes();
    
    const house = houses.find(h => h.id === houseId);
    if (!house) {
      console.error(`✗ House not found: ${houseId}`);
      return null;
    }

    if (!addonTypes[addonType]) {
      console.error(`✗ Invalid addon type: ${addonType}`);
      console.log('Available types:', Object.keys(addonTypes).join(', '));
      return null;
    }

    const typeInfo = addonTypes[addonType];
    
    const addon = {
      id: `addon-${Date.now().toString(36)}`,
      houseId: houseId,
      type: addonType,
      name: typeInfo.name,
      description: typeInfo.description,
      category: typeInfo.category,
      provides: typeInfo.provides,
      data: {}, // Addon-specific data storage
      config: {},
      builtAt: new Date().toISOString(),
      active: true
    };

    addons.push(addon);
    this.writeData(this.addonsFile, addons);

    // Link addon to house
    house.addons.push(addon.id);
    this.writeData(this.housesFile, houses);

    console.log(`\n🔨 Built ${addon.name} for ${house.name}!`);
    console.log(`   Addon ID: ${addon.id}`);
    console.log(`   Category: ${addon.category}`);
    console.log(`   Provides: ${addon.provides.join(', ')}`);
    console.log(`\n   Your house is now expanded with ${addon.name}!`);

    return addon;
  }

  // Add house to neighborhood (adjacency system)
  addToNeighborhood(houseId) {
    const neighborhood = this.readData(this.neighborhoodFile);
    
    if (!neighborhood.houses.includes(houseId)) {
      neighborhood.houses.push(houseId);
      
      // Create adjacency with existing houses
      const existingHouses = neighborhood.houses.slice(0, -1);
      neighborhood.adjacency[houseId] = [];
      
      // Make new house adjacent to recent houses (like houses in a village)
      if (existingHouses.length > 0) {
        // Adjacent to the last 2 houses (neighbors)
        const adjacentCount = Math.min(2, existingHouses.length);
        for (let i = 0; i < adjacentCount; i++) {
          const adjacentHouse = existingHouses[existingHouses.length - 1 - i];
          neighborhood.adjacency[houseId].push(adjacentHouse);
          
          // Bidirectional adjacency
          if (!neighborhood.adjacency[adjacentHouse]) {
            neighborhood.adjacency[adjacentHouse] = [];
          }
          if (!neighborhood.adjacency[adjacentHouse].includes(houseId)) {
            neighborhood.adjacency[adjacentHouse].push(houseId);
          }
        }
      }
      
      this.writeData(this.neighborhoodFile, neighborhood);
    }
  }

  // Visit another house
  visitHouse(visitorName, houseId) {
    const houses = this.readData(this.housesFile);
    const house = houses.find(h => h.id === houseId);
    
    if (!house) {
      console.error(`✗ House not found: ${houseId}`);
      return;
    }

    // Record visit
    if (!house.visitors) {
      house.visitors = [];
    }
    
    house.visitors.push({
      visitor: visitorName,
      visitedAt: new Date().toISOString()
    });
    
    this.writeData(this.housesFile, houses);

    console.log(`\n🚶 ${visitorName} visiting ${house.name}!`);
    console.log(`   Owner: ${house.owner}`);
    console.log(`   Location: ${house.id}`);
    
    // Show house stats
    console.log(`\n   📊 House Stats:`);
    console.log(`      Total Runs: ${house.stats.totalRuns}`);
    console.log(`      Total Messages: ${house.stats.totalMessages}`);
    console.log(`      Last Active: ${new Date(house.stats.lastActive).toLocaleString()}`);
    
    // Show addons
    if (house.addons && house.addons.length > 0) {
      const addons = this.readData(this.addonsFile);
      console.log(`\n   🔨 Addons (${house.addons.length}):`);
      house.addons.forEach(addonId => {
        const addon = addons.find(a => a.id === addonId);
        if (addon) {
          console.log(`      - ${addon.name} (${addon.category})`);
        }
      });
    } else {
      console.log(`\n   No addons built yet. House has basic EV CLI functionality.`);
    }

    // Show adjacent houses
    const neighborhood = this.readData(this.neighborhoodFile);
    const adjacent = neighborhood.adjacency[houseId] || [];
    if (adjacent.length > 0) {
      console.log(`\n   🏘️  Neighbors: ${adjacent.length}`);
      adjacent.forEach(adjId => {
        const adjHouse = houses.find(h => h.id === adjId);
        if (adjHouse) {
          console.log(`      - ${adjHouse.name} (${adjHouse.owner})`);
        }
      });
    }
  }

  // List all houses in the neighborhood
  listNeighborhood() {
    const neighborhood = this.readData(this.neighborhoodFile);
    const houses = this.readData(this.housesFile);
    const addons = this.readData(this.addonsFile);

    console.log(`\n🏘️  ${neighborhood.name}`);
    console.log('═'.repeat(60));

    if (houses.length === 0) {
      console.log('No houses in the neighborhood yet.');
      console.log('\nCreate your first house with: exx create <owner> [name]');
      return;
    }

    houses.forEach(house => {
      console.log(`\n🏠 ${house.name}`);
      console.log(`   Owner: ${house.owner}`);
      console.log(`   ID: ${house.id}`);
      console.log(`   Created: ${new Date(house.createdAt).toLocaleDateString()}`);
      
      // Show addons
      const houseAddons = addons.filter(a => a.houseId === house.id);
      if (houseAddons.length > 0) {
        console.log(`   🔨 Addons: ${houseAddons.map(a => a.name).join(', ')}`);
      } else {
        console.log(`   📦 Basic house (no addons yet)`);
      }
      
      // Show neighbors
      const adjacent = neighborhood.adjacency[house.id] || [];
      if (adjacent.length > 0) {
        const adjNames = adjacent.map(adjId => {
          const adjHouse = houses.find(h => h.id === adjId);
          return adjHouse ? adjHouse.owner : 'Unknown';
        });
        console.log(`   👥 Neighbors: ${adjNames.join(', ')}`);
      }
    });

    console.log('\n' + '═'.repeat(60));
    console.log(`Total houses: ${houses.length}`);
    console.log(`Total addons: ${addons.length}`);
  }

  // List available addon types
  listAddonTypes() {
    const addonTypes = this.getAddonTypes();
    
    console.log('\n🔨 Available Addon Types:\n');
    console.log('═'.repeat(70));
    
    // Group by category
    const categories = {};
    Object.entries(addonTypes).forEach(([key, type]) => {
      if (!categories[type.category]) {
        categories[type.category] = [];
      }
      categories[type.category].push({ key, ...type });
    });

    Object.entries(categories).forEach(([category, addons]) => {
      console.log(`\n📁 ${category.toUpperCase()}`);
      addons.forEach(addon => {
        console.log(`\n   ${addon.name} (${addon.key})`);
        console.log(`   ${addon.description}`);
        console.log(`   Provides: ${addon.provides.join(', ')}`);
      });
    });
    
    console.log('\n' + '═'.repeat(70));
    console.log('\nUse: exx build <houseId> <addonType>');
  }

  // Show house details
  showHouse(houseId) {
    const houses = this.readData(this.housesFile);
    const house = houses.find(h => h.id === houseId);
    
    if (!house) {
      console.error(`✗ House not found: ${houseId}`);
      return;
    }

    const addons = this.readData(this.addonsFile);
    const houseAddons = addons.filter(a => a.houseId === houseId);

    console.log(`\n🏠 ${house.name}`);
    console.log('═'.repeat(60));
    console.log(`Owner: ${house.owner}`);
    console.log(`ID: ${house.id}`);
    console.log(`Created: ${new Date(house.createdAt).toLocaleString()}`);
    
    console.log(`\n📊 Stats:`);
    console.log(`   Total Runs: ${house.stats.totalRuns}`);
    console.log(`   Total Messages: ${house.stats.totalMessages}`);
    console.log(`   Last Active: ${new Date(house.stats.lastActive).toLocaleString()}`);
    
    console.log(`\n💾 Storage:`);
    console.log(`   Conversations: ${house.storage.conversations.length}`);
    console.log(`   Events: ${house.storage.events.length}`);
    console.log(`   Nodes: ${house.storage.nodes.length}`);
    console.log(`   Logs: ${house.storage.logs.length}`);
    
    if (houseAddons.length > 0) {
      console.log(`\n🔨 Addons (${houseAddons.length}):`);
      houseAddons.forEach(addon => {
        console.log(`\n   ${addon.name}`);
        console.log(`   └─ ID: ${addon.id}`);
        console.log(`   └─ Category: ${addon.category}`);
        console.log(`   └─ Provides: ${addon.provides.join(', ')}`);
        console.log(`   └─ Status: ${addon.active ? '✓ Active' : '✗ Inactive'}`);
      });
    } else {
      console.log(`\n🔨 No addons yet`);
      console.log(`   Add addons to expand functionality!`);
      console.log(`   Use: exx build ${houseId} <addonType>`);
    }
    
    if (house.visitors && house.visitors.length > 0) {
      console.log(`\n👥 Recent Visitors:`);
      house.visitors.slice(-5).forEach(v => {
        console.log(`   - ${v.visitor} (${new Date(v.visitedAt).toLocaleString()})`);
      });
    }
  }

  // Show help
  showHelp() {
    console.log(`
EXX System - House & Addon Management (Stardew Valley-inspired)

CONCEPT:
  Your EV CLI IS your house - it stores all your data, logs, and runs.
  Expand your house with addons to add functionality (like farm buildings).
  Different houses exist in the same neighborhood (like Pokemon villages).

COMMANDS:
  exx create <owner> [name]        Create a new house (EV CLI instance)
  exx build <houseId> <addonType>  Build an addon to expand functionality
  exx addons                       List available addon types
  exx show <houseId>               Show detailed house information
  exx visit <visitor> <houseId>    Visit another house
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
  exx build house-xyz greenhouse          Add automation addon
  exx addons                              See all available addons
  exx show house-xyz                      View house details
  exx visit Bob house-xyz                 Bob visits house-xyz
  exx neighborhood                        View all houses

PHILOSOPHY:
  🏠 Your house = Your EV CLI with all your data
  🔨 Addons = Expansions that add features
  🏘️  Neighborhood = Connected houses that can visit each other
`);
  }
}

// Main execution
const args = process.argv.slice(2);

if (args.length === 0) {
  const system = new ExxFarmSystem();
  system.showHelp();
  process.exit(0);
}

const system = new ExxFarmSystem();
const command = args[0];

switch (command) {
  case 'create':
    const owner = args[1];
    const houseName = args.slice(2).join(' ') || null;
    if (!owner) {
      console.error('✗ Owner name is required');
      system.showHelp();
    } else {
      system.createHouse(owner, houseName);
    }
    break;

  case 'build':
    const houseId = args[1];
    const addonType = args[2];
    if (!houseId || !addonType) {
      console.error('✗ House ID and addon type are required');
      console.log('\nUsage: exx build <houseId> <addonType>');
      console.log('Run "exx addons" to see available types');
    } else {
      system.buildAddon(houseId, addonType);
    }
    break;

  case 'addons':
    system.listAddonTypes();
    break;

  case 'show':
    const showHouseId = args[1];
    if (!showHouseId) {
      console.error('✗ House ID is required');
    } else {
      system.showHouse(showHouseId);
    }
    break;

  case 'visit':
    const visitor = args[1];
    const targetHouseId = args[2];
    if (!visitor || !targetHouseId) {
      console.error('✗ Visitor name and house ID are required');
    } else {
      system.visitHouse(visitor, targetHouseId);
    }
    break;

  case 'neighborhood':
    system.listNeighborhood();
    break;

  case 'help':
  case '--help':
  case '-h':
    system.showHelp();
    break;

  default:
    console.error(`✗ Unknown command: ${command}`);
    system.showHelp();
}
