# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### Email contacts

- Nando → fsanchezrequ@gmail.com
- Mihai Stana → mihai.stana@gmail.com
- Carlos Iravedra → iravedra.carlos@gmail.com

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

## Calendar / Reminders command rules (Nando)

- Decisive word `Evento` → create calendar event.
- Decisive word `Recordatorio` → create reminder.
- If neither is specified, ask whether Nando wants `Recordatorio`, `Evento`, or both.

### Required questions before creating

For `Evento`:
1. Day/time
2. Title
3. Target calendar
4. Duration (always ask explicitly)

For `Recordatorio`:
1. Reminder name
2. When it should alert

### Fixed footer

- Calendar events must always include: `Creado por Tormenta`.

## Docker vocabulary (Nando)

- `levanta(r) <proyecto>` => run `docker compose up` (normally detached)
- `tira(r) <proyecto>` => run `docker compose down`
- For Laravel projects, run frontend build on host (outside containers) using `npm run build` by default.
- Do not rely on long-running `npm run dev` unless Nando explicitly asks for dev mode.

## Repo safeguards (Tormenta workspace)

- Para tareas >3 pasos o de alto riesgo, usar `improvements/how-to-use-execution-contract.md`.
- Secret scanning local: instalar hook con `bash scripts/setup-gitleaks-hook.sh`.

---

Add whatever helps you do your job. This is your cheat sheet.
