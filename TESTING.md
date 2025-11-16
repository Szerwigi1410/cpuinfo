# Testing cpuinfo.sh

This document describes the automated testing setup for `cpuinfo.sh` across multiple platforms.

## Supported Platforms

The automated tests verify that `cpuinfo.sh` works on:

1. **Ubuntu** (latest LTS)
2. **ArchLinux** (latest)

## Test Coverage

The automated tests simply verify that the script executes without errors on both platforms.

## Running Tests

### Automated Testing (GitHub Actions)

Tests run automatically on:
- Push to `main`, `master`, or any `copilot/**` branch
- Pull requests to `main` or `master` branches
- Manual workflow dispatch

To manually trigger tests:
1. Go to the Actions tab in GitHub
2. Select "Test cpuinfo.sh" workflow
3. Click "Run workflow"

### Manual Testing

#### On Ubuntu:
```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y util-linux

# Run the script
./cpuinfo.sh
```

#### On ArchLinux:
```bash
# Install dependencies
sudo pacman -Syu
sudo pacman -S util-linux

# Run the script
./cpuinfo.sh
```

## Dependencies

Both platforms require:
- `util-linux` package (provides `lscpu` command)
- `bash` shell
