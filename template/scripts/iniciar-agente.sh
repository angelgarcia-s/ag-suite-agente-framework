#!/bin/bash

# Sistema Multiagente — Arranque de un agente individual
# Uso: ./scripts/iniciar-agente.sh [rol]
# Roles válidos: orquestador | backend | frontend | contexto | documentador

RUTA_PROYECTO="$(cd "$(dirname "$0")/.." && pwd)"
ROL="$1"

if [ -z "$ROL" ]; then
    echo "❌ Uso: ./scripts/iniciar-agente.sh [orquestador|backend|frontend|contexto|documentador]"
    exit 1
fi

cd "$RUTA_PROYECTO" || exit 1

# Leer nombre del proyecto desde agent-config.md
NOMBRE_PROYECTO=$(grep "^nombre=" docs/.agents/agent-config.md 2>/dev/null | cut -d= -f2)
NOMBRE_PROYECTO="${NOMBRE_PROYECTO:-Proyecto}"

clear

case "$ROL" in
    orquestador)
        ETIQUETA="🧠 Orquestador"
        ARCHIVO_PROMPT="docs/.agents/prompts/orchestrator.md"
        ;;
    backend)
        ETIQUETA="⚙️  Backend"
        ARCHIVO_PROMPT="docs/.agents/prompts/backend.md"
        ;;
    frontend)
        ETIQUETA="🎨 Frontend"
        ARCHIVO_PROMPT="docs/.agents/prompts/frontend.md"
        ;;
    contexto)
        ETIQUETA="📋 Contexto"
        ARCHIVO_PROMPT="docs/.agents/prompts/context.md"
        ;;
    documentador)
        ETIQUETA="📚 Documentador"
        ARCHIVO_PROMPT="docs/.agents/prompts/featuredocs.md"
        ;;
    *)
        echo "❌ Rol desconocido: $ROL"
        echo "Roles válidos: orquestador | backend | frontend | contexto | documentador"
        exit 1
        ;;
esac

if [ ! -f "$RUTA_PROYECTO/$ARCHIVO_PROMPT" ]; then
    echo "❌ Archivo de prompt no encontrado: $ARCHIVO_PROMPT"
    echo "   Asegúrate de haber instalado el framework correctamente."
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  $NOMBRE_PROYECTO — $ETIQUETA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Proyecto : $RUTA_PROYECTO"
echo "  Prompt   : $ARCHIVO_PROMPT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

exec claude \
    --append-system-prompt "$(cat "$RUTA_PROYECTO/$ARCHIVO_PROMPT")" \
    --name "$NOMBRE_PROYECTO | $ETIQUETA"
