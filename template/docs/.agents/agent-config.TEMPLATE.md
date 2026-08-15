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

## 🚨 Reglas críticas del proyecto
<!-- Reglas NO negociables específicas de este proyecto -->
<!-- Ejemplos: multi-tenancy, permisos, i18n, etc. -->

-
-
-
