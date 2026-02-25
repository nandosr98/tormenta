# Repo profile: Mihai + Nando Laravel

## Priority repos reviewed
- dgt_report
- notasimple

Both share very similar architecture and business flow patterns.

## Shared architecture signals
- Laravel + Breeze auth scaffolding
- Livewire components for dashboard/admin
- Stripe via Cashier + webhook jobs
- Custom Rules for domain validation
- Extensive business-event mailers
- Helpers for 3rd-party integrations (Stripe/Google Ads)

## Repos reviewed (extra)
- cvMaker: Laravel 12 app baseline (lighter)
- laravel-remarketing: package-oriented repo (not app flow)
- laravel-support-center: package-oriented + Livewire package stack

## Coding behavior cues
- Explicit control flow in controllers is accepted.
- Logging is first-class for troubleshooting production flows.
- Session recovery paths are implemented for interrupted journeys.
- Practical implementation > over-engineered abstraction.

## Do / Don't

Do:
- Copy nearest existing feature pattern.
- Keep names, routes, and view style coherent with repo.
- Prefer incremental edits and compatibility.

Don't:
- Introduce unrelated frameworks/patterns.
- Rename broad domains without request.
- Replace controller-heavy flows with big refactors unasked.
