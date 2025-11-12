# Contributing to deriv_explore_markets

Thank you for considering contributing to deriv_explore_markets! This document outlines the guidelines for contributing to this project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:
- A clear title and description
- Steps to reproduce the issue
- Expected vs actual behavior
- Your environment (Dart/Flutter version, OS, etc.)
- Any relevant code samples or screenshots

### Suggesting Enhancements

Enhancement suggestions are welcome! Please create an issue with:
- A clear title and description
- Use cases for the enhancement
- Potential implementation approach (optional)

### Pull Requests

1. **Fork** the repository
2. **Create a branch** from `main` for your changes
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** following the coding standards below
4. **Write tests** for your changes
5. **Ensure all tests pass**
   ```bash
   flutter test
   ```
6. **Run the analyzer** and fix any issues
   ```bash
   flutter analyze
   ```
7. **Format your code**
   ```bash
   dart format .
   ```
8. **Commit your changes** with a descriptive message
   ```bash
   git commit -m "feat: add new feature X"
   ```
9. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```
10. **Create a Pull Request** with a clear description

## Coding Standards

### Dart Code Style

- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `very_good_analysis` lint rules (already configured)
- Maintain 80-character line length where reasonable
- Use meaningful variable and function names
- Add dartdoc comments for all public APIs

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(widgets): add custom loading indicator support
fix(service): resolve websocket reconnection issue
docs(readme): update installation instructions
```

## Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/ahrar-deriv/deriv_explore_markets.git
   cd deriv_explore_markets
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run tests**
   ```bash
   flutter test
   ```

4. **Run the example app**
   ```bash
   cd example
   flutter run
   ```

## Testing Guidelines

- Write unit tests for all new functionality
- Maintain or improve code coverage
- Use `mocktail` for mocking dependencies
- Test both success and error scenarios
- Write widget tests for UI components

## Documentation

- Add dartdoc comments to all public APIs
- Include code examples in documentation
- Update README.md if adding new features
- Update CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/)

## Review Process

- All PRs require review before merging
- Address review feedback promptly
- Keep PRs focused and reasonably sized
- Ensure CI checks pass

## Questions?

Feel free to create an issue for any questions about contributing!

---

Thank you for contributing to deriv_explore_markets! 🎉

