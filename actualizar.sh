#!/bin/bash

# AG Suite Agent Framework — Actualizador
# Uso: bash <(curl -fsSL https://raw.githubusercontent.com/angelgarcia-s/ag-suite-agente-framework/main/actualizar.sh)
#
# La forma "curl ... | bash" también funciona: la confirmación se lee de
# /dev/tty, no de stdin (que ahí lo ocupa el propio script).
# Después de la primera instalación, usa: agente actualizar


set -e

REPO_URL="https://github.com/angelgarcia-s/ag-suite-agente-framework"
RAMA="main"
TMP_DIR="$(mktemp -d)"
INSTALL_DIR="$HOME/.ag-suite-agente-framework"

VERDE="\033[0;32m"
AMARILLO="\033[0;33m"
AZUL="\033[0;34m"
GRIS="\033[0;90m"
NEGRITA="\033[1m"
RESET="\033[0m"

ok()    { echo -e "  ${VERDE}✅${RESET} $1"; }
warn()  { echo -e "  ${AMARILLO}⚠️ ${RESET} $1"; }
info()  { echo -e "  ${AZUL}›${RESET}  $1"; }
skip()  { echo -e "  ${GRIS}⏭️  $1 — no modificado${RESET}"; }
linea() { echo -e "${GRIS}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }

echo ""
linea
echo -e "  ${NEGRITA}AG Suite Agent Framework — Actualizador${RESET}"
linea
echo ""
echo -e "  Actualiza el framework ${NEGRITA}global${RESET} en:"
echo -e "    ${GRIS}$INSTALL_DIR${RESET}"
echo ""
echo -e "  ${NEGRITA}No toca ningún proyecto.${RESET} Para aplicarlo a uno, después corre"
echo -e "  ${VERDE}agente actualizar proyecto${RESET} desde su raíz."
echo ""

# Se lee de /dev/tty y no de stdin: con 'curl ... | bash' el script llega POR
# stdin, así que un 'read' normal recibe EOF, contesta vacío y el actualizador
# se cancelaba solo sin actualizar nada. Si no hay terminal (CI), se continúa.
if [ -t 0 ] || [ -e /dev/tty ]; then
    read -p "  ¿Continuar? (s/N): " CONTINUAR < /dev/tty 2>/dev/null || CONTINUAR="s"
else
    CONTINUAR="s"
fi
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

# Detectar nombre de la carpeta extraída dinámicamente
FRAMEWORK_SRC="$(find "$TMP_DIR" -maxdepth 1 -type d -name "*-$RAMA" | head -1)"

if [ -z "$FRAMEWORK_SRC" ] || [ ! -d "$FRAMEWORK_SRC/template" ]; then
    echo "  ❌ No se encontró el template del framework."
    rm -rf "$TMP_DIR"
    exit 1
fi

ok "Framework descargado"

# ─── Actualizar framework en HOME ────────────────────────────────────────────
info "Actualizando archivos del framework..."

cp -r "$FRAMEWORK_SRC/template/docs/.agents/prompts" "$INSTALL_DIR/template/docs/.agents/"
cp "$FRAMEWORK_SRC/template/docs/.agents/agentes.md"              "$INSTALL_DIR/template/docs/.agents/"
cp "$FRAMEWORK_SRC/template/docs/.agents/arranque-terminal.md"    "$INSTALL_DIR/template/docs/.agents/"
cp "$FRAMEWORK_SRC/template/docs/.agents/arranque-sesion.md"      "$INSTALL_DIR/template/docs/.agents/"
cp "$FRAMEWORK_SRC/template/docs/.agents/agente-inicializador.md" "$INSTALL_DIR/template/docs/.agents/"
cp -r "$FRAMEWORK_SRC/template/scripts" "$INSTALL_DIR/template/"
cp "$FRAMEWORK_SRC/bin/agente" "$INSTALL_DIR/bin/agente"
cp "$FRAMEWORK_SRC/VERSION"    "$INSTALL_DIR/VERSION" 2>/dev/null || true

# Plantillas base del framework — se refrescan SOLO en el install dir.
# Son la fuente de la que 'agente init' copia en proyectos nuevos; sin esto
# el install dir queda con la versión vieja e init instala plantillas obsoletas.
# En el proyecto (más abajo) estos archivos NO se tocan nunca.
cp "$FRAMEWORK_SRC/template/docs/.agents/agent-config.TEMPLATE.md" "$INSTALL_DIR/template/docs/.agents/"
cp "$FRAMEWORK_SRC/template/docs/.agents/status.md"                "$INSTALL_DIR/template/docs/.agents/"
cp "$FRAMEWORK_SRC/template/Makefile"                              "$INSTALL_DIR/template/"
cp "$FRAMEWORK_SRC/template/CLAUDE.md"                             "$INSTALL_DIR/template/"
cp "$FRAMEWORK_SRC/template/AGENTS.md"                             "$INSTALL_DIR/template/"
mkdir -p "$INSTALL_DIR/template/.github/workflows"
cp "$FRAMEWORK_SRC/template/.github/workflows/agentes-ci.yml"      "$INSTALL_DIR/template/.github/workflows/"

chmod +x "$INSTALL_DIR/bin/agente"
chmod +x "$INSTALL_DIR/template/scripts/iniciar-agente.sh" 2>/dev/null
chmod +x "$INSTALL_DIR/template/scripts/lanzar-agentes-terminal.sh" 2>/dev/null

ok "Prompts actualizados"
ok "Scripts actualizados"
ok "CLI actualizado"
ok "Plantillas base actualizadas (agent-config.TEMPLATE.md, status.md, Makefile)"

# ─── Proyecto actual ─────────────────────────────────────────────────────────
# La actualización de una instancia NO se duplica aquí: la hace el CLI recién
# instalado ('agente actualizar proyecto'), que es el dueño de esa lógica.
# Así hay una sola definición del conjunto preservado, y este script queda
# como lo que es: el bootstrap que trae el framework global desde GitHub.
RUTA_PROYECTO="$(pwd)"
if [ -f "$RUTA_PROYECTO/docs/.agents/agent-config.md" ]; then
    echo ""
    info "Este directorio es un proyecto con el framework."
    echo ""
    echo -e "  Para aplicarle la versión nueva:"
    echo -e "    ${VERDE}agente actualizar proyecto${RESET}"
    echo ""
    echo -e "  ${GRIS}(Se hace por separado a propósito: así actualizas el framework una vez${RESET}"
    echo -e "  ${GRIS} y lo aplicas a los proyectos que quieras, cuando quieras.)${RESET}"
fi

# ─── Limpiar ─────────────────────────────────────────────────────────────────
rm -rf "$TMP_DIR"

echo ""
linea
echo -e "  ${VERDE}${NEGRITA}✅ Framework actualizado${RESET}"
linea
echo ""
