#!/usr/bin/env python3
"""
Simple API server for bridge monitoring dashboard
Provides endpoints to check bridge service status
"""

import subprocess
import json
import http.server
import socketserver
import re
from urllib.parse import urlparse, parse_qs
from pathlib import Path

PORT = 8766
SCRIPT_DIR = Path(__file__).parent


def check_bridge_service():
    """Check if bridge service is running via launchctl and process list"""
    try:
        # Check launchctl status
        result = subprocess.run(
            ['launchctl', 'list', 'com.sf.imessage-bridge'],
            capture_output=True,
            text=True,
            timeout=2
        )
        
        # Check if process is running
        process_result = subprocess.run(
            ['pgrep', '-f', 'bridge.py'],
            capture_output=True,
            text=True,
            timeout=2
        )
        
        pids = [pid.strip() for pid in process_result.stdout.strip().split('\n') if pid.strip()]
        running = len(pids) == 1
        
        if running:
            pid = pids[0]
            # Get process uptime
            try:
                uptime_result = subprocess.run(
                    ['ps', '-p', pid, '-o', 'etime='],
                    capture_output=True,
                    text=True,
                    timeout=1
                )
                uptime = uptime_result.stdout.strip()
            except:
                uptime = 'N/A'
        else:
            pid = None
            uptime = None
        
        return {
            'running': running,
            'pid': pid,
            'uptime': uptime,
            'launchctl_output': result.stdout if result.returncode == 0 else None
        }
    except Exception as e:
        return {
            'running': False,
            'error': str(e)
        }


def check_ngrok():
    """Check ngrok status via API"""
    try:
        import urllib.request
        response = urllib.request.urlopen('http://localhost:4040/api/tunnels', timeout=2)
        data = json.loads(response.read())
        tunnels = data.get('tunnels', [])
        
        if tunnels:
            tunnel = tunnels[0]
            return {
                'running': True,
                'tunnel': {
                    'public_url': tunnel.get('public_url'),
                    'addr': tunnel.get('config', {}).get('addr')
                }
            }
        else:
            return {
                'running': False,
                'error': 'No active tunnels'
            }
    except Exception as e:
        return {
            'running': False,
            'error': str(e)
        }


def check_http_server():
    """Check HTTP server on port 3001"""
    try:
        import urllib.request
        response = urllib.request.urlopen('http://localhost:3001/health', timeout=2)
        data = json.loads(response.read())
        return {
            'running': True,
            'status': data.get('status'),
            'service': data.get('service')
        }
    except Exception as e:
        return {
            'running': False,
            'error': str(e)
        }


def get_recent_logs(source='all', lines=50):
    """Get recent logs from various log files"""
    logs = []
    log_files = []
    
    if source == 'all' or source == 'bridge':
        log_files.append(('bridge', SCRIPT_DIR / 'logs' / 'bridge.stdout.log'))
        log_files.append(('bridge', SCRIPT_DIR / 'logs' / 'bridge.stderr.log'))
    
    if source == 'all' or source == 'ngrok':
        log_files.append(('ngrok', SCRIPT_DIR / 'logs' / 'ngrok.stdout.log'))
        log_files.append(('ngrok', SCRIPT_DIR / 'logs' / 'ngrok.stderr.log'))
    
    if source == 'all' or source == 'monitor':
        log_files.append(('monitor', SCRIPT_DIR / 'logs' / 'monitor.stdout.log'))
        log_files.append(('monitor', SCRIPT_DIR / 'logs' / 'monitor.stderr.log'))
    
    for log_source, log_path in log_files:
        if not log_path.exists():
            continue
        
        try:
            # Read last N lines from file
            with open(log_path, 'r', encoding='utf-8', errors='ignore') as f:
                file_lines = f.readlines()
                # Get last lines
                recent_lines = file_lines[-lines:] if len(file_lines) > lines else file_lines
                
                for line in recent_lines:
                    line = line.strip()
                    if not line:
                        continue
                    
                    # Determine log level
                    level = 'info'
                    if 'error' in line.lower() or 'ERROR' in line or 'Traceback' in line:
                        level = 'error'
                    elif 'warning' in line.lower() or 'WARNING' in line:
                        level = 'warning'
                    elif '✅' in line or 'success' in line.lower() or 'ok' in line.lower():
                        level = 'success'
                    
                    # Try to extract timestamp if present
                    timestamp = None
                    if '[' in line and ']' in line:
                        # Look for timestamp pattern like [2025-12-03 11:23:35.871]
                        timestamp_match = re.search(r'\[([^\]]+)\]', line)
                        if timestamp_match:
                            timestamp = timestamp_match.group(1)
                    
                    logs.append({
                        'source': log_source,
                        'message': line,
                        'level': level,
                        'timestamp': timestamp
                    })
        except Exception as e:
            logs.append({
                'source': log_source,
                'message': f'Error reading log file: {str(e)}',
                'level': 'error',
                'timestamp': None
            })
    
    # Sort by timestamp if available, otherwise keep file order
    logs.sort(key=lambda x: x['timestamp'] if x['timestamp'] else '', reverse=True)
    
    # Return most recent N logs
    return logs[:lines]


class MonitorAPIHandler(http.server.SimpleHTTPRequestHandler):
    """HTTP handler for monitor API and dashboard"""
    
    def do_GET(self):
        """Handle GET requests"""
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        
        # Handle CORS preflight
        if self.command == 'OPTIONS':
            self.send_response(200)
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS')
            self.send_header('Access-Control-Allow-Headers', 'Content-Type')
            self.end_headers()
            return
        
        # API endpoints
        if path == '/api/check-bridge':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            status = check_bridge_service()
            self.wfile.write(json.dumps(status).encode())
            return
        
        elif path == '/api/check-ngrok':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Cache-Control', 'no-cache')
            self.end_headers()
            status = check_ngrok()
            self.wfile.write(json.dumps(status).encode())
            return
        
        elif path == '/api/check-http':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Cache-Control', 'no-cache')
            self.end_headers()
            status = check_http_server()
            self.wfile.write(json.dumps(status).encode())
            return
        
        elif path == '/api/status':
            # Combined status endpoint
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            status = {
                'bridge': check_bridge_service(),
                'ngrok': check_ngrok(),
                'http': check_http_server()
            }
            self.wfile.write(json.dumps(status).encode())
            return
        
        elif path.startswith('/api/logs'):
            # Logs endpoint
            query_params = parse_qs(parsed_path.query)
            source = query_params.get('source', ['all'])[0]
            lines = int(query_params.get('lines', ['50'])[0])
            
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            
            logs = get_recent_logs(source, lines)
            self.wfile.write(json.dumps({'logs': logs}).encode())
            return
        
        # Serve dashboard HTML
        elif path == '/' or path == '/dashboard.html':
            dashboard_path = SCRIPT_DIR / 'bridge_monitor_dashboard.html'
            if dashboard_path.exists():
                self.send_response(200)
                self.send_header('Content-Type', 'text/html')
                self.end_headers()
                with open(dashboard_path, 'rb') as f:
                    self.wfile.write(f.read())
                return
        
        # Default: serve files from script directory
        return super().do_GET()
    
    def log_message(self, format, *args):
        """Suppress default logging"""
        pass


def main():
    """Start the monitor API server"""
    os.chdir(SCRIPT_DIR)
    
    with socketserver.TCPServer(("", PORT), MonitorAPIHandler) as httpd:
        print(f"🌐 Bridge Monitor API Server running on http://localhost:{PORT}")
        print(f"📊 Open http://localhost:{PORT}/dashboard.html in your browser")
        print("Press Ctrl+C to stop")
        
        # Try to open browser automatically
        try:
            import webbrowser
            webbrowser.open(f'http://localhost:{PORT}/dashboard.html')
        except Exception:
            pass
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n👋 Shutting down monitor server...")


if __name__ == "__main__":
    import os
    main()

