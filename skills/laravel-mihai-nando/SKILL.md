---
name: laravel-mihai-nando
description: Implement Laravel features following Mihai + Nando coding style and project philosophy. Use when creating or updating controllers, Livewire components, Stripe/Cashier flows, webhook jobs, mails, enums, validation rules, and directory structure in their repos.
---

# Laravel Mihai + Nando

Implement code in existing project style. Prioritize consistency over “clean rewrite”.

## Workflow

1. Detect nearest existing module in the same repo.
2. Mirror folder placement and naming from that module.
3. Keep business flow explicit (request -> validate -> persist -> pay/webhook -> notify -> redirect).
4. Add trace logs at critical steps.
5. Reuse existing helpers/jobs/rules before adding new abstractions.
6. Run minimal verification (lint/tests available + route smoke).

## First-run bootstrap (Laravel repos in Mihai/Nando style)

When cloning a project for the first time, do this in order:

1. Bring stack up with build:
   - `docker compose up --build -d`
2. Ensure env file for compose exists (`.env.local` when compose expects it).
3. Ensure Laravel writable paths have correct permissions in backend container (bind mounts override Dockerfile permissions):
   - `storage`
   - `storage/framework`
   - `storage/framework/views`
   - `bootstrap/cache`
   - Recommended fix command:
     - `docker exec -it <backend-container> sh -lc "chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache"`
4. Enter backend container and run:
   - `composer install`
   - `php artisan key:generate`
   - `php artisan migrate`
   - `php artisan db:seed`
   - `php artisan optimize:clear`
5. Build frontend assets on host:
   - `npm install`
   - `npm run build`
6. Do not use `npm run dev` by default; only use it when Nando explicitly asks for dev mode.

Preferred command style for running commands inside backend container:
- `docker exec -it <backend-container-name> <command>`

Example:
- `docker exec -it cv-maker-backend <comando_que_quieres_lanzar>`

## Mandatory style rules

- Keep controllers pragmatic; do not force new architecture unless requested.
- Use existing `Enum` status patterns for state transitions.
- Keep route names and blade/livewire naming conventions aligned with repo.
- Preserve mixed ES/EN business naming used by the project.
- Keep validation messages human and domain-specific.
- For Stripe work, follow existing `Helpers/StripeHelper.php` + `Jobs/StripeWebhooks/*` pattern.
- For Dockerized projects, mirror the current `docker-compose.yml` structure and referenced docker files exactly.
- Preferred proven layout (from Ororo commit `[Feat] Docker Fixed and adapted to PHP@8.4`):
  - `docker-compose.yml` with services:
    - `webserver` (`container_name: <project>-webserver`) built from `docker/nginx/Dockerfile`
    - `<project>-backend` built from `docker/<project>/Dockerfile`
    - `<project>-db` (MySQL) using `.env.local`
  - Nginx split configs:
    - `docker/nginx/Dockerfile`
    - `docker/nginx/nginx.base.conf`
    - `docker/nginx/nginx-dev.conf` (or env-specific conf)
  - Backend Dockerfile based on `php:8.4-fpm` with required extensions.
- For new projects, enforce container name = project name across compose services to avoid collisions.

## Output contract for each task

- What was changed (files)
- Why this matches repo style
- Risks / follow-up
- Quick verification steps

## References

- Read `references/repo-profile.md` before substantial implementation.
