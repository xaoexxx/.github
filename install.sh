#!/bin/bash
# Installation script for EV CLI

echo "🚀 Installing EV (Eventual) CLI..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    echo "   Visit: https://nodejs.org/"
    exit 1
fi

# Make ev executable
chmod +x ev

# Check if npm is available for global install
if command -v npm &> /dev/null; then
    echo "📦 Installing globally via npm..."
    npm link
    echo "✅ EV CLI installed! Try: ev help"
else
    # Manual installation
    echo "📋 Manual installation:"
    echo "   1. Add this directory to your PATH, or"
    echo "   2. Create a symlink: ln -s $(pwd)/ev /usr/local/bin/ev"
    echo "   3. Run: ./ev help"
fi

echo ""
echo "📖 Quick start:"
echo "   ev help                          # Show help"
echo "   ev +e myevent                    # Create an event"
echo "   ev +e ?xx(s) @node (runall) .repos  # Complex operation"
echo ""
echo "📚 Full documentation: See EV-README.md"
