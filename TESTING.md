# Testing cpuinfo.sh

This document describes the automated testing setup for `cpuinfo.sh` across multiple platforms.

## Supported Platforms

The automated tests verify that `cpuinfo.sh` works correctly on:

1. **Ubuntu** (latest LTS)
2. **ArchLinux** (latest)

## Test Coverage

The automated tests verify the following functionality:

### Basic Functionality
- ✓ Script executes without errors
- ✓ Script detects and displays OS information
- ✓ Script detects and displays CPU brand (Intel, AMD, ARM, etc.)
- ✓ Script displays core count
- ✓ Script displays thread count
- ✓ Script displays cache information (L1, L2, L3)

### Feature Testing
- ✓ `-a` flag works to override ASCII art brand
- ✓ Configuration file is created at `~/.config/cpuinfo/config`
- ✓ lscpu dependency is properly detected

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

# Test with override flag
./cpuinfo.sh -a intel
./cpuinfo.sh -a amd
```

#### On ArchLinux:
```bash
# Install dependencies
sudo pacman -Syu
sudo pacman -S util-linux

# Run the script
./cpuinfo.sh

# Test with override flag
./cpuinfo.sh -a powerpc
./cpuinfo.sh -a arm
```

## Test Results

The workflow verifies that the output contains:
- OS information line starting with "OS:"
- CPU brand line starting with "Brand:"
- Core count line starting with "Cores:"
- Thread count line starting with "Threads:"

If any of these checks fail, the test will fail and report which check failed.

## Dependencies

Both platforms require:
- `util-linux` package (provides `lscpu` command)
- `bash` shell
- `grep`, `awk`, `sed` (typically pre-installed)

## Configuration

The script creates a config file at `~/.config/cpuinfo/config` with default color settings:
```
COLOR_NAME=WHITE
SECOND_COLOR_NAME=BLUE
```

These can be customized by editing the config file. Available colors:
- RED, GREEN, BLUE, CYAN, WHITE, YELLOW, PURPLE, BLACK, GRAY
