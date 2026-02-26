# Integración Email (Gmail API, gratis)

## Qué falta de tu lado
1. Crear proyecto en Google Cloud Console.
2. Habilitar Gmail API.
3. Crear OAuth Client ID (Desktop App).
4. Obtener `refresh_token` con scope `https://www.googleapis.com/auth/gmail.send`.

## Variables de entorno
Copia `.env.example` a `.env` y rellena:
- `GMAIL_CLIENT_ID`
- `GMAIL_CLIENT_SECRET`
- `GMAIL_REFRESH_TOKEN`
- `GMAIL_SENDER`

## Envío de prueba
```bash
node integrations/email/send-gmail.js "destino@correo.com" "Prueba" "Hola desde Storm"
```

## Nota
No subir `.env` ni tokens al repo.
