#!/bin/bash

# Sistema Multiagente — Lanzador en Terminal.app
# Abre una ventana por agente
# Uso: ./scripts/lanzar-agentes-terminal.sh

RUTA_PROYECTO="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_INICIO="$RUTA_PROYECTO/scripts/iniciar-agente.sh"

NOMBRE_PROYECTO=$(grep "^nombre=" "$RUTA_PROYECTO/docs/.agents/agent-config.md" 2>/dev/null | cut -d= -f2)
NOMBRE_PROYECTO="${NOMBRE_PROYECTO:-Proyecto}"

abrir_agente() {
    local rol="$1"
    local titulo="$2"
    osascript <<EOF
tell application "Terminal"
    activate
    set nuevaVentana to do script "bash '$SCRIPT_INICIO' $rol"
    set custom title of nuevaVentana to "$titulo"
end tell
EOF
    sleep 0.8
}

echo "🚀 Lanzando agentes de $NOMBRE_PROYECTO..."
echo "   Proyecto: $RUTA_PROYECTO"
echo ""

abrir_agente "orquestador"  "$NOMBRE_PROYECTO | 🧠 Orquestador"
abrir_agente "backend"      "$NOMBRE_PROYECTO | ⚙️  Backend"
abrir_agente "frontend"     "$NOMBRE_PROYECTO | 🎨 Frontend"
abrir_agente "contexto"     "$NOMBRE_PROYECTO | 📋 Contexto"
abrir_agente "documentador" "$NOMBRE_PROYECTO | 📚 Documentador"

echo "✅ 5 agentes lanzados."
