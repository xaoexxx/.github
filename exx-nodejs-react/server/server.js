import express from 'express';
import cors from 'cors';
import { WebSocketServer } from 'ws';
import { promises as fs } from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import os from 'os';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Data directory
const dataDir = path.join(os.homedir(), '.ev');
const housesFile = path.join(dataDir, 'exx-houses.json');
const addonsFile = path.join(dataDir, 'exx-addons.json');
const neighborhoodFile = path.join(dataDir, 'exx-neighborhood.json');

// Initialize storage
async function initializeStorage() {
  try {
    await fs.mkdir(dataDir, { recursive: true });
    
    try {
      await fs.access(housesFile);
    } catch {
      await fs.writeFile(housesFile, JSON.stringify([], null, 2));
    }
    
    try {
      await fs.access(addonsFile);
    } catch {
      await fs.writeFile(addonsFile, JSON.stringify([], null, 2));
    }
    
    try {
      await fs.access(neighborhoodFile);
    } catch {
      await fs.writeFile(neighborhoodFile, JSON.stringify({
        name: 'Valley Town',
        houses: [],
        adjacency: {}
      }, null, 2));
    }
  } catch (error) {
    console.error('Failed to initialize storage:', error);
  }
}

// Read data helper
async function readData(file) {
  try {
    const data = await fs.readFile(file, 'utf8');
    return JSON.parse(data);
  } catch (e) {
    return file.includes('neighborhood') ? 
      { name: 'Valley Town', houses: [], adjacency: {} } : [];
  }
}

// Write data helper
async function writeData(file, data) {
  await fs.writeFile(file, JSON.stringify(data, null, 2));
}

// Addon types definition
const addonTypes = {
  storage: {
    name: 'Storage Shed',
    description: 'Additional storage for logs, data, and archived conversations',
    provides: ['Extended log retention', 'Archive management', 'Data backup'],
    category: 'utility',
    icon: '📦'
  },
  workshop: {
    name: 'Workshop',
    description: 'Development and build environment for custom scripts',
    provides: ['Script editor', 'Build tools', 'Testing environment'],
    category: 'development',
    icon: '🔧'
  },
  greenhouse: {
    name: 'Greenhouse',
    description: 'Always-on task runner and automation hub',
    provides: ['Scheduled tasks', 'Cron jobs', 'Background processes'],
    category: 'automation',
    icon: '🌱'
  },
  barn: {
    name: 'Server Barn',
    description: 'Host multiple services and applications',
    provides: ['Service hosting', 'Container management', 'Load balancing'],
    category: 'infrastructure',
    icon: '🏛️'
  },
  coop: {
    name: 'Bot Coop',
    description: 'Manage and run multiple bots and agents',
    provides: ['Bot management', 'Agent orchestration', 'AI assistants'],
    category: 'automation',
    icon: '🐔'
  },
  marketplace: {
    name: 'Marketplace',
    description: 'Share and discover addons from other houses',
    provides: ['Addon marketplace', 'Community plugins', 'Shared scripts'],
    category: 'community',
    icon: '🏪'
  },
  observatory: {
    name: 'Observatory',
    description: 'Monitor and visualize your data and metrics',
    provides: ['Dashboard', 'Metrics visualization', 'Alert system'],
    category: 'monitoring',
    icon: '🔭'
  },
  library: {
    name: 'Library',
    description: 'Documentation and knowledge base storage',
    provides: ['Documentation', 'Knowledge base', 'Search system'],
    category: 'utility',
    icon: '📚'
  }
};

// API Routes

// Get all houses
app.get('/api/houses', async (req, res) => {
  try {
    const houses = await readData(housesFile);
    res.json(houses);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get specific house
app.get('/api/houses/:id', async (req, res) => {
  try {
    const houses = await readData(housesFile);
    const house = houses.find(h => h.id === req.params.id);
    
    if (!house) {
      return res.status(404).json({ error: 'House not found' });
    }
    
    res.json(house);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create house
app.post('/api/houses', async (req, res) => {
  try {
    const { owner, name } = req.body;
    
    if (!owner) {
      return res.status(400).json({ error: 'Owner is required' });
    }
    
    const houses = await readData(housesFile);
    const neighborhood = await readData(neighborhoodFile);
    
    const house = {
      id: `house-${Date.now().toString(36)}`,
      owner,
      name: name || `${owner}'s House`,
      createdAt: new Date().toISOString(),
      storage: {
        conversations: [],
        events: [],
        nodes: [],
        logs: []
      },
      addons: [],
      stats: {
        totalRuns: 0,
        totalMessages: 0,
        lastActive: new Date().toISOString()
      },
      visitors: []
    };
    
    houses.push(house);
    await writeData(housesFile, houses);
    
    // Add to neighborhood
    neighborhood.houses.push(house.id);
    neighborhood.adjacency[house.id] = [];
    
    // Create adjacency
    const existingHouses = neighborhood.houses.slice(0, -1);
    if (existingHouses.length > 0) {
      const adjacentCount = Math.min(2, existingHouses.length);
      for (let i = 0; i < adjacentCount; i++) {
        const adjacentHouse = existingHouses[existingHouses.length - 1 - i];
        neighborhood.adjacency[house.id].push(adjacentHouse);
        
        if (!neighborhood.adjacency[adjacentHouse]) {
          neighborhood.adjacency[adjacentHouse] = [];
        }
        if (!neighborhood.adjacency[adjacentHouse].includes(house.id)) {
          neighborhood.adjacency[adjacentHouse].push(house.id);
        }
      }
    }
    
    await writeData(neighborhoodFile, neighborhood);
    
    res.status(201).json(house);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get addons for a house
app.get('/api/houses/:id/addons', async (req, res) => {
  try {
    const addons = await readData(addonsFile);
    const houseAddons = addons.filter(a => a.houseId === req.params.id);
    res.json(houseAddons);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Build addon
app.post('/api/houses/:id/addons', async (req, res) => {
  try {
    const { type } = req.body;
    const houseId = req.params.id;
    
    if (!type || !addonTypes[type]) {
      return res.status(400).json({ error: 'Invalid addon type' });
    }
    
    const houses = await readData(housesFile);
    const house = houses.find(h => h.id === houseId);
    
    if (!house) {
      return res.status(404).json({ error: 'House not found' });
    }
    
    const addons = await readData(addonsFile);
    const typeInfo = addonTypes[type];
    
    const addon = {
      id: `addon-${Date.now().toString(36)}`,
      houseId,
      type,
      name: typeInfo.name,
      description: typeInfo.description,
      category: typeInfo.category,
      provides: typeInfo.provides,
      icon: typeInfo.icon,
      data: {},
      config: {},
      builtAt: new Date().toISOString(),
      active: true
    };
    
    addons.push(addon);
    await writeData(addonsFile, addons);
    
    house.addons.push(addon.id);
    await writeData(housesFile, houses);
    
    res.status(201).json(addon);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get addon types
app.get('/api/addon-types', (req, res) => {
  res.json(addonTypes);
});

// Get neighborhood
app.get('/api/neighborhood', async (req, res) => {
  try {
    const neighborhood = await readData(neighborhoodFile);
    const houses = await readData(housesFile);
    const addons = await readData(addonsFile);
    
    const enrichedNeighborhood = {
      ...neighborhood,
      housesData: neighborhood.houses.map(houseId => {
        const house = houses.find(h => h.id === houseId);
        if (!house) return null;
        
        const houseAddons = addons.filter(a => a.houseId === houseId);
        const neighbors = (neighborhood.adjacency[houseId] || []).map(nId => {
          const neighbor = houses.find(h => h.id === nId);
          return neighbor ? { id: neighbor.id, owner: neighbor.owner, name: neighbor.name } : null;
        }).filter(Boolean);
        
        return {
          ...house,
          addonsData: houseAddons,
          neighbors
        };
      }).filter(Boolean)
    };
    
    res.json(enrichedNeighborhood);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Visit house
app.post('/api/houses/:id/visit', async (req, res) => {
  try {
    const { visitor } = req.body;
    const houseId = req.params.id;
    
    if (!visitor) {
      return res.status(400).json({ error: 'Visitor name is required' });
    }
    
    const houses = await readData(housesFile);
    const house = houses.find(h => h.id === houseId);
    
    if (!house) {
      return res.status(404).json({ error: 'House not found' });
    }
    
    if (!house.visitors) {
      house.visitors = [];
    }
    
    house.visitors.push({
      visitor,
      visitedAt: new Date().toISOString()
    });
    
    await writeData(housesFile, houses);
    
    res.json({ success: true, house });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Initialize and start server
initializeStorage().then(() => {
  const server = app.listen(PORT, () => {
    console.log(`🏠 EXX Server running on http://localhost:${PORT}`);
    console.log(`📊 Data directory: ${dataDir}`);
  });
  
  // WebSocket server for real-time updates
  const wss = new WebSocketServer({ server });
  
  wss.on('connection', (ws) => {
    console.log('Client connected');
    
    ws.on('message', (message) => {
      console.log('Received:', message.toString());
    });
    
    ws.on('close', () => {
      console.log('Client disconnected');
    });
  });
}).catch(error => {
  console.error('Failed to start server:', error);
  process.exit(1);
});

export default app;
