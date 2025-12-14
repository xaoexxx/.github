# Getting Started with xx

Welcome to the **xx eventual movement** ecosystem! This guide will help you understand and start working with the xx system.

## What is xx?

**xx** is a comprehensive family of libraries, packages, and data structures that provides:

- 🔒 **Maximum Security**: Enterprise-grade security built-in
- 🤖 **AI-Powered Intelligence**: Pre-organizing, prediction, and smart execution
- ⚡ **Terminal-Like Performance**: Self-contained, fast, and efficient
- 📦 **Modular Design**: Clean abstractions with cross-repository references
- 🎯 **100% EMS**: Pure ECMAScript Modules for maximum compatibility

## Quick Start

### Prerequisites

- Node.js >= 18.0.0
- Validated user account (currently: Oktay, Rasmus)
- Access to organizational repositories

### Installation

Since xx spans multiple repositories, installation depends on which components you need:

```bash
# Core system
npm install @xx/core

# Data controllers
npm install @xx/controllers

# Security features
npm install @xx/security

# AI capabilities
npm install @xx/ai

# Terminal interface
npm install @xx/terminal

# Module system
npm install @xx/modules
```

Or install everything:

```bash
npm install @xx/core @xx/controllers @xx/security @xx/ai @xx/terminal @xx/modules
```

### Basic Usage

```javascript
// Import core xx functionality
import { Core } from '@xx/core';
import { Security } from '@xx/security';
import { AI } from '@xx/ai';

// Initialize xx with maximum security
const xx = new Core({
  security: 'maximum',
  ai: { enabled: true },
  user: 'oktay'
});

// Set up security
const security = new Security({
  validatedUsers: ['oktay', 'rasmus']
});

// Initialize AI capabilities
const ai = new AI({
  model: 'xx-predictor-v1',
  learning: true
});

// Initialize the system
await xx.initialize();

// Execute with AI pre-organization
const data = { /* your data */ };
const organized = await ai.organize(data);
const result = await xx.execute(organized);

console.log('Execution complete:', result);
```

## Core Concepts

### 1. EMS-First Architecture

All xx code uses ECMAScript Modules:

```javascript
// ✅ Correct - EMS
import { module } from '@xx/package';
export const feature = () => {};

// ❌ Wrong - CommonJS (not used in xx)
const { module } = require('@xx/package');
module.exports = feature;
```

### 2. Validated User Access

Every operation requires validated user:

```javascript
import { Security } from '@xx/security';

const security = new Security();

// Validate user before operations
await security.validateUser('oktay');

// Check permissions
const canExecute = await security.can('oktay', 'execute', 'module');
```

### 3. AI-Powered Operations

xx leverages AI for intelligent operations:

```javascript
import { AI } from '@xx/ai';

const ai = new AI();

// Pre-organize data intelligently
const organized = await ai.organize(rawData);

// Predict next operations
const prediction = await ai.predict(context);

// Auto-execute based on predictions
await ai.autoExecute(prediction);
```

### 4. Cross-Repository Module References

Reference modules from any organizational repository:

```javascript
import { ModuleRegistry } from '@xx/modules';

const registry = new ModuleRegistry();

// Reference module from another repo
const utils = await registry.loadFrom('xaoexxx/utilities', 'src/utils.js');

// Use the module
const result = utils.process(data);
```

## Project Structure

When creating an xx-based project:

```
my-xx-project/
├── src/
│   ├── index.js              # Main entry (EMS)
│   ├── controllers/          # Data controllers
│   │   └── data-controller.js
│   ├── modules/              # Local modules
│   │   └── processor.js
│   └── config/               # Configuration
│       └── xx.config.js
├── tests/
│   └── *.test.js             # Tests
├── .xx/                      # xx system config
│   ├── manifest.json         # Module manifest
│   └── permissions.json      # User permissions
├── package.json              # Must have "type": "module"
└── README.md
```

### package.json Configuration

```json
{
  "name": "my-xx-project",
  "version": "1.0.0",
  "type": "module",
  "exports": {
    ".": "./src/index.js"
  },
  "dependencies": {
    "@xx/core": "^1.0.0",
    "@xx/security": "^1.0.0",
    "@xx/ai": "^1.0.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
```

### xx.config.js

```javascript
export default {
  // xx configuration
  version: '1.0.0',
  security: {
    level: 'maximum',
    validatedUsers: ['oktay', 'rasmus']
  },
  ai: {
    enabled: true,
    model: 'xx-predictor-v1'
  },
  modules: {
    registry: {
      // Cross-repo module references
      utilities: 'xaoexxx/utilities/src/utils.js',
      helpers: 'xaoexxx/helpers/src/index.js'
    }
  }
};
```

## Development Workflow

### For Oktay (Owner)

1. **Create or modify** any component
2. **Test** in development environment
3. **Review** security implications
4. **Deploy** to production when ready
5. **Monitor** performance and security

### For Rasmus (Learning Phase)

1. **Study** existing xx code and documentation
2. **Create** new features in approved repositories
3. **Test** thoroughly in development environment
4. **Submit** for review by Oktay
5. **Learn** from review feedback
6. **Iterate** until approved

## Common Patterns

### Pattern 1: Secure Data Processing

```javascript
import { Core } from '@xx/core';
import { Security } from '@xx/security';
import { Controller } from '@xx/controllers';

class SecureProcessor extends Controller {
  constructor(user) {
    super();
    this.security = new Security();
    this.user = user;
  }
  
  async process(data) {
    // Validate user
    await this.security.validateUser(this.user);
    
    // Check permissions
    if (!await this.security.can(this.user, 'process', 'data')) {
      throw new Error('Permission denied');
    }
    
    // Process with AI
    const organized = await this.ai.organize(data);
    return await this.transform(organized);
  }
}
```

### Pattern 2: AI-Enhanced Execution

```javascript
import { AI } from '@xx/ai';
import { Core } from '@xx/core';

const ai = new AI({ learning: true });
const xx = new Core({ ai });

// Let AI predict optimal execution path
const context = { operation: 'transform', data: inputData };
const prediction = await ai.predict(context);

// Execute based on prediction
const result = await xx.execute(prediction.suggestedPath);
```

### Pattern 3: Terminal-Like Interface

```javascript
import { Terminal } from '@xx/terminal';

const terminal = new Terminal();

// Define command
terminal.command('process', async (args) => {
  await terminal.log('Processing with maximum security...');
  
  const result = await processData(args.input);
  
  await terminal.success(`Processed ${result.count} items`);
  return result;
});

// Run terminal
await terminal.run();
```

## Testing

All xx code should include tests:

```javascript
import { describe, it, expect } from 'vitest';
import { Core } from '@xx/core';

describe('xx Core', () => {
  it('should initialize with maximum security', async () => {
    const xx = new Core({ security: 'maximum' });
    await xx.initialize();
    
    expect(xx.security.level).toBe('maximum');
    expect(xx.isInitialized).toBe(true);
  });
  
  it('should validate users correctly', async () => {
    const xx = new Core({ security: 'maximum' });
    await xx.initialize();
    
    const isValid = await xx.security.validateUser('oktay');
    expect(isValid).toBe(true);
  });
});
```

## Best Practices

1. **Always use EMS**: Pure ES modules, no CommonJS
2. **Validate users first**: Check permissions before operations
3. **Leverage AI**: Use AI for pre-organizing and prediction
4. **Maximum security**: Never compromise on security
5. **Self-contained**: Keep components independent
6. **Cross-repo references**: Reuse code across repositories
7. **Document everything**: Clear documentation for all modules
8. **Test thoroughly**: Comprehensive test coverage

## Troubleshooting

### Issue: Module not found

```javascript
// Make sure package.json has "type": "module"
{
  "type": "module"
}

// Use .js extensions in imports
import { Core } from '@xx/core/index.js';
```

### Issue: Permission denied

```javascript
// Ensure user is validated
const security = new Security();
await security.validateUser(currentUser);

// Check user has required permissions
const canExecute = await security.can(currentUser, 'execute', 'resource');
```

### Issue: AI not responding

```javascript
// Ensure AI is initialized
const ai = new AI({ enabled: true });
await ai.initialize();

// Check model is loaded
console.log('Model loaded:', ai.model.isLoaded);
```

## Next Steps

1. **Read Architecture Documentation**: `/docs/XX_ARCHITECTURE.md`
2. **Explore Libraries**: `/docs/XX_LIBRARIES.md`
3. **Understand Security**: `/docs/XX_SECURITY.md`
4. **Start Building**: Create your first xx module

## Support

- **Primary Contact**: Oktay (Owner)
- **Learning Support**: Available for Rasmus
- **Documentation**: All docs in `/docs` directory
- **Repository**: https://github.com/xaoexxx

---

Welcome to the **xx eventual movement**! Build with maximum security, AI intelligence, and pure EMS. 🚀
