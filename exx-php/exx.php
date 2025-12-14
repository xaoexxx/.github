#!/usr/bin/env php
<?php
/**
 * EXX System - House & Addon Management (PHP Implementation)
 * 
 * Your EV CLI IS your house that stores all your data, logs, and runs.
 * Expand it with addons for additional functionality.
 * 
 * @package EXX
 * @author xaoexxx
 * @license MIT
 */

class ExxFarmSystem {
    private string $dataDir;
    private string $housesFile;
    private string $addonsFile;
    private string $neighborhoodFile;
    private array $addonTypes;
    
    public function __construct() {
        $this->dataDir = $_SERVER['HOME'] . '/.ev';
        $this->housesFile = $this->dataDir . '/exx-houses.json';
        $this->addonsFile = $this->dataDir . '/exx-addons.json';
        $this->neighborhoodFile = $this->dataDir . '/exx-neighborhood.json';
        
        $this->initAddonTypes();
        $this->initializeStorage();
    }
    
    private function initAddonTypes(): void {
        $this->addonTypes = [
            'storage' => [
                'name' => 'Storage Shed',
                'description' => 'Additional storage for logs, data, and archived conversations',
                'provides' => ['Extended log retention', 'Archive management', 'Data backup'],
                'category' => 'utility',
                'icon' => '📦'
            ],
            'workshop' => [
                'name' => 'Workshop',
                'description' => 'Development and build environment for custom scripts',
                'provides' => ['Script editor', 'Build tools', 'Testing environment'],
                'category' => 'development',
                'icon' => '🔧'
            ],
            'greenhouse' => [
                'name' => 'Greenhouse',
                'description' => 'Always-on task runner and automation hub',
                'provides' => ['Scheduled tasks', 'Cron jobs', 'Background processes'],
                'category' => 'automation',
                'icon' => '🌱'
            ],
            'barn' => [
                'name' => 'Server Barn',
                'description' => 'Host multiple services and applications',
                'provides' => ['Service hosting', 'Container management', 'Load balancing'],
                'category' => 'infrastructure',
                'icon' => '🏛️'
            ],
            'coop' => [
                'name' => 'Bot Coop',
                'description' => 'Manage and run multiple bots and agents',
                'provides' => ['Bot management', 'Agent orchestration', 'AI assistants'],
                'category' => 'automation',
                'icon' => '🐔'
            ],
            'marketplace' => [
                'name' => 'Marketplace',
                'description' => 'Share and discover addons from other houses',
                'provides' => ['Addon marketplace', 'Community plugins', 'Shared scripts'],
                'category' => 'community',
                'icon' => '🏪'
            ],
            'observatory' => [
                'name' => 'Observatory',
                'description' => 'Monitor and visualize your data and metrics',
                'provides' => ['Dashboard', 'Metrics visualization', 'Alert system'],
                'category' => 'monitoring',
                'icon' => '🔭'
            ],
            'library' => [
                'name' => 'Library',
                'description' => 'Documentation and knowledge base storage',
                'provides' => ['Documentation', 'Knowledge base', 'Search system'],
                'category' => 'utility',
                'icon' => '📚'
            ]
        ];
    }
    
    private function initializeStorage(): void {
        if (!is_dir($this->dataDir)) {
            mkdir($this->dataDir, 0755, true);
        }
        
        if (!file_exists($this->housesFile)) {
            $this->writeData($this->housesFile, []);
        }
        
        if (!file_exists($this->addonsFile)) {
            $this->writeData($this->addonsFile, []);
        }
        
        if (!file_exists($this->neighborhoodFile)) {
            $this->writeData($this->neighborhoodFile, [
                'name' => 'Valley Town',
                'houses' => [],
                'adjacency' => []
            ]);
        }
    }
    
    private function readData(string $file): array {
        if (!file_exists($file)) {
            return strpos($file, 'neighborhood') !== false
                ? ['name' => 'Valley Town', 'houses' => [], 'adjacency' => []]
                : [];
        }
        
        $content = file_get_contents($file);
        return json_decode($content, true) ?? [];
    }
    
    private function writeData(string $file, array $data): void {
        file_put_contents($file, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
    }
    
    private function generateId(string $prefix): string {
        return sprintf('%s-%s', $prefix, base_convert(time() . mt_rand(), 10, 36));
    }
    
    public function createHouse(string $owner, ?string $name = null): array {
        if (empty($owner)) {
            throw new InvalidArgumentException('Owner name is required');
        }
        
        $houses = $this->readData($this->housesFile);
        $neighborhood = $this->readData($this->neighborhoodFile);
        
        $houseId = $this->generateId('house');
        $timestamp = date('c');
        
        $house = [
            'id' => $houseId,
            'owner' => $owner,
            'name' => $name ?? "{$owner}'s House",
            'createdAt' => $timestamp,
            'storage' => [
                'conversations' => [],
                'events' => [],
                'nodes' => [],
                'logs' => []
            ],
            'addons' => [],
            'stats' => [
                'totalRuns' => 0,
                'totalMessages' => 0,
                'lastActive' => $timestamp
            ],
            'visitors' => []
        ];
        
        $houses[] = $house;
        $this->writeData($this->housesFile, $houses);
        
        // Add to neighborhood
        $neighborhood['houses'][] = $houseId;
        $neighborhood['adjacency'][$houseId] = [];
        
        // Create adjacency
        $existingHouses = array_slice($neighborhood['houses'], 0, -1);
        if (!empty($existingHouses)) {
            $adjacentCount = min(2, count($existingHouses));
            for ($i = 0; $i < $adjacentCount; $i++) {
                $adjacentId = $existingHouses[count($existingHouses) - 1 - $i];
                $neighborhood['adjacency'][$houseId][] = $adjacentId;
                
                if (!isset($neighborhood['adjacency'][$adjacentId])) {
                    $neighborhood['adjacency'][$adjacentId] = [];
                }
                if (!in_array($houseId, $neighborhood['adjacency'][$adjacentId])) {
                    $neighborhood['adjacency'][$adjacentId][] = $houseId;
                }
            }
        }
        
        $this->writeData($this->neighborhoodFile, $neighborhood);
        
        echo "\n🏠 Created {$house['name']}!\n";
        echo "   Owner: {$owner}\n";
        echo "   House ID: {$houseId}\n";
        echo "   This house will store all your EV CLI data, logs, and runs\n";
        echo "   You can expand it with addons for extra functionality!\n\n";
        
        return $house;
    }
    
    public function buildAddon(string $houseId, string $addonType): array {
        if (empty($houseId) || empty($addonType)) {
            throw new InvalidArgumentException('House ID and addon type are required');
        }
        
        if (!isset($this->addonTypes[$addonType])) {
            throw new InvalidArgumentException("Invalid addon type: {$addonType}");
        }
        
        $houses = $this->readData($this->housesFile);
        $house = null;
        $houseIndex = null;
        
        foreach ($houses as $index => $h) {
            if ($h['id'] === $houseId) {
                $house = $h;
                $houseIndex = $index;
                break;
            }
        }
        
        if (!$house) {
            throw new RuntimeException("House not found: {$houseId}");
        }
        
        $addons = $this->readData($this->addonsFile);
        $typeInfo = $this->addonTypes[$addonType];
        
        $addonId = $this->generateId('addon');
        
        $addon = [
            'id' => $addonId,
            'houseId' => $houseId,
            'type' => $addonType,
            'name' => $typeInfo['name'],
            'description' => $typeInfo['description'],
            'category' => $typeInfo['category'],
            'provides' => $typeInfo['provides'],
            'icon' => $typeInfo['icon'],
            'data' => [],
            'config' => [],
            'builtAt' => date('c'),
            'active' => true
        ];
        
        $addons[] = $addon;
        $this->writeData($this->addonsFile, $addons);
        
        $houses[$houseIndex]['addons'][] = $addonId;
        $this->writeData($this->housesFile, $houses);
        
        echo "\n🔨 Built {$addon['name']} for {$house['name']}!\n";
        echo "   Addon ID: {$addonId}\n";
        echo "   Category: {$addon['category']}\n";
        echo "   Provides: " . implode(', ', $addon['provides']) . "\n";
        echo "\n   Your house is now expanded with {$addon['name']}!\n\n";
        
        return $addon;
    }
    
    public function listAddonTypes(): void {
        echo "\n🔨 Available Addon Types:\n";
        echo str_repeat('=', 70) . "\n";
        
        // Group by category
        $categories = [];
        foreach ($this->addonTypes as $key => $type) {
            $categories[$type['category']][] = ['key' => $key] + $type;
        }
        
        foreach ($categories as $category => $addons) {
            echo "\n📁 " . strtoupper($category) . "\n";
            foreach ($addons as $addon) {
                echo "\n   {$addon['icon']} {$addon['name']} ({$addon['key']})\n";
                echo "   {$addon['description']}\n";
                echo "   Provides: " . implode(', ', $addon['provides']) . "\n";
            }
        }
        
        echo "\n" . str_repeat('=', 70) . "\n";
        echo "\nUse: exx build <houseId> <addonType>\n\n";
    }
    
    public function showHouse(string $houseId): void {
        if (empty($houseId)) {
            throw new InvalidArgumentException('House ID is required');
        }
        
        $houses = $this->readData($this->housesFile);
        $house = null;
        
        foreach ($houses as $h) {
            if ($h['id'] === $houseId) {
                $house = $h;
                break;
            }
        }
        
        if (!$house) {
            throw new RuntimeException("House not found: {$houseId}");
        }
        
        $addons = $this->readData($this->addonsFile);
        $houseAddons = array_filter($addons, fn($a) => $a['houseId'] === $houseId);
        
        echo "\n🏠 {$house['name']}\n";
        echo str_repeat('=', 60) . "\n";
        echo "Owner: {$house['owner']}\n";
        echo "ID: {$house['id']}\n";
        echo "Created: {$house['createdAt']}\n";
        
        echo "\n📊 Stats:\n";
        echo "   Total Runs: {$house['stats']['totalRuns']}\n";
        echo "   Total Messages: {$house['stats']['totalMessages']}\n";
        echo "   Last Active: {$house['stats']['lastActive']}\n";
        
        echo "\n💾 Storage:\n";
        echo "   Conversations: " . count($house['storage']['conversations']) . "\n";
        echo "   Events: " . count($house['storage']['events']) . "\n";
        echo "   Nodes: " . count($house['storage']['nodes']) . "\n";
        echo "   Logs: " . count($house['storage']['logs']) . "\n";
        
        if (!empty($houseAddons)) {
            echo "\n🔨 Addons (" . count($houseAddons) . "):\n";
            foreach ($houseAddons as $addon) {
                echo "\n   {$addon['icon']} {$addon['name']}\n";
                echo "   └─ ID: {$addon['id']}\n";
                echo "   └─ Category: {$addon['category']}\n";
                echo "   └─ Provides: " . implode(', ', $addon['provides']) . "\n";
                echo "   └─ Status: " . ($addon['active'] ? '✓ Active' : '✗ Inactive') . "\n";
            }
        } else {
            echo "\n🔨 No addons yet\n";
            echo "   Add addons to expand functionality!\n";
            echo "   Use: exx build {$houseId} <addonType>\n";
        }
        
        echo "\n";
    }
    
    public function listNeighborhood(): void {
        $neighborhood = $this->readData($this->neighborhoodFile);
        $houses = $this->readData($this->housesFile);
        $addons = $this->readData($this->addonsFile);
        
        echo "\n🏘️  {$neighborhood['name']}\n";
        echo str_repeat('=', 60) . "\n";
        
        if (empty($neighborhood['houses'])) {
            echo "No houses in the neighborhood yet.\n";
            echo "\nCreate your first house with: exx create <owner> [name]\n\n";
            return;
        }
        
        foreach ($neighborhood['houses'] as $houseId) {
            $house = null;
            foreach ($houses as $h) {
                if ($h['id'] === $houseId) {
                    $house = $h;
                    break;
                }
            }
            
            if (!$house) continue;
            
            echo "\n🏠 {$house['name']}\n";
            echo "   Owner: {$house['owner']}\n";
            echo "   ID: {$house['id']}\n";
            echo "   Created: " . explode('T', $house['createdAt'])[0] . "\n";
            
            $houseAddons = array_filter($addons, fn($a) => $a['houseId'] === $houseId);
            if (!empty($houseAddons)) {
                $addonNames = array_map(fn($a) => $a['name'], $houseAddons);
                echo "   🔨 Addons: " . implode(', ', $addonNames) . "\n";
            } else {
                echo "   📦 Basic house (no addons yet)\n";
            }
            
            $adjacent = $neighborhood['adjacency'][$houseId] ?? [];
            if (!empty($adjacent)) {
                $neighborNames = [];
                foreach ($adjacent as $adjId) {
                    foreach ($houses as $h) {
                        if ($h['id'] === $adjId) {
                            $neighborNames[] = $h['owner'];
                            break;
                        }
                    }
                }
                if (!empty($neighborNames)) {
                    echo "   👥 Neighbors: " . implode(', ', $neighborNames) . "\n";
                }
            }
        }
        
        echo "\n" . str_repeat('=', 60) . "\n";
        echo "Total houses: " . count($neighborhood['houses']) . "\n";
        echo "Total addons: " . count($addons) . "\n\n";
    }
    
    public function showHelp(): void {
        echo <<<'HELP'

EXX System - House & Addon Management (PHP Implementation)

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

HELP;
        echo "\n";
    }
}

// Main execution
$system = new ExxFarmSystem();
$command = $argv[1] ?? 'help';

try {
    switch ($command) {
        case 'create':
            $owner = $argv[2] ?? null;
            $name = isset($argv[3]) ? implode(' ', array_slice($argv, 3)) : null;
            $system->createHouse($owner, $name);
            break;
            
        case 'build':
            $houseId = $argv[2] ?? null;
            $addonType = $argv[3] ?? null;
            $system->buildAddon($houseId, $addonType);
            break;
            
        case 'addons':
            $system->listAddonTypes();
            break;
            
        case 'show':
            $houseId = $argv[2] ?? null;
            $system->showHouse($houseId);
            break;
            
        case 'neighborhood':
            $system->listNeighborhood();
            break;
            
        case 'help':
        case '--help':
        case '-h':
            $system->showHelp();
            break;
            
        default:
            echo "✗ Unknown command: {$command}\n";
            $system->showHelp();
    }
} catch (Exception $e) {
    echo "✗ Error: " . $e->getMessage() . "\n\n";
    exit(1);
}
