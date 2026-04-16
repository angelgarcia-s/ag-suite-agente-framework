#!/bin/bash

# AG Suite Agent Framework — Actualizador
# Actualiza los archivos genéricos sin tocar agent-config.md ni status.md
# Uso: curl -fsSL https://raw.githubusercontent.com/tu-usuario/agente-framework/main/actualizar.sh | bash

set -e

REPO_URL="https://github.com/tu-usuario/agente-framework"
RAMA="main"
TMP_DIR="$(mktemp -d)"
INSTALL_DIR="$HOME/.agente-framework"

VERDE="\033[0;32m"
AMARILLO="\033[0;33m"
AZUL="\033[0;34m"
GRIS="\033[0;90m"
NEGRITA="\033[1m"
RESET="\033[0m"

ok()    { echo -e "  ${VERDE}✅${RESET} $1"; }
warn()  { echo -e "  ${AMARILLO}⚠️ ${RESET} $1"; }
info()  { echo -e "  ${AZUL}→${RESET}  $1"; }
skip()  { echo -e "  ${GRIS}⏭️  $1 — no modificado${RESET}"; }
linea() { echo -e "${GRIS}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }

echo ""
linea
echo -e "  ${NEGRITA}AG Suite Agent Framework — Actualizador${RESET}"
linea
echo ""
warn "Solo se actualizarán archivos genéricos."
warn "agent-config.md y status.md NO se tocarán."
echo ""
read -p "  ¿Continuar? (s/N): " CONTINUAR
[[ "$CONTINUAR" != "s" && "$CONTINUAR" != "S" ]] && { echo "  Cancelado."; exit 0; }
echo ""

# ─── Descargar ───────────────────────────────────────────────────────────────
info "Descargando versión actualizada..."

if command -v curl &>/dev/null; then
    curl -fsSL "$REPO_URL/archive/$RAMA.zip" -o "$TMP_DIR/framework.zip"
elif command -v wget &>/dev/null; then
    wget -q "$REPO_URL/archive/$RAMA.zip" -O "$TMP_DIR/framework.zip"
else
    echo "  ❌ Se necesita curl o wget."
    exit 1
fi

unzip -q "$TMP_DIR/framework.zip" -d "$TMP_DIR"
FRAMEWORK_SRC="$TMP_DIR/agente-framework-$RAMA"

# ─── Actualizar framework en HOME ────────────────────────────────────────────
info "Actualizando archivos del framework..."

cp -r "$FRAMEWORK_SRC/template/docs/.agents/prompts" "$INSTALL_DIR/template/docs/.agents/"
cp "$FRAMEWORK_SRC/template/docs/.agents/agentes.md"             "$INSTALL_DIR/template/docs/.agents/"
cp "$FRAMEWORK_SRC/template/docs/.agents/arranque-terminal.md"   "$INSTALL_DIR/template/docs/.agents/"
cp "$FRAMEWORK_SRC/template/docs/.agents/arranque-sesion.md"     "$INSTALL_DIR/template/docs/.agents/"
cp "$FRAMEWORK_SRC/template/docs/.agents/agente-inicializador.md" "$INSTALL_DIR/template/docs/.agents/"
cp -r "$FRAMEWORK_SRC/template/scripts" "$INSTALL_DIR/template/"
cp "$FRAMEWORK_SRC/bin/agente" "$INSTALL_DIR/bin/agente"
chmod +x "$INSTALL_DIR/bin/agente"

ok "Prompts actualizados"
ok "Scripts actualizados"
ok "CLI actualizado"

skip "agent-config.md"
skip "status.md"
skip "Makefile del proyecto"

# ─── Actualizar en proyecto actual ───────────────────────────────────────────
RUTA_PROYECTO="$(pwd)"
if [ -d "$RUTA_PROYECTO/docs/.agents" ]; then
    echo ""
    info "Actualizando archivos en el proyecto actual..."

    cp -r "$FRAMEWORK_SRC/template/docs/.agents/prompts/." "$RUTA_PROYECTO/docs/.agents/prompts/"
    cp "$FRAMEWORK_SRC/template/docs/.agents/agentes.md"              "$RUTA_PROYECTO/docs/.agents/"
    cp "$FRAMEWORK_SRC/template/docs/.agents/arranque-terminal.md"    "$RUTA_PROYECTO/docs/.agents/"
    cp "$FRAMEWORK_SRC/template/docs/.agents/arranque-sesion.md"      "$RUTA_PROYECTO/docs/.agents/"
    cp "$FRAMEWORK_SRC/template/docs/.agents/agente-inicializador.md" "$RUTA_PROYECTO/docs/.agents/"

    for script in iniciar-agente.sh lanzar-agentes-iterm.applescript lanzar-agentes-terminal.sh; do
        cp "$FRAMEWORK_SRC/template/scripts/$script" "$RUTA_PROYECTO/scripts/$script"
    done
    chmod +x "$RUTA_PROYECTO/scripts/iniciar-agente.sh"
    chmod +x "$RUTA_PROYECTO/scripts/lanzar-agentes-terminal.sh"

    ok "Proyecto actualizado"
fi

# ─── Limpiar ─────────────────────────────────────────────────────────────────
rm -rf "$TMP_DIR"

echo ""
linea
echo -e "  ${VERDE}${NEGRITA}✅ Framework actualizado${RESET}"
linea
echo ""
