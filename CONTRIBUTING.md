# Contributing to ArchBootstrap

Thanks for your interest! Here's how to contribute:

## Steps

1. **Fork** the repository
2. **Create a branch** for your changes
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
   - Edit scripts in the appropriate file
   - Keep changes focused and minimal
4. **Run shellcheck** to validate bash syntax
   ```bash
   shellcheck *.sh roles/*.sh
   ```
   - Install if needed: `pacman -S shellcheck`
5. **Test your changes** before submitting
6. **Commit** with clear messages
   ```bash
   git commit -m "Add description of change"
   ```
7. **Submit a pull request** with details about what changed and why

## Guidelines

- Keep scripts modular and focused
- Use consistent style (see existing scripts)
- Test on a fresh Arch install if possible
- Update README.md if adding new features
- Use descriptive commit messages

## Reporting Issues

Found a bug? Open an issue with:
- What happened
- Expected behavior
- Arch Linux version / system info
- Steps to reproduce

Thanks for helping improve ArchBootstrap!
