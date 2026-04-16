# agente-framework

Sistema multiagente para desarrollo de software con Claude Code y GitHub Copilot.

Pipeline autónomo de desarrollo: Orquestador → Backend → Frontend → Contexto → Documentador.

---

## Instalación

Desde la raíz de tu proyecto:

```bash
curl -fsSL https://raw.githubusercontent.com/tu-usuario/agente-framework/main/instalar.sh | bash
```

El instalador crea la estructura, copia los archivos y genera tu `agent-config.md` desde el template.

---

## Configuración

Abre `docs/.agents/agent-config.md` y llena:

1. **Stack** — tu backend, frontend, base de datos
2. **Estructura de carpetas** — dónde viven tus ADRs, issues, contracts
3. **Lectura obligatoria por rol** — qué archivos debe leer cada agente al arrancar
4. **Componentes y patrones clave** — los patrones obligatorios de tu proyecto con ejemplos de código
5. **Reglas críticas** — las reglas NO negociables de tu proyecto

Este archivo es lo que hace el framework inteligente para tu proyecto específico.

---

## Modos de uso

### Modo Terminal — Claude Code (máxima paralelización)

```bash
make agentes        # iTerm2 con paneles
make agentes-terminal  # Terminal.app con ventanas
```

Cada agente corre en su propia sesión. Usa `poll` para activar cada agente cuando el Orquestador notifique.

Ver: `docs/.agents/arranque-terminal.md`

### Modo Sesión Única — Copilot o Claude Code

Pega el prompt de `docs/.agents/arranque-sesion.md` en Copilot Chat o Claude Code.

Un solo agente cambia de rol autónomamente según `status.md`.

Ver: `docs/.agents/arranque-sesion.md`

---

## Flujo de un feature

```
1. Tú describes el feature al Orquestador
2. Orquestador planea: ADR + issues + api-contract
3. Tú confirmas el plan
4. Backend implementa → Orquestador valida
5. Frontend implementa → Orquestador valida integración
6. Tú pruebas en el navegador/app
7. "aprobado para commit"
8. Contexto + Documentador cierran el ADR
9. Commits + PR
```

---

## Actualizar el framework

```bash
curl -fsSL https://raw.githubusercontent.com/tu-usuario/agente-framework/main/actualizar.sh | bash
```

Solo actualiza los archivos genéricos (prompts, scripts, reglas).
Tu `agent-config.md` y `status.md` nunca se tocan.

---

## Estructura instalada en tu proyecto

```
proyecto/
  Makefile
  scripts/
    iniciar-agente.sh
    lanzar-agentes-iterm.applescript
    lanzar-agentes-terminal.sh
  docs/
    .agents/
      agent-config.md          ← TÚ configuras esto
      status.md                ← canal de comunicación entre agentes
      agentes.md               ← reglas del sistema
      arranque-terminal.md     ← guía modo Claude Code
      arranque-sesion.md       ← guía modo Copilot / sesión única
      prompts/
        orchestrator.md
        backend.md
        frontend.md
        context.md
        featuredocs.md
```

---

## Comandos disponibles

```bash
make ayuda          # ver todos los comandos
make agentes        # lanzar todos en iTerm2
make orquestador    # agente individual
make backend
make frontend
make contexto
make documentador
```

---

## Compatibilidad

| Herramienta | Modo | Notas |
|-------------|------|-------|
| Claude Code | Terminal | Sesiones paralelas, polling con "poll" |
| Claude Code | Sesión única | Cambio de rol autónomo |
| GitHub Copilot | Sesión única | Prompt de arranque en Copilot Chat |
| Cualquier LLM | Sesión única | El prompt es agnóstico al modelo |
