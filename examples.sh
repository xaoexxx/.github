#!/bin/bash
# Example usage scripts for EV CLI

echo "=== EV CLI Examples ==="
echo ""

echo "1. Creating an event:"
echo "   $ ./ev +e deployment"
./ev +e deployment
echo ""

echo "2. Querying events:"
echo "   $ ./ev ?deploy"
./ev ?deploy
echo ""

echo "3. Working with nodes:"
echo "   $ ./ev @production"
./ev @production
echo ""

echo "4. Starting a conversation:"
echo "   $ ./ev start build-chat @staging"
./ev start build-chat @staging
echo ""

echo "5. Complex operation (original example):"
echo "   $ ./ev +e ?xx(s) @node (runall) .repos"
./ev +e ?xx\(s\) @node \(runall\) .repos
echo ""

echo "6. Listing all nodes:"
echo "   $ ./ev nodes"
./ev nodes
echo ""

echo "=== Examples Complete ==="
echo "Try 'ev help' for more information"
