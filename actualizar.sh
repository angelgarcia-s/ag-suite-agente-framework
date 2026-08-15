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

# Claves de configuración GLOBALES del template.
# Excluye la sección "Agentes de proyecto": ahí las claves (nombre, prompt,
# activacion, estados) son de cada bloque [agente], no del proyecto, y
# reportarlas como faltantes sería ruido. También ignora los ejemplos comentados.
_claves_globales() {
    awk '
        /^## .*Agentes de proyecto/ { en_seccion = 1; next }
        /^## / { en_seccion = 0 }
        /<!--/ { en_comentario = 1 }
        /-->/  { en_comentario = 0; next }
        en_seccion || en_comentario { next }
        /^[a-z_]+=/ { sub(/=.*/, ""); print }
    ' "$1" | sort -u
}

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
echo -e "  ${NEGRITA}NUNCA se sobrescribe (es tuyo):${RESET}"
echo -e "    ${GRIS}docs/.agents/agent-config.md${RESET}"
echo -e "    ${GRIS}docs/.agents/status.md${RESET}"
echo -e "    ${GRIS}docs/.agents/prompts/proyecto/*${RESET}   (tus agentes de proyecto)"
echo -e "    ${GRIS}CLAUDE.md y AGENTS.md${RESET}             (solo se crean si faltan)"
echo ""
warn "Todo lo demás del núcleo se actualiza a la versión nueva."
echo ""

# Actualizar a media ADR cambia las reglas bajo los pies de los agentes: los
# prompts y el flujo se reemplazan mientras hay trabajo en curso. Avisar antes.
ADR_EN_CURSO="$(grep '^adr=' "$(pwd)/docs/.agents/status.md" 2>/dev/null | head -1 | cut -d= -f2 | xargs)"
if [ -n "$ADR_EN_CURSO" ]; then
    echo -e "  ${AMARILLO}${NEGRITA}⚠️  Hay una ADR en curso: $ADR_EN_CURSO${RESET}"
    echo ""
    echo -e "  Actualizar ahora reemplaza los prompts y el flujo mientras hay trabajo"
    echo -e "  a medias. Lo ideal es actualizar ${NEGRITA}entre ADRs${RESET}, con el pipeline limpio."
    echo ""
    echo -e "  Si decides seguir:"
    echo -e "    ${GRIS}• cierra las terminales de los agentes antes de continuar${RESET}"
    echo -e "    ${GRIS}• corre 'agente migrar-status' después, para actualizar el esquema${RESET}"
    echo -e "    ${GRIS}• revisa el flujo nuevo: el gate y los pasos pueden haber cambiado${RESET}"
    echo ""
fi
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
skip "agent-config.md del proyecto"
skip "status.md del proyecto"
skip "Makefile del proyecto"

# ─── Actualizar en proyecto actual si tiene el framework ─────────────────────
RUTA_PROYECTO="$(pwd)"
if [ -d "$RUTA_PROYECTO/docs/.agents" ]; then
    echo ""
    info "Actualizando archivos en el proyecto actual..."

    # Prompts del núcleo: solo los .md de primer nivel. La subcarpeta
    # prompts/proyecto/ es del usuario y NO se toca (igual que agent-config.md
    # y status.md), porque ahí viven los agentes propios de su proyecto.
    for prompt in "$FRAMEWORK_SRC"/template/docs/.agents/prompts/*.md; do
        [ -f "$prompt" ] && cp "$prompt" "$RUTA_PROYECTO/docs/.agents/prompts/"
    done

    # Carpeta de agentes de proyecto: los prompts del usuario NO se tocan, pero
    # el README es documentación del núcleo y debe llegar aunque la carpeta ya
    # exista (una instancia vieja la tiene sin README).
    mkdir -p "$RUTA_PROYECTO/docs/.agents/prompts/proyecto"
    if [ -f "$RUTA_PROYECTO/docs/.agents/prompts/proyecto/README.md" ]; then
        cp "$FRAMEWORK_SRC/template/docs/.agents/prompts/proyecto/README.md" \
           "$RUTA_PROYECTO/docs/.agents/prompts/proyecto/"
    else
        cp "$FRAMEWORK_SRC/template/docs/.agents/prompts/proyecto/README.md" \
           "$RUTA_PROYECTO/docs/.agents/prompts/proyecto/"
        ok "prompts/proyecto/README.md instalado"
    fi
    skip "prompts/proyecto/*.md — tus agentes de proyecto, preservados"
    cp "$FRAMEWORK_SRC/template/docs/.agents/agentes.md"              "$RUTA_PROYECTO/docs/.agents/"
    cp "$FRAMEWORK_SRC/template/docs/.agents/arranque-terminal.md"    "$RUTA_PROYECTO/docs/.agents/"
    cp "$FRAMEWORK_SRC/template/docs/.agents/arranque-sesion.md"      "$RUTA_PROYECTO/docs/.agents/"
    cp "$FRAMEWORK_SRC/template/docs/.agents/agente-inicializador.md" "$RUTA_PROYECTO/docs/.agents/"

    for script in iniciar-agente.sh lanzar-agentes-iterm.applescript lanzar-agentes-terminal.sh ci-checks.sh; do
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
    chmod +x "$RUTA_PROYECTO/scripts/ci-checks.sh" 2>/dev/null

    # Workflow de CI: se refresca solo si el proyecto ya lo tiene instalado.
    if [ -f "$RUTA_PROYECTO/.github/workflows/agentes-ci.yml" ]; then
        cp "$FRAMEWORK_SRC/template/.github/workflows/agentes-ci.yml" \
           "$RUTA_PROYECTO/.github/workflows/agentes-ci.yml"
        ok "workflow de CI actualizado"
    fi

    ok "Proyecto actualizado"

    # ── Registrar la versión aplicada en la instancia ────────────────────────
    # Es la única clave que el updater escribe en agent-config.md, y solo esa
    # línea: sin ella no hay forma de saber con qué versión corre la instancia.
    VERSION_NUEVA="$(cat "$FRAMEWORK_SRC/VERSION" 2>/dev/null || echo "")"
    CONFIG_PROYECTO="$RUTA_PROYECTO/docs/.agents/agent-config.md"
    if [ -n "$VERSION_NUEVA" ] && [ -f "$CONFIG_PROYECTO" ]; then
        if grep -q "^framework_version=" "$CONFIG_PROYECTO"; then
            VERSION_ANTERIOR="$(grep '^framework_version=' "$CONFIG_PROYECTO" | head -1 | cut -d= -f2 | xargs)"
            TMP_CFG="$(mktemp)"
            sed "s|^framework_version=.*|framework_version=$VERSION_NUEVA|" "$CONFIG_PROYECTO" > "$TMP_CFG" \
                && mv "$TMP_CFG" "$CONFIG_PROYECTO"
            ok "Versión registrada: ${VERSION_ANTERIOR:-sin registrar} → $VERSION_NUEVA"
        else
            # Config de una instancia anterior al versionado: se agrega la clave
            # al final sin tocar nada de lo que el usuario ya escribió.
            printf '\n---\n\n## 🏷 Versión del framework\n\n```\nframework_version=%s\n```\n' \
                "$VERSION_NUEVA" >> "$CONFIG_PROYECTO"
            ok "Versión registrada: $VERSION_NUEVA (clave agregada)"
        fi
    fi

    # ── Reportar claves de config nuevas, sin tocarlas ───────────────────────
    TEMPLATE_CFG="$FRAMEWORK_SRC/template/docs/.agents/agent-config.TEMPLATE.md"
    if [ -f "$TEMPLATE_CFG" ] && [ -f "$CONFIG_PROYECTO" ]; then
        FALTANTES=""
        while IFS= read -r clave; do
            grep -q "^$clave=" "$CONFIG_PROYECTO" || FALTANTES="$FALTANTES $clave"
        done < <(_claves_globales "$TEMPLATE_CFG")

        if [ -n "$FALTANTES" ]; then
            echo ""
            warn "Claves de configuración nuevas disponibles (NO se agregaron):"
            for c in $FALTANTES; do echo -e "    ${AMARILLO}$c${RESET}"; done
            echo ""
            info "Son opcionales. Agrégalas a mano si quieres usarlas."
            info "Detalle completo: agente doctor"
        fi
    fi
fi

# ─── Limpiar ─────────────────────────────────────────────────────────────────
rm -rf "$TMP_DIR"

echo ""
linea
echo -e "  ${VERDE}${NEGRITA}✅ Framework actualizado${RESET}"
linea
echo ""
