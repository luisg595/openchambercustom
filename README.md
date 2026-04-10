# OpenChamber + OpenCode Slim Stack

Stack local para desarrollo asistido con IA usando:

-   OpenChamber (UI web)
-   OpenCode CLI
-   oh-my-opencode-slim (orchestrator + subagentes)
-   Docker socket para ejecutar comandos/tests en tus proyectos

## Requisitos

-   Docker + Docker Compose
-   Cuenta de OpenAI con sesión iniciada en OpenCode
-   Linux (recomendado Ubuntu)

## Estructura

``` text
.
├── docker-compose.yml
├── Dockerfile.openchamber
├── .env
├── .env.example
└── data/
    ├── auth/
    ├── config/
    └── app/
```

## Configuración

Crea tu archivo `.env`:

``` env
WORKSPACE_PATH=/ruta/a/tus/proyectos
OPENCHAMBER_PORT=puerto_para_levantar_la_ui
UI_PASSWORD=tu_clave_segura
CONFIG_PATH=./data/config
DATA_PATH=./data/app
```

## Levantar el stack

``` bash
docker compose up -d --build
```

Abre:

-   OpenChamber: http://localhost:{puerto_configurado_en_el_env}

## Primer inicio

1.  Entra con tu `UI_PASSWORD`
2.  Ve a Providers
3.  Inicia sesión con OpenAI
4.  Verifica que aparezcan los agentes de oh-my-opencode-slim

## Qué incluye

-   Agentes slim:
    -   orchestrator
    -   oracle
    -   librarian
    -   explorer
    -   designer
-   Persistencia de auth
-   Persistencia de configuración
-   Acceso al workspace local
-   Acceso al Docker socket

## Proyectos

Tu carpeta de proyectos se monta en `/workspace`.

Selecciona tu repo desde OpenChamber.

## Reiniciar

``` bash
docker compose restart
```

## Actualizar dependencias

``` bash
docker compose down
docker compose up -d --build
```

## Backup recomendado

Respalda:

-   `data/auth`
-   `data/config`
-   `.env`

## Seguridad

-   La UI está protegida con contraseña.
-   El stack escucha solo en localhost.
-   Para acceso remoto, usa Cloudflare Tunnel o un reverse proxy seguro.
