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

1. `docker compose up --build` (or equivalent compose file command)
2. Enter backend container and run:
   - `composer install`
   - `php artisan migrate`
3. Start frontend dev server:
   - `npm run dev`
4. If there is more than 5 minutes of inactivity, stop the frontend dev process (`npm run dev`) to avoid unnecessary resource usage.

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
- For Dockerized projects, mirror the current `docker-compose.yml` structure and the referenced docker folders/files.
- For new projects, enforce container name = project name across compose services to avoid collisions.

## Output contract for each task

- What was changed (files)
- Why this matches repo style
- Risks / follow-up
- Quick verification steps

## References

- Read `references/repo-profile.md` before substantial implementation.
