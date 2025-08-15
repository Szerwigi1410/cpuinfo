# cpuinfo

![logo](photos/CPUinfo-logo.png)

---

## Overview
`cpuinfo` is a Bash script that provides a colorful and detailed overview of your CPU using `lscpu`. It shows system information alongside fun ASCII art based on your CPU brand.  

Created by the creator of [Brokefetch](https://github.com/Szerwigi1410/brokefetch).

It supports CPUs from **Intel, AMD, PowerPC, ARM, Snapdragon**, and has a default “funny” fallback if the brand is unrecognized.

---

## Features
- Detects CPU brand, model, cores, threads, and frequency
- Shows CPU cache (L1, L2, L3)
- OS name and version
- Architecture info
- Supports custom color configuration
- Fun, brand-specific ASCII art
- Lightweight and fast

---

## Installation

1. Clone the repository:

```bash
git clone https://github.com/Szerwigi1410/cpuinfo.git
cd cpuinfo
chomd +x cpuinfo.sh
./cpuinfo.sh
```
**Note:** lscpu must be installed for cpuinfo to work. See the Error Codes section below if it's missing.

---

## Configuration

By default, a configuration file is created at:
```
~/.config/cpuinfo/config
```