# Sistema de Agentes — Reglas Generales

Reglas del sistema multiagente: roles, flujo y protocolo de comunicación.
FUENTE DE VERDAD para cualquier sesión nueva, reinicio o auditoría.

El **contexto del proyecto** (stack, convenciones, reglas críticas) vive en
`agent-config.md`. El **workflow detallado de cada rol** vive en su prompt
(`prompts/<rol>.md`). Aquí solo está lo que aplica a todos.

---

## ⚡ Reglas de Oro

### ✅ Los agentes COMMITEAN solos — el gate humano está en el PR y el merge
- Cada agente commitea en la branch del ADR conforme avanza.
- **Ningún agente crea el PR** sin indicación explícita del líder del proyecto.
- **Ningún agente hace merge** ni empuja a la rama destino o a ramas protegidas.

### 🌲 Una branch por ADR completo
- Rama destino y formato en `agent-config.md` (`branch_target`, `branch_formato`)
  — el núcleo no clava `main` ni `develop`.
- Backend implementa primero; Frontend continúa en la **misma branch**; la
  documentación entra en la misma branch. **Un solo PR** al final.

### 🎯 Roles estrictos

| Rol | Hace | NO hace |
|---|---|---|
| **Orquestador** | Arquitectura, ADRs, Contracts, code review, crea el PR autorizado | Implementar código |
| **Backend** | Implementación del servidor | Tocar frontend, decidir arquitectura |
| **Frontend** | Implementación UI, consume el api-contract | Tocar backend, lógica de negocio |
| **QA** | Valida contra criterios de aceptación, corre tests, reporta hallazgos | **Implementar el fix** |
| **Contexto** | Memoria viva del proyecto | Implementar código |
| **Documentador** | Wiki técnica del feature | Implementar código |

Qué roles corren lo decide cada proyecto en `agent-config.md` (`rol_*`). Un rol
desactivado no se marca `ready` ni se espera: un CLI o una API sin interfaz corre
con `rol_frontend=no` y el flujo pasa de Backend a la validación final.

**Ausencia = activo.** Si la clave `rol_*` no está en la config (instancias
anteriores a estas claves), el rol corre normal. Solo un `no` explícito apaga.

### ⏸️ No cambiar de ADR sin completar el actual

---

## 🔄 Flujo canónico (obligatorio para todos los roles)

1. Los agentes codifican y **commitean** en la branch del ADR.
2. **QA valida (paso obligatorio, no saltable)** tras Backend y tras Frontend:
   tests, edge cases y criterios de aceptación. Reporta al Orquestador.
   Sus hallazgos son **recomendaciones** —el líder y el Orquestador deciden
   cuáles bloquean—, pero **ejecutar el paso** no es opcional.
3. Se atienden los hallazgos bloqueantes.
4. El Orquestador **valida contra el ADR y los Contracts** y reporta al líder:
   _"terminado, listo para tu revisión."_
5. El líder **revisa el código**. Si pide cambios → corrección y QA revalida.
6. El líder **aprueba la implementación**.
7. **Contexto y Documentador** documentan y **commitean** en la misma branch.
   Corren aquí, después de la aprobación, a propósito: si documentaran antes de
   la revisión, cualquier cambio los obligaría a rehacer el trabajo.
8. El líder **autoriza el PR** → el Orquestador **crea el PR** (código + docs).
9. El líder **hace el merge**.

**Los pasos 8 y 9 son el gate humano.** Nada de lo anterior requiere autorización;
nada de lo posterior lo hace un agente.

---

## 📡 Protocolo de `status.md`

`status.md` es un archivo compartido que varios procesos leen y escriben a la vez
(en modo terminal, Backend y Frontend corren en paralelo). Sin disciplina de
escritura se pierden actualizaciones. Estas reglas son obligatorias:

1. **Ownership** — cada campo tiene un solo dueño. Escribe únicamente los campos
   de tu bloque; nunca los de otro agente.
2. **El estado es un testigo** — el Orquestador escribe `ready` y `needs_fix` en
   el campo de un agente (le pasa el testigo); el agente escribe `in_progress`,
   `done` y `blocked` en su propio campo. Nunca escriben los dos a la vez.
3. **Relee antes de escribir** — otro agente pudo cambiar el archivo desde tu
   última lectura.
4. **Edición quirúrgica** — modifica solo tus líneas. **Nunca reescribas el
   archivo completo**: eso es lo que pisa el trabajo de los demás. (La única
   excepción es el Orquestador al resetear tras el merge, cuando ya nadie trabaja.)
5. **Timestamp** — al cambiar tu estado, actualiza tu `_ts` con
   `date '+%Y-%m-%d %H:%M'`.
6. **Bitácora append-only** — los eventos se agregan al final; nadie edita ni
   borra lo ya escrito.

### Quién escribe qué

| Campos | Dueño |
|--------|-------|
| `adr`, `titulo`, `branch`, `api_contract`, `iniciado` | Orquestador |
| `orchestrator`, `orchestrator_ts` | Orquestador |
| `<agente>`, `<agente>_ts`, `<agente>_mensaje` | Ese agente (salvo `ready`/`needs_fix`, que los pone el Orquestador) |
| `qa_alcance` | Orquestador — QA solo lo lee |
| `backend_issues`, `frontend_issues`, `completados` | Orquestador |
| `handoff_phase`, `handoff_message` | Orquestador — **ningún agente escribe aquí** |
| `blocker_agente`, `blocker_detalle` | Orquestador — **ningún agente escribe aquí** |
| `aprobacion`, `aprobado_por`, `nota` | Orquestador, reflejando la decisión del líder |
| Bitácora | Cualquiera, solo agregando al final |

### Cómo leer y escribir

```bash
cat docs/.agents/status.md                                   # leer todo
grep "^backend=" docs/.agents/status.md | cut -d= -f2        # un valor
```

Al escribir, edita la línea de la clave — sin markdown y sin reescribir el archivo:
```
backend=done          # ✅ correcto
backend: done         # ❌ incorrecto
```

### Cómo reportar un blocker

Un agente bloqueado **no escribe la sección de blocker**. Marca su propio estado
en `blocked`, explica en su `_mensaje`, y el Orquestador lo promueve y lo asigna:

```
frontend=blocked
frontend_ts=2026-08-14 11:30
frontend_mensaje=Endpoint GET /api/items del api-contract no existe en backend
```

### Estados

- **Agentes:** `idle | ready | in_progress | done | needs_fix | blocked`
- **Orquestador:** `idle | coordinating | reviewing | awaiting_human | pr_ready`

`awaiting_human` y `pr_ready` son los que encienden los avisos del dashboard para
el líder. Si el Orquestador no los escribe, el líder no se entera de que le toca.

---

## 🚨 Reglas Críticas

### ⛔ PROHIBIDO crear el PR o mergear sin autorización
Los agentes commitean solos, pero la integración es del líder:
1. El Orquestador valida que se cumplió el ADR completamente
2. El líder revisa y aprueba la implementación
3. El líder autoriza explícitamente la creación del PR
4. El **merge lo hace el líder** — ningún agente lo ejecuta

### ⛔ QA no es opcional y no corrige
Ejecutar la validación es obligatorio. QA reporta con evidencia; si corrigiera lo
que encuentra, dejaría de ser un validador independiente.

### ⛔ Orquestador NO implementa código
Define arquitectura, crea ADRs, revisa — nunca escribe la implementación.
