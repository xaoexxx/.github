# EV (Eventual) CLI

A terminal-based chat/messaging application where conversations make things happen. Think Signal meets command-line meets automation.

## Installation

```bash
npm install -g @xaoexxx/ev-cli
# or
chmod +x ev
./ev help
```

## Usage

The EV CLI uses a unique syntax for creating, managing, and executing conversations that can trigger actions.

### Basic Commands

```bash
# Show help
ev help

# Create/enable a new event
ev +e myevent

# Query conversations (with optional pattern)
ev ?xx
ev ?(s)          # Query all

# Target a specific node
ev @mynode

# Run all pending conversations
ev (runall)

# Scan and display repositories in scope
ev .repos

# List all nodes
ev nodes

# Start a new conversation
ev start chatname
ev start chatname @nodename

# Send a message
ev send <conversation-id> Hello world
```

### Combined Operations

The real power comes from chaining operations together:

```bash
# Create event, query instances, target node, run all, and scan repos
ev +e ?xx(s) @node (runall) .repos

# Create multiple events on a specific node
ev +e event1 +e event2 @production (runall)

# Query and execute on a node
ev ?pending @node1 (runall)
```

## Command Syntax

### `+e <name>` - Create Event
Creates or enables a new event/conversation.
```bash
ev +e deployment
ev +e testing
```

### `?<pattern>(s)` - Query
Lists conversations and events. Add `(s)` for plural/multiple instances.
```bash
ev ?xx         # Query items matching 'xx'
ev ?xx(s)      # Query multiple xx instances
ev ?           # Query all
```

### `@<node>` - Target Node
Specifies which node to operate on. Can be any identifier.
```bash
ev @production
ev @staging
ev @node1
```

### `(runall)` - Execute All
Runs all pending conversations on the current or specified node.
```bash
ev (runall)              # Run all on local
ev @production (runall)  # Run all on production node
```

### `.repos` - Repository Scanner
Scans the current scope for git repositories and displays them.
```bash
ev .repos
```

## How It Works

### Data Storage
All data is stored in `~/.ev/`:
- `conversations.json` - Active conversations and their messages
- `events.json` - Events and their current status
- `nodes.json` - Connected nodes and their state

### Conversations
Conversations are chat-like entities that can:
- Store messages
- Be assigned to specific nodes
- Have pending/executed states
- Trigger actions when run

### Nodes
Nodes represent different execution contexts:
- Servers
- Environments (dev/staging/production)
- Services
- Or any logical grouping you define

### Events
Events are actionable items that can be:
- Created and enabled
- Queried and filtered
- Executed individually or in bulk

## Example Workflows

### Deploy to Multiple Environments
```bash
# Create deployment events for multiple repos
ev +e deploy-api @production +e deploy-web @production .repos

# Check what's pending
ev ?deploy

# Execute all deployments
ev @production (runall)
```

### Monitor and Sync Repositories
```bash
# Scan repos and create sync events
ev .repos +e sync @backup

# Run sync on backup node
ev @backup (runall)
```

### Manage Multiple Instances
```bash
# Query all instances matching pattern
ev ?xx(s)

# Create new instance on specific node
ev +e xx-instance-1 @node1

# Run all instances
ev @node1 (runall)
```

## Advanced Usage

### Starting Conversations
```bash
# Start a conversation on local node
ev start deployment-chat

# Start a conversation on specific node
ev start deployment-chat @production
```

### Sending Messages
```bash
# First, get the conversation ID from query
ev ?deployment

# Send a message (use the ID from above)
ev send abc123 "Deployment completed successfully"
```

### Node Management
```bash
# List all nodes
ev nodes

# Connect to new nodes
ev @newnode
```

## Philosophy

EV is designed around the idea that conversations should be executable. By treating chat-like interactions as first-class automation primitives, you can:

1. **Coordinate**: Use conversations to coordinate actions across nodes
2. **Automate**: Chain commands to create complex automation workflows
3. **Track**: Keep a record of what happened and when
4. **Scale**: Manage multiple instances and environments easily

## Examples from Usage

The original example that inspired EV:
```bash
ev +e ?xx(s) @node (runall) .repos
```

This command:
1. `+e` - Creates a new event
2. `?xx(s)` - Queries for multiple instances matching 'xx'
3. `@node` - Targets the 'node' execution context
4. `(runall)` - Executes all pending items
5. `.repos` - Scans and pipes in repository data

## Contributing

This is a living project. The syntax and capabilities will evolve based on real-world usage.

## License

MIT
