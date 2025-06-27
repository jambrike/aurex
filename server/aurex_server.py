#!/usr/bin/env python3
"""
Aurex Server - Command execution server for iPhone app
Handles WebSocket connections and executes commands on the laptop
"""

import asyncio
import json
import logging
import os
import subprocess
import sys
import websockets
from datetime import datetime
from typing import Dict, List, Optional
import psutil
import pyautogui
import keyboard
import mouse
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('aurex_server.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class CommandExecutor:
    """Handles execution of various commands on the laptop"""
    
    def __init__(self):
        self.command_history: List[Dict] = []
        self.custom_commands = self.load_custom_commands()
        
    def load_custom_commands(self) -> Dict[str, str]:
        """Load custom command mappings from config file"""
        config_path = Path(__file__).parent / "config" / "commands.json"
        if config_path.exists():
            try:
                with open(config_path, 'r') as f:
                    return json.load(f)
            except Exception as e:
                logger.error(f"Failed to load custom commands: {e}")
        return {}
    
    def save_command_history(self):
        """Save command history to file"""
        history_path = Path(__file__).parent / "data" / "command_history.json"
        history_path.parent.mkdir(exist_ok=True)
        
        try:
            with open(history_path, 'w') as f:
                json.dump(self.command_history, f, indent=2, default=str)
        except Exception as e:
            logger.error(f"Failed to save command history: {e}")
    
    def execute_command(self, command_text: str) -> Dict:
        """Execute a command and return the result"""
        command_text = command_text.strip().lower()
        timestamp = datetime.now()
        
        logger.info(f"Executing command: {command_text}")
        
        result = {
            "command": command_text,
            "timestamp": timestamp.isoformat(),
            "success": False,
            "output": "",
            "error": ""
        }
        
        try:
            # Check for custom commands first
            if command_text in self.custom_commands:
                result = self.execute_custom_command(command_text)
            else:
                # Handle built-in commands
                result = self.execute_builtin_command(command_text)
            
            # Add to history
            self.command_history.append(result)
            if len(self.command_history) > 1000:  # Keep last 1000 commands
                self.command_history = self.command_history[-1000:]
            
            self.save_command_history()
            
        except Exception as e:
            result["error"] = str(e)
            logger.error(f"Command execution failed: {e}")
        
        return result
    
    def execute_custom_command(self, command_text: str) -> Dict:
        """Execute a custom command"""
        custom_cmd = self.custom_commands[command_text]
        logger.info(f"Executing custom command: {custom_cmd}")
        
        try:
            # Execute the custom command
            process = subprocess.run(
                custom_cmd,
                shell=True,
                capture_output=True,
                text=True,
                timeout=30
            )
            
            return {
                "command": command_text,
                "timestamp": datetime.now().isoformat(),
                "success": process.returncode == 0,
                "output": process.stdout,
                "error": process.stderr
            }
        except subprocess.TimeoutExpired:
            return {
                "command": command_text,
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": "Command timed out"
            }
    
    def execute_builtin_command(self, command_text: str) -> Dict:
        """Execute built-in commands"""
        
        # System commands
        if command_text in ["lock", "lock computer", "lock screen"]:
            return self.lock_computer()
        
        elif command_text in ["sleep", "suspend"]:
            return self.sleep_computer()
        
        elif command_text in ["shutdown", "turn off", "power off"]:
            return self.shutdown_computer()
        
        elif command_text in ["restart", "reboot"]:
            return self.restart_computer()
        
        # Application commands
        elif command_text.startswith("open "):
            app_name = command_text[5:]  # Remove "open "
            return self.open_application(app_name)
        
        elif command_text.startswith("close "):
            app_name = command_text[6:]  # Remove "close "
            return self.close_application(app_name)
        
        # Media controls
        elif command_text in ["play", "pause", "play/pause"]:
            return self.media_play_pause()
        
        elif command_text in ["next", "next track"]:
            return self.media_next()
        
        elif command_text in ["previous", "previous track"]:
            return self.media_previous()
        
        elif command_text in ["volume up", "increase volume"]:
            return self.volume_up()
        
        elif command_text in ["volume down", "decrease volume"]:
            return self.volume_down()
        
        elif command_text in ["mute", "unmute"]:
            return self.volume_mute()
        
        # Screenshot
        elif command_text in ["screenshot", "take screenshot", "capture screen"]:
            return self.take_screenshot()
        
        # Clipboard
        elif command_text in ["copy", "copy to clipboard"]:
            return self.copy_to_clipboard()
        
        elif command_text in ["paste", "paste from clipboard"]:
            return self.paste_from_clipboard()
        
        # System info
        elif command_text in ["system info", "system status", "status"]:
            return self.get_system_info()
        
        # Default: try to run as shell command
        else:
            return self.run_shell_command(command_text)
    
    def lock_computer(self) -> Dict:
        """Lock the computer"""
        try:
            if sys.platform == "win32":
                subprocess.run(["rundll32.exe", "user32.dll,LockWorkStation"])
            elif sys.platform == "darwin":  # macOS
                subprocess.run(["pmset", "displaysleepnow"])
            else:  # Linux
                subprocess.run(["gnome-screensaver-command", "--lock"])
            
            return {
                "command": "lock computer",
                "timestamp": datetime.now().isoformat(),
                "success": True,
                "output": "Computer locked successfully",
                "error": ""
            }
        except Exception as e:
            return {
                "command": "lock computer",
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": str(e)
            }
    
    def sleep_computer(self) -> Dict:
        """Put computer to sleep"""
        try:
            if sys.platform == "win32":
                subprocess.run(["powercfg", "/hibernate", "off"])
                subprocess.run(["rundll32.exe", "powrprof.dll,SetSuspendState", "0,1,0"])
            elif sys.platform == "darwin":
                subprocess.run(["pmset", "sleepnow"])
            else:
                subprocess.run(["systemctl", "suspend"])
            
            return {
                "command": "sleep",
                "timestamp": datetime.now().isoformat(),
                "success": True,
                "output": "Computer put to sleep",
                "error": ""
            }
        except Exception as e:
            return {
                "command": "sleep",
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": str(e)
            }
    
    def shutdown_computer(self) -> Dict:
        """Shutdown the computer"""
        try:
            if sys.platform == "win32":
                subprocess.run(["shutdown", "/s", "/t", "0"])
            elif sys.platform == "darwin":
                subprocess.run(["sudo", "shutdown", "-h", "now"])
            else:
                subprocess.run(["sudo", "shutdown", "-h", "now"])
            
            return {
                "command": "shutdown",
                "timestamp": datetime.now().isoformat(),
                "success": True,
                "output": "Computer shutting down",
                "error": ""
            }
        except Exception as e:
            return {
                "command": "shutdown",
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": str(e)
            }
    
    def restart_computer(self) -> Dict:
        """Restart the computer"""
        try:
            if sys.platform == "win32":
                subprocess.run(["shutdown", "/r", "/t", "0"])
            elif sys.platform == "darwin":
                subprocess.run(["sudo", "shutdown", "-r", "now"])
            else:
                subprocess.run(["sudo", "shutdown", "-r", "now"])
            
            return {
                "command": "restart",
                "timestamp": datetime.now().isoformat(),
                "success": True,
                "output": "Computer restarting",
                "error": ""
            }
        except Exception as e:
            return {
                "command": "restart",
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": str(e)
            }
    
    def open_application(self, app_name: str) -> Dict:
        """Open an application"""
        try:
            # Common applications mapping
            app_mapping = {
                "chrome": "google-chrome",
                "firefox": "firefox",
                "safari": "safari",
                "edge": "msedge",
                "spotify": "spotify",
                "music": "spotify",
                "terminal": "gnome-terminal" if sys.platform != "win32" else "cmd",
                "calculator": "gnome-calculator" if sys.platform != "win32" else "calc",
                "notepad": "notepad" if sys.platform == "win32" else "gedit",
                "finder": "nautilus" if sys.platform != "win32" else "explorer",
                "explorer": "explorer" if sys.platform == "win32" else "nautilus"
            }
            
            app_to_open = app_mapping.get(app_name, app_name)
            
            if sys.platform == "win32":
                subprocess.Popen(app_to_open, shell=True)
            else:
                subprocess.Popen([app_to_open])
            
            return {
                "command": f"open {app_name}",
                "timestamp": datetime.now().isoformat(),
                "success": True,
                "output": f"Opened {app_name}",
                "error": ""
            }
        except Exception as e:
            return {
                "command": f"open {app_name}",
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": str(e)
            }
    
    def close_application(self, app_name: str) -> Dict:
        """Close an application"""
        try:
            # Kill processes by name
            for proc in psutil.process_iter(['pid', 'name']):
                if app_name.lower() in proc.info['name'].lower():
                    proc.kill()
            
            return {
                "command": f"close {app_name}",
                "timestamp": datetime.now().isoformat(),
                "success": True,
                "output": f"Closed {app_name}",
                "error": ""
            }
        except Exception as e:
            return {
                "command": f"close {app_name}",
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": str(e)
            }
    
    def media_play_pause(self) -> Dict:
        """Media play/pause"""
        try:
            keyboard.press_and_release('play/pause media')
            return {
                "command": "play/pause",
                "timestamp": datetime.now().isoformat(),
                "success": True,
                "output": "Media play/pause toggled",
                "error": ""
            }
        except Exception as e:
            return {
                "command": "play/pause",
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": str(e)
            }
    
    def media_next(self) -> Dict:
        """Next track"""
        try:
            keyboard.press_and_release('next track media')
            return {
                "command": "next track",
                "timestamp": datetime.now().isoformat(),
                "success": True,
                "output": "Next track",
                "error": ""
            }
        except Exception as e:
            return {
                "command": "next track",
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": str(e)
            }
    
    def media_previous(self) -> Dict:
        """Previous track"""
        try:
            keyboard.press_and_release('previous track media')
            return {
                "command": "previous track",
                "timestamp": datetime.now().isoformat(),
                "success": True,
                "output": "Previous track",
                "error": ""
            }
        except Exception as e:
            return {
                "command": "previous track",
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": str(e)
            }
    
    def volume_up(self) -> Dict:
        """Increase volume"""
        try:
            keyboard.press_and_release('volume up')
            return {
                "command": "volume up",
                "timestamp": datetime.now().isoformat(),
                "success": True,
                "output": "Volume increased",
                "error": ""
            }
        except Exception as e:
            return {
                "command": "volume up",
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": str(e)
            }
    
    def volume_down(self) -> Dict:
        """Decrease volume"""
        try:
            keyboard.press_and_release('volume down')
            return {
                "command": "volume down",
                "timestamp": datetime.now().isoformat(),
                "success": True,
                "output": "Volume decreased",
                "error": ""
            }
        except Exception as e:
            return {
                "command": "volume down",
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": str(e)
            }
    
    def volume_mute(self) -> Dict:
        """Mute/unmute volume"""
        try:
            keyboard.press_and_release('volume mute')
            return {
                "command": "mute",
                "timestamp": datetime.now().isoformat(),
                "success": True,
                "output": "Volume muted/unmuted",
                "error": ""
            }
        except Exception as e:
            return {
                "command": "mute",
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": str(e)
            }
    
    def take_screenshot(self) -> Dict:
        """Take a screenshot"""
        try:
            screenshot_path = Path(__file__).parent / "screenshots"
            screenshot_path.mkdir(exist_ok=True)
            
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"screenshot_{timestamp}.png"
            filepath = screenshot_path / filename
            
            screenshot = pyautogui.screenshot()
            screenshot.save(filepath)
            
            return {
                "command": "screenshot",
                "timestamp": datetime.now().isoformat(),
                "success": True,
                "output": f"Screenshot saved: {filepath}",
                "error": ""
            }
        except Exception as e:
            return {
                "command": "screenshot",
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": str(e)
            }
    
    def copy_to_clipboard(self) -> Dict:
        """Copy selected text to clipboard"""
        try:
            pyautogui.hotkey('ctrl', 'c')
            return {
                "command": "copy",
                "timestamp": datetime.now().isoformat(),
                "success": True,
                "output": "Copied to clipboard",
                "error": ""
            }
        except Exception as e:
            return {
                "command": "copy",
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": str(e)
            }
    
    def paste_from_clipboard(self) -> Dict:
        """Paste from clipboard"""
        try:
            pyautogui.hotkey('ctrl', 'v')
            return {
                "command": "paste",
                "timestamp": datetime.now().isoformat(),
                "success": True,
                "output": "Pasted from clipboard",
                "error": ""
            }
        except Exception as e:
            return {
                "command": "paste",
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": str(e)
            }
    
    def get_system_info(self) -> Dict:
        """Get system information"""
        try:
            cpu_percent = psutil.cpu_percent(interval=1)
            memory = psutil.virtual_memory()
            disk = psutil.disk_usage('/')
            
            info = {
                "cpu_usage": f"{cpu_percent}%",
                "memory_usage": f"{memory.percent}%",
                "disk_usage": f"{disk.percent}%",
                "platform": sys.platform,
                "uptime": str(datetime.now() - datetime.fromtimestamp(psutil.boot_time()))
            }
            
            return {
                "command": "system info",
                "timestamp": datetime.now().isoformat(),
                "success": True,
                "output": json.dumps(info, indent=2),
                "error": ""
            }
        except Exception as e:
            return {
                "command": "system info",
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": str(e)
            }
    
    def run_shell_command(self, command: str) -> Dict:
        """Run a shell command"""
        try:
            process = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=30
            )
            
            return {
                "command": command,
                "timestamp": datetime.now().isoformat(),
                "success": process.returncode == 0,
                "output": process.stdout,
                "error": process.stderr
            }
        except subprocess.TimeoutExpired:
            return {
                "command": command,
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": "Command timed out"
            }
        except Exception as e:
            return {
                "command": command,
                "timestamp": datetime.now().isoformat(),
                "success": False,
                "output": "",
                "error": str(e)
            }

class AurexServer:
    """WebSocket server for handling iPhone app connections"""
    
    def __init__(self, host: str = "0.0.0.0", port: int = 8765):
        self.host = host
        self.port = port
        self.executor = CommandExecutor()
        self.clients = set()
    
    async def handle_client(self, websocket, path):
        """Handle individual client connections"""
        client_id = id(websocket)
        self.clients.add(websocket)
        
        logger.info(f"Client {client_id} connected from {websocket.remote_address}")
        
        try:
            async for message in websocket:
                try:
                    # Parse the command
                    command_text = message.strip()
                    
                    if not command_text:
                        continue
                    
                    # Execute the command
                    result = self.executor.execute_command(command_text)
                    
                    # Send result back to client
                    response = json.dumps(result)
                    await websocket.send(response)
                    
                    logger.info(f"Command executed: {command_text} - Success: {result['success']}")
                    
                except json.JSONDecodeError:
                    logger.error(f"Invalid JSON from client {client_id}")
                    await websocket.send(json.dumps({
                        "error": "Invalid JSON format",
                        "success": False
                    }))
                except Exception as e:
                    logger.error(f"Error processing command from client {client_id}: {e}")
                    await websocket.send(json.dumps({
                        "error": str(e),
                        "success": False
                    }))
        
        except websockets.exceptions.ConnectionClosed:
            logger.info(f"Client {client_id} disconnected")
        except Exception as e:
            logger.error(f"Error with client {client_id}: {e}")
        finally:
            self.clients.remove(websocket)
    
    async def start_server(self):
        """Start the WebSocket server"""
        logger.info(f"Starting Aurex server on {self.host}:{self.port}")
        
        try:
            async with websockets.serve(self.handle_client, self.host, self.port):
                logger.info("Aurex server is running. Press Ctrl+C to stop.")
                await asyncio.Future()  # Run forever
        except KeyboardInterrupt:
            logger.info("Server stopped by user")
        except Exception as e:
            logger.error(f"Server error: {e}")

def main():
    """Main entry point"""
    print("=" * 50)
    print("Aurex Server - iPhone Command Interface")
    print("=" * 50)
    
    # Get server configuration
    host = os.getenv("AUREX_HOST", "0.0.0.0")
    port = int(os.getenv("AUREX_PORT", "8765"))
    
    # Create and start server
    server = AurexServer(host, port)
    
    try:
        asyncio.run(server.start_server())
    except KeyboardInterrupt:
        print("\nServer stopped.")
    except Exception as e:
        logger.error(f"Failed to start server: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main() 