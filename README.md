<p align="center">
  <img src="docs/cover.png" alt="OpenChamber cover" />
</p>

# OpenChamber + OpenCode Slim Stack

Stack local para desarrollo asistido con IA usando:

-   OpenChamber (UI web)
-   OpenCode CLI
-   oh-my-opencode-slim (orchestrator + subagentes)
-   Docker socket opcional para ejecutar comandos/tests en tus proyectos

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

- `CONFIG_PATH` guarda la configuración de OpenCode/proveedores.
- `DATA_PATH` guarda el estado de OpenChamber, incluyendo proyectos recientes y sesión web.
- El callback OAuth de OpenCode/OpenAI queda publicado automáticamente en `127.0.0.1:1455`, porque OpenCode devuelve el navegador a `http://localhost:1455/auth/callback`. No es el puerto de la UI de OpenChamber.

Al levantar el contenedor, si `CONFIG_PATH` está vacío, el stack ahora copia la config base automáticamente. El plugin `oh-my-opencode-slim` vive dentro de la imagen, así que el bind mount de `CONFIG_PATH` ya no tapa la instalación.

## Levantar el stack

``` bash
docker compose up -d --build
```

## Docker socket opcional

Si necesitas acceso a Docker del host desde OpenChamber, levanta el stack con el compose adicional:

``` bash
docker compose -f docker-compose.yml -f docker-compose.docker-sock.yml up -d --build
```

Si también quieres levantar simultáneamente el soporte SSH opcional, solo tienes que sumar ambos `-f` en el mismo comando:

``` bash
docker compose -f docker-compose.yml -f docker-compose.docker-sock.yml -f docker-compose.ssh.yml up -d --build
```

Ese acceso es sensible: equivale prácticamente a dar control administrativo del host a procesos dentro del contenedor. La configuración incluida deja solo algunos comandos de inspección en `allow`, pide confirmación para comandos Docker en general y deniega varios patrones de escape obvios, pero sigue siendo una superficie de alto riesgo.

Mientras el Docker socket esté activo, cualquier comando `docker ...` o `docker compose ...` ejecutado vía OpenCode/OpenChamber quedará en modo `ask`, así que siempre se te consultará antes de ejecutarlo.

## SSH opcional

Por defecto el stack ya no monta ninguna key SSH local, así que no rompe si otro dev no tiene el mismo archivo o usa otro tipo de clave.

Si necesitas acceso SSH dentro del contenedor, define `SSH_DIR` en tu `.env`:

``` env
SSH_DIR=/home/tu_usuario/.ssh
```

Esto monta tu carpeta SSH completa en modo solo lectura dentro del contenedor, así que úsalo solo si realmente lo necesitas.

Y levanta el stack sumando el compose opcional:

``` bash
docker compose -f docker-compose.yml -f docker-compose.ssh.yml up -d --build
```

Si además quieres montar también el Docker socket opcional, usa este comando completo:

``` bash
docker compose -f docker-compose.yml -f docker-compose.docker-sock.yml -f docker-compose.ssh.yml up -d --build
```

Abre:

-   OpenChamber: http://localhost:{puerto_configurado_en_el_env}

## Primer inicio

1.  Entra con tu `UI_PASSWORD`
2.  Ve a Providers
3.  Inicia sesión con OpenAI
4.  Verifica que aparezcan los agentes de oh-my-opencode-slim

Durante el login con OpenAI es normal ver una URL de callback en `http://localhost:1455/auth/callback`: ese puerto pertenece al flujo OAuth de OpenCode y el compose lo publica automáticamente, mientras que la UI de OpenChamber sigue en `OPENCHAMBER_PORT`.

Si entras por primera vez y el volumen de config estaba vacío, ese bootstrap ocurre al arrancar el contenedor. Si ya tenías un volumen viejo o roto, reconstruye y reinicia para que regenere la config faltante.

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
-   Acceso opcional al Docker socket

## Proyectos

Tu carpeta de proyectos se monta en `/workspace`.

Al iniciar el contenedor, el stack registra automáticamente como `safe.directory` cada repo Git detectado directamente dentro de `/workspace`.

Selecciona tu repo desde OpenChamber.

Si en logs ves `GET /api/git/branches` seguido de `fatal: not a git repository`, normalmente significa que la UI todavía está apuntando a `/workspace` o a una carpeta padre que no es repo Git. No suele ser un fallo del stack: desaparece al abrir un proyecto que sí tenga `.git` o al montar directamente la raíz del repo como `WORKSPACE_PATH`.

## Reiniciar

``` bash
docker compose restart
```

## Actualizar dependencias

Si OpenChamber tiene una actualización nueva y quieres reconstruir las imágenes desde cero, usa este flujo:

``` bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

Si levantaste el stack con composes opcionales, repite el mismo conjunto de archivos en los tres comandos. Por ejemplo:

``` bash
docker compose -f docker-compose.yml -f docker-compose.docker-sock.yml -f docker-compose.ssh.yml down
docker compose -f docker-compose.yml -f docker-compose.docker-sock.yml -f docker-compose.ssh.yml build --no-cache
docker compose -f docker-compose.yml -f docker-compose.docker-sock.yml -f docker-compose.ssh.yml up -d
```

## Backup recomendado

Respalda:

-   `data/auth`
-   `data/config`
-   `.env`

## Seguridad

-   La UI está protegida con contraseña.
-   El stack escucha solo en localhost.
-   El Docker socket no se monta por defecto.
-   Para acceso remoto, usa Cloudflare Tunnel o un reverse proxy seguro.
