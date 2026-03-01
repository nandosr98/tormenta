#!/usr/bin/env python3
import os
import sys
import uuid
from datetime import datetime, timedelta
from dateutil import tz
import caldav


def load_env(path):
    if not os.path.exists(path):
        return
    with open(path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#') or '=' not in line:
                continue
            k, v = line.split('=', 1)
            os.environ.setdefault(k.strip(), v.strip())


def get_calendar(principal, preferred_name=None):
    calendars = principal.calendars()
    if not calendars:
        raise RuntimeError('No calendars found in iCloud account')
    if preferred_name:
        for c in calendars:
            name = (getattr(c, 'name', None) or '').strip()
            if name.lower() == preferred_name.lower():
                return c
    return calendars[0]


def cmd_list(principal):
    for c in principal.calendars():
        print(f"- {getattr(c, 'name', '(no-name)')}")


def cmd_add_test(principal, cal_name):
    cal = get_calendar(principal, cal_name)
    local_tz = tz.gettz('Europe/Berlin')
    start = datetime.now(local_tz) + timedelta(minutes=10)
    end = start + timedelta(minutes=30)
    uid = f"storm-{int(start.timestamp())}@openclaw"
    ics = f"""BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Storm//OpenClaw//ES
BEGIN:VEVENT
UID:{uid}
DTSTAMP:{datetime.utcnow().strftime('%Y%m%dT%H%M%SZ')}
DTSTART:{start.strftime('%Y%m%dT%H%M%S')}
DTEND:{end.strftime('%Y%m%dT%H%M%S')}
SUMMARY:Prueba Storm Calendar
DESCRIPTION:Evento de prueba creado por Storm
END:VEVENT
END:VCALENDAR
"""
    cal.save_event(ics)
    print('OK: test event created')


def cmd_add_reminder(principal, cal_name, title='Recordatorio de prueba', minutes=60):
    cal = get_calendar(principal, cal_name)
    local_tz = tz.gettz('Europe/Berlin')
    due = datetime.now(local_tz) + timedelta(minutes=minutes)
    uid = f"storm-reminder-{uuid.uuid4()}@openclaw"
    dtstamp = datetime.utcnow().strftime('%Y%m%dT%H%M%SZ')
    due_local = due.strftime('%Y%m%dT%H%M%S')

    # Apple Reminders-compatible VTODO
    ics = f"""BEGIN:VCALENDAR
VERSION:2.0
CALSCALE:GREGORIAN
PRODID:-//Tormenta//Reminders//ES
BEGIN:VTODO
UID:{uid}
DTSTAMP:{dtstamp}
CREATED:{dtstamp}
LAST-MODIFIED:{dtstamp}
SUMMARY:{title}
DESCRIPTION:Creado por Tormenta
STATUS:NEEDS-ACTION
DTSTART;TZID=Europe/Berlin:{due_local}
DUE;TZID=Europe/Berlin:{due_local}
PRIORITY:5
END:VTODO
END:VCALENDAR
"""
    cal.save_todo(ics)
    print(f"OK: reminder created in '{getattr(cal, 'name', '?')}' for {due.strftime('%H:%M:%S')}")


def main():
    base = os.path.dirname(os.path.abspath(__file__))
    load_env(os.path.join(base, '.env'))

    url = os.getenv('ICLOUD_CALDAV_URL', 'https://caldav.icloud.com')
    user = os.getenv('ICLOUD_APPLE_ID')
    pwd = os.getenv('ICLOUD_APP_PASSWORD')
    cal_name = os.getenv('ICLOUD_CALENDAR_NAME')

    if not user or not pwd:
        print('Missing ICLOUD_APPLE_ID / ICLOUD_APP_PASSWORD in integrations/calendar/.env')
        sys.exit(1)

    client = caldav.DAVClient(url=url, username=user, password=pwd)
    principal = client.principal()

    cmd = sys.argv[1] if len(sys.argv) > 1 else 'list'
    if cmd == 'list':
        cmd_list(principal)
    elif cmd == 'add-test':
        cmd_add_test(principal, cal_name)
    elif cmd == 'add-reminder-test':
        cmd_add_reminder(principal, cal_name)
    elif cmd == 'add-reminder':
        # Usage: add-reminder <title> <minutes> [calendar_name]
        title = sys.argv[2] if len(sys.argv) > 2 else 'Recordatorio'
        minutes = int(sys.argv[3]) if len(sys.argv) > 3 else 1
        target_cal = sys.argv[4] if len(sys.argv) > 4 else cal_name
        cmd_add_reminder(principal, target_cal, title=title, minutes=minutes)
    else:
        print('Usage: icloud-calendar.py [list|add-test|add-reminder-test|add-reminder <title> <minutes> [calendar_name]]')
        sys.exit(2)


if __name__ == '__main__':
    main()
