# CLAUDE.md

Este proyecto usa un sistema multiagente. Este archivo es un **puntero**: no
contiene contexto del proyecto, solo dice dónde está.

No inlinees aquí stack, módulos ni reglas de negocio. Si lo haces, tendrás dos
fuentes de verdad que se desincronizan, y este archivo terminará lleno de
placeholders a medio llenar.

## Contexto del proyecto

**`docs/.agents/agent-config.md`** — stack, estructura de carpetas, convenciones,
componentes y patrones obligatorios, comandos, reglas críticas, rama destino,
roles activos y definición de terminado.

Es la única fuente de verdad del proyecto. Léelo antes de escribir código.

## Reglas del sistema multiagente

**`docs/.agents/agentes.md`** — roles, flujo canónico, gate humano y protocolo de
escritura de `status.md`.

## Estado actual y rol activo

- **`docs/.agents/status.md`** — qué ADR está activo y en qué va cada agente.
- **`docs/.agents/prompts/<rol>.md`** — el prompt del rol que estés ejecutando
  (`orchestrator`, `backend`, `frontend`, `qa`, `context`, `featuredocs`).

## Gate humano — lo esencial

Los agentes **commitean solos** en la branch del ADR. El gate está en la
integración:

- **Ningún agente crea el PR** sin indicación explícita del líder del proyecto.
- **Ningún agente hace merge** ni empuja a la rama destino.

El detalle completo está en `docs/.agents/agentes.md`.
