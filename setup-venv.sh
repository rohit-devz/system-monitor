#!/bin/bash

# System Monitor - Virtual Environment Setup

echo "🔧 Setting up Python Virtual Environment"
echo "========================================"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/venv"

echo "📂 Project directory: $SCRIPT_DIR"
echo "🐍 Virtual environment: $VENV_DIR"
echo ""

# Check if venv already exists
if [ -d "$VENV_DIR" ]; then
    echo "✅ Virtual environment already exists"
else
    echo "📦 Creating virtual environment..."
    python3 -m venv "$VENV_DIR"

    if [ $? -ne 0 ]; then
        echo "❌ Failed to create virtual environment"
        echo "   Try: sudo apt install python3-venv"
        exit 1
    fi
    echo "✅ Virtual environment created"
fi

echo ""
echo "📥 Installing dependencies..."
"$VENV_DIR/bin/pip" install --upgrade pip setuptools wheel
"$VENV_DIR/bin/pip" install streamlit psutil docker

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "✅ Dependencies installed"
echo ""
echo "✨ Setup complete!"
echo ""
echo "📝 To test the app, run:"
echo "   $VENV_DIR/bin/python -m streamlit run $SCRIPT_DIR/app.py"
echo ""
echo "Next step: Run the install-service.sh script to create the systemd service"
