# AGENTS.md

Convención abierta de instrucciones para agentes. Este proyecto usa un sistema
multiagente cuyo detalle vive en `docs/.agents/`.

Este archivo es un **puntero**, no un contenedor de contexto: nada de stack,
módulos ni reglas de negocio inlineados aquí.

## Dónde está cada cosa

| Necesitas | Archivo |
|---|---|
| Contexto del proyecto (stack, convenciones, reglas críticas, comandos) | `docs/.agents/agent-config.md` |
| Reglas del sistema, roles y flujo | `docs/.agents/agentes.md` |
| Estado del pipeline y ADR activo | `docs/.agents/status.md` |
| Prompt del rol que vas a ejecutar | `docs/.agents/prompts/<rol>.md` |

`agent-config.md` es la única fuente de verdad sobre el proyecto.

## Gate humano

Los agentes **commitean solos** en la branch del ADR. **Ningún agente crea el PR**
sin indicación explícita del líder del proyecto, y **ningún agente hace merge**.

## Compatibilidad

Este archivo existe para herramientas que leen la convención `AGENTS.md`.
Claude Code lee `CLAUDE.md`, que apunta a los mismos lugares. Ambos son punteros
al mismo contenido: si actualizas uno, no copies contexto en el otro.
