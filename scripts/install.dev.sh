#!/bin/bash
# Script to install and configure the project dev environment setup

set -e

chmode +x scripts/utils/basic-install.sh
./scripts/utils/basic-install.sh

if ! grep -q 'TinyTeX/bin/x86_64-linux' ~/.profile 2>/dev/null; then
    echo 'export PATH="$HOME/.TinyTeX/bin/x86_64-linux:$PATH"' >> ~/.profile
    echo "Added TinyTeX bin to PATH in ~/.profile"
fi

echo "=== Installing tex-fmt (LaTex formatter written in rust) ==="
if ! command -v tex-fmt &>/dev/null; then
    if command -v cargo &>/dev/null; then
        cargo install tex-fmt
    else
        echo "Error: cargo is not installed. Please install Rust and Cargo first."
        exit 1
    fi
fi

# Recommended editor setup
echo "=== Installing LaTeX Workshop & LTex (for grammar) extensions for VS Code ==="
if command -v code &>/dev/null; then
    code --install-extension James-Yu.latex-workshop --force
    code --install-extension streetsidesoftware.code-spell-checker --force
    code --install-extension streetsidesoftware.code-spell-checker --force
else
    echo "Warning: VS Code (code) command not found. Skipping LaTeX Workshop extension installation."
fi

echo "=== Buscando el archivo .tex en la raíz ==="
TEXFILE=$(find . -maxdepth 1 -type f -name "*.tex" | head -n 1)

if [[ -z "$TEXFILE" ]]; then
    echo "Error: No se encontró ningún archivo .tex en la raíz."
    exit 1
fi

echo "=== Compilando el documento LaTeX: $TEXFILE ==="
if command -v latexmk &>/dev/null; then
    latexmk -pdf "$TEXFILE"
else
    BASENAME="${TEXFILE%.tex}"
    pdflatex "$TEXFILE"
    bibtex "${BASENAME}.aux" || true
    pdflatex "$TEXFILE"
    pdflatex "$TEXFILE"
fi

echo "=== Taskfile for common tasks ==="
if ! command -v task &>/dev/null; then
    if command -v npm &>/dev/null; then
        npm install -g @go-task/cli
    else
        echo "Error: npm is not installed. Please install Node.js and npm first."
        exit 1
    fi
fi

echo "=== Listo. Proyecto inicializado exitosamente. ==="
