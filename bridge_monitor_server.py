#!/usr/bin/env python3
"""
Simple HTTP server for Bridge Monitor
Works on macOS 12.6 - uses only standard library, no tkinter
"""

import http.server
import socketserver
import json
import subprocess
import urllib.parse
from pathlib import Path


class BridgeMonitorHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/api/status':
            self.send_status()
        elif self.path == '/' or self.path == '/bridge_monitor.html':
            # Serve the HTML file
            self.path = '/bridge_monitor.html'
            return super().do_GET()
        else:
            super().do_GET()
    
    def do_POST(self):
        if self.path == '/api/kill-duplicates':
            self.kill_duplicates()
        else:
            self.send_error(404)
    
    def send_status(self):
        """Get bridge process status"""
        pids = self.get_bridge_processes()
        processes = []
        
        for pid in pids:
            details = self.get_process_details(pid)
            if details:
                processes.append(details)
            else:
                processes.append(f"PID: {pid}")
        
        response = {
            'count': len(pids),
            'pids': pids,
            'processes': processes
        }
        
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(response).encode())
    
    def kill_duplicates(self):
        """Kill all bridge processes except one"""
        pids = self.get_bridge_processes()
        if len(pids) <= 1:
            response = {'success': True, 'message': 'No duplicates to kill'}
        else:
            to_kill = pids[1:]
            try:
                for pid in to_kill:
                    subprocess.run(['kill', '-9', pid], timeout=5, check=True)
                response = {'success': True, 'killed': len(to_kill)}
            except Exception as e:
                response = {'success': False, 'error': str(e)}
        
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(response).encode())
    
    def get_bridge_processes(self):
        """Get list of bridge.py processes"""
        try:
            result = subprocess.run(
                ['pgrep', '-f', 'bridge.py'],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            if result.returncode == 0 and result.stdout.strip():
                return [pid.strip() for pid in result.stdout.strip().split('\n') if pid.strip()]
            return []
        except Exception:
            return []
    
    def get_process_details(self, pid):
        """Get detailed info about a process"""
        try:
            result = subprocess.run(
                ['ps', '-p', pid, '-o', 'pid,etime,command='],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                return result.stdout.strip()
            return None
        except Exception:
            return None
    
    def log_message(self, message):
        """Log a message"""
        print(f"[{self.log_date_time_string()}] {message}")


def main():
    PORT = 8765
    script_dir = Path(__file__).parent
    
    # Change to script directory to serve files
    import os
    os.chdir(script_dir)
    
    with socketserver.TCPServer(("", PORT), BridgeMonitorHandler) as httpd:
        print(f"🌐 Bridge Monitor Server running on http://localhost:{PORT}")
        print(f"📊 Open http://localhost:{PORT}/bridge_monitor.html in your browser")
        print("Press Ctrl+C to stop")
        
        # Try to open browser automatically
        try:
            import webbrowser
            webbrowser.open(f'http://localhost:{PORT}/bridge_monitor.html')
        except Exception:
            pass
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n👋 Shutting down server...")


if __name__ == "__main__":
    main()

