# agent-config.md — Configuración del Proyecto
# Copia este archivo como docs/.agents/agent-config.md
# y llénalo con los detalles de tu proyecto.
# Este archivo es leído por todos los agentes al arrancar.

---

## 🎯 Proyecto

```
nombre=
descripcion=
tipo=                    # web-app | api | saas | mobile-backend | otro
estado=                  # activo | pausado | mantenimiento
```

---

## 🛠 Stack

```
backend=                 # ej: Laravel 12, Node.js 20, Django 4, etc.
frontend=                # ej: Vue 3 + Inertia.js, React 18, Next.js 14, etc.
base_datos=              # ej: MySQL 8, PostgreSQL 15, MongoDB, etc.
estilos=                 # ej: Tailwind CSS v4, SCSS, Bootstrap 5, etc.
otros=                   # librerías críticas adicionales
```

---

## 📁 Estructura de carpetas

```
adr=                     # ej: docs/adr/
issues=                  # ej: docs/issues/
contracts=               # ej: docs/contracts/
features=                # ej: docs/features/
context=docs/PROJECT_CONTEXT.md
superpowers_plans=       # ej: docs/superpowers/plans/ (dejar vacío si no aplica)
superpowers_specs=       # ej: docs/superpowers/specs/ (dejar vacío si no aplica)
```

---

## 📋 Convenciones

```
idioma_commits=          # español | english
formato_commits=         # ej: <tipo>(<módulo>): <descripción> (<referencia>)
tipos_commits=           # ej: feat, fix, refactor, docs, test, chore
idioma_codigo=           # español | english (nombres de variables, funciones, etc.)
```

---

## 🌲 Git y ramas

```
branch_target=           # rama destino del PR: main | develop | otra
                         # si lo dejas vacío se detecta la rama por defecto del remoto
branch_formato=          # ej: feature/adrXXX-nombre-corto
```

---

## 👥 Roles activos

Desactiva los roles que no apliquen a tu proyecto. Un CLI, una API o una
librería sin interfaz normalmente corren con `frontend=no`.
El Orquestador salta los roles en `no` y no los espera en `status.md`.

```
rol_backend=si           # si | no
rol_frontend=si          # si | no  — pon 'no' en proyectos sin UI
rol_qa=si                # si | no  — desactivarlo elimina el gate de calidad
rol_contexto=si          # si | no
rol_documentador=si      # si | no
```

---

## ✅ Definición de terminado

Qué exige este proyecto para dar un issue por terminado. Lo usa QA como
criterio de validación; lo que dejes vacío no se exige.

```
tests_requeridos=        # ej: unitarios, integración, e2e (vacío = sin exigencia)
cobertura_minima=        # ej: 80 (vacío = sin umbral; no inventes uno)
lint_obligatorio=        # si | no
analisis_estatico=       # si | no
```

---

## 📖 Lectura obligatoria por rol

### Orquestador — leer al arrancar:
-
-

### Backend — leer al arrancar:
-
-

### Frontend — leer al arrancar:
-
-

### QA — leer al arrancar:
-
-

### Contexto — leer al arrancar:
-

### Documentador — leer al arrancar:
-

---

## 🧩 Componentes y patrones clave

### Backend
<!-- Documenta aquí los patrones obligatorios de tu backend -->
<!-- Ejemplos: cómo se estructura un Controller, Service, Model -->
<!-- Patrones que el agente DEBE seguir sin excepción -->


### Frontend
<!-- Documenta aquí los componentes disponibles y cómo usarlos -->
<!-- Ejemplos: formularios, tablas, layouts, toasts, etc. -->
<!-- Patrones que el agente DEBE seguir sin excepción -->


---

## ⚙️ Comandos de desarrollo

```bash
# Levantar entorno

# Correr tests

# Build

# Linting
```

---

## 🔧 Perfil OPT-IN — CI

**Apagado por defecto.** Le da verificación mecánica a los gates que sin esto son
solo texto en un prompt. Corre **en el PR** y condiciona el merge (que hace el
líder) a que los checks activos pasen.

Cada check se activa por separado y **necesita su comando declarado**: sin comando
no corre, y `ci-checks.sh` lo reporta como no ejecutado en vez de darlo por bueno.

```
ci=off                        # on | off

check_tests=si                # respalda a QA
comando_tests=

check_lint=no                 # estilo y formato
comando_lint=

check_static_analysis=no      # tipos y bugs antes de runtime — distinto de lint
comando_static_analysis=

check_secret_scan=no          # que ninguna credencial se cuele
comando_secret_scan=

# Estos dos solo corren si rest_openapi=on
check_openapi_validate=no
comando_openapi_validate=

check_oasdiff=no              # breaking changes de API contra el baseline
comando_oasdiff=
```

La lógica vive en `scripts/ci-checks.sh`, no en el YAML del proveedor: puedes
correrlo a mano (`./scripts/ci-checks.sh`) o portarlo a otro host de CI sin
reescribir los checks. Si tu proyecto no tiene CI, deja `ci=off` y nada cambia.

---

## 🔌 Perfil OPT-IN — API REST con OpenAPI

**Apagado por defecto.** Actívalo solo si el proyecto expone una API REST para
apps o terceros. Un proyecto sin API REST, o cuyo tráfico es server-rendered o de
props a páginas, **no activa este perfil**: esa disciplina contract-first es otra
y no pasa por OpenAPI.

```
rest_openapi=off         # on | off
spec_ubicacion=          # ej: docs/api/v{N}/ — dónde vive el spec y su baseline
generador=               # herramienta que genera OpenAPI DESDE EL CÓDIGO
generador_config=        # ruta a su configuración, si tiene
diff_breaking=           # herramienta de diff de breaking changes en CI
cliente_tipado=off       # on | off — generar cliente tipado desde el spec
dictamen_reviewer=consultivo   # vinculante | consultivo (el líder siempre puede hacer override)
rondas_maximas=2         # rondas Architect<->Reviewer antes de escalar al líder
trigger_agentes=recurso público nuevo, v2, o invocación manual sobre superficie existente
```

El código es la fuente de verdad: el spec se **genera**, no se escribe a mano.

### Convenciones de plataforma de la API

Las decisiones ya tomadas de este proyecto. Los agentes las **consumen**, no las
reinventan por endpoint. Deja vacío lo que no aplique.

```
api_auth=                # ej: Bearer token | OAuth2 | API key
api_forma_errores=       # la forma de error de casa, con un ejemplo del shape
api_paginacion=          # el shape de paginación de casa
api_versionado=          # política: dónde va la versión, cuándo sube, soporte y deprecación
api_scope_tenant=        # cómo se resuelve el tenant/organización (header, claim, etc.)
api_glosario=            # términos del dominio que un consumidor externo confundiría
```

<!-- api_glosario importa más de lo que parece: si dos entidades del dominio
     suenan intercambiables pero una es la cuenta de facturación y otra la unidad
     de aislamiento, documéntalo o los consumidores externos lo van a mezclar. -->

---

## 🤖 Agentes de proyecto

Agentes propios de ESTE proyecto, que el framework no conoce. Sus prompts viven
en `docs/.agents/prompts/proyecto/` y el actualizador nunca los toca.

Deja la sección vacía si no tienes ninguno — el pipeline corre igual.

Declara uno por bloque, con este esquema:

```
[agente]
nombre=                  # identificador corto, sin espacios: se usa como clave en status.md
prompt=                  # ej: docs/.agents/prompts/proyecto/mi-agente.md
activacion=              # cuándo lo enciende el Orquestador (ver abajo)
estados=ready,done,n/a   # estados válidos para este agente en status.md
```

`activacion` describe la condición en lenguaje claro; el Orquestador la evalúa.
Ejemplos: `post-implementacion` (junto a Contexto y Documentador),
`manual` (solo cuando el líder lo pide), o una condición concreta como
"cuando el ADR toca la interfaz pública".

Los agentes de proyecto **heredan las reglas de oro**: commitean solos en la
branch del ADR, no crean PRs y no mergean. Un prompt de proyecto **no puede**
definir su propia política de commits ni saltarse el gate humano.

<!-- Ejemplo (borra o reemplaza):
[agente]
nombre=ayuda
prompt=docs/.agents/prompts/proyecto/ayuda.md
activacion=post-implementacion
estados=ready,done,n/a
-->

---

## 🚨 Reglas críticas del proyecto
<!-- Reglas NO negociables específicas de este proyecto -->
<!-- Ejemplos: multi-tenancy, permisos, i18n, etc. -->

-
-
-
