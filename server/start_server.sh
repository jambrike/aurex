#!/bin/bash

# Aurex Server Startup Script
# This script starts the Aurex command server on your laptop

echo "=========================================="
echo "Aurex Server - iPhone Command Interface"
echo "=========================================="

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed. Please install Python 3 first."
    exit 1
fi

# Check if pip is installed
if ! command -v pip3 &> /dev/null; then
    echo "Error: pip3 is not installed. Please install pip3 first."
    exit 1
fi

# Install/upgrade required packages
echo "Installing/upgrading required packages..."
pip3 install -r requirements.txt

# Create necessary directories
echo "Creating necessary directories..."
mkdir -p screenshots
mkdir -p data
mkdir -p logs

# Get the local IP address
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "Your laptop's IP address is: $LOCAL_IP"
echo "Make sure your iPhone is connected to the same WiFi network."
echo ""

# Set environment variables
export AUREX_HOST="0.0.0.0"
export AUREX_PORT="8765"

# Start the server
echo "Starting Aurex server..."
echo "Server will be available at: ws://$LOCAL_IP:8765"
echo "Press Ctrl+C to stop the server"
echo ""

python3 aurex_server.py 