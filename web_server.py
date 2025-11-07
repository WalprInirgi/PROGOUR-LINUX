#!/usr/bin/env python3
"""
PROGOUR-LINUX Web Interface Server
Blue-themed web interface for 50 penetration testing tools
"""

import http.server
import socketserver
import json
import os
import subprocess
import sys
import threading
import time
from urllib.parse import parse_qs, urlparse

# Configuration
PORT = 8080
HOST = "0.0.0.0"
WEB_DIR = os.path.dirname(os.path.abspath(__file__))

class ProGourHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)
    
    def log_message(self, format, *args):
        # Custom logging format
        print(f"[WEB] {self.address_string()} - {format % args}")
    
    def do_GET(self):
        if self.path == '/':
            self.path = '/index.html'
        elif self.path.startswith('/api/'):
            self.handle_api()
            return
        elif self.path.startswith('/tools/'):
            self.handle_tools()
            return
        return super().do_GET()
    
    def do_POST(self):
        if self.path.startswith('/api/'):
            self.handle_api()
        else:
            self.send_error(404)
    
    def handle_api(self):
        """Handle API requests"""
        if self.path == '/api/tools':
            self.send_tools_list()
        elif self.path == '/api/execute':
            self.execute_tool()
        elif self.path == '/api/system':
            self.get_system_info()
        elif self.path == '/api/status':
            self.get_server_status()
        elif self.path == '/api/install':
            self.install_tool()
        else:
            self.send_error(404)
    
    def handle_tools(self):
        """Serve tool-specific pages"""
        tool_name = self.path.split('/')[-1]
        tool_page = f'tools/{tool_name}.html'
        
        if os.path.exists(os.path.join(WEB_DIR, tool_page)):
            self.path = f'/{tool_page}'
            return super().do_GET()
        else:
            self.send_error(404)
    
    def send_tools_list(self):
        """Send categorized tools list"""
        tools_data = {
            "categories": [
                {
                    "name": "Reconnaissance",
                    "icon": "🔍",
                    "tools": [
                        {"id": 1, "name": "Nmap", "description": "Network discovery and security auditing", "command": "nmap", "installed": self.check_tool_installed("nmap")},
                        {"id": 2, "name": "Recon-ng", "description": "Web reconnaissance framework", "command": "recon-ng", "installed": self.check_tool_installed("recon-ng")},
                        {"id": 3, "name": "theHarvester", "description": "Email and subdomain gathering", "command": "theHarvester", "installed": self.check_tool_installed("theHarvester")},
                        {"id": 4, "name": "Maltego", "description": "Link analysis and data mining", "command": "maltego", "installed": self.check_tool_installed("maltego")},
                        {"id": 5, "name": "Shodan", "description": "Internet connected device search", "command": "shodan", "installed": self.check_tool_installed("shodan")}
                    ]
                },
                {
                    "name": "Web Application",
                    "icon": "🌐",
                    "tools": [
                        {"id": 11, "name": "Burp Suite", "description": "Web application security testing", "command": "burpsuite", "installed": self.check_tool_installed("burpsuite")},
                        {"id": 12, "name": "OWASP ZAP", "description": "Web application scanner", "command": "zap", "installed": self.check_tool_installed("zap")},
                        {"id": 13, "name": "Nikto", "description": "Web server scanner", "command": "nikto", "installed": self.check_tool_installed("nikto")},
                        {"id": 14, "name": "SQLmap", "description": "SQL injection tool", "command": "sqlmap", "installed": self.check_tool_installed("sqlmap")},
                        {"id": 15, "name": "Wfuzz", "description": "Web application fuzzer", "command": "wfuzz", "installed": self.check_tool_installed("wfuzz")}
                    ]
                },
                {
                    "name": "Password Tools",
                    "icon": "🔐",
                    "tools": [
                        {"id": 21, "name": "John the Ripper", "description": "Password cracker", "command": "john", "installed": self.check_tool_installed("john")},
                        {"id": 22, "name": "Hashcat", "description": "Advanced password recovery", "command": "hashcat", "installed": self.check_tool_installed("hashcat")},
                        {"id": 23, "name": "Hydra", "description": "Network logon cracker", "command": "hydra", "installed": self.check_tool_installed("hydra")},
                        {"id": 24, "name": "Crunch", "description": "Wordlist generator", "command": "crunch", "installed": self.check_tool_installed("crunch")},
                        {"id": 25, "name": "CeWL", "description": "Custom wordlist generator", "command": "cewl", "installed": self.check_tool_installed("cewl")}
                    ]
                },
                {
                    "name": "Wireless Tools",
                    "icon": "📡",
                    "tools": [
                        {"id": 31, "name": "Aircrack-ng", "description": "WiFi security auditing", "command": "aircrack-ng", "installed": self.check_tool_installed("aircrack-ng")},
                        {"id": 32, "name": "Kismet", "description": "Wireless network detector", "command": "kismet", "installed": self.check_tool_installed("kismet")},
                        {"id": 33, "name": "Wifite", "description": "Automated wireless auditor", "command": "wifite", "installed": self.check_tool_installed("wifite")},
                        {"id": 34, "name": "Fern Wifi Cracker", "description": "Wireless security tool", "command": "fern-wifi-cracker", "installed": self.check_tool_installed("fern-wifi-cracker")},
                        {"id": 35, "name": "PixieWPS", "description": "WPS PIN recovery", "command": "pixiewps", "installed": self.check_tool_installed("pixiewps")}
                    ]
                },
                {
                    "name": "System Tools",
                    "icon": "⚡",
                    "tools": [
                        {"id": 41, "name": "Metasploit", "description": "Penetration testing framework", "command": "msfconsole", "installed": self.check_tool_installed("msfconsole")},
                        {"id": 42, "name": "Wireshark", "description": "Network protocol analyzer", "command": "wireshark", "installed": self.check_tool_installed("wireshark")},
                        {"id": 43, "name": "Ettercap", "description": "Network security tool", "command": "ettercap", "installed": self.check_tool_installed("ettercap")},
                        {"id": 44, "name": "Netcat", "description": "Network utility", "command": "nc", "installed": self.check_tool_installed("nc")},
                        {"id": 45, "name": "SET", "description": "Social Engineering Toolkit", "command": "setoolkit", "installed": self.check_tool_installed("setoolkit")}
                    ]
                }
            ]
        }
        
        self.send_json_response(tools_data)
    
    def execute_tool(self):
        """Execute a tool command"""
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length).decode()
        data = parse_qs(post_data)
        
        tool_id = data.get('tool_id', [''])[0]
        command = data.get('command', [''])[0]
        
        try:
            if command:
                # Execute custom command
                result = self.run_command(command)
                response = {"status": "success", "output": result, "type": "custom"}
            elif tool_id:
                # Execute predefined tool
                result = self.run_tool_command(tool_id)
                response = {"status": "success", "output": result, "type": "tool"}
            else:
                response = {"status": "error", "message": "No tool or command specified"}
        except Exception as e:
            response = {"status": "error", "message": str(e)}
        
        self.send_json_response(response)
    
    def run_tool_command(self, tool_id):
        """Run command for specific tool"""
        tool_commands = {
            "1": "nmap --help",
            "2": "recon-ng --help",
            "3": "theHarvester --help",
            "11": "echo 'Starting Burp Suite... (GUI tool)'",
            "12": "zap --help",
            "13": "nikto --help",
            "14": "sqlmap --help",
            "15": "wfuzz --help",
            "21": "john --help",
            "22": "hashcat --help",
            "23": "hydra --help",
            "24": "crunch --help",
            "25": "cewl --help",
            "31": "aircrack-ng --help",
            "32": "kismet --help",
            "33": "wifite --help",
            "41": "msfconsole --version",
            "42": "wireshark --version",
            "43": "ettercap --help",
            "44": "nc -h",
            "45": "setoolkit --help"
        }
        
        cmd = tool_commands.get(tool_id, "echo 'Tool command not configured'")
        return self.run_command(cmd)
    
    def run_command(self, command, timeout=30):
        """Execute a shell command"""
        try:
            result = subprocess.check_output(
                command, 
                shell=True, 
                stderr=subprocess.STDOUT, 
                timeout=timeout
            )
            return result.decode('utf-8', errors='ignore')
        except subprocess.TimeoutExpired:
            return f"Command timed out after {timeout} seconds"
        except subprocess.CalledProcessError as e:
            return f"Error (code {e.returncode}): {e.output.decode('utf-8', errors='ignore')}"
        except Exception as e:
            return f"Exception: {str(e)}"
    
    def get_system_info(self):
        """Get system information"""
        info = {}
        try:
            info['hostname'] = self.run_command("hostname").strip()
            info['system'] = self.run_command("uname -s").strip()
            info['kernel'] = self.run_command("uname -r").strip()
            info['user'] = self.run_command("whoami").strip()
            info['uptime'] = self.run_command("uptime -p").strip()
            
            # Get installed tools count
            installed_tools = 0
            for category in self.send_tools_list():
                for tool in category.get('tools', []):
                    if tool.get('installed'):
                        installed_tools += 1
            info['installed_tools'] = installed_tools
            
        except Exception as e:
            info['error'] = str(e)
        
        self.send_json_response(info)
    
    def get_server_status(self):
        """Get server status"""
        status = {
            "status": "running",
            "port": PORT,
            "host": HOST,
            "start_time": time.strftime("%Y-%m-%d %H:%M:%S"),
            "connections": self.server.request_count if hasattr(self.server, 'request_count') else 0
        }
        self.send_json_response(status)
    
    def install_tool(self):
        """Install a specific tool"""
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length).decode()
        data = parse_qs(post_data)
        
        tool_name = data.get('tool_name', [''])[0]
        
        if not tool_name:
            self.send_json_response({"status": "error", "message": "No tool specified"})
            return
        
        try:
            # This would need to be expanded based on package manager
            install_commands = {
                "nmap": "sudo apt install -y nmap",
                "sqlmap": "sudo apt install -y sqlmap",
                "wireshark": "sudo apt install -y wireshark",
                "aircrack-ng": "sudo apt install -y aircrack-ng",
                "john": "sudo apt install -y john",
            }
            
            cmd = install_commands.get(tool_name, f"sudo apt install -y {tool_name}")
            result = self.run_command(cmd, timeout=120)
            
            self.send_json_response({
                "status": "success", 
                "message": f"Installation attempt completed for {tool_name}",
                "output": result
            })
            
        except Exception as e:
            self.send_json_response({"status": "error", "message": str(e)})
    
    def check_tool_installed(self, tool_name):
        """Check if a tool is installed"""
        try:
            result = subprocess.run(
                ["which", tool_name],
                capture_output=True,
                text=True,
                timeout=5
            )
            return result.returncode == 0
        except:
            return False
    
    def send_json_response(self, data):
        """Send JSON response"""
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

class ProGourServer(socketserver.TCPServer):
    """Custom server with request counting"""
    def __init__(self, *args, **kwargs):
        self.request_count = 0
        super().__init__(*args, **kwargs)
    
    def process_request(self, request, client_address):
        self.request_count += 1
        super().process_request(request, client_address)

def get_network_info():
    """Get network information for display"""
    try:
        import socket
        hostname = socket.gethostname()
        local_ip = socket.gethostbyname(hostname)
        
        # Get external IPs
        ips = [local_ip]
        try:
            # Get all network interfaces
            result = subprocess.check_output("hostname -I", shell=True).decode().strip()
            ips = result.split()
        except:
            pass
            
        return ips
    except:
        return ["127.0.0.1"]

def main():
    """Main server function"""
    os.chdir(WEB_DIR)
    
    # Create necessary directories
    os.makedirs('tools', exist_ok=True)
    
    # Create index.html if it doesn't exist
    if not os.path.exists('index.html'):
        create_web_interface()
    
    # Start server
    with ProGourServer((HOST, PORT), ProGourHandler) as httpd:
        print("╔══════════════════════════════════════════════════════════════╗")
        print("║                   PROGOUR-LINUX Web Server                  ║")
        print("╠══════════════════════════════════════════════════════════════╣")
        print("║  Server is running!                                         ║")
        print("║                                                              ║")
        
        network_ips = get_network_info()
        print(f"║  Local access:    http://localhost:{PORT}")
        for ip in network_ips:
            print(f"║  Network access:  http://{ip}:{PORT}")
        
        print("║                                                              ║")
        print("║  Press Ctrl+C to stop the server                            ║")
        print("╚══════════════════════════════════════════════════════════════╝")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n╔══════════════════════════════════════════════════════════════╗")
            print("║                   Shutting down server...                    ║")
            print("╚══════════════════════════════════════════════════════════════╝")

def create_web_interface():
    """Create the web interface files"""
    # This function would create index.html and other web files
    # The actual HTML content is in the main file for simplicity
    pass

if __name__ == "__main__":
    main()