#!/bin/bash

# PROGOUR-LINUX Main Interface with Web Option
# Blue-themed terminal interface for 50 pentesting tools

# Color codes for blue theme
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
CYAN='\033[0;36m'
LIGHT_CYAN='\033[1;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
WEB_PORT=8080
WEB_HOST="0.0.0.0"
WEB_DIR="./web_interface"

# Display header
show_header() {
    clear
    echo -e "${LIGHT_BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║   ██████  ██████  ██████   ██████  ██    ██ ██████  ██      ║"
    echo "║  ██      ██    ██ ██   ██ ██    ██ ██    ██ ██   ██ ██      ║"
    echo "║  ██      ██    ██ ██████  ██    ██ ██    ██ ██████  ██      ║"
    echo "║  ██      ██    ██ ██   ██ ██    ██ ██    ██ ██   ██ ██      ║"
    echo "║   ██████  ██████  ██   ██  ██████   ██████  ██   ██ ███████ ║"
    echo "║                                                              ║"
    echo "║             50 Penetration Testing Tools Suite              ║"
    echo "║                     Blue Terminal Edition                   ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Main menu
show_main_menu() {
    echo -e "${LIGHT_BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                        MAIN MENU                            ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║  1. 🖥️   Terminal Mode Only                                ║"
    echo "║  2. 🌐   Web Interface + Terminal                          ║"
    echo "║  3. ⚙️   Settings & Configuration                          ║"
    echo "║  4. ℹ️   System Information                                ║"
    echo "║  5. 🚪  Exit                                               ║"
    echo "╚══════════════════════════════════════════════════════════════╣"
    echo -e "${NC}"
}

# Terminal tools menu
show_terminal_menu() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    TERMINAL TOOLS MENU                      ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║  1.  🔍  Reconnaissance Tools                              ║"
    echo "║  2.  🌐  Web Application Tools                             ║"
    echo "║  3.  🔐  Password Tools                                    ║"
    echo "║  4.  📡  Wireless Tools                                    ║"
    echo "║  5.  ⚡  System Tools                                       ║"
    echo "║  0.  Back to Main Menu                                     ║"
    echo "╚══════════════════════════════════════════════════════════════╣"
    echo -e "${NC}"
}

# Start web interface
start_web_interface() {
    echo -e "${GREEN}Starting Web Interface...${NC}"
    
    # Check if web directory exists
    if [ ! -d "$WEB_DIR" ]; then
        echo -e "${YELLOW}Web interface not found. Installing...${NC}"
        install_web_interface
    fi
    
    # Check if Python is available
    if command -v python3 &> /dev/null; then
        echo -e "${GREEN}Starting web server on http://localhost:$WEB_PORT${NC}"
        echo -e "${YELLOW}Press Ctrl+C to stop the web server${NC}"
        cd "$WEB_DIR"
        python3 web_server.py
    else
        echo -e "${RED}Python3 is required for web interface but not installed.${NC}"
        echo -e "${YELLOW}Falling back to terminal mode only.${NC}"
        sleep 2
        terminal_mode
    fi
}

# Install web interface
install_web_interface() {
    echo -e "${BLUE}Installing web interface components...${NC}"
    
    # Create web directory
    mkdir -p "$WEB_DIR"
    
    # Create main web server file
    cat > "$WEB_DIR/web_server.py" << 'EOF'
#!/usr/bin/env python3
"""
PROGOUR-LINUX Web Interface Server
Simple web interface for the penetration testing tools
"""

import http.server
import socketserver
import json
import os
import subprocess
import sys
from urllib.parse import parse_qs

PORT = 8080
WEB_DIR = os.path.dirname(os.path.abspath(__file__))

class ProGourHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)
    
    def do_GET(self):
        if self.path == '/':
            self.path = '/index.html'
        elif self.path.startswith('/api/'):
            self.handle_api()
            return
        return super().do_GET()
    
    def do_POST(self):
        if self.path.startswith('/api/'):
            self.handle_api()
        else:
            self.send_error(404)
    
    def handle_api(self):
        if self.path == '/api/tools':
            self.send_tools_list()
        elif self.path == '/api/execute':
            self.execute_tool()
        elif self.path == '/api/system':
            self.get_system_info()
        else:
            self.send_error(404)
    
    def send_tools_list(self):
        tools = {
            "categories": [
                {
                    "name": "Reconnaissance",
                    "tools": [
                        {"id": 1, "name": "Nmap", "description": "Network discovery and security auditing"},
                        {"id": 2, "name": "Recon-ng", "description": "Web reconnaissance framework"},
                        {"id": 3, "name": "theHarvester", "description": "Email and subdomain gathering"}
                    ]
                },
                {
                    "name": "Web Application",
                    "tools": [
                        {"id": 11, "name": "Burp Suite", "description": "Web application security testing"},
                        {"id": 12, "name": "OWASP ZAP", "description": "Web application scanner"},
                        {"id": 13, "name": "SQLmap", "description": "SQL injection tool"}
                    ]
                }
            ]
        }
        
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(tools).encode())
    
    def execute_tool(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length).decode()
        data = parse_qs(post_data)
        
        tool_id = data.get('tool_id', [''])[0]
        command = data.get('command', [''])[0]
        
        try:
            if tool_id:
                result = self.run_tool_command(tool_id, command)
                response = {"status": "success", "output": result}
            else:
                response = {"status": "error", "message": "No tool specified"}
        except Exception as e:
            response = {"status": "error", "message": str(e)}
        
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(response).encode())
    
    def run_tool_command(self, tool_id, command):
        # Map tool IDs to actual commands
        tool_commands = {
            "1": "nmap --help",
            "2": "recon-ng --help", 
            "3": "theHarvester --help",
            "11": "echo 'Burp Suite would start here'",
            "12": "echo 'OWASP ZAP would start here'",
            "13": "sqlmap --help"
        }
        
        cmd = tool_commands.get(tool_id, "echo 'Tool not configured'")
        if command:
            cmd = command
        
        try:
            result = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT, timeout=30)
            return result.decode('utf-8', errors='ignore')
        except subprocess.TimeoutExpired:
            return "Command timed out after 30 seconds"
        except subprocess.CalledProcessError as e:
            return f"Error: {e.output.decode('utf-8', errors='ignore')}"
        except Exception as e:
            return f"Exception: {str(e)}"
    
    def get_system_info(self):
        info = {}
        try:
            # Get basic system info
            info['hostname'] = subprocess.check_output("hostname", shell=True).decode().strip()
            info['system'] = subprocess.check_output("uname -s", shell=True).decode().strip()
            info['kernel'] = subprocess.check_output("uname -r", shell=True).decode().strip()
            info['user'] = subprocess.check_output("whoami", shell=True).decode().strip()
        except Exception as e:
            info['error'] = str(e)
        
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(info).encode())

def main():
    os.chdir(WEB_DIR)
    
    # Create index.html if it doesn't exist
    if not os.path.exists('index.html'):
        create_web_files()
    
    with socketserver.TCPServer(("", PORT), ProGourHandler) as httpd:
        print(f"PROGOUR-LINUX Web Interface")
        print(f"Server running at http://localhost:{PORT}")
        print(f"Access the interface from any browser on your network")
        print(f"Press Ctrl+C to stop the server")
        
        # Get network IPs
        try:
            import socket
            hostname = socket.gethostname()
            local_ip = socket.gethostbyname(hostname)
            print(f"Local access: http://localhost:{PORT}")
            print(f"Network access: http://{local_ip}:{PORT}")
        except:
            print(f"Local access: http://localhost:{PORT}")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nShutting down web server...")

def create_web_files():
    """Create the web interface files"""
    
    # Create index.html
    with open('index.html', 'w') as f:
        f.write('''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PROGOUR-LINUX Web Interface</title>
    <style>
        :root {
            --primary-blue: #1e3a8a;
            --secondary-blue: #3b82f6;
            --light-blue: #dbeafe;
            --dark-blue: #1e40af;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Courier New', monospace;
            background: linear-gradient(135deg, var(--primary-blue), var(--dark-blue));
            color: white;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            text-align: center;
            padding: 2rem 0;
            background: rgba(0,0,0,0.3);
            border-radius: 10px;
            margin-bottom: 2rem;
        }
        
        .header h1 {
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
            color: var(--light-blue);
        }
        
        .header p {
            font-size: 1.1rem;
            opacity: 0.9;
        }
        
        .grid {
            display: grid;
            grid-template-columns: 300px 1fr;
            gap: 20px;
        }
        
        .sidebar {
            background: rgba(0,0,0,0.4);
            border-radius: 10px;
            padding: 1rem;
        }
        
        .main-content {
            background: rgba(0,0,0,0.4);
            border-radius: 10px;
            padding: 1rem;
        }
        
        .category {
            margin-bottom: 1rem;
        }
        
        .category h3 {
            color: var(--secondary-blue);
            margin-bottom: 0.5rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid var(--secondary-blue);
        }
        
        .tool-item {
            padding: 0.5rem;
            margin: 0.25rem 0;
            background: rgba(59, 130, 246, 0.2);
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s;
        }
        
        .tool-item:hover {
            background: rgba(59, 130, 246, 0.4);
        }
        
        .terminal {
            background: #1a1a1a;
            border-radius: 5px;
            padding: 1rem;
            font-family: 'Courier New', monospace;
            height: 400px;
            overflow-y: auto;
            color: #00ff00;
        }
        
        .command-input {
            width: 100%;
            padding: 0.5rem;
            background: #2d2d2d;
            border: 1px solid var(--secondary-blue);
            border-radius: 5px;
            color: white;
            font-family: 'Courier New', monospace;
        }
        
        .btn {
            background: var(--secondary-blue);
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s;
        }
        
        .btn:hover {
            background: var(--dark-blue);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>PROGOUR-LINUX</h1>
            <p>50 Penetration Testing Tools - Web Interface</p>
        </div>
        
        <div class="grid">
            <div class="sidebar" id="sidebar">
                <h3>Tools Categories</h3>
                <div id="categories-list">
                    <!-- Categories will be loaded here -->
                </div>
            </div>
            
            <div class="main-content">
                <h3>Terminal Output</h3>
                <div class="terminal" id="terminal">
                    <div>PROGOUR-LINUX Web Interface Ready</div>
                    <div>Select a tool from the sidebar to get started</div>
                </div>
                
                <div style="margin-top: 1rem;">
                    <input type="text" class="command-input" id="commandInput" 
                           placeholder="Enter custom command or modify the tool command...">
                    <button class="btn" onclick="executeCommand()" style="margin-top: 0.5rem;">
                        Execute Command
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        let currentToolId = null;
        
        // Load tools when page loads
        window.addEventListener('DOMContentLoaded', loadTools);
        
        async function loadTools() {
            try {
                const response = await fetch('/api/tools');
                const data = await response.json();
                displayCategories(data.categories);
            } catch (error) {
                console.error('Error loading tools:', error);
            }
        }
        
        function displayCategories(categories) {
            const container = document.getElementById('categories-list');
            container.innerHTML = '';
            
            categories.forEach(category => {
                const categoryDiv = document.createElement('div');
                categoryDiv.className = 'category';
                
                categoryDiv.innerHTML = `
                    <h3>${category.name}</h3>
                    <div id="tools-${category.name}"></div>
                `;
                
                container.appendChild(categoryDiv);
                displayTools(category.name, category.tools);
            });
        }
        
        function displayTools(categoryName, tools) {
            const container = document.getElementById(`tools-${categoryName}`);
            
            tools.forEach(tool => {
                const toolDiv = document.createElement('div');
                toolDiv.className = 'tool-item';
                toolDiv.innerHTML = `
                    <strong>${tool.name}</strong>
                    <div style="font-size: 0.8rem; opacity: 0.8;">${tool.description}</div>
                `;
                
                toolDiv.addEventListener('click', () => selectTool(tool.id, tool.name));
                container.appendChild(toolDiv);
            });
        }
        
        function selectTool(toolId, toolName) {
            currentToolId = toolId;
            document.getElementById('commandInput').placeholder = `Command for ${toolName}...`;
            addToTerminal(`> Selected tool: ${toolName} (ID: ${toolId})`);
            addToTerminal('> Modify the command above or click Execute to run the default command');
        }
        
        async function executeCommand() {
            const commandInput = document.getElementById('commandInput');
            const command = commandInput.value.trim();
            
            if (!currentToolId && !command) {
                addToTerminal('> Error: Please select a tool or enter a command');
                return;
            }
            
            try {
                const response = await fetch('/api/execute', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: `tool_id=${currentToolId}&command=${encodeURIComponent(command)}`
                });
                
                const result = await response.json();
                
                if (result.status === 'success') {
                    addToTerminal('> Command output:');
                    addToTerminal(result.output);
                } else {
                    addToTerminal(`> Error: ${result.message}`);
                }
            } catch (error) {
                addToTerminal(`> Network error: ${error.message}`);
            }
            
            commandInput.value = '';
        }
        
        function addToTerminal(text) {
            const terminal = document.getElementById('terminal');
            const line = document.createElement('div');
            line.textContent = text;
            terminal.appendChild(line);
            terminal.scrollTop = terminal.scrollHeight;
        }
        
        // Allow pressing Enter to execute command
        document.getElementById('commandInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                executeCommand();
            }
        });
    </script>
</body>
</html>''')
    
    print("Web interface files created successfully")

if __name__ == "__main__":
    main()
EOF

    # Make web server executable
    os.chmod("$WEB_DIR/web_server.py", 0o755)
    
    print_success "Web interface installed successfully"
}

# Terminal mode
terminal_mode() {
    while true; do
        show_header
        show_terminal_menu
        
        read -p "Select category [1-5] or 0 to go back: " category
        
        case $category in
            1)
                # Reconnaissance tools
                echo -e "${GREEN}Launching Nmap...${NC}"
                nmap --help
                read -p "Press Enter to continue..."
                ;;
            2)
                # Web tools
                echo -e "${GREEN}Launching SQLMap...${NC}"
                sqlmap --help
                read -p "Press Enter to continue..."
                ;;
            0)
                break
                ;;
            *)
                echo -e "${RED}Invalid selection${NC}"
                sleep 1
                ;;
        esac
    done
}

# System information
show_system_info() {
    echo -e "${LIGHT_BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    SYSTEM INFORMATION                       ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo -e "${NC}"
    
    echo -e "${CYAN}System:${NC} $(uname -s)"
    echo -e "${CYAN}Hostname:${NC} $(hostname)"
    echo -e "${CYAN}Kernel:${NC} $(uname -r)"
    echo -e "${CYAN}User:${NC} $(whoami)"
    echo ""
    
    # Check web server status
    if [ -d "$WEB_DIR" ]; then
        echo -e "${GREEN}✓ Web interface is installed${NC}"
    else
        echo -e "${YELLOW}✗ Web interface not installed${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Main function
main() {
    while true; do
        show_header
        show_main_menu
        
        read -p "Select an option [1-5]: " choice
        
        case $choice in
            1)
                terminal_mode
                ;;
            2)
                start_web_interface
                ;;
            4)
                show_system_info
                ;;
            5)
                echo -e "${GREEN}Thank you for using PROGOUR-LINUX!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

# Check dependencies
check_dependencies() {
    local missing=0
    
    # Check for essential tools
    for tool in python3 curl wget; do
        if ! command -v $tool &> /dev/null; then
            echo -e "${YELLOW}Warning: $tool is not installed${NC}"
            ((missing++))
        fi
    done
    
    if [ $missing -gt 0 ]; then
        echo -e "${YELLOW}Some dependencies are missing. Web interface may not work properly.${NC}"
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Start the application
check_dependencies
main