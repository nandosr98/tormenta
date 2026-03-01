#!/usr/bin/env python3
import argparse
from datetime import datetime, timedelta
from urllib.parse import quote


def main():
    p = argparse.ArgumentParser(description="Generate iOS Shortcuts URL for 'Tormenta - Crear Recordatorio'")
    p.add_argument("title", help="Reminder title")
    p.add_argument("--minutes", type=int, default=5, help="Minutes from now")
    p.add_argument("--list", default="Recordatorios", help="Reminders list name")
    p.add_argument("--shortcut", default="Tormenta - Crear Recordatorio", help="Shortcut name")
    p.add_argument("--tz", default="+01:00", help="ISO offset (e.g. +01:00)")
    args = p.parse_args()

    when = datetime.now() + timedelta(minutes=args.minutes)
    iso = when.strftime("%Y-%m-%dT%H:%M:%S") + args.tz
    payload = f"{args.title}|{iso}|{args.list}"

    url = (
        "shortcuts://run-shortcut"
        f"?name={quote(args.shortcut)}"
        "&input=text"
        f"&text={quote(payload)}"
    )

    print("PAYLOAD:")
    print(payload)
    print("\nURL:")
    print(url)


if __name__ == "__main__":
    main()
