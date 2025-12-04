#!/usr/bin/env python3
"""
Bridge Process Monitor GUI
Shows how many bridge.py processes are currently running
"""

import tkinter as tk
from tkinter import ttk, scrolledtext
import subprocess
import threading
import time
from datetime import datetime


class BridgeMonitor:
    def __init__(self, root):
        self.root = root
        self.root.title("Bridge Process Monitor")
        self.root.geometry("600x400")
        self.root.resizable(True, True)
        
        # Auto-refresh every 2 seconds
        self.refresh_interval = 2.0
        self.auto_refresh = True
        
        self.setup_ui()
        self.update_status()
        self.start_auto_refresh()
    
    def setup_ui(self):
        # Main frame
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(0, weight=1)
        
        # Title
        title_label = ttk.Label(
            main_frame, 
            text="Bridge Process Monitor", 
            font=("Helvetica", 16, "bold")
        )
        title_label.grid(row=0, column=0, pady=(0, 10))
        
        # Status frame
        status_frame = ttk.LabelFrame(main_frame, text="Status", padding="10")
        status_frame.grid(row=1, column=0, sticky=(tk.W, tk.E), pady=(0, 10))
        status_frame.columnconfigure(1, weight=1)
        
        # Process count display
        self.count_label = ttk.Label(
            status_frame, 
            text="Checking...", 
            font=("Helvetica", 24, "bold")
        )
        self.count_label.grid(row=0, column=0, columnspan=2, pady=10)
        
        # Status text
        self.status_label = ttk.Label(
            status_frame, 
            text="", 
            font=("Helvetica", 12)
        )
        self.status_label.grid(row=1, column=0, columnspan=2, pady=5)
        
        # Process details
        self.details_label = ttk.Label(
            status_frame, 
            text="", 
            font=("Helvetica", 10),
            foreground="gray"
        )
        self.details_label.grid(row=2, column=0, columnspan=2, pady=5)
        
        # Last update time
        self.update_time_label = ttk.Label(
            status_frame, 
            text="", 
            font=("Helvetica", 9),
            foreground="gray"
        )
        self.update_time_label.grid(row=3, column=0, columnspan=2, pady=5)
        
        # Controls frame
        controls_frame = ttk.Frame(main_frame)
        controls_frame.grid(row=2, column=0, sticky=(tk.W, tk.E), pady=(0, 10))
        
        # Refresh button
        refresh_btn = ttk.Button(
            controls_frame, 
            text="🔄 Refresh Now", 
            command=self.update_status
        )
        refresh_btn.grid(row=0, column=0, padx=(0, 10))
        
        # Kill duplicates button (initially hidden)
        self.kill_duplicates_btn = ttk.Button(
            controls_frame, 
            text="⚠️ Kill Duplicates", 
            command=self.kill_duplicates,
            state=tk.DISABLED
        )
        self.kill_duplicates_btn.grid(row=0, column=1, padx=(0, 10))
        
        # Auto-refresh toggle
        self.auto_refresh_var = tk.BooleanVar(value=True)
        auto_refresh_check = ttk.Checkbutton(
            controls_frame,
            text="Auto-refresh (2s)",
            variable=self.auto_refresh_var,
            command=self.toggle_auto_refresh
        )
        auto_refresh_check.grid(row=0, column=2)
        
        # Log/Details area
        log_frame = ttk.LabelFrame(main_frame, text="Process Details", padding="10")
        log_frame.grid(row=3, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), pady=(0, 10))
        log_frame.columnconfigure(0, weight=1)
        log_frame.rowconfigure(0, weight=1)
        main_frame.rowconfigure(3, weight=1)
        
        self.log_text = scrolledtext.ScrolledText(
            log_frame, 
            height=8, 
            font=("Monaco", 10),
            wrap=tk.WORD
        )
        self.log_text.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        self.log_text.config(state=tk.DISABLED)
    
    def get_bridge_processes(self):
        """Get list of bridge.py processes"""
        try:
            result = subprocess.run(
                ["pgrep", "-f", "bridge.py"],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            if result.returncode == 0 and result.stdout.strip():
                pids = [pid.strip() for pid in result.stdout.strip().split('\n') if pid.strip()]
                return pids
            else:
                return []
        except subprocess.TimeoutExpired:
            return []
        except Exception as e:
            self.log_message(f"Error getting processes: {e}")
            return []
    
    def get_process_details(self, pid):
        """Get detailed info about a process"""
        try:
            result = subprocess.run(
                ["ps", "-p", pid, "-o", "pid,etime,command="],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                return result.stdout.strip()
            return None
        except Exception:
            return None
    
    def update_status(self):
        """Update the status display"""
        pids = self.get_bridge_processes()
        count = len(pids)
        
        # Update count display with color
        if count == 0:
            self.count_label.config(text="0", foreground="red")
            self.status_label.config(text="❌ No bridge processes running", foreground="red")
            self.details_label.config(text="Bridge is not running")
            self.kill_duplicates_btn.config(state=tk.DISABLED)
        elif count == 1:
            self.count_label.config(text="1", foreground="green")
            self.status_label.config(text="✅ One bridge process running (correct)", foreground="green")
            pid = pids[0]
            details = self.get_process_details(pid)
            if details:
                self.details_label.config(text=f"PID: {pid}")
            else:
                self.details_label.config(text=f"PID: {pid}")
            self.kill_duplicates_btn.config(state=tk.DISABLED)
        else:
            self.count_label.config(text=str(count), foreground="orange")
            self.status_label.config(
                text=f"⚠️ {count} bridge processes running (should be 1)", 
                foreground="orange"
            )
            self.details_label.config(text=f"PIDs: {', '.join(pids)}")
            self.kill_duplicates_btn.config(state=tk.NORMAL)
        
        # Update log
        self.log_text.config(state=tk.NORMAL)
        self.log_text.delete(1.0, tk.END)
        
        if count == 0:
            self.log_text.insert(tk.END, "No bridge processes found.\n\n")
            self.log_text.insert(tk.END, "To start the bridge:\n")
            self.log_text.insert(tk.END, "  launchctl start com.sf.imessage-bridge\n")
            self.log_text.insert(tk.END, "  or\n")
            self.log_text.insert(tk.END, "  ./keep_bridge_alive.sh\n")
        else:
            self.log_text.insert(tk.END, f"Found {count} bridge process(es):\n\n")
            for pid in pids:
                details = self.get_process_details(pid)
                if details:
                    self.log_text.insert(tk.END, f"{details}\n")
                else:
                    self.log_text.insert(tk.END, f"PID: {pid}\n")
                self.log_text.insert(tk.END, "\n")
            
            if count > 1:
                self.log_text.insert(tk.END, "\n⚠️ Multiple instances detected!\n")
                self.log_text.insert(tk.END, "Click 'Kill Duplicates' to stop all but one.\n")
        
        self.log_text.config(state=tk.DISABLED)
        
        # Update timestamp
        now = datetime.now().strftime("%H:%M:%S")
        self.update_time_label.config(text=f"Last updated: {now}")
    
    def kill_duplicates(self):
        """Kill all bridge processes except one"""
        pids = self.get_bridge_processes()
        if len(pids) <= 1:
            return
        
        # Keep the first one, kill the rest
        to_kill = pids[1:]
        
        try:
            for pid in to_kill:
                subprocess.run(["kill", "-9", pid], timeout=5)
            self.log_message(f"Killed {len(to_kill)} duplicate process(es)")
            # Wait a moment then refresh
            self.root.after(500, self.update_status)
        except Exception as e:
            self.log_message(f"Error killing processes: {e}")
    
    def log_message(self, message):
        """Add a message to the log"""
        self.log_text.config(state=tk.NORMAL)
        timestamp = datetime.now().strftime("%H:%M:%S")
        self.log_text.insert(tk.END, f"[{timestamp}] {message}\n")
        self.log_text.see(tk.END)
        self.log_text.config(state=tk.DISABLED)
    
    def toggle_auto_refresh(self):
        """Toggle auto-refresh on/off"""
        self.auto_refresh = self.auto_refresh_var.get()
        if self.auto_refresh:
            self.start_auto_refresh()
        else:
            self.stop_auto_refresh()
    
    def start_auto_refresh(self):
        """Start auto-refresh loop"""
        if self.auto_refresh:
            self.update_status()
            self.root.after(int(self.refresh_interval * 1000), self.start_auto_refresh)
    
    def stop_auto_refresh(self):
        """Stop auto-refresh (handled by checking flag)"""
        pass


def main():
    root = tk.Tk()
    app = BridgeMonitor(root)
    root.mainloop()


if __name__ == "__main__":
    main()

