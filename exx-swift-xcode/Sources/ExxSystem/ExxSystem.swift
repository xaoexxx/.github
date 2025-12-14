//
//  ExxSystem.swift
//  EXX House & Addon System
//
//  Created by xaoexxx
//  Copyright © 2025 xaoexxx. All rights reserved.
//  Licensed under the MIT License
//

import Foundation

/// Addon type definition
public struct AddonType: Codable {
    let name: String
    let description: String
    let provides: [String]
    let category: String
    let icon: String
}

/// House structure
public struct House: Codable {
    let id: String
    let owner: String
    let name: String
    let createdAt: String
    var storage: Storage
    var addons: [String]
    var stats: Stats
    var visitors: [Visitor]
    
    struct Storage: Codable {
        var conversations: [String]
        var events: [String]
        var nodes: [String]
        var logs: [String]
    }
    
    struct Stats: Codable {
        var totalRuns: Int
        var totalMessages: Int
        var lastActive: String
    }
    
    struct Visitor: Codable {
        let visitor: String
        let visitedAt: String
    }
}

/// Addon structure
public struct Addon: Codable {
    let id: String
    let houseId: String
    let type: String
    let name: String
    let description: String
    let category: String
    let provides: [String]
    let icon: String
    var data: [String: String]
    var config: [String: String]
    let builtAt: String
    var active: Bool
}

/// Neighborhood structure
public struct Neighborhood: Codable {
    var name: String
    var houses: [String]
    var adjacency: [String: [String]]
}

/// Main EXX Farm System
public class ExxFarmSystem {
    private let dataDir: URL
    private let housesFile: URL
    private let addonsFile: URL
    private let neighborhoodFile: URL
    private let addonTypes: [String: AddonType]
    
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    public init() throws {
        // Setup data directory
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        self.dataDir = homeDir.appendingPathComponent(".ev")
        self.housesFile = dataDir.appendingPathComponent("exx-houses.json")
        self.addonsFile = dataDir.appendingPathComponent("exx-addons.json")
        self.neighborhoodFile = dataDir.appendingPathComponent("exx-neighborhood.json")
        
        // Setup JSON encoding/decoding
        self.encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.decoder = JSONDecoder()
        
        // Initialize addon types
        self.addonTypes = [
            "storage": AddonType(
                name: "Storage Shed",
                description: "Additional storage for logs, data, and archived conversations",
                provides: ["Extended log retention", "Archive management", "Data backup"],
                category: "utility",
                icon: "📦"
            ),
            "workshop": AddonType(
                name: "Workshop",
                description: "Development and build environment for custom scripts",
                provides: ["Script editor", "Build tools", "Testing environment"],
                category: "development",
                icon: "🔧"
            ),
            "greenhouse": AddonType(
                name: "Greenhouse",
                description: "Always-on task runner and automation hub",
                provides: ["Scheduled tasks", "Cron jobs", "Background processes"],
                category: "automation",
                icon: "🌱"
            ),
            "barn": AddonType(
                name: "Server Barn",
                description: "Host multiple services and applications",
                provides: ["Service hosting", "Container management", "Load balancing"],
                category: "infrastructure",
                icon: "🏛️"
            ),
            "coop": AddonType(
                name: "Bot Coop",
                description: "Manage and run multiple bots and agents",
                provides: ["Bot management", "Agent orchestration", "AI assistants"],
                category: "automation",
                icon: "🐔"
            ),
            "marketplace": AddonType(
                name: "Marketplace",
                description: "Share and discover addons from other houses",
                provides: ["Addon marketplace", "Community plugins", "Shared scripts"],
                category: "community",
                icon: "🏪"
            ),
            "observatory": AddonType(
                name: "Observatory",
                description: "Monitor and visualize your data and metrics",
                provides: ["Dashboard", "Metrics visualization", "Alert system"],
                category: "monitoring",
                icon: "🔭"
            ),
            "library": AddonType(
                name: "Library",
                description: "Documentation and knowledge base storage",
                provides: ["Documentation", "Knowledge base", "Search system"],
                category: "utility",
                icon: "📚"
            )
        ]
        
        try initializeStorage()
    }
    
    private func initializeStorage() throws {
        // Create data directory if needed
        if !FileManager.default.fileExists(atPath: dataDir.path) {
            try FileManager.default.createDirectory(at: dataDir, withIntermediateDirectories: true)
        }
        
        // Initialize files if they don't exist
        if !FileManager.default.fileExists(atPath: housesFile.path) {
            try writeData([], to: housesFile)
        }
        
        if !FileManager.default.fileExists(atPath: addonsFile.path) {
            try writeData([] as [Addon], to: addonsFile)
        }
        
        if !FileManager.default.fileExists(atPath: neighborhoodFile.path) {
            let neighborhood = Neighborhood(name: "Valley Town", houses: [], adjacency: [:])
            try writeData(neighborhood, to: neighborhoodFile)
        }
    }
    
    private func readData<T: Decodable>(_ type: T.Type, from url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        return try decoder.decode(T.self, from: data)
    }
    
    private func writeData<T: Encodable>(_ value: T, to url: URL) throws {
        let data = try encoder.encode(value)
        try data.write(to: url)
    }
    
    private func generateId(prefix: String) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let random = Int.random(in: 0..<1000)
        return "\(prefix)-\(String(timestamp, radix: 36))\(String(random, radix: 36))"
    }
    
    /// Create a new house
    public func createHouse(owner: String, name: String? = nil) throws -> House {
        guard !owner.isEmpty else {
            throw NSError(domain: "ExxSystem", code: 1, userInfo: [NSLocalizedDescriptionKey: "Owner name is required"])
        }
        
        var houses = try readData([House].self, from: housesFile)
        var neighborhood = try readData(Neighborhood.self, from: neighborhoodFile)
        
        let houseId = generateId(prefix: "house")
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        let house = House(
            id: houseId,
            owner: owner,
            name: name ?? "\(owner)'s House",
            createdAt: timestamp,
            storage: House.Storage(conversations: [], events: [], nodes: [], logs: []),
            addons: [],
            stats: House.Stats(totalRuns: 0, totalMessages: 0, lastActive: timestamp),
            visitors: []
        )
        
        houses.append(house)
        try writeData(houses, to: housesFile)
        
        // Add to neighborhood
        neighborhood.houses.append(houseId)
        neighborhood.adjacency[houseId] = []
        
        // Create adjacency with existing houses
        let existingHouses = Array(neighborhood.houses.dropLast())
        if !existingHouses.isEmpty {
            let adjacentCount = min(2, existingHouses.count)
            for i in 0..<adjacentCount {
                let adjacentId = existingHouses[existingHouses.count - 1 - i]
                neighborhood.adjacency[houseId]?.append(adjacentId)
                
                if neighborhood.adjacency[adjacentId] == nil {
                    neighborhood.adjacency[adjacentId] = []
                }
                if !neighborhood.adjacency[adjacentId]!.contains(houseId) {
                    neighborhood.adjacency[adjacentId]?.append(houseId)
                }
            }
        }
        
        try writeData(neighborhood, to: neighborhoodFile)
        
        print("\n🏠 Created \(house.name)!")
        print("   Owner: \(owner)")
        print("   House ID: \(houseId)")
        print("   This house will store all your EV CLI data, logs, and runs")
        print("   You can expand it with addons for extra functionality!\n")
        
        return house
    }
    
    /// Build an addon for a house
    public func buildAddon(houseId: String, addonType: String) throws -> Addon {
        guard !houseId.isEmpty && !addonType.isEmpty else {
            throw NSError(domain: "ExxSystem", code: 2, userInfo: [NSLocalizedDescriptionKey: "House ID and addon type are required"])
        }
        
        guard let typeInfo = addonTypes[addonType] else {
            throw NSError(domain: "ExxSystem", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid addon type: \(addonType)"])
        }
        
        var houses = try readData([House].self, from: housesFile)
        guard let houseIndex = houses.firstIndex(where: { $0.id == houseId }) else {
            throw NSError(domain: "ExxSystem", code: 4, userInfo: [NSLocalizedDescriptionKey: "House not found: \(houseId)"])
        }
        
        var addons = try readData([Addon].self, from: addonsFile)
        
        let addonId = generateId(prefix: "addon")
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        let addon = Addon(
            id: addonId,
            houseId: houseId,
            type: addonType,
            name: typeInfo.name,
            description: typeInfo.description,
            category: typeInfo.category,
            provides: typeInfo.provides,
            icon: typeInfo.icon,
            data: [:],
            config: [:],
            builtAt: timestamp,
            active: true
        )
        
        addons.append(addon)
        try writeData(addons, to: addonsFile)
        
        houses[houseIndex].addons.append(addonId)
        try writeData(houses, to: housesFile)
        
        print("\n🔨 Built \(addon.name) for \(houses[houseIndex].name)!")
        print("   Addon ID: \(addonId)")
        print("   Category: \(addon.category)")
        print("   Provides: \(addon.provides.joined(separator: ", "))")
        print("\n   Your house is now expanded with \(addon.name)!\n")
        
        return addon
    }
    
    /// List all available addon types
    public func listAddonTypes() {
        print("\n🔨 Available Addon Types:\n")
        print(String(repeating: "=", count: 70))
        
        // Group by category
        var categories: [String: [(key: String, type: AddonType)]] = [:]
        for (key, type) in addonTypes {
            categories[type.category, default: []].append((key, type))
        }
        
        for category in categories.keys.sorted() {
            print("\n📁 \(category.uppercased())")
            for (key, type) in categories[category]! {
                print("\n   \(type.icon) \(type.name) (\(key))")
                print("   \(type.description)")
                print("   Provides: \(type.provides.joined(separator: ", "))")
            }
        }
        
        print("\n" + String(repeating: "=", count: 70))
        print("\nUse: exx build <houseId> <addonType>\n")
    }
    
    /// Show house details
    public func showHouse(houseId: String) throws {
        guard !houseId.isEmpty else {
            throw NSError(domain: "ExxSystem", code: 5, userInfo: [NSLocalizedDescriptionKey: "House ID is required"])
        }
        
        let houses = try readData([House].self, from: housesFile)
        guard let house = houses.first(where: { $0.id == houseId }) else {
            throw NSError(domain: "ExxSystem", code: 6, userInfo: [NSLocalizedDescriptionKey: "House not found: \(houseId)"])
        }
        
        let addons = try readData([Addon].self, from: addonsFile)
        let houseAddons = addons.filter { $0.houseId == houseId }
        
        print("\n🏠 \(house.name)")
        print(String(repeating: "=", count: 60))
        print("Owner: \(house.owner)")
        print("ID: \(house.id)")
        print("Created: \(house.createdAt)")
        
        print("\n📊 Stats:")
        print("   Total Runs: \(house.stats.totalRuns)")
        print("   Total Messages: \(house.stats.totalMessages)")
        print("   Last Active: \(house.stats.lastActive)")
        
        print("\n💾 Storage:")
        print("   Conversations: \(house.storage.conversations.count)")
        print("   Events: \(house.storage.events.count)")
        print("   Nodes: \(house.storage.nodes.count)")
        print("   Logs: \(house.storage.logs.count)")
        
        if !houseAddons.isEmpty {
            print("\n🔨 Addons (\(houseAddons.count)):")
            for addon in houseAddons {
                print("\n   \(addon.icon) \(addon.name)")
                print("   └─ ID: \(addon.id)")
                print("   └─ Category: \(addon.category)")
                print("   └─ Provides: \(addon.provides.joined(separator: ", "))")
                print("   └─ Status: \(addon.active ? "✓ Active" : "✗ Inactive")")
            }
        } else {
            print("\n🔨 No addons yet")
            print("   Add addons to expand functionality!")
            print("   Use: exx build \(houseId) <addonType>")
        }
        
        print()
    }
    
    /// List all houses in the neighborhood
    public func listNeighborhood() throws {
        let neighborhood = try readData(Neighborhood.self, from: neighborhoodFile)
        let houses = try readData([House].self, from: housesFile)
        let addons = try readData([Addon].self, from: addonsFile)
        
        print("\n🏘️  \(neighborhood.name)")
        print(String(repeating: "=", count: 60))
        
        if neighborhood.houses.isEmpty {
            print("No houses in the neighborhood yet.")
            print("\nCreate your first house with: exx create <owner> [name]\n")
            return
        }
        
        for houseId in neighborhood.houses {
            guard let house = houses.first(where: { $0.id == houseId }) else { continue }
            
            print("\n🏠 \(house.name)")
            print("   Owner: \(house.owner)")
            print("   ID: \(house.id)")
            print("   Created: \(house.createdAt.split(separator: "T")[0])")
            
            let houseAddons = addons.filter { $0.houseId == houseId }
            if !houseAddons.isEmpty {
                let addonNames = houseAddons.map { $0.name }
                print("   🔨 Addons: \(addonNames.joined(separator: ", "))")
            } else {
                print("   📦 Basic house (no addons yet)")
            }
            
            if let adjacent = neighborhood.adjacency[houseId], !adjacent.isEmpty {
                let neighborNames = adjacent.compactMap { adjId in
                    houses.first(where: { $0.id == adjId })?.owner
                }
                if !neighborNames.isEmpty {
                    print("   👥 Neighbors: \(neighborNames.joined(separator: ", "))")
                }
            }
        }
        
        print("\n" + String(repeating: "=", count: 60))
        print("Total houses: \(neighborhood.houses.count)")
        print("Total addons: \(addons.count)\n")
    }
    
    /// Show help message
    public func showHelp() {
        print("""
        
        EXX System - House & Addon Management (Swift Implementation)
        
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
    }
}
