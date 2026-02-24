# HEARTBEAT.md

# Token monitor (active)
# - Check token usage on each heartbeat.
# - Notify only when a new 10% consumption boundary is crossed.
# - Warn early if >80% consumed.
# - Include: consumed %, remaining %, pace, and ETA (hours) to empty.
# - Keep alerts brief; otherwise respond HEARTBEAT_OK.

# Body health monitor (active)
# - Check temperatures on each heartbeat via /sys/class/thermal.
# - Alert if any key zone (x86_pkg_temp, TCPU, acpitz) exceeds 85°C.
# - Alert if temperature rises >15°C within one heartbeat interval.
# - If fan sensors are unavailable, report only temperature risk alerts.
