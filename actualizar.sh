#!/bin/bash

# AG Suite Agent Framework — Actualizador
# Uso: curl -fsSL https://raw.githubusercontent.com/angelgarcia-s/ag-suite-agente-framework/main/actualizar.sh | bash

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
warn "Solo se actualizarán archivos genéricos."
warn "El agent-config.md y el status.md de tu proyecto NO se tocarán."
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

# Plantillas base del framework — se refrescan SOLO en el install dir.
# Son la fuente de la que 'agente init' copia en proyectos nuevos; sin esto
# el install dir queda con la versión vieja e init instala plantillas obsoletas.
# En el proyecto (más abajo) estos archivos NO se tocan nunca.
cp "$FRAMEWORK_SRC/template/docs/.agents/agent-config.TEMPLATE.md" "$INSTALL_DIR/template/docs/.agents/"
cp "$FRAMEWORK_SRC/template/docs/.agents/status.md"                "$INSTALL_DIR/template/docs/.agents/"
cp "$FRAMEWORK_SRC/template/Makefile"                              "$INSTALL_DIR/template/"
cp "$FRAMEWORK_SRC/template/CLAUDE.md"                             "$INSTALL_DIR/template/"
cp "$FRAMEWORK_SRC/template/AGENTS.md"                             "$INSTALL_DIR/template/"

chmod +x "$INSTALL_DIR/bin/agente"
chmod +x "$INSTALL_DIR/template/scripts/iniciar-agente.sh" 2>/dev/null
chmod +x "$INSTALL_DIR/template/scripts/lanzar-agentes-terminal.sh" 2>/dev/null

ok "Prompts actualizados"
ok "Scripts actualizados"
ok "CLI actualizado"
ok "Plantillas base actualizadas (agent-config.TEMPLATE.md, status.md, Makefile)"
skip "agent-config.md del proyecto"
skip "status.md del proyecto"
skip "Makefile del proyecto"

# ─── Actualizar en proyecto actual si tiene el framework ─────────────────────
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
        [ -d "$RUTA_PROYECTO/scripts" ] && cp "$FRAMEWORK_SRC/template/scripts/$script" "$RUTA_PROYECTO/scripts/$script"
    done

    # Punteros de arranque: se instalan solo si faltan. NO se sobrescriben —
    # una instancia vieja puede tener un CLAUDE.md escrito a mano y pisarlo
    # sería perder contenido del usuario.
    for puntero in CLAUDE.md AGENTS.md; do
        if [ -f "$RUTA_PROYECTO/$puntero" ]; then
            skip "$puntero — ya existe (revísalo: debería ser un puntero, no contexto inline)"
        else
            cp "$FRAMEWORK_SRC/template/$puntero" "$RUTA_PROYECTO/$puntero"
            ok "$puntero instalado"
        fi
    done
    chmod +x "$RUTA_PROYECTO/scripts/iniciar-agente.sh" 2>/dev/null
    chmod +x "$RUTA_PROYECTO/scripts/lanzar-agentes-terminal.sh" 2>/dev/null

    ok "Proyecto actualizado"
fi

# ─── Limpiar ─────────────────────────────────────────────────────────────────
rm -rf "$TMP_DIR"

echo ""
linea
echo -e "  ${VERDE}${NEGRITA}✅ Framework actualizado${RESET}"
linea
echo ""
