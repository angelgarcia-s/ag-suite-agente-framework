#!/usr/bin/osascript

# Sistema Multiagente — Lanzador en iTerm2
# Layout: 2 columnas x 3 filas
#
#  ┌─────────────────┬─────────────────┐
#  │  Orquestador    │       QA        │
#  ├─────────────────┼─────────────────┤
#  │    Backend      │    Contexto     │
#  ├─────────────────┼─────────────────┤
#  │    Frontend     │  Documentador   │
#  └─────────────────┴─────────────────┘
#
# Uso: osascript scripts/lanzar-agentes-iterm.applescript
# O desde raíz: make agentes

set scriptPath to POSIX path of (path to me)
set rutaProyecto to do shell script "cd \"" & scriptPath & "\" && cd .. && pwd"
set scriptInicio to rutaProyecto & "/scripts/iniciar-agente.sh"

tell application "iTerm2"
    activate
    set nuevaVentana to (create window with default profile)

    tell nuevaVentana
        # Panel 1 — Orquestador (arriba izquierda)
        tell current session
            set name to "Orquestador"
            write text "cd " & quoted form of rutaProyecto
            write text "bash " & quoted form of scriptInicio & " orquestador"
            set s2 to (split vertically with default profile)
        end tell

        # Panel 2 — QA (arriba derecha)
        tell s2
            set name to "QA"
            write text "cd " & quoted form of rutaProyecto
            write text "bash " & quoted form of scriptInicio & " qa"
            set s3 to (split horizontally with default profile)
        end tell

        # Panel 3 — Contexto (centro derecha)
        tell s3
            set name to "Contexto"
            write text "cd " & quoted form of rutaProyecto
            write text "bash " & quoted form of scriptInicio & " contexto"
            set s4 to (split horizontally with default profile)
        end tell

        # Panel 4 — Documentador (abajo derecha)
        tell s4
            set name to "Documentador"
            write text "cd " & quoted form of rutaProyecto
            write text "bash " & quoted form of scriptInicio & " documentador"
        end tell

        # Volver a Panel 1 → columna izquierda
        tell first session
            set s5 to (split horizontally with default profile)
        end tell

        # Panel 5 — Backend (centro izquierda)
        tell s5
            set name to "Backend"
            write text "cd " & quoted form of rutaProyecto
            write text "bash " & quoted form of scriptInicio & " backend"
            set s6 to (split horizontally with default profile)
        end tell

        # Panel 6 — Frontend (abajo izquierda)
        tell s6
            set name to "Frontend"
            write text "cd " & quoted form of rutaProyecto
            write text "bash " & quoted form of scriptInicio & " frontend"
        end tell

    end tell
end tell
