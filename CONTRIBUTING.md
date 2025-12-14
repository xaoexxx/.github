# Contributing to EXX

Thank you for your interest in contributing to EXX! This document provides guidelines for contributing to this Free and Open Source Software (FOSS) project.

## Code of Conduct

Be respectful, inclusive, and constructive in all interactions.

## How to Contribute

### Reporting Issues

- Use the GitHub issue tracker
- Provide detailed descriptions
- Include steps to reproduce bugs
- Specify your environment (OS, language version, etc.)

### Submitting Changes

1. **Fork the Repository**
   ```bash
   git clone https://github.com/xaevex/.github.git
   cd .github
   ```

2. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Your Changes**
   - Follow the existing code style
   - Add tests if applicable
   - Update documentation

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "Description of changes"
   ```

5. **Push and Create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Development Setup

### Node.js/React Implementation
```bash
cd exx-nodejs-react/server
npm install
npm start

cd ../client
npm install
npm run dev
```

### Python/Cython Implementation
```bash
cd exx-cython
pip install cython
python setup.py build_ext --inplace
python exx_system.py help
```

### Perl Implementation
```bash
cd exx-perl
cpan JSON::PP File::HomeDir
perl exx.pl help
```

### PHP Implementation
```bash
cd exx-php
php exx.php help
```

### Ruby Implementation
```bash
cd exx-ruby
ruby exx.rb help
```

### Swift/Xcode Implementation
```bash
cd exx-swift-xcode
swift build
.build/debug/exx help
```

## Docker Development

```bash
cd docker
docker-compose up -d
docker exec -it exx-multi bash
```

## Testing

Each implementation should be tested before submitting:

```bash
# Test creating a house
./exx create TestUser "Test House"

# Test building an addon
./exx build <house-id> workshop

# Test listing
./exx neighborhood
```

## Documentation

- Update README files for significant changes
- Add inline comments for complex logic
- Update EXX-README.md for user-facing features

## Code Style

### Node.js/JavaScript
- Use ES6+ features
- Use `const` and `let`, avoid `var`
- 2-space indentation
- Semicolons optional but consistent

### Python/Cython
- Follow PEP 8
- Type hints encouraged
- 4-space indentation

### Perl
- Use `strict` and `warnings`
- POD documentation for modules

### PHP
- PSR-12 coding standard
- Type declarations encouraged

### Ruby
- Follow Ruby Style Guide
- 2-space indentation

### Swift
- Follow Swift API Design Guidelines
- Use SwiftLint if available

## Adding New Features

### New Addon Types

1. Add to addon types definition in all implementations
2. Document the addon in EXX-README.md
3. Test with all implementations

### New Commands

1. Add command handling in CLI
2. Add API endpoint (for Node.js version)
3. Update help text
4. Update documentation

## Multi-Language Consistency

When making changes, ensure consistency across all implementations:

- JavaScript (Node.js)
- Python (Cython)
- Perl
- PHP  
- Ruby
- Swift

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Open an issue for questions about contributing!

## Recognition

Contributors will be acknowledged in the project README.

---

Thank you for contributing to EXX! 🏠🔨
