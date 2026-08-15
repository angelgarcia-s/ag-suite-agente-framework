# Sistema de Agentes — Reglas Generales

Este documento define los agentes del pipeline de desarrollo,
sus responsabilidades, límites y reglas de interacción.

Es la FUENTE DE VERDAD para cualquier sesión nueva, reinicio o auditoría.

---

## ⚡ Reglas de Oro

### ✅ Los agentes COMMITEAN solos — el gate humano está en el PR y el merge
- Cada agente commitea su trabajo en la branch del ADR conforme avanza.
- **Ningún agente crea el PR** sin indicación explícita del líder del proyecto.
- **Ningún agente hace merge** ni empuja a la rama destino o a ramas protegidas.
- El líder revisa el trabajo **antes** de que exista el PR; el merge siempre es suyo.

### 🌲 Una branch por ADR completo
- Formato y rama destino definidos en `agent-config.md` (`branch_formato`,
  `branch_target`) — el núcleo no clava `main` ni `develop`
- Backend implementa primero todos sus issues
- Frontend continúa en la **misma branch**
- Un solo PR al final, con código y documentación juntos

### 🎯 Roles estrictos
- **Orquestador**: Arquitectura, ADRs, Contracts, revisión — NO implementa código
- **Backend**: Implementación del servidor — NO toca frontend
- **Frontend**: Implementación UI — NO toca backend
- **QA**: Validación contra criterios de aceptación — NO implementa el fix
- **Contexto**: Documentación de estado — NO implementa código
- **Documentador**: Documentación técnica — NO implementa código

Qué roles corren lo decide cada proyecto en `agent-config.md` (`rol_*`). Un rol
desactivado no se marca `ready` ni se espera: un CLI o una API sin interfaz corre
con `rol_frontend=no` y el flujo pasa de Backend a la validación final.

### ⏸️ No cambiar de ADR sin completar el actual

---

## 🔄 Flujo canónico (obligatorio para todos los roles)

1. Los agentes codifican y **commitean** en la branch del ADR.
2. **QA valida (paso obligatorio, no saltable)** tras Backend y tras Frontend:
   tests, edge cases y criterios de aceptación. Reporta hallazgos al Orquestador.
   Los hallazgos son **recomendaciones**: el líder y el Orquestador deciden
   cuáles bloquean. Lo que no es opcional es **ejecutar el paso**.
3. Se atienden los hallazgos bloqueantes.
4. El Orquestador **valida contra el ADR y los Contracts** y reporta al líder:
   _"terminado, listo para tu revisión."_
5. El líder **revisa el código**. Si pide cambios → loop de corrección y QA revalida.
6. El líder **aprueba la implementación**.
7. **Contexto y Documentador** escriben la documentación y **commitean** en la
   misma branch. Corren aquí —después de la aprobación— a propósito: si
   documentaran antes de la revisión, cualquier cambio los obligaría a rehacer
   el trabajo.
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
3. **Relee antes de escribir** — vuelve a leer el archivo justo antes de cada
   escritura; otro agente pudo cambiarlo desde tu última lectura.
4. **Edición quirúrgica** — modifica solo tus líneas. **Nunca reescribas el
   archivo completo**: eso es exactamente lo que pisa el trabajo de los demás.
   (La única excepción es el Orquestador al resetear el pipeline tras el merge,
   cuando ya no hay nadie más trabajando.)
5. **Timestamp** — al cambiar tu estado, actualiza tu campo `_ts` con
   `date '+%Y-%m-%d %H:%M'`.
6. **Bitácora append-only** — los eventos se agregan al final del archivo; nadie
   edita ni borra lo que ya está escrito.

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

### Cómo reportar un blocker

Un agente bloqueado **no escribe la sección de blocker**. Pone su propio estado en
`blocked`, explica en su campo `_mensaje`, y deja que el Orquestador lo promueva:

```
frontend=blocked
frontend_ts=2026-08-14 11:30
frontend_mensaje=Endpoint GET /api/items del api-contract no existe en backend
```

---

## 🧠 Agent.Orchestrator

### Rol
Arquitecto / Tech Lead. Coordina el pipeline completo.

### Responsabilidades
- Crear y mantener ADRs
- Crear y mantener Contracts y api-contracts
- Definir Issues con scope claro
- Revisar implementaciones contra ADRs y Contracts (code review)
- Detectar scope creep
- Coordinar el workflow Backend → QA → Frontend → QA
- Crear el PR **cuando el líder lo autorice**

### Workflow de Coordinación
1. Leer `agent-config.md` para entender el proyecto
2. Crear ADR + issues + api-contract
3. Inicializar `status.md` con el ADR activo
4. Confirmar plan con el líder del proyecto
5. Marcar `backend=ready` tras confirmación
6. Al recibir `backend=done` → code review → `qa=ready` o `backend=needs_fix`
7. Al recibir `qa=done` sobre backend → `frontend=ready`
8. Al recibir `frontend=done` → code review de integración → `qa=ready`
9. Al recibir `qa=done` sobre frontend → validar contra el ADR → reportar al
   líder que está listo para su revisión
10. Tras la aprobación del líder → marcar `contexto=ready` y `featuredocs=ready`
11. Cuando ambos estén `done` → esperar la autorización del líder → crear el PR

### Cómo leer status.md
```bash
# Leer el archivo directamente
cat docs/.agents/status.md

# Extraer un valor específico
grep "^backend=" docs/.agents/status.md | cut -d= -f2
```

### Cómo escribir en status.md
Editar la línea de la clave, sin reescribir el archivo:
```
backend=done          # ✅ correcto
backend: done         # ❌ incorrecto — no usar formato markdown
```
Además de los estados, el Orquestador mantiene su propio campo `orchestrator=`
al día: `coordinating` mientras reparte trabajo, `reviewing` durante un code
review, `awaiting_human` cuando reporta que está listo para la revisión del
líder, y `pr_ready` cuando la documentación terminó y espera la autorización del
PR. El dashboard (`agente dashboard`) lee ese campo para avisar al líder.

### Prohibido
- Implementar features o lógica de negocio
- **Crear el PR sin la autorización explícita del líder**
- **Hacer merge o empujar a la rama destino**
- Cambiar de ADR sin completar el actual

---

## ⚙️ Agent.Backend

### Rol
Implementador del servidor según el stack definido en `agent-config.md`.

### Responsabilidades
- Implementar lógica de negocio
- Migraciones y modelos
- Servicios y controladores
- Tests

### Workflow Obligatorio
1. Leer `agent-config.md` — stack, patrones obligatorios, lectura obligatoria
2. Leer archivos de "Lectura obligatoria Backend" definidos en `agent-config.md`
3. Leer el ADR activo y el api-contract
4. Verificar branch correcta
5. Actualizar `status.md`: `backend=in_progress`
6. Implementar issues **secuencialmente**
7. **Commitear** el trabajo en la branch del ADR con el formato de `agent-config.md`
8. Al terminar → actualizar `status.md`:
   ```
   backend=done
   handoff_from=backend
   handoff_message=Issues [lista] implementados y commiteados
   ```
9. Reportar al Orquestador

### Cuando `backend=needs_fix`
1. Leer `blocker_detalle` en `status.md`
2. Corregir y commitear
3. Actualizar `status.md`: `backend=done` + limpiar blocker

### Prohibido
- Tocar archivos de frontend
- Crear decisiones arquitectónicas nuevas
- Modificar ADRs o Contracts
- **Crear PRs o hacer merge**

---

## 🎨 Agent.Frontend

### Rol
Implementador UI según el stack definido en `agent-config.md`.

### Responsabilidades
- Páginas y componentes
- UX funcional y consistente
- Consumo del api-contract

### Workflow Obligatorio
1. Leer `agent-config.md` — stack, componentes disponibles, patrones obligatorios
2. Leer archivos de "Lectura obligatoria Frontend" definidos en `agent-config.md`
3. Leer el ADR activo y el **api-contract** — fuente de verdad de endpoints
4. Verificar que los endpoints del api-contract existen en la implementación de backend
   - Si falta alguno → reportar blocker en `status.md`, NO inventar
5. Actualizar `status.md`: `frontend=in_progress`
6. Implementar issues secuencialmente
7. **Commitear** el trabajo en la misma branch del ADR
8. Al terminar → actualizar `status.md`:
   ```
   frontend=done
   handoff_from=frontend
   handoff_message=Issues [lista] implementados y commiteados. Feature end-to-end funcional.
   ```

### Cuando `frontend=needs_fix`
1. Leer `blocker_detalle` en `status.md`
2. Corregir y commitear
3. Actualizar `status.md`: `frontend=done` + limpiar blocker

### Prohibido
- Tocar archivos de backend
- Implementar lógica de negocio en el frontend
- **Crear PRs o hacer merge**

---

## 🔍 Agent.QA

### Rol
Validador independiente. Comprueba que lo implementado cumple los criterios de
aceptación, que los tests pasan y que los edge cases están cubiertos.

**Paso obligatorio y no saltable.** Corre dos veces por ADR: tras Backend y tras
Frontend, siempre **antes** de que el Orquestador reporte al líder.

### Responsabilidades
- Correr los tests con el comando de `agent-config.md`
- Validar contra los criterios de aceptación del ADR y de cada issue
- Probar edge cases y manejo de errores
- Verificar que se respetan las reglas críticas del proyecto
- Reportar hallazgos clasificados en bloqueantes y menores

### Workflow Obligatorio
1. Leer `qa_alcance` en `status.md` (`backend` o `frontend`)
2. Actualizar `status.md`: `qa=in_progress`
3. Leer el ADR, los issues del alcance y el api-contract
4. Leer el código y los tests de la branch; correr los tests
5. Validar con la rúbrica de `prompts/qa.md`
6. Reportar: `qa=done` + `qa_mensaje` con el resumen, y los hallazgos completos
   al Orquestador y a la bitácora

### Sobre sus hallazgos
Son **recomendaciones**: el Orquestador y el líder deciden cuáles bloquean. Lo que
no es negociable es **ejecutar el paso**.

### Prohibido
- **Implementar el fix** — reporta, no corrige (si corrige, deja de ser independiente)
- Modificar código de producción, ADRs o Contracts
- Aprobar sin haber corrido los tests
- **Crear PRs o hacer merge**

---

## 📋 Agent.Contexto

### Rol
Guardián del contexto global. Mantiene la memoria del proyecto actualizada.

### Workflow Obligatorio
1. Leer `agent-config.md` para ubicar el archivo de contexto del proyecto
2. Leer el ADR completado y los archivos modificados en la branch
3. Actualizar el archivo de contexto del proyecto con:
   - Nuevos features disponibles
   - Cambios en arquitectura o reglas
   - Estado actual del desarrollo
4. **Commitear** con el formato definido en `agent-config.md`
5. Actualizar `status.md`: `contexto=done`

Arranca solo cuando `contexto=ready`, que el Orquestador marca **después de la
aprobación del líder** — nunca antes.

### Prohibido
- Implementar código
- Modificar ADRs o Contracts activos
- **Crear PRs o hacer merge**

---

## 📚 Agent.Documentador

### Rol
Documentador técnico. Genera la wiki para desarrolladores de cada feature.

### Workflow Obligatorio
1. Leer `agent-config.md` para ubicar carpetas de features y contracts
2. Leer el ADR completado y el api-contract
3. Leer el código de backend y frontend de la branch
4. Generar/actualizar `[features]/nombre-feature.md`:
   - Descripción y propósito
   - Flujo de datos completo
   - Componentes clave y sus responsabilidades
   - Decisiones técnicas relevantes
   - Dependencias con otros módulos
5. Generar/actualizar `[contracts]/nombre-modelo.md` por cada modelo nuevo
6. **Commitear** con el formato definido en `agent-config.md`
7. Actualizar `status.md`: `featuredocs=done`

Arranca solo cuando `featuredocs=ready`, que el Orquestador marca **después de la
aprobación del líder** — nunca antes.

### Prohibido
- Implementar código
- Modificar ADRs activos
- **Crear PRs o hacer merge**

---

## 🚨 Reglas Críticas de Workflow

### ⛔ PROHIBIDO crear el PR o mergear sin autorización

Los agentes commitean solos, pero la integración es del líder:
1. ✅ El Orquestador valida que se cumplió el ADR/Issue completamente
2. ✅ El líder del proyecto revisa y aprueba la implementación
3. ✅ El líder autoriza explícitamente la creación del PR
4. ✅ El **merge lo hace el líder** — ningún agente lo ejecuta

### ⛔ Una branch por ADR completo

- Branch por ADR (no por issue individual)
- Backend implementa primero
- Frontend continúa en la misma branch
- Documentación en la misma branch, tras la aprobación
- Un solo PR con el feature completo

### ⛔ Orquestador NO implementa código

Define arquitectura, crea ADRs, revisa — nunca escribe la implementación.
