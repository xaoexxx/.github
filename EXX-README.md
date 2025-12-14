# EXX System - House & Addon Management

A Stardew Valley-inspired system where your EV CLI instance is your house, which can be expanded with addons for additional functionality.

## Core Concept

### 🏠 Your House IS Your CLI
- **Your EV CLI instance = Your house**
- Stores all your data, logs, conversations, events, and runs
- Your personal space in the neighborhood
- Can be expanded with addons

### 🔨 Addons Expand Functionality
Like building structures on your farm in Stardew Valley, you can build addons to expand your house:
- **Storage Shed** - Extended log retention and archives
- **Workshop** - Development and build environment
- **Greenhouse** - Always-on automation and scheduled tasks
- **Server Barn** - Host multiple services
- **Bot Coop** - Manage bots and AI agents
- **Marketplace** - Share and discover community addons
- **Observatory** - Monitoring and metrics visualization
- **Library** - Documentation and knowledge base

### 🏘️ Neighborhood System
Like Pokémon villages (Pallet Town, etc.), houses exist adjacent to each other:
- Houses are connected in the same scope
- Visit other houses to see their data and addons
- Share addons through the marketplace
- Collaborate with neighbors

## Installation

```bash
# Make executable
chmod +x exx

# Test it
./exx help
```

Or use directly:
```bash
node exx-farm-system.js help
```

## Quick Start

### 1. Create Your House
```bash
# Create a basic house
./exx create Alice "Alice's Dev House"

# This creates your house with basic EV CLI functionality
# Output shows your house ID (e.g., house-abc123)
```

### 2. Build Addons
```bash
# See available addon types
./exx addons

# Build a workshop addon for development
./exx build house-abc123 workshop

# Build a greenhouse for automation
./exx build house-abc123 greenhouse

# Build storage for extended logs
./exx build house-abc123 storage
```

### 3. Explore the Neighborhood
```bash
# View all houses
./exx neighborhood

# Visit a neighbor's house
./exx visit Bob house-abc123

# Show detailed info about a house
./exx show house-abc123
```

## Commands Reference

### `exx create <owner> [name]`
Create a new house (EV CLI instance).

```bash
./exx create Alice                    # Creates "Alice's House"
./exx create Alice "Alice's Dev Lab"  # Creates with custom name
```

**What it does:**
- Creates a new house that stores all EV CLI data
- Initializes storage for conversations, events, nodes, and logs
- Adds the house to the neighborhood
- Makes it adjacent to recent houses (neighbors)

### `exx build <houseId> <addonType>`
Build an addon to expand house functionality.

```bash
./exx build house-abc123 workshop
./exx build house-abc123 greenhouse
./exx build house-abc123 storage
```

**Available addon types:**
- `storage` - Extended log retention, archives, backups
- `workshop` - Development environment, script editor, build tools
- `greenhouse` - Scheduled tasks, cron jobs, always-on automation
- `barn` - Service hosting, containers, load balancing
- `coop` - Bot management, agent orchestration, AI assistants
- `marketplace` - Share/discover community addons and plugins
- `observatory` - Dashboards, metrics, monitoring, alerts
- `library` - Documentation, knowledge base, search

### `exx addons`
List all available addon types with descriptions.

```bash
./exx addons
```

Shows addons grouped by category (utility, development, automation, infrastructure, community, monitoring).

### `exx show <houseId>`
Show detailed information about a house.

```bash
./exx show house-abc123
```

**Displays:**
- Owner and creation date
- Stats (runs, messages, last active)
- Storage info (conversations, events, nodes, logs)
- All installed addons
- Recent visitors

### `exx visit <visitor> <houseId>`
Visit another house in the neighborhood.

```bash
./exx visit Bob house-abc123
```

**What happens:**
- Records the visit in the house's visitor log
- Shows house owner and stats
- Lists all addons installed
- Shows adjacent houses (neighbors)

### `exx neighborhood`
List all houses in the neighborhood.

```bash
./exx neighborhood
```

**Shows:**
- All houses with their owners
- Installed addons for each house
- Neighborhood connections (who's adjacent to whom)
- Total statistics

## Architecture

### Data Storage
All data stored in `~/.ev/`:

```
~/.ev/
├── exx-houses.json        # House definitions
├── exx-addons.json        # Addon instances
├── exx-neighborhood.json  # Adjacency graph
├── conversations.json     # EV CLI conversations
├── events.json           # EV CLI events
└── nodes.json            # EV CLI nodes
```

### House Structure
```json
{
  "id": "house-abc123",
  "owner": "Alice",
  "name": "Alice's House",
  "createdAt": "2025-12-14T...",
  "storage": {
    "conversations": [],
    "events": [],
    "nodes": [],
    "logs": []
  },
  "addons": ["addon-xyz", "addon-def"],
  "stats": {
    "totalRuns": 0,
    "totalMessages": 0,
    "lastActive": "2025-12-14T..."
  },
  "visitors": []
}
```

### Addon Structure
```json
{
  "id": "addon-xyz",
  "houseId": "house-abc123",
  "type": "workshop",
  "name": "Workshop",
  "category": "development",
  "provides": ["Script editor", "Build tools", "Testing environment"],
  "data": {},
  "config": {},
  "builtAt": "2025-12-14T...",
  "active": true
}
```

### Neighborhood Structure
```json
{
  "name": "Valley Town",
  "houses": ["house-abc123", "house-def456", "house-ghi789"],
  "adjacency": {
    "house-abc123": ["house-def456"],
    "house-def456": ["house-abc123", "house-ghi789"],
    "house-ghi789": ["house-def456"]
  }
}
```

## Addon Types Deep Dive

### Storage Shed 📦
**Purpose:** Extended data retention and archival
- Archives old conversations and logs
- Compressed storage for historical data
- Backup and restore functionality
- Data export tools

### Workshop 🔧
**Purpose:** Development environment
- Built-in script editor
- Build and compile tools
- Testing framework
- Debugging capabilities

### Greenhouse 🌱
**Purpose:** Always-on automation
- Cron-like scheduled tasks
- Background process management
- Task queues and workers
- Automated workflows

### Server Barn 🏛️
**Purpose:** Infrastructure hosting
- Multi-service hosting
- Container orchestration
- Load balancing
- Resource management

### Bot Coop 🐔
**Purpose:** Bot and agent management
- Multiple bot instances
- Agent orchestration
- AI assistant integration
- Inter-bot communication

### Marketplace 🏪
**Purpose:** Community addon sharing
- Discover community addons
- Share your custom addons
- Plugin installation
- Version management

### Observatory 🔭
**Purpose:** Monitoring and metrics
- Real-time dashboards
- Metric collection and visualization
- Alert system
- Performance tracking

### Library 📚
**Purpose:** Documentation hub
- Markdown documentation
- Knowledge base
- Full-text search
- Version tracking

## Use Cases

### Solo Developer
```bash
# Create your house
./exx create Alice "Alice's Dev Lab"

# Build essential addons
./exx build house-abc123 workshop
./exx build house-abc123 storage
./exx build house-abc123 observatory

# All your dev tools in one place!
```

### Team Environment
```bash
# Each team member creates their house
./exx create Alice "Alice's House"
./exx create Bob "Bob's House"
./exx create Charlie "Charlie's House"

# Visit each other for collaboration
./exx visit Alice house-bob123
./exx visit Bob house-charlie456

# Share addons via marketplace
./exx build house-alice123 marketplace
```

### Automation Hub
```bash
# Create automation-focused house
./exx create AutoBot "Automation Hub"

# Build automation addons
./exx build house-auto123 greenhouse
./exx build house-auto123 coop
./exx build house-auto123 observatory

# Monitor all your automated tasks
./exx show house-auto123
```

## Integration with EV CLI

The exx system complements the existing EV CLI:

```bash
# EV CLI commands (existing)
ev +e myevent
ev ?xx(s)
ev @node (runall)

# EXX commands (new)
./exx create Alice
./exx build house-xyz workshop

# They share the same data directory (~/.ev/)
# Your house stores all EV CLI data
```

## Future Enhancements

### Planned Features
- [ ] Addon marketplace implementation
- [ ] Inter-house messaging
- [ ] Shared community spaces
- [ ] Addon upgrade system
- [ ] House themes/customization
- [ ] Collaborative addons
- [ ] House backup/restore
- [ ] Neighborhood events

### Community Addons (Ideas)
- Weather Station (API monitoring)
- Farm Stand (Data sharing)
- Tavern (Chat room)
- Post Office (Notifications)
- Bank (Resource management)
- Museum (Achievement tracking)

## Examples

### Example 1: Creating Your First House
```bash
$ ./exx create Alice "Alice's Command Center"

🏠 Created Alice's Command Center!
   Owner: Alice
   House ID: house-m8k3p2
   This house will store all your EV CLI data, logs, and runs
   You can expand it with addons for extra functionality!

$ ./exx show house-m8k3p2

🏠 Alice's Command Center
════════════════════════════════════════════════════════════
Owner: Alice
ID: house-m8k3p2
Created: 12/14/2025, 9:50:00 PM

📊 Stats:
   Total Runs: 0
   Total Messages: 0
   Last Active: 12/14/2025, 9:50:00 PM

💾 Storage:
   Conversations: 0
   Events: 0
   Nodes: 0
   Logs: 0

🔨 No addons yet
   Add addons to expand functionality!
   Use: exx build house-m8k3p2 <addonType>
```

### Example 2: Building Addons
```bash
$ ./exx build house-m8k3p2 workshop

🔨 Built Workshop for Alice's Command Center!
   Addon ID: addon-m8k3r5
   Category: development
   Provides: Script editor, Build tools, Testing environment

   Your house is now expanded with Workshop!

$ ./exx build house-m8k3p2 greenhouse

🔨 Built Greenhouse for Alice's Command Center!
   Addon ID: addon-m8k3t9
   Category: automation
   Provides: Scheduled tasks, Cron jobs, Background processes

   Your house is now expanded with Greenhouse!
```

### Example 3: Neighborhood
```bash
$ ./exx neighborhood

🏘️  Valley Town
════════════════════════════════════════════════════════════

🏠 Alice's Command Center
   Owner: Alice
   ID: house-m8k3p2
   Created: 12/14/2025
   🔨 Addons: Workshop, Greenhouse
   👥 Neighbors: Bob

🏠 Bob's Dev Space
   Owner: Bob
   ID: house-m8k4a1
   Created: 12/14/2025
   🔨 Addons: Storage Shed
   👥 Neighbors: Alice, Charlie

🏠 Charlie's Lab
   Owner: Charlie
   ID: house-m8k4b3
   Created: 12/14/2025
   📦 Basic house (no addons yet)
   👥 Neighbors: Bob

════════════════════════════════════════════════════════════
Total houses: 3
Total addons: 3
```

## Philosophy

**EXX is about ownership and expansion:**

1. **Your house, your data** - You own your EV CLI instance
2. **Expand as needed** - Add only the functionality you need via addons
3. **Community-driven** - Share and discover addons from others
4. **Adjacent living** - Houses exist together, supporting collaboration
5. **Familiar metaphor** - Like Stardew Valley farms or Pokémon villages

This creates a cozy, village-like environment where everyone has their own space that they can customize and expand, while still being part of a connected community.

## License

MIT
