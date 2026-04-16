#!/bin/bash

# AG Suite Agent Framework — Instalador
# Uso: curl -fsSL https://raw.githubusercontent.com/angelgarcia-s/ag-suite-agente-framework/main/instalar.sh | bash

set -e

REPO_URL="https://github.com/angelgarcia-s/ag-suite-agente-framework"
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
linea() { echo -e "${GRIS}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }

echo ""
linea
echo -e "  ${NEGRITA}AG Suite Agent Framework — Instalador${RESET}"
linea
echo ""

# ─── Descargar ───────────────────────────────────────────────────────────────
info "Descargando framework..."

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

# ─── Instalar framework en HOME ──────────────────────────────────────────────
info "Instalando en $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp -r "$FRAMEWORK_SRC/template" "$INSTALL_DIR/"
cp -r "$FRAMEWORK_SRC/bin" "$INSTALL_DIR/"

# Apuntar el CLI a su directorio de instalación
sed -i.bak "s|RUTA_FRAMEWORK=\"\$(cd.*)\"|RUTA_FRAMEWORK=\"$INSTALL_DIR\"|" \
    "$INSTALL_DIR/bin/agente" 2>/dev/null || true
rm -f "$INSTALL_DIR/bin/agente.bak"

chmod +x "$INSTALL_DIR/bin/agente"
ok "Framework instalado"

# ─── Instalar comando 'agente' en PATH ───────────────────────────────────────
info "Instalando comando 'agente'..."

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"
ln -sf "$INSTALL_DIR/bin/agente" "$LOCAL_BIN/agente"
ok "Enlace creado en $LOCAL_BIN/agente"

# Verificar PATH
if ! echo "$PATH" | grep -q "$LOCAL_BIN"; then
    echo ""
    warn "Agrega esto a tu ~/.zshrc o ~/.bashrc para usar 'agente' globalmente:"
    echo ""
    echo -e "    ${VERDE}export PATH=\"\$HOME/.local/bin:\$PATH\"${RESET}"
    echo ""
    echo -e "  Luego ejecuta: ${VERDE}source ~/.zshrc${RESET}"
    echo ""
fi

# ─── Limpiar ─────────────────────────────────────────────────────────────────
rm -rf "$TMP_DIR"

# ─── Resultado ───────────────────────────────────────────────────────────────
echo ""
linea
echo -e "  ${VERDE}${NEGRITA}✅ AG Suite Agent Framework instalado${RESET}"
linea
echo ""
echo -e "  Ahora ve a tu proyecto y ejecuta:"
echo ""
echo -e "    ${VERDE}agente init${RESET}    Inicializa el framework en tu proyecto"
echo -e "    ${VERDE}agente help${RESET}    Ver todos los comandos"
echo ""
linea
echo ""
