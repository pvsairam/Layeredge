#!/bin/bash

set -e  # Exit on any error

echo "=============================================="
echo "      LayerEdge Light Node Setup Script       "
echo "=============================================="

# Update system packages
echo "[INFO] Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required dependencies
echo "[INFO] Installing required packages..."
sudo apt install -y lsof curl git screen

# Remove any existing Go installation
echo "[INFO] Removing any existing Go installation..."
sudo rm -rf /usr/local/go

# Install Go (version 1.23.1)
GO_VERSION="1.23.1"
echo "[INFO] Installing Go version $GO_VERSION..."
wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# Verify Go installation
if ! command -v go &> /dev/null; then
    echo "[ERROR] Go installation failed! Exiting..."
    exit 1
fi
echo "[SUCCESS] Go installed successfully: $(go version)"

# Install Rust
echo "[INFO] Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# Verify Rust installation
if ! command -v rustc &> /dev/null; then
    echo "[ERROR] Rust installation failed! Exiting..."
    exit 1
fi
echo "[SUCCESS] Rust installed successfully: $(rustc --version)"

# Install Risc0 Toolchain
echo "[INFO] Installing Risc0 Toolchain..."
curl -L https://risczero.com/install | bash

# Add Risc0 to PATH
export PATH="$PATH:/root/.risc0/bin"

# Install Risc0 components
if ! /root/.risc0/bin/rzup install; then
    echo "[ERROR] Risc0 installation failed! Exiting..."
    exit 1
fi
echo "[SUCCESS] Risc0 Toolchain installed successfully."

# Securely capture the user's private key
read -sp "[SECURITY] Enter your private key (input hidden): " PRIVATE_KEY
echo -e "\n[INFO] Private key has been recorded securely."

# Clone or update the LayerEdge repository
REPO_DIR="light-node"
if [ -d "$REPO_DIR" ]; then
    echo "[INFO] LayerEdge repository already exists. Updating..."
    cd "$REPO_DIR"
    git pull
else
    echo "[INFO] Cloning LayerEdge repository..."
    git clone https://github.com/Layer-Edge/light-node.git
    cd "$REPO_DIR"
fi

# Create .env file inside the project directory
ENV_FILE=".env"
echo "[INFO] Creating environment configuration file..."
cat <<EOF > $ENV_FILE
GRPC_URL=34.31.74.109:9090
CONTRACT_ADDR=cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709
ZK_PROVER_URL=http://127.0.0.1:3001
API_REQUEST_TIMEOUT=100
POINTS_API=http://127.0.0.1:8080
PRIVATE_KEY=$PRIVATE_KEY
EOF

# Secure .env file
chmod 600 $ENV_FILE

if [ ! -f "$ENV_FILE" ]; then
    echo "[ERROR] Failed to create the .env file. Exiting..."
    exit 1
fi
echo "[SUCCESS] .env file created and secured."

# Kill any process using port 3001
PORT=3001
PID=$(lsof -ti:$PORT)
if [ -n "$PID" ]; then
    echo "[INFO] Port $PORT is in use. Terminating process ID $PID..."
    kill -9 $PID
fi

# Start the Merkle service
echo "[INFO] Starting the Risc0 Merkle Service..."
cd risc0-merkle-service
cargo build
cargo run &

# Return to the light-node directory
cd ..

# Load environment variables
echo "[INFO] Loading environment variables..."
export $(grep -v '^#' $ENV_FILE | xargs)

# Build and run the LayerEdge light node
echo "[INFO] Compiling the LayerEdge light node..."
if ! go build; then
    echo "[ERROR] Go build failed! Exiting..."
    exit 1
fi
echo "[SUCCESS] Build successful."

# Run the light node
echo "[INFO] Starting the LayerEdge light node..."
./light-node &

echo "[SUCCESS] LayerEdge light node setup is complete!"

echo "🚀 For more alpha, join our Telegram channel: https://t.me/Airdrop_OG"
