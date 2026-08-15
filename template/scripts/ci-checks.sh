#!/bin/bash

# Sistema Multiagente — Checks de CI
#
# Toda la lógica de los checks vive AQUÍ, no en el YAML del proveedor de CI.
# Así corre igual en GitHub Actions, GitLab, otro host, o a mano en tu terminal:
#
#   ./scripts/ci-checks.sh            # corre los checks activos
#   ./scripts/ci-checks.sh tests      # corre solo uno
#
# Qué se activa y con qué comando lo decide docs/.agents/agent-config.md.
# El framework no asume ningún stack ni nombra ninguna herramienta.

set -uo pipefail

RUTA_PROYECTO="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$RUTA_PROYECTO/docs/.agents/agent-config.md"

VERDE="\033[0;32m"; ROJO="\033[0;31m"; AMARILLO="\033[0;33m"
GRIS="\033[0;90m"; NEGRITA="\033[1m"; RESET="\033[0m"

ok()   { echo -e "  ${VERDE}✅${RESET} $1"; }
falla(){ echo -e "  ${ROJO}❌${RESET} $1"; }
skip() { echo -e "  ${GRIS}⏭️  $1${RESET}"; }
warn() { echo -e "  ${AMARILLO}⚠️ ${RESET} $1"; }

leer_config() {
    grep "^$1=" "$CONFIG" 2>/dev/null | head -1 | cut -d= -f2- | sed 's/#.*//' | xargs
}

FALLIDOS=0
EJECUTADOS=0
OMITIDOS=()

# Corre un check: si no hay comando declarado, se omite y se REPORTA.
# Un check silenciosamente omitido es peor que uno que falla: da falsa confianza.
correr_check() {
    local nombre="$1" activo="$2" comando="$3"

    if [ "$activo" != "si" ] && [ "$activo" != "on" ]; then
        skip "$nombre — desactivado en agent-config.md"
        OMITIDOS+=("$nombre (desactivado)")
        return 0
    fi

    if [ -z "$comando" ]; then
        warn "$nombre — activo pero SIN COMANDO declarado en agent-config.md"
        OMITIDOS+=("$nombre (sin comando)")
        return 0
    fi

    echo ""
    echo -e "  ${NEGRITA}▶ $nombre${RESET}  ${GRIS}$comando${RESET}"
    EJECUTADOS=$((EJECUTADOS + 1))

    if ( cd "$RUTA_PROYECTO" && eval "$comando" ); then
        ok "$nombre"
    else
        falla "$nombre"
        FALLIDOS=$((FALLIDOS + 1))
    fi
}

if [ ! -f "$CONFIG" ]; then
    falla "No se encontró docs/.agents/agent-config.md"
    exit 1
fi

CI_ACTIVO="$(leer_config ci)"
if [ "$CI_ACTIVO" != "on" ] && [ "$CI_ACTIVO" != "si" ]; then
    echo ""
    skip "CI desactivado (ci=off en agent-config.md) — nada que hacer"
    echo ""
    exit 0
fi

SOLO="${1:-}"

echo ""
echo -e "${GRIS}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${NEGRITA}Checks de CI${RESET}"
echo -e "${GRIS}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

ejecutar() {
    [ -n "$SOLO" ] && [ "$SOLO" != "$1" ] && return 0
    correr_check "$@"
}

ejecutar "tests"            "$(leer_config check_tests)"            "$(leer_config comando_tests)"
ejecutar "lint"             "$(leer_config check_lint)"             "$(leer_config comando_lint)"
ejecutar "static-analysis"  "$(leer_config check_static_analysis)"  "$(leer_config comando_static_analysis)"
ejecutar "secret-scan"      "$(leer_config check_secret_scan)"      "$(leer_config comando_secret_scan)"

# Checks encadenados al perfil de API: solo tienen sentido con rest_openapi=on
REST_OPENAPI="$(leer_config rest_openapi)"
if [ "$REST_OPENAPI" = "on" ]; then
    ejecutar "openapi-validate" "$(leer_config check_openapi_validate)" "$(leer_config comando_openapi_validate)"
    ejecutar "oasdiff"          "$(leer_config check_oasdiff)"          "$(leer_config comando_oasdiff)"
else
    skip "openapi-validate y oasdiff — requieren rest_openapi=on"
fi

echo ""
echo -e "${GRIS}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

# Reportar siempre lo que NO se corrió: un check omitido en silencio se lee
# como "pasó" y esa es exactamente la falsa confianza que hay que evitar.
if [ ${#OMITIDOS[@]} -gt 0 ]; then
    echo ""
    echo -e "  ${GRIS}No ejecutados: ${OMITIDOS[*]}${RESET}"
fi

echo ""
if [ "$FALLIDOS" -gt 0 ]; then
    falla "$FALLIDOS de $EJECUTADOS checks fallaron"
    echo ""
    exit 1
fi

if [ "$EJECUTADOS" -eq 0 ]; then
    warn "Ningún check se ejecutó — revisa agent-config.md"
    echo ""
    exit 0
fi

ok "$EJECUTADOS checks pasaron"
echo ""
exit 0
