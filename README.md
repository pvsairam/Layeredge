# LayerEdge CLI Node

This script automates the installation process by installing all necessary dependencies and adding them to your system's path.

# How to Install?

### Clone the repository:
```bash
git clone https://github.com/pvsairam/Layeredge.git
```

### Enter the folder:
```bash
cd Layeredge
```

### Start the Installation:
```bash
./layeredge_node.sh
```

```bash
chmod +x ./layeredge_node.sh
```

### Or use this single command to automate the process ⬇️
```bash
git clone https://github.com/pvsairam/Layeredge.git && cd Layeredge && ./layeredge_node.sh
```

## Notes

The script automatically installs all dependencies.
If you encounter an error stating "Go not found", run the following commands to add Go to your path and re-run the script:

```bash
export PATH=$PATH:/usr/local/go/bin
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
source ~/.bashrc
```

When prompted, enter your private key.

⚠ Note: The private key will not be visible when you paste it for security reasons. Just paste it and press Enter.

Done! ✅ Once the setup is complete, the LayerEdge CLI Node will be up and running.
