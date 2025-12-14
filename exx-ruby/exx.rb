#!/usr/bin/env ruby

=begin
EXX System - House & Addon Management (Ruby Implementation)

Your EV CLI IS your house that stores all your data, logs, and runs.
Expand it with addons for additional functionality.

Copyright (c) 2025 xaoexxx
Licensed under the MIT License
=end

require 'json'
require 'fileutils'
require 'time'

class ExxFarmSystem
  attr_reader :data_dir, :houses_file, :addons_file, :neighborhood_file
  
  def initialize
    @data_dir = File.join(Dir.home, '.ev')
    @houses_file = File.join(@data_dir, 'exx-houses.json')
    @addons_file = File.join(@data_dir, 'exx-addons.json')
    @neighborhood_file = File.join(@data_dir, 'exx-neighborhood.json')
    
    init_addon_types
    initialize_storage
  end
  
  def init_addon_types
    @addon_types = {
      'storage' => {
        'name' => 'Storage Shed',
        'description' => 'Additional storage for logs, data, and archived conversations',
        'provides' => ['Extended log retention', 'Archive management', 'Data backup'],
        'category' => 'utility',
        'icon' => '📦'
      },
      'workshop' => {
        'name' => 'Workshop',
        'description' => 'Development and build environment for custom scripts',
        'provides' => ['Script editor', 'Build tools', 'Testing environment'],
        'category' => 'development',
        'icon' => '🔧'
      },
      'greenhouse' => {
        'name' => 'Greenhouse',
        'description' => 'Always-on task runner and automation hub',
        'provides' => ['Scheduled tasks', 'Cron jobs', 'Background processes'],
        'category' => 'automation',
        'icon' => '🌱'
      },
      'barn' => {
        'name' => 'Server Barn',
        'description' => 'Host multiple services and applications',
        'provides' => ['Service hosting', 'Container management', 'Load balancing'],
        'category' => 'infrastructure',
        'icon' => '🏛️'
      },
      'coop' => {
        'name' => 'Bot Coop',
        'description' => 'Manage and run multiple bots and agents',
        'provides' => ['Bot management', 'Agent orchestration', 'AI assistants'],
        'category' => 'automation',
        'icon' => '🐔'
      },
      'marketplace' => {
        'name' => 'Marketplace',
        'description' => 'Share and discover addons from other houses',
        'provides' => ['Addon marketplace', 'Community plugins', 'Shared scripts'],
        'category' => 'community',
        'icon' => '🏪'
      },
      'observatory' => {
        'name' => 'Observatory',
        'description' => 'Monitor and visualize your data and metrics',
        'provides' => ['Dashboard', 'Metrics visualization', 'Alert system'],
        'category' => 'monitoring',
        'icon' => '🔭'
      },
      'library' => {
        'name' => 'Library',
        'description' => 'Documentation and knowledge base storage',
        'provides' => ['Documentation', 'Knowledge base', 'Search system'],
        'category' => 'utility',
        'icon' => '📚'
      }
    }
  end
  
  def initialize_storage
    FileUtils.mkdir_p(@data_dir) unless Dir.exist?(@data_dir)
    
    write_data(@houses_file, []) unless File.exist?(@houses_file)
    write_data(@addons_file, []) unless File.exist?(@addons_file)
    
    unless File.exist?(@neighborhood_file)
      write_data(@neighborhood_file, {
        'name' => 'Valley Town',
        'houses' => [],
        'adjacency' => {}
      })
    end
  end
  
  def read_data(file)
    return [] unless File.exist?(file)
    
    content = File.read(file)
    JSON.parse(content)
  rescue JSON::ParserError
    file.include?('neighborhood') ? 
      { 'name' => 'Valley Town', 'houses' => [], 'adjacency' => {} } : []
  end
  
  def write_data(file, data)
    File.write(file, JSON.pretty_generate(data))
  end
  
  def generate_id(prefix)
    "#{prefix}-#{Time.now.to_i.to_s(36)}#{rand(1000).to_s(36)}"
  end
  
  def create_house(owner, name = nil)
    raise ArgumentError, 'Owner name is required' if owner.nil? || owner.empty?
    
    houses = read_data(@houses_file)
    neighborhood = read_data(@neighborhood_file)
    
    house_id = generate_id('house')
    timestamp = Time.now.iso8601
    
    house = {
      'id' => house_id,
      'owner' => owner,
      'name' => name || "#{owner}'s House",
      'createdAt' => timestamp,
      'storage' => {
        'conversations' => [],
        'events' => [],
        'nodes' => [],
        'logs' => []
      },
      'addons' => [],
      'stats' => {
        'totalRuns' => 0,
        'totalMessages' => 0,
        'lastActive' => timestamp
      },
      'visitors' => []
    }
    
    houses << house
    write_data(@houses_file, houses)
    
    # Add to neighborhood
    neighborhood['houses'] << house_id
    neighborhood['adjacency'][house_id] = []
    
    # Create adjacency
    existing_houses = neighborhood['houses'][0...-1]
    unless existing_houses.empty?
      adjacent_count = [2, existing_houses.length].min
      adjacent_count.times do |i|
        adjacent_id = existing_houses[-(1 + i)]
        neighborhood['adjacency'][house_id] << adjacent_id
        
        neighborhood['adjacency'][adjacent_id] ||= []
        neighborhood['adjacency'][adjacent_id] << house_id unless neighborhood['adjacency'][adjacent_id].include?(house_id)
      end
    end
    
    write_data(@neighborhood_file, neighborhood)
    
    puts "\n🏠 Created #{house['name']}!"
    puts "   Owner: #{owner}"
    puts "   House ID: #{house_id}"
    puts "   This house will store all your EV CLI data, logs, and runs"
    puts "   You can expand it with addons for extra functionality!\n\n"
    
    house
  end
  
  def build_addon(house_id, addon_type)
    raise ArgumentError, 'House ID and addon type are required' if house_id.nil? || addon_type.nil?
    raise ArgumentError, "Invalid addon type: #{addon_type}" unless @addon_types.key?(addon_type)
    
    houses = read_data(@houses_file)
    house = houses.find { |h| h['id'] == house_id }
    raise RuntimeError, "House not found: #{house_id}" unless house
    
    addons = read_data(@addons_file)
    type_info = @addon_types[addon_type]
    
    addon_id = generate_id('addon')
    
    addon = {
      'id' => addon_id,
      'houseId' => house_id,
      'type' => addon_type,
      'name' => type_info['name'],
      'description' => type_info['description'],
      'category' => type_info['category'],
      'provides' => type_info['provides'],
      'icon' => type_info['icon'],
      'data' => {},
      'config' => {},
      'builtAt' => Time.now.iso8601,
      'active' => true
    }
    
    addons << addon
    write_data(@addons_file, addons)
    
    house['addons'] << addon_id
    write_data(@houses_file, houses)
    
    puts "\n🔨 Built #{addon['name']} for #{house['name']}!"
    puts "   Addon ID: #{addon_id}"
    puts "   Category: #{addon['category']}"
    puts "   Provides: #{addon['provides'].join(', ')}"
    puts "\n   Your house is now expanded with #{addon['name']}!\n\n"
    
    addon
  end
  
  def list_addon_types
    puts "\n🔨 Available Addon Types:\n"
    puts '=' * 70
    
    # Group by category
    categories = {}
    @addon_types.each do |key, type|
      categories[type['category']] ||= []
      categories[type['category']] << { 'key' => key }.merge(type)
    end
    
    categories.sort.each do |category, addons|
      puts "\n📁 #{category.upcase}"
      addons.each do |addon|
        puts "\n   #{addon['icon']} #{addon['name']} (#{addon['key']})"
        puts "   #{addon['description']}"
        puts "   Provides: #{addon['provides'].join(', ')}"
      end
    end
    
    puts "\n#{'=' * 70}"
    puts "\nUse: exx build <houseId> <addonType>\n\n"
  end
  
  def show_house(house_id)
    raise ArgumentError, 'House ID is required' if house_id.nil?
    
    houses = read_data(@houses_file)
    house = houses.find { |h| h['id'] == house_id }
    raise RuntimeError, "House not found: #{house_id}" unless house
    
    addons = read_data(@addons_file)
    house_addons = addons.select { |a| a['houseId'] == house_id }
    
    puts "\n🏠 #{house['name']}"
    puts '=' * 60
    puts "Owner: #{house['owner']}"
    puts "ID: #{house['id']}"
    puts "Created: #{house['createdAt']}"
    
    puts "\n📊 Stats:"
    puts "   Total Runs: #{house['stats']['totalRuns']}"
    puts "   Total Messages: #{house['stats']['totalMessages']}"
    puts "   Last Active: #{house['stats']['lastActive']}"
    
    puts "\n💾 Storage:"
    puts "   Conversations: #{house['storage']['conversations'].length}"
    puts "   Events: #{house['storage']['events'].length}"
    puts "   Nodes: #{house['storage']['nodes'].length}"
    puts "   Logs: #{house['storage']['logs'].length}"
    
    if house_addons.any?
      puts "\n🔨 Addons (#{house_addons.length}):"
      house_addons.each do |addon|
        puts "\n   #{addon['icon']} #{addon['name']}"
        puts "   └─ ID: #{addon['id']}"
        puts "   └─ Category: #{addon['category']}"
        puts "   └─ Provides: #{addon['provides'].join(', ')}"
        puts "   └─ Status: #{addon['active'] ? '✓ Active' : '✗ Inactive'}"
      end
    else
      puts "\n🔨 No addons yet"
      puts "   Add addons to expand functionality!"
      puts "   Use: exx build #{house_id} <addonType>"
    end
    
    puts
  end
  
  def list_neighborhood
    neighborhood = read_data(@neighborhood_file)
    houses = read_data(@houses_file)
    addons = read_data(@addons_file)
    
    puts "\n🏘️  #{neighborhood['name']}"
    puts '=' * 60
    
    if neighborhood['houses'].empty?
      puts "No houses in the neighborhood yet."
      puts "\nCreate your first house with: exx create <owner> [name]\n\n"
      return
    end
    
    neighborhood['houses'].each do |house_id|
      house = houses.find { |h| h['id'] == house_id }
      next unless house
      
      puts "\n🏠 #{house['name']}"
      puts "   Owner: #{house['owner']}"
      puts "   ID: #{house['id']}"
      puts "   Created: #{house['createdAt'].split('T')[0]}"
      
      house_addons = addons.select { |a| a['houseId'] == house_id }
      if house_addons.any?
        addon_names = house_addons.map { |a| a['name'] }
        puts "   🔨 Addons: #{addon_names.join(', ')}"
      else
        puts "   📦 Basic house (no addons yet)"
      end
      
      adjacent = neighborhood['adjacency'][house_id] || []
      if adjacent.any?
        neighbor_names = adjacent.map do |adj_id|
          adj_house = houses.find { |h| h['id'] == adj_id }
          adj_house ? adj_house['owner'] : 'Unknown'
        end
        puts "   👥 Neighbors: #{neighbor_names.join(', ')}"
      end
    end
    
    puts "\n#{'=' * 60}"
    puts "Total houses: #{neighborhood['houses'].length}"
    puts "Total addons: #{addons.length}\n\n"
  end
  
  def show_help
    puts <<~HELP

      EXX System - House & Addon Management (Ruby Implementation)

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

    HELP
  end
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  system = ExxFarmSystem.new
  command = ARGV[0] || 'help'
  
  begin
    case command
    when 'create'
      owner = ARGV[1]
      name = ARGV[2..-1].join(' ') if ARGV.length > 2
      system.create_house(owner, name)
      
    when 'build'
      house_id = ARGV[1]
      addon_type = ARGV[2]
      system.build_addon(house_id, addon_type)
      
    when 'addons'
      system.list_addon_types
      
    when 'show'
      house_id = ARGV[1]
      system.show_house(house_id)
      
    when 'neighborhood'
      system.list_neighborhood
      
    when 'help', '--help', '-h'
      system.show_help
      
    else
      puts "✗ Unknown command: #{command}"
      system.show_help
    end
  rescue StandardError => e
    puts "✗ Error: #{e.message}\n\n"
    exit 1
  end
end
