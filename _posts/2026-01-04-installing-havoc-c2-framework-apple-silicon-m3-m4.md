---
title: "Installing Havoc C2 Framework on Apple Silicon (M3/M4 Max) Kali Linux"
date: 2026-01-04 01:00:00 +0000
categories: [Security, Tools]
tags: [havoc, c2, kali, apple-silicon, m3, m4, arm64, python, qt, penetration-testing, red-team]
pin: false
math: false
mermaid: false
---

## Overview

Havoc is a modern post-exploitation Command & Control (C2) framework similar to Cobalt Strike, designed for red team operations and penetration testing. However, installing it on Apple Silicon (M3/M4 Max) running Kali Linux ARM64 presents unique challenges due to library conflicts and architecture-specific issues.

In this guide, you'll learn:
- How to successfully install Havoc C2 on ARM64 Kali Linux
- Solutions to Python 3.13/3.10 compatibility issues
- Fixing Anaconda library conflicts
- Resolving Qt version mismatches
- Proper configuration for Apple Silicon architecture

**What is Havoc?** A Command & Control framework for authorized penetration testing, red team operations, and security research. Think Cobalt Strike, but open-source.

---

## Prerequisites

**Hardware:**
- MacBook Pro with M3/M4/M3 Max/M4 Max chip
- 8GB+ RAM allocated to VM (18GB recommended)

**Software:**
- Kali Linux ARM64 (latest version)
- Terminal access
- sudo privileges

**Knowledge:**
- Basic Linux command line
- Understanding of C2 frameworks (helpful but not required)

⚠️ **Legal Notice:** Only use Havoc on systems you own or have explicit written authorization to test. Unauthorized access is illegal.

---

## The Problem: Why Standard Installation Fails

When following the official Havoc installation guide on Apple Silicon Kali Linux, you'll encounter three critical issues:

1. **Python 3.13 incompatibility** - Havoc requires Python 3.10, but Kali ships with 3.13
2. **Anaconda library conflicts** - Old libstdc++ from Anaconda breaks compilation
3. **Qt version mismatch** - Binary links to Anaconda's Qt 5.15.2 instead of system Qt 5.15.17

Let's fix all of these.

---

## Step 1: Install System Dependencies

First, install the required packages:

```bash
sudo apt update
sudo apt install -y git build-essential apt-utils cmake libfontconfig1 \
    libglu1-mesa-dev libgtest-dev libspdlog-dev libboost-all-dev \
    libncurses5-dev libgdbm-dev libssl-dev libreadline-dev libffi-dev \
    libsqlite3-dev libbz2-dev mesa-common-dev qtbase5-dev qtchooser \
    qt5-qmake qtbase5-dev-tools libqt5websockets5 libqt5websockets5-dev \
    qtdeclarative5-dev golang-go nasm mingw-w64
```

**Why these packages?**
- Qt5 packages: GUI framework for the client
- Boost libraries: C++ dependencies
- mingw-w64: Cross-compiler for Windows payloads
- golang-go: Required for teamserver
- nasm: Assembler for payload generation

---

## Step 2: Clone Havoc Repository

```bash
cd ~/Documents/Apps/
git clone https://github.com/HavocFramework/Havoc.git
cd Havoc
```

**Expected output:**
```
Cloning into 'Havoc'...
remote: Enumerating objects: 12345, done.
remote: Total 12345 (delta 0), reused 0 (delta 0), pack-reused 12345
Receiving objects: 100% (12345/12345), 15.23 MiB | 8.45 MiB/s, done.
```

---

## Step 3: Fix Python 3.10 Requirement

### The Problem

Havoc's CMakeLists.txt specifically requires Python 3.10:

```cmake
set( Python_ADDITIONAL_VERSIONS 3.10 )
```

Kali Linux 2025+ ships with Python 3.13, which causes build failures:

```
/usr/bin/ld: /usr/lib/aarch64-linux-gnu/libpython3.13.so: undefined reference to `XML_SetAllocTrackerActivationThreshold'
```

### The Solution: Install Python 3.10 via pyenv

**Create installation script:**

```bash
cd ~/Documents/Apps/Havoc
cat > install-python310.sh << 'EOF'
#!/bin/bash

echo "[*] Installing pyenv and Python 3.10 for Havoc"

# Install pyenv dependencies
sudo apt install -y make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
libffi-dev liblzma-dev

# Install pyenv
if [ ! -d "$HOME/.pyenv" ]; then
    echo "[*] Installing pyenv..."
    curl https://pyenv.run | bash
fi

# Setup pyenv environment
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Install Python 3.10.14
echo "[*] Installing Python 3.10.14..."
pyenv install 3.10.14 -s

# Set as local version for Havoc
pyenv local 3.10.14

echo "[*] Python 3.10 installation complete!"
python3 --version
EOF

chmod +x install-python310.sh
```

**Run the installer:**

```bash
./install-python310.sh
```

**Add pyenv to shell config:**

For **zsh** (Kali default):

```bash
cat >> ~/.zshrc << 'EOF'

# Pyenv for Python version management
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
eval "$(pyenv virtualenv-init -)"
EOF

source ~/.zshrc
```

For **bash**:

```bash
cat >> ~/.bashrc << 'EOF'

# Pyenv for Python version management
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
eval "$(pyenv virtualenv-init -)"
EOF

source ~/.bashrc
```

**Verify Python 3.10:**

```bash
cd ~/Documents/Apps/Havoc
python3 --version
```

**Expected output:**
```
Python 3.10.14
```

---

## Step 4: Create Build Script (Anaconda-Safe)

### The Problem

If you have Anaconda installed, CMake will find Anaconda's libraries first:
- Old libstdc++ (GLIBCXX 3.4.29 vs required 3.4.32)
- Old Qt 5.15.2 (vs system Qt 5.15.17)

This causes runtime errors:

```
Cannot mix incompatible Qt library (5.15.2) with this library (5.15.17)
```

### The Solution: Force System Libraries

**Create build script:**

```bash
cat > build-havoc-client.sh << 'EOF'
#!/bin/bash

echo "[*] Building Havoc Client with Python 3.10 and System Qt"

# Exclude Anaconda from PATH
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Initialize pyenv AFTER setting clean PATH
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Get Python 3.10 paths
PYTHON310_BIN=$(pyenv which python3)
PYTHON310_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")

if [ "$PYTHON310_VERSION" != "3.10" ]; then
    echo "[!] Error: Python 3.10 not found!"
    exit 1
fi

PYTHON310_INCLUDE=$(python3 -c "from sysconfig import get_paths; print(get_paths()['include'])")
PYTHON310_LIB=$(python3 -c "from sysconfig import get_config_var; print(get_config_var('LIBDIR'))")/libpython3.10.so

# Force system Qt5
QT5_DIR="/usr/lib/aarch64-linux-gnu/cmake/Qt5"

echo "[*] Using Python: $PYTHON310_BIN"
echo "[*] Qt5 directory: $QT5_DIR"

# Clean previous build
make client-cleanup

# Update submodules
git submodule update --init --recursive

# Create build directory
mkdir -p client/Build
cd client/Build

# Configure with CMake
cmake -DPYTHON_EXECUTABLE="$PYTHON310_BIN" \
      -DPYTHON_INCLUDE_DIR="$PYTHON310_INCLUDE" \
      -DPYTHON_LIBRARY="$PYTHON310_LIB" \
      -DPython3_EXECUTABLE="$PYTHON310_BIN" \
      -DPython3_INCLUDE_DIR="$PYTHON310_INCLUDE" \
      -DPython3_LIBRARY="$PYTHON310_LIB" \
      -DQt5_DIR="$QT5_DIR" \
      -DCMAKE_PREFIX_PATH="/usr/lib/aarch64-linux-gnu/cmake" \
      ..

# Build
cmake --build . -- -j 4

if [ $? -eq 0 ]; then
    echo "[*] Build successful!"
    echo "[*] Verifying Qt libraries..."
    ldd ../Havoc | grep libQt5Core

    cd ../..
    if [ ! -d "client/Modules" ]; then
        git clone https://github.com/HavocFramework/Modules client/Modules --single-branch --branch main
    fi
fi
EOF

chmod +x build-havoc-client.sh
```

**Run the build:**

```bash
./build-havoc-client.sh
```

**Expected output:**

```
[*] Build successful!
[*] Verifying Qt libraries...
	libQt5Core.so.5 => /usr/lib/aarch64-linux-gnu/libQt5Core.so.5 ✓
```

❌ **Bad output (Anaconda conflict):**
```
	libQt5Core.so.5 => /home/kali/anaconda3/lib/libQt5Core.so.5 ✗
```

---

## Step 5: Build Teamserver

The teamserver is written in Go and compiles easily:

```bash
make ts-build
```

**Expected output:**

```
[*] building teamserver
[*] Installing musl compiler...
[*] Building teamserver binary...
```

This creates the `havoc` binary (teamserver).

---

## Step 6: Create Launcher Scripts

### The Problem

Even with correct compilation, running the client directly picks up Anaconda libraries at runtime.

### The Solution: Environment Override Scripts

**Create client launcher:**

```bash
cat > start-client.sh << 'EOF'
#!/bin/bash

cd "$(dirname "$0")"

# Override library paths to exclude Anaconda
export LD_LIBRARY_PATH="/usr/lib/aarch64-linux-gnu:/usr/lib:/lib/aarch64-linux-gnu:/lib"
export QT_PLUGIN_PATH="/usr/lib/aarch64-linux-gnu/qt5/plugins"
export QT_QPA_PLATFORM_PLUGIN_PATH="/usr/lib/aarch64-linux-gnu/qt5/plugins/platforms"

# Remove Anaconda Qt variables
unset QTDIR
unset QT_HOME

# Initialize pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
eval "$(pyenv init -)"

echo "Starting Havoc Client..."
echo "Python: $(python3 --version)"

./client/Havoc
EOF

chmod +x start-client.sh
```

**Create teamserver launcher:**

```bash
cat > start-server.sh << 'EOF'
#!/bin/bash

cd "$(dirname "$0")"

PROFILE="${1:-./profiles/havoc.yaotl}"

if [ ! -f "$PROFILE" ]; then
    echo "Error: Profile not found: $PROFILE"
    exit 1
fi

export LD_LIBRARY_PATH="/usr/lib/aarch64-linux-gnu:/usr/lib:/lib/aarch64-linux-gnu:/lib"

echo "Starting Havoc Teamserver..."
echo "Profile: $PROFILE"

./havoc server --profile "$PROFILE" -v --debug
EOF

chmod +x start-server.sh
```

---

## Step 7: Configure and Run Havoc

### Check Default Credentials

```bash
cat profiles/havoc.yaotl
```

**Default configuration:**

```yaml
Teamserver {
    Host = "0.0.0.0"
    Port = 40056
}

Operators {
    user "5pider" {
        Password = "password1234"
    }
    user "Neo" {
        Password = "password1234"
    }
}
```

### Start Teamserver

**Terminal 1:**

```bash
cd ~/Documents/Apps/Havoc
sudo ./start-server.sh
```

**Expected output:**

```
Starting Havoc Teamserver...
Profile: ./profiles/havoc.yaotl

[INFO] Havoc Framework [Version: 0.7] [CodeName: Bites The Dust]
[INFO] Time: 2026-01-04 14:00:00
[INFO] Teamserver listening on 0.0.0.0:40056
```

### Start Client

**Terminal 2:**

```bash
cd ~/Documents/Apps/Havoc
./start-client.sh
```

**Expected output:**

```
Starting Havoc Client...
Python: Python 3.10.14

[info] Havoc Framework [Version: 0.7] [CodeName: Bites The Dust]
[info] Successful created database
[info] loaded config file: client/config.toml
```

The GUI should launch successfully.

### Connect to Teamserver

In the Havoc client GUI:

1. Click **"New Profile"**
2. Enter connection details:
   - **Profile Name:** Local Server
   - **Host:** `127.0.0.1`
   - **Port:** `40056`
   - **User:** `Neo`
   - **Password:** `password1234`
3. Click **"Save"**
4. Click **"Connect"**

**Success indicators:**
- Status changes to "Connected"
- Teamserver shows: `[INFO] New client connected`
- Client shows operators panel and session table

---

## Troubleshooting

### Issue 1: libstdc++ Version Error

**Problem:**

```
client/Havoc: /home/kali/anaconda3/lib/libstdc++.so.6: version `GLIBCXX_3.4.30' not found
```

**Cause:** Anaconda's old libstdc++ is being loaded instead of system library.

**Solution:**

Always use `./start-client.sh` which sets `LD_LIBRARY_PATH` correctly.

**Verify:**

```bash
ldd client/Havoc | grep libstdc++
```

Should show: `/usr/lib/aarch64-linux-gnu/libstdc++.so.6`

---

### Issue 2: Qt Version Mismatch

**Problem:**

```
Cannot mix incompatible Qt library (5.15.2) with this library (5.15.17)
```

**Cause:** Binary was built linking to Anaconda Qt.

**Solution:**

Rebuild with clean environment:

```bash
make client-cleanup
./build-havoc-client.sh
```

**Verify correct Qt linkage:**

```bash
ldd client/Havoc | grep libQt5Core
```

**Good output:**
```
libQt5Core.so.5 => /usr/lib/aarch64-linux-gnu/libQt5Core.so.5
```

**Bad output:**
```
libQt5Core.so.5 => /home/kali/anaconda3/lib/libQt5Core.so.5
```

---

### Issue 3: Python Version Mismatch

**Problem:**

Build uses Python 3.13 instead of 3.10.

**Cause:** Not in Havoc directory where `.python-version` file exists.

**Solution:**

```bash
cd ~/Documents/Apps/Havoc
python3 --version  # Should be 3.10.14
```

If still showing 3.13:

```bash
source ~/.zshrc  # or ~/.bashrc
pyenv local 3.10.14
```

---

### Issue 4: Connection Refused

**Problem:**

Client shows "remote host closed the connection"

**Cause:** Teamserver not running.

**Solution:**

1. Start teamserver: `sudo ./start-server.sh`
2. Verify listening: `sudo netstat -tlnp | grep 40056`
3. Check firewall isn't blocking localhost

---

### Issue 5: Permission Denied on Port 40056

**Problem:**

```
bind: permission denied
```

**Cause:** Ports below 1024 and some teamserver operations require root.

**Solution:**

```bash
sudo ./start-server.sh
```

---

## Key Takeaways

1. **Python 3.10 is mandatory** - Use pyenv to install it alongside system Python
2. **Anaconda conflicts are real** - Override library paths to use system libraries
3. **Build environment matters** - Remove Anaconda from PATH during compilation
4. **Use launcher scripts** - Don't run binaries directly; they need environment setup
5. **ARM64 works great** - Native compilation on Apple Silicon performs excellently

---

## Quick Reference

### Installation Commands

```bash
# Clone repository
git clone https://github.com/HavocFramework/Havoc.git
cd Havoc

# Install Python 3.10
./install-python310.sh
source ~/.zshrc

# Build client
./build-havoc-client.sh

# Build teamserver
make ts-build
```

### Running Havoc

```bash
# Terminal 1: Start teamserver
sudo ./start-server.sh

# Terminal 2: Start client
./start-client.sh
```

### Default Credentials

- Host: `127.0.0.1`
- Port: `40056`
- User: `Neo` or `5pider`
- Password: `password1234`

### Verify Build

```bash
# Check Python version
python3 --version  # Should be 3.10.14

# Check Qt linkage
ldd client/Havoc | grep libQt5Core
# Should point to /usr/lib/aarch64-linux-gnu/

# Check C++ library
ldd client/Havoc | grep libstdc++
# Should point to /usr/lib/aarch64-linux-gnu/
```

---

## Resources

- **Havoc GitHub:** [https://github.com/HavocFramework/Havoc](https://github.com/HavocFramework/Havoc)
- **Official Docs:** [https://havocframework.com/docs/](https://havocframework.com/docs/)
- **Wiki:** [https://github.com/HavocFramework/Havoc/wiki](https://github.com/HavocFramework/Havoc/wiki)
- **Discord Community:** [https://discord.gg/z3PF3NRDE5](https://discord.gg/z3PF3NRDE5)
- **Python API:** [https://github.com/HavocFramework/havoc-py](https://github.com/HavocFramework/havoc-py)
- **Modules:** [https://github.com/HavocFramework/Modules](https://github.com/HavocFramework/Modules)

---

## Support This Content

If this guide helped you get Havoc running on your M3/M4 Mac, consider supporting more tutorials like this!

[![Buy me a coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=davidtkeane&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff)](https://buymeacoffee.com/davidtkeane)

Your support helps create more in-depth guides and tutorials!

---

**Installation Time:** ~30 minutes
**Difficulty:** Intermediate
**Tested On:** MacBook Pro M4 Max, Kali Linux ARM64 2025.1
**Havoc Version:** 0.7 (Bites The Dust)
