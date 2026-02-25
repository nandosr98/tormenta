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

## Mandatory style rules

- Keep controllers pragmatic; do not force new architecture unless requested.
- Use existing `Enum` status patterns for state transitions.
- Keep route names and blade/livewire naming conventions aligned with repo.
- Preserve mixed ES/EN business naming used by the project.
- Keep validation messages human and domain-specific.
- For Stripe work, follow existing `Helpers/StripeHelper.php` + `Jobs/StripeWebhooks/*` pattern.

## Output contract for each task

- What was changed (files)
- Why this matches repo style
- Risks / follow-up
- Quick verification steps

## References

- Read `references/repo-profile.md` before substantial implementation.
