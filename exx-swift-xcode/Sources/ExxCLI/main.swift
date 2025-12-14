//
//  main.swift
//  EXX CLI
//
//  Created by xaoexxx
//  Copyright © 2025 xaoexxx. All rights reserved.
//  Licensed under the MIT License
//

import Foundation
import ExxSystem

// Main CLI entry point
let arguments = CommandLine.arguments
let command = arguments.count > 1 ? arguments[1] : "help"

do {
    let system = try ExxFarmSystem()
    
    switch command {
    case "create":
        let owner = arguments.count > 2 ? arguments[2] : ""
        let name = arguments.count > 3 ? arguments[3...].joined(separator: " ") : nil
        _ = try system.createHouse(owner: owner, name: name)
        
    case "build":
        let houseId = arguments.count > 2 ? arguments[2] : ""
        let addonType = arguments.count > 3 ? arguments[3] : ""
        _ = try system.buildAddon(houseId: houseId, addonType: addonType)
        
    case "addons":
        system.listAddonTypes()
        
    case "show":
        let houseId = arguments.count > 2 ? arguments[2] : ""
        try system.showHouse(houseId: houseId)
        
    case "neighborhood":
        try system.listNeighborhood()
        
    case "help", "--help", "-h":
        system.showHelp()
        
    default:
        print("✗ Unknown command: \(command)")
        system.showHelp()
        exit(1)
    }
    
} catch {
    print("✗ Error: \(error.localizedDescription)\n")
    exit(1)
}
