# agente-framework

Sistema multiagente para desarrollo de software con Claude Code y GitHub Copilot.

Pipeline autónomo de desarrollo: Orquestador → Backend → QA → Frontend → QA → Contexto → Documentador.

QA valida dos veces por ADR y es un paso obligatorio del pipeline.

---

## Instalación

```bash
curl -fsSL https://raw.githubusercontent.com/angelgarcia-s/ag-suite-agente-framework/main/instalar.sh | bash
```

El instalador coloca el framework en `~/.ag-suite-agente-framework` y deja
disponible el comando `agente`. Después, desde la raíz de tu proyecto:

```bash
agente init
```

`agente init` crea la estructura, copia los archivos del núcleo y genera tu
`agent-config.md` detectando el stack real del proyecto.

---

## Configuración

Abre `docs/.agents/agent-config.md` y llena:

1. **Stack** — tu backend, frontend, base de datos
2. **Estructura de carpetas** — dónde viven tus ADRs, issues, contracts
3. **Lectura obligatoria por rol** — qué archivos debe leer cada agente al arrancar
4. **Componentes y patrones clave** — los patrones obligatorios de tu proyecto con ejemplos de código
5. **Reglas críticas** — las reglas NO negociables de tu proyecto

Este archivo es lo que hace el framework inteligente para tu proyecto específico.

**Una sola fuente de verdad.** `CLAUDE.md` y `AGENTS.md` se instalan como
punteros: no llevan stack ni reglas de negocio, solo apuntan a `agent-config.md`.
No copies contexto en ellos — dos fuentes de verdad se desincronizan y terminas
con placeholders a medio llenar.

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
4. Backend implementa y commitea → QA valida → Orquestador valida
5. Frontend implementa y commitea → QA valida → Orquestador valida integración
6. Orquestador valida contra el ADR y te reporta: listo para tu revisión
7. Tú pruebas y revisas → "aprobado"
8. Contexto + Documentador documentan y commitean (mismo branch, mismo PR)
9. Tú autorizas → el Orquestador crea el PR
10. Tú haces el merge
```

**El gate humano está en el PR y el merge, no en cada commit.** Los agentes
commitean solos en la branch del ADR; ningún agente crea un PR sin tu indicación
explícita y **ningún agente hace merge**.

---

## Perfiles opt-in

Apagados por defecto. Si no los activas, nada cambia.

| Perfil | Clave | Qué agrega |
|---|---|---|
| **CI** | `ci=on` | Verificación mecánica en el PR: tests, lint, análisis estático, secret-scan. La lógica vive en `scripts/ci-checks.sh` (portable, corre también a mano); el workflow solo lo invoca. Los comandos los declaras tú. |
| **API REST con OpenAPI** | `rest_openapi=on` | Spec generado desde el código y dos agentes (`API-Architect` y `API-Contract-Reviewer`) que se activan solo al diseñar superficie pública nueva o una versión mayor. |

## Agentes de proyecto

¿Necesitas un agente que solo tiene sentido en tu repo? Ponlo en
`docs/.agents/prompts/proyecto/` y decláralo en la sección **Agentes de proyecto**
de `agent-config.md`. El framework aporta el slot y el protocolo de activación; el
actualizador nunca toca esa carpeta.

Heredan las reglas de oro: commitean solos, no crean PRs y no mergean.

## Actualizar el framework

```bash
curl -fsSL https://raw.githubusercontent.com/angelgarcia-s/ag-suite-agente-framework/main/actualizar.sh | bash
```

Trae los archivos del núcleo nuevos y actualiza los existentes, incluida la
versión del framework, que queda registrada en tu instancia.

**Nunca se sobrescribe** (es tuyo):

| Archivo | Por qué |
|---|---|
| `docs/.agents/agent-config.md` | Es la configuración de tu proyecto |
| `docs/.agents/status.md` | Es el estado vivo de tu pipeline |
| `docs/.agents/prompts/proyecto/*.md` | Son tus agentes de proyecto |
| `CLAUDE.md` y `AGENTS.md` | Solo se crean si faltan |

Cuando el núcleo agrega claves de configuración nuevas, el updater **las reporta
sin agregarlas**. Para ver el detalle:

```bash
agente doctor
```

Compara tu instancia contra el framework: versión, claves de config que te faltan
y archivos del núcleo ausentes. No modifica nada.

---

## Estructura instalada en tu proyecto

```
proyecto/
  CLAUDE.md                    ← puntero (Claude Code) — sin contexto inline
  AGENTS.md                    ← puntero (convención abierta)
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
        qa.md
        context.md
        featuredocs.md
```

---

## Comandos disponibles

### CLI `agente` (recomendado)

```bash
agente              # launcher interactivo — punto de entrada
agente init         # inicializa el framework en este proyecto
agente doctor       # compara tu instancia con el framework
agente start iterm  # abre los 6 agentes en paneles de iTerm2
agente start sesion # modo sesión única (Copilot, Cursor, cualquier LLM)
agente dashboard    # monitoreo del pipeline con notificaciones
agente status       # estado rápido
agente run backend  # inicia un agente en esta terminal
agente reset        # limpia status.md después del merge
agente help         # todos los comandos
```

Roles: `orquestador` · `backend` · `frontend` · `qa` · `contexto` · `documentador`

### Makefile (equivalente, dentro del proyecto)

```bash
make ayuda          # ver todos los comandos
make agentes        # lanzar todos en iTerm2
make orquestador    # agente individual
make backend
make frontend
make qa
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
