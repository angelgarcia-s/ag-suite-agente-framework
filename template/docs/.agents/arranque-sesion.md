# Arranque — Modo Sesión Única (Copilot / Claude Code)

Usa este modo cuando:
- Estás en VS Code con GitHub Copilot
- Claude Code agotó tokens en la terminal
- Prefieres una sola conversación que cambie de rol

Un solo agente ejecuta el pipeline completo cambiando de rol autónomamente.
`status.md` sigue siendo la memoria compartida — cualquier agente puede continuar desde ahí.

---

## Prompt de arranque

Pega esto como primer mensaje en Copilot Chat o en Claude Code:

```
Eres un sistema multiagente autónomo para [nombre del proyecto].

Lee en este orden:
1. docs/.agents/agent-config.md — stack, convenciones, componentes del proyecto
2. docs/.agents/agentes.md — roles y reglas del sistema
3. docs/.agents/status.md — estado actual del pipeline

Ejecuta el pipeline completo cambiando de rol según el estado:
- Cuando toque Backend: adopta el rol de Agent.Backend
- Cuando toque Frontend: adopta el rol de Agent.Frontend
- Entre fases: vuelve al rol de Orquestador para validar

Anuncia cada cambio de rol explícitamente.
Actualiza status.md al terminar cada fase.
Respeta los gates de aprobación humana — espera mi "aprobado para commit" antes de continuar.
```

---

## Prompt para iniciar un ADR nuevo

```
Eres Agent.Orchestrator. Lee docs/.agents/agent-config.md y 
docs/.agents/status.md. Planea este feature: [descripción]
```

Con Superpowers:
```
Eres Agent.Orchestrator. Lee docs/.agents/agent-config.md y 
docs/.agents/status.md. Planea desde superpowers/plans/nombre-plan.md
```

---

## Prompt para continuar un ADR en curso

```
Eres un sistema multiagente autónomo. Lee docs/.agents/agent-config.md
y docs/.agents/status.md. Continúa el pipeline desde donde está.
```

---

## Prompt para activar un rol específico

```
Continúa como Agent.Backend. Lee docs/.agents/status.md e implementa tu fase.
```

```
Continúa como Agent.Frontend. Lee docs/.agents/status.md e implementa tu fase.
```

```
Continúa como Agent.Documentador. Lee docs/.agents/status.md y genera la documentación.
```

---

## Comportamiento esperado

El agente anuncia cada cambio de rol:
```
Entrando en modo Backend...
[implementa]
Backend completo. Actualizando status.md...
Regresando a modo Orquestador para validar...
[valida]
✅ Backend validado. Entrando en modo Frontend...
```

Cuando llega al gate humano, para y espera:
```
🎯 Feature implementado y validado. Listo para que pruebes.
Esperando tu aprobación para continuar con Contexto y Documentador.
```

---

## Diferencias vs Modo Terminal

| Aspecto | Modo Terminal | Modo Sesión Única |
|---------|--------------|-------------------|
| Paralelización | ✅ Backend + Frontend simultáneos | ❌ Secuencial |
| Tokens | Sesiones independientes | Una sesión (se agota antes) |
| Visibilidad | Ver cada agente en su terminal | Todo en una conversación |
| Intervención | Poll en cada terminal | Instrucción de cambio de rol |
| Fallback | — | ✅ Cuando se agotan tokens |

---

## Retomar con otro agente (Claude Code → Copilot o viceversa)

Si cambias de herramienta a mitad de un ADR:

```
Retoma el trabajo de Agent.[Rol]. Lee docs/.agents/agent-config.md
y docs/.agents/status.md para entender el contexto completo.
El pipeline está en fase [X]. Continúa desde ahí.
```

El `status.md` tiene todo el contexto — el nuevo agente puede continuar sin perder nada.
