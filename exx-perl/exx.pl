#!/usr/bin/env perl

=head1 NAME

exx - House & Addon System (Perl Implementation)

=head1 SYNOPSIS

    exx create <owner> [name]        Create a new house
    exx build <houseId> <addonType>  Build an addon
    exx addons                       List available addon types
    exx show <houseId>               Show house details
    exx visit <visitor> <houseId>    Visit a house
    exx neighborhood                 List all houses
    exx help                         Show this help

=head1 DESCRIPTION

EXX system in Perl - Your EV CLI IS your house that stores all your data.
Expand it with addons for additional functionality.

=cut

use strict;
use warnings;
use JSON::PP;
use File::Path qw(make_path);
use File::Spec;
use File::HomeDir;
use Data::Dumper;
use Time::Piece;

package ExxFarmSystem;

sub new {
    my ($class) = @_;
    
    my $home_dir = File::HomeDir->my_home;
    my $data_dir = File::Spec->catdir($home_dir, '.ev');
    
    my $self = {
        data_dir => $data_dir,
        houses_file => File::Spec->catfile($data_dir, 'exx-houses.json'),
        addons_file => File::Spec->catfile($data_dir, 'exx-addons.json'),
        neighborhood_file => File::Spec->catfile($data_dir, 'exx-neighborhood.json'),
    };
    
    bless $self, $class;
    $self->initialize_storage();
    return $self;
}

sub initialize_storage {
    my ($self) = @_;
    
    make_path($self->{data_dir}) unless -d $self->{data_dir};
    
    unless (-f $self->{houses_file}) {
        $self->write_data($self->{houses_file}, []);
    }
    
    unless (-f $self->{addons_file}) {
        $self->write_data($self->{addons_file}, []);
    }
    
    unless (-f $self->{neighborhood_file}) {
        $self->write_data($self->{neighborhood_file}, {
            name => 'Valley Town',
            houses => [],
            adjacency => {}
        });
    }
}

sub read_data {
    my ($self, $file) = @_;
    
    return [] unless -f $file;
    
    open my $fh, '<', $file or die "Cannot read $file: $!";
    my $content = do { local $/; <$fh> };
    close $fh;
    
    return decode_json($content);
}

sub write_data {
    my ($self, $file, $data) = @_;
    
    open my $fh, '>', $file or die "Cannot write $file: $!";
    print $fh encode_json($data);
    close $fh;
}

sub get_addon_types {
    return {
        storage => {
            name => 'Storage Shed',
            description => 'Additional storage for logs, data, and archived conversations',
            provides => ['Extended log retention', 'Archive management', 'Data backup'],
            category => 'utility',
            icon => '📦'
        },
        workshop => {
            name => 'Workshop',
            description => 'Development and build environment for custom scripts',
            provides => ['Script editor', 'Build tools', 'Testing environment'],
            category => 'development',
            icon => '🔧'
        },
        greenhouse => {
            name => 'Greenhouse',
            description => 'Always-on task runner and automation hub',
            provides => ['Scheduled tasks', 'Cron jobs', 'Background processes'],
            category => 'automation',
            icon => '🌱'
        },
        barn => {
            name => 'Server Barn',
            description => 'Host multiple services and applications',
            provides => ['Service hosting', 'Container management', 'Load balancing'],
            category => 'infrastructure',
            icon => '🏛️'
        },
        coop => {
            name => 'Bot Coop',
            description => 'Manage and run multiple bots and agents',
            provides => ['Bot management', 'Agent orchestration', 'AI assistants'],
            category => 'automation',
            icon => '🐔'
        },
        marketplace => {
            name => 'Marketplace',
            description => 'Share and discover addons from other houses',
            provides => ['Addon marketplace', 'Community plugins', 'Shared scripts'],
            category => 'community',
            icon => '🏪'
        },
        observatory => {
            name => 'Observatory',
            description => 'Monitor and visualize your data and metrics',
            provides => ['Dashboard', 'Metrics visualization', 'Alert system'],
            category => 'monitoring',
            icon => '🔭'
        },
        library => {
            name => 'Library',
            description => 'Documentation and knowledge base storage',
            provides => ['Documentation', 'Knowledge base', 'Search system'],
            category => 'utility',
            icon => '📚'
        }
    };
}

sub create_house {
    my ($self, $owner, $name) = @_;
    
    die "Owner name is required\n" unless $owner;
    
    my $houses = $self->read_data($self->{houses_file});
    my $neighborhood = $self->read_data($self->{neighborhood_file});
    
    my $id = 'house-' . time();
    my $timestamp = localtime->datetime;
    
    my $house = {
        id => $id,
        owner => $owner,
        name => $name || "$owner's House",
        createdAt => $timestamp,
        storage => {
            conversations => [],
            events => [],
            nodes => [],
            logs => []
        },
        addons => [],
        stats => {
            totalRuns => 0,
            totalMessages => 0,
            lastActive => $timestamp
        },
        visitors => []
    };
    
    push @$houses, $house;
    $self->write_data($self->{houses_file}, $houses);
    
    # Add to neighborhood
    push @{$neighborhood->{houses}}, $id;
    $neighborhood->{adjacency}{$id} = [];
    
    # Create adjacency
    my @existing = @{$neighborhood->{houses}};
    pop @existing; # Remove the new house
    
    if (@existing) {
        my $adjacent_count = @existing > 2 ? 2 : scalar @existing;
        for (my $i = 0; $i < $adjacent_count; $i++) {
            my $adjacent_id = $existing[-1 - $i];
            push @{$neighborhood->{adjacency}{$id}}, $adjacent_id;
            
            $neighborhood->{adjacency}{$adjacent_id} ||= [];
            push @{$neighborhood->{adjacency}{$adjacent_id}}, $id
                unless grep { $_ eq $id } @{$neighborhood->{adjacency}{$adjacent_id}};
        }
    }
    
    $self->write_data($self->{neighborhood_file}, $neighborhood);
    
    print "\n🏠 Created $house->{name}!\n";
    print "   Owner: $owner\n";
    print "   House ID: $id\n";
    print "   This house will store all your EV CLI data, logs, and runs\n";
    print "   You can expand it with addons for extra functionality!\n\n";
    
    return $house;
}

sub build_addon {
    my ($self, $house_id, $addon_type) = @_;
    
    die "House ID and addon type are required\n" unless $house_id && $addon_type;
    
    my $addon_types = $self->get_addon_types();
    die "Invalid addon type: $addon_type\n" unless exists $addon_types->{$addon_type};
    
    my $houses = $self->read_data($self->{houses_file});
    my ($house) = grep { $_->{id} eq $house_id } @$houses;
    die "House not found: $house_id\n" unless $house;
    
    my $addons = $self->read_data($self->{addons_file});
    my $type_info = $addon_types->{$addon_type};
    
    my $addon = {
        id => 'addon-' . time(),
        houseId => $house_id,
        type => $addon_type,
        name => $type_info->{name},
        description => $type_info->{description},
        category => $type_info->{category},
        provides => $type_info->{provides},
        icon => $type_info->{icon},
        data => {},
        config => {},
        builtAt => localtime->datetime,
        active => JSON::PP::true
    };
    
    push @$addons, $addon;
    $self->write_data($self->{addons_file}, $addons);
    
    push @{$house->{addons}}, $addon->{id};
    $self->write_data($self->{houses_file}, $houses);
    
    print "\n🔨 Built $addon->{name} for $house->{name}!\n";
    print "   Addon ID: $addon->{id}\n";
    print "   Category: $addon->{category}\n";
    print "   Provides: " . join(', ', @{$addon->{provides}}) . "\n";
    print "\n   Your house is now expanded with $addon->{name}!\n\n";
    
    return $addon;
}

sub list_addon_types {
    my ($self) = @_;
    
    my $addon_types = $self->get_addon_types();
    
    print "\n🔨 Available Addon Types:\n";
    print "=" x 70 . "\n";
    
    # Group by category
    my %categories;
    for my $key (keys %$addon_types) {
        my $type = $addon_types->{$key};
        push @{$categories{$type->{category}}}, { key => $key, %$type };
    }
    
    for my $category (sort keys %categories) {
        print "\n📁 " . uc($category) . "\n";
        for my $addon (@{$categories{$category}}) {
            print "\n   $addon->{icon} $addon->{name} ($addon->{key})\n";
            print "   $addon->{description}\n";
            print "   Provides: " . join(', ', @{$addon->{provides}}) . "\n";
        }
    }
    
    print "\n" . ("=" x 70) . "\n";
    print "\nUse: exx build <houseId> <addonType>\n\n";
}

sub show_house {
    my ($self, $house_id) = @_;
    
    die "House ID is required\n" unless $house_id;
    
    my $houses = $self->read_data($self->{houses_file});
    my ($house) = grep { $_->{id} eq $house_id } @$houses;
    die "House not found: $house_id\n" unless $house;
    
    my $addons = $self->read_data($self->{addons_file});
    my @house_addons = grep { $_->{houseId} eq $house_id } @$addons;
    
    print "\n🏠 $house->{name}\n";
    print "=" x 60 . "\n";
    print "Owner: $house->{owner}\n";
    print "ID: $house->{id}\n";
    print "Created: $house->{createdAt}\n";
    
    print "\n📊 Stats:\n";
    print "   Total Runs: $house->{stats}{totalRuns}\n";
    print "   Total Messages: $house->{stats}{totalMessages}\n";
    print "   Last Active: $house->{stats}{lastActive}\n";
    
    print "\n💾 Storage:\n";
    print "   Conversations: " . scalar(@{$house->{storage}{conversations}}) . "\n";
    print "   Events: " . scalar(@{$house->{storage}{events}}) . "\n";
    print "   Nodes: " . scalar(@{$house->{storage}{nodes}}) . "\n";
    print "   Logs: " . scalar(@{$house->{storage}{logs}}) . "\n";
    
    if (@house_addons) {
        print "\n🔨 Addons (" . scalar(@house_addons) . "):\n";
        for my $addon (@house_addons) {
            print "\n   $addon->{icon} $addon->{name}\n";
            print "   └─ ID: $addon->{id}\n";
            print "   └─ Category: $addon->{category}\n";
            print "   └─ Provides: " . join(', ', @{$addon->{provides}}) . "\n";
            print "   └─ Status: " . ($addon->{active} ? '✓ Active' : '✗ Inactive') . "\n";
        }
    } else {
        print "\n🔨 No addons yet\n";
        print "   Add addons to expand functionality!\n";
        print "   Use: exx build $house_id <addonType>\n";
    }
    
    print "\n";
}

sub list_neighborhood {
    my ($self) = @_;
    
    my $neighborhood = $self->read_data($self->{neighborhood_file});
    my $houses = $self->read_data($self->{houses_file});
    my $addons = $self->read_data($self->{addons_file});
    
    print "\n🏘️  $neighborhood->{name}\n";
    print "=" x 60 . "\n";
    
    unless (@{$neighborhood->{houses}}) {
        print "No houses in the neighborhood yet.\n";
        print "\nCreate your first house with: exx create <owner> [name]\n\n";
        return;
    }
    
    for my $house_id (@{$neighborhood->{houses}}) {
        my ($house) = grep { $_->{id} eq $house_id } @$houses;
        next unless $house;
        
        print "\n🏠 $house->{name}\n";
        print "   Owner: $house->{owner}\n";
        print "   ID: $house->{id}\n";
        print "   Created: " . (split('T', $house->{createdAt}))[0] . "\n";
        
        my @house_addons = grep { $_->{houseId} eq $house_id } @$addons;
        if (@house_addons) {
            print "   🔨 Addons: " . join(', ', map { $_->{name} } @house_addons) . "\n";
        } else {
            print "   📦 Basic house (no addons yet)\n";
        }
        
        my $adjacent = $neighborhood->{adjacency}{$house_id} || [];
        if (@$adjacent) {
            my @neighbor_names = map {
                my $adj_id = $_;
                my ($adj_house) = grep { $_->{id} eq $adj_id } @$houses;
                $adj_house ? $adj_house->{owner} : 'Unknown';
            } @$adjacent;
            print "   👥 Neighbors: " . join(', ', @neighbor_names) . "\n";
        }
    }
    
    print "\n" . ("=" x 60) . "\n";
    print "Total houses: " . scalar(@{$neighborhood->{houses}}) . "\n";
    print "Total addons: " . scalar(@$addons) . "\n\n";
}

sub show_help {
    print <<'HELP';

EXX System - House & Addon Management (Perl Implementation)

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
}

package main;

my $system = ExxFarmSystem->new();
my $command = shift @ARGV || 'help';

if ($command eq 'create') {
    my $owner = shift @ARGV;
    my $name = join(' ', @ARGV);
    $system->create_house($owner, $name || undef);
}
elsif ($command eq 'build') {
    my $house_id = shift @ARGV;
    my $addon_type = shift @ARGV;
    $system->build_addon($house_id, $addon_type);
}
elsif ($command eq 'addons') {
    $system->list_addon_types();
}
elsif ($command eq 'show') {
    my $house_id = shift @ARGV;
    $system->show_house($house_id);
}
elsif ($command eq 'neighborhood') {
    $system->list_neighborhood();
}
elsif ($command eq 'help' || $command eq '--help' || $command eq '-h') {
    $system->show_help();
}
else {
    print "✗ Unknown command: $command\n";
    $system->show_help();
}
