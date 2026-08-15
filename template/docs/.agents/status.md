# Pipeline Status
# Canal de comunicación entre agentes.
# Formato: clave=valor — NO usar markdown ni bloques de código al escribir.
#
# ─────────────────────────────────────────────────────────────────────────────
#  PROTOCOLO DE ESCRITURA — obligatorio, sobre todo con agentes en paralelo
# ─────────────────────────────────────────────────────────────────────────────
#  1. OWNERSHIP: cada campo tiene UN solo dueño. Escribe únicamente los campos
#     de tu bloque. Nunca escribas el bloque de otro agente.
#  2. EL ESTADO ES UN TESTIGO: el Orquestador escribe 'ready' y 'needs_fix' en
#     el campo de un agente (le pasa el testigo). El agente escribe
#     'in_progress', 'done' y 'blocked' en su propio campo. Nunca los dos a la
#     vez: si tu estado es 'ready', el testigo es tuyo.
#  3. RELEE ANTES DE ESCRIBIR: vuelve a leer el archivo justo antes de cada
#     escritura. Otro agente pudo haberlo cambiado desde tu última lectura.
#  4. EDICIÓN QUIRÚRGICA: modifica solo tus líneas. NUNCA reescribas el archivo
#     completo (eso es lo que pisa el trabajo de los demás).
#  5. TIMESTAMP: al cambiar tu estado, actualiza tu campo _ts con
#     `date '+%Y-%m-%d %H:%M'`. Un estado sin timestamp fresco es sospechoso.
#  6. BITÁCORA: los eventos se AGREGAN al final del archivo, nunca se editan ni
#     se borran. Es el registro append-only del ADR.
# ─────────────────────────────────────────────────────────────────────────────

# ─── ADR Activo ──────────────────────────────────────────────────────────────
# Dueño: Orquestador
adr=
titulo=
branch=
api_contract=
iniciado=

# ─── Estado del Orquestador ──────────────────────────────────────────────────
# Dueño: Orquestador
# Valores: idle | coordinating | reviewing | awaiting_human | pr_ready
# awaiting_human = implementación terminada, esperando la revisión del líder.
# pr_ready       = docs listas, esperando que el líder autorice el PR.
orchestrator=idle
orchestrator_ts=

# ─── Estado por agente ───────────────────────────────────────────────────────
# Valores: idle | ready | in_progress | done | needs_fix | blocked
# 'ready' y 'needs_fix' los escribe el Orquestador. El resto, el propio agente.
# Cada agente es dueño de su bloque completo (estado + _ts + _mensaje).

backend=idle
backend_ts=
backend_mensaje=

frontend=idle
frontend_ts=
frontend_mensaje=

# QA valida dos veces por ADR: tras Backend y tras Frontend.
# qa_alcance (backend | frontend) lo escribe el Orquestador al pasar el testigo.
qa=idle
qa_ts=
qa_mensaje=
qa_alcance=

contexto=idle
contexto_ts=
contexto_mensaje=

featuredocs=idle
featuredocs_ts=
featuredocs_mensaje=

# ─── Issues ──────────────────────────────────────────────────────────────────
# Dueño: Orquestador
backend_issues=
frontend_issues=
completados=

# ─── Handoff ─────────────────────────────────────────────────────────────────
# Dueño: Orquestador — ningún agente escribe aquí.
# Fases: planeacion | backend_ready | qa_backend | frontend_ready | qa_frontend |
#        awaiting_human | docs | pr_autorizado | pr_creado
handoff_phase=
handoff_message=

# ─── Blocker ─────────────────────────────────────────────────────────────────
# Dueño: Orquestador — ningún agente escribe aquí.
# Un agente bloqueado pone su propio estado en 'blocked' y explica en su
# campo _mensaje; el Orquestador lo promueve a esta sección y lo asigna.
blocker_agente=
blocker_detalle=

# ─── Aprobación humana ───────────────────────────────────────────────────────
# Dueño: Orquestador, reflejando la decisión del líder del proyecto.
# Valores: pending | approved | rejected
aprobacion=pending
aprobado_por=
nota=

# ─── Bitácora (APPEND-ONLY) ──────────────────────────────────────────────────
# Cualquier agente AGREGA líneas al final. Nadie edita ni borra lo anterior.
# Formato: [YYYY-MM-DD HH:MM] agente: qué pasó
