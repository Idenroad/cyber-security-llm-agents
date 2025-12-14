#!/bin/bash
# Script to setup LLM models for Ollama

echo "==================================="
echo "Ollama Model Setup"
echo "==================================="
echo ""

# Check if Ollama is installed
if ! command -v ollama &> /dev/null
then
    echo "❌ Ollama is not installed. Please install it from https://ollama.ai"
    exit 1
fi

echo "✓ Ollama is installed"
echo ""
echo "Choose your setup option:"
echo "  1) Use llama3.1:8b (recommended - simple and fast)"
echo "  2) Install a custom model from GGUF file"
echo ""
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        echo ""
        echo "📥 Downloading llama3.1:8b model..."
        echo ""
        
        ollama pull llama3.1:8b
        
        if [ $? -ne 0 ]; then
            echo "❌ Failed to download the model"
            exit 1
        fi
        
        echo ""
        echo "✅ Model setup complete!"
        echo ""
        echo "To use this model, add this to your .env file:"
        echo "  OLLAMA_MODEL_NAME=\"llama3.1:8b\""
        echo ""
        echo "You can test it with:"
        echo "  ollama run llama3.1:8b"
        echo ""
        ;;
        
    2)
        echo ""
        echo "📦 Custom Model Installation"
        echo ""
        read -p "Enter the model name (e.g., pentest-agent): " model_name
        read -p "Enter the GGUF file URL: " gguf_url
        
        # Extract filename from URL
        gguf_filename="${model_name}.gguf"
        
        echo ""
        echo "📥 Downloading GGUF model..."
        echo "   Source: $gguf_url"
        echo ""
        
        if [ ! -f "$gguf_filename" ]; then
            wget -O "$gguf_filename" "$gguf_url"
            
            if [ $? -ne 0 ]; then
                echo "❌ Failed to download the model"
                exit 1
            fi
            echo "✓ Model downloaded successfully"
        else
            echo "✓ Model file already exists"
        fi
        
        echo ""
        echo "🔨 Creating Modelfile..."
        
        # Create a Modelfile
        cat > Modelfile << EOF
FROM ./${gguf_filename}

PARAMETER temperature 0.7
PARAMETER num_ctx 4096
PARAMETER top_p 0.9
PARAMETER top_k 40

SYSTEM """You are a helpful AI assistant specialized in cybersecurity and penetration testing. You provide accurate, detailed, and actionable security advice."""
EOF
        
        echo "✓ Modelfile created"
        echo ""
        echo "🔨 Creating model in Ollama..."
        
        ollama create "$model_name" -f Modelfile
        
        if [ $? -ne 0 ]; then
            echo "❌ Failed to create the model in Ollama"
            exit 1
        fi
        
        echo ""
        echo "✅ Model setup complete!"
        echo ""
        echo "To use this model, add this to your .env file:"
        echo "  OLLAMA_MODEL_NAME=\"$model_name\""
        echo ""
        echo "You can test it with:"
        echo "  ollama run $model_name"
        echo ""
        ;;
        
    *)
        echo "❌ Invalid choice. Please run the script again and choose 1 or 2."
        exit 1
        ;;
esac

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Example download URLs for custom models:"
echo "  - Pentest Agent (Llama 3.1 8B Q4):"
echo "    https://huggingface.co/jason-oneal/pentest-agent-q4_k_m-gguf/resolve/main/Meta-Llama-3.1-8B-Instruct.Q4_K_M.gguf?download=true"
echo "  - Other models: Browse https://huggingface.co/models?search=gguf"
echo ""
