# Prompts de agentes de proyecto

Los prompts que pongas aquí son **tuyos**, no del framework.

`actualizar.sh` **nunca toca esta carpeta**, igual que no toca `agent-config.md`
ni `status.md`. Los prompts del núcleo (un directorio arriba) sí se sobrescriben
en cada actualización — por eso los agentes propios viven aquí y no allá.

## Cuándo va aquí un agente

| | Dónde vive | Ejemplo |
|---|---|---|
| Reusable en cualquier proyecto | Núcleo, apagado por defecto | Un perfil opt-in del framework |
| Depende de artefactos que solo existen en este repo | **Aquí** | Un redactor de la ayuda in-app, un generador de datos de demo |

Si tu agente solo tiene sentido en este repo, va aquí. Si serviría igual en otro
proyecto, probablemente sea un perfil del núcleo.

## Cómo agregar uno

1. Escribe el prompt en esta carpeta (ej: `ayuda.md`).
2. Decláralo en la sección **Agentes de proyecto** de `agent-config.md`:
   nombre, ruta del prompt, condición de activación y estados válidos.
3. El Orquestador lo leerá del registro y lo activará en `status.md` con la clave
   que declaraste (`<nombre>=ready|done|n/a`).

## Reglas que tu agente hereda (no son negociables)

- **Commitea solo** en la branch del ADR, con el formato de `agent-config.md`.
- **No crea PRs** y **no hace merge** — eso es del Orquestador autorizado y del líder.
- Sigue el protocolo de `status.md`: escribe solo su propio bloque, relee antes de
  escribir y nunca reescribe el archivo completo.
- Respeta las reglas críticas del proyecto.

Un prompt de proyecto **no puede** definir una política de commits propia que
salte el gate humano. Si tu prompt y `agent-config.md` se contradicen, manda la
política del proyecto.

## Estructura sugerida del prompt

```markdown
# Agent.<Nombre> — Prompt de Arranque

## Carga obligatoria al iniciar
1. docs/.agents/agent-config.md
2. docs/.agents/agentes.md
3. docs/.agents/status.md

## Tu rol
[qué hace y qué NO hace]

## Cuándo te toca
[la condición de activación declarada en agent-config.md]

## Workflow obligatorio
[pasos concretos, terminando en commit + actualizar tu bloque en status.md]

## Prohibido
- Crear PRs o hacer merge
- [lo que no debe tocar]
```
