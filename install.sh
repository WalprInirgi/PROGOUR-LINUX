#!/bin/bash

# PROGOUR-LINUX Installation Script with Web Interface

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Print colored output
print_status() {
    echo -e "${BLUE}[PROGOUR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Linux
check_linux() {
    if [ "$(uname)" != "Linux" ]; then
        print_error "This script is designed for Linux systems only."
        exit 1
    fi
}

# Detect package manager
detect_package_manager() {
    if command -v apt &> /dev/null; then
        PM="apt"
    elif command -v yum &> /dev/null; then
        PM="yum"
    elif command -v dnf &> /dev/null; then
        PM="dnf"
    elif command -v pacman &> /dev/null; then
        PM="pacman"
    else
        print_error "Could not detect package manager."
        exit 1
    fi
    print_status "Detected package manager: $PM"
}

# Install web interface dependencies
install_web_dependencies() {
    print_status "Installing web interface dependencies..."
    
    # Install Python3 and required packages
    case $PM in
        apt)
            sudo apt update
            sudo apt install -y python3 python3-pip curl wget
            ;;
        yum|dnf)
            sudo $PM update -y
            sudo $PM install -y python3 python3-pip curl wget
            ;;
        pacman)
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm python python-pip curl wget
            ;;
    esac
    
    # Install Python HTTP server module
    if ! python3 -c "import http.server" &> /dev/null; then
        print_status "Installing Python HTTP server module..."
        python3 -m pip install --upgrade pip
    fi
}

# Install penetration testing tools
install_tools() {
    print_status "Installing penetration testing tools..."
    
    # Basic tools that are commonly available
    case $PM in
        apt)
            sudo apt install -y \
                nmap \
                sqlmap \
                wireshark \
                aircrack-ng \
                john \
                hashcat \
                hydra \
                crunch \
                metasploit-framework \
                netcat
            ;;
        yum|dnf)
            sudo $PM install -y \
                nmap \
                sqlmap \
                wireshark \
                aircrack-ng \
                john \
                hashcat \
                hydra \
                crunch \
                netcat
            ;;
        pacman)
            sudo pacman -S --noconfirm \
                nmap \
                sqlmap \
                wireshark \
                aircrack-ng \
                john \
                hashcat \
                hydra \
                crunch \
                netcat
            ;;
    esac
}

# Create desktop entry
create_desktop_entry() {
    print_status "Creating desktop entry..."
    
    DESKTOP_FILE="$HOME/.local/share/applications/progour-linux.desktop"
    
    mkdir -p "$(dirname "$DESKTOP_FILE")"
    
    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=PROGOUR-LINUX
Comment=50 Penetration Testing Tools Suite
Exec=/bin/bash -c "cd '$PWD' && ./progour.sh"
Icon=terminal
Terminal=true
Categories=System;Security;
Keywords=security;pentesting;tools;
EOF
    
    chmod +x "$DESKTOP_FILE"
    print_success "Desktop entry created"
}

# Main installation function
main_install() {
    print_status "Starting PROGOUR-LINUX installation..."
    
    check_linux
    detect_package_manager
    
    # Install dependencies
    install_web_dependencies
    install_tools
    
    # Make main script executable
    chmod +x progour.sh
    
    # Create web interface directory
    mkdir -p web_interface
    
    # Create desktop entry
    create_desktop_entry
    
    print_success "PROGOUR-LINUX installation completed!"
    echo ""
    echo -e "${GREEN}Usage:${NC}"
    echo "  Terminal only: ./progour.sh"
    echo "  Web interface: Select option 2 in the menu"
    echo ""
    echo -e "${YELLOW}The web interface will be available at:${NC}"
    echo "  http://localhost:8080"
    echo "  http://[YOUR-IP]:8080"
    echo ""
    echo -e "${BLUE}You can also find PROGOUR-LINUX in your application menu${NC}"
}

# Check if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_install
fi