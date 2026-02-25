# Laravel repo style analysis (Nando + Mihai)

## cvMaker
- Laravel: yes
- PHP: `^8.2`
- laravel/framework: `^12.0`
- Frontend stack hints: alpinejs, axios, laravel-vite-plugin, tailwindcss, vite
- Estructura detectada: app, app/Http/Controllers, routes, database/migrations, resources/views, resources/js, tests
- Patrones detectados:
  - FormRequest validation: app/Http/Requests/ProfileUpdateRequest.php, app/Http/Requests/Auth/LoginRequest.php
  - Service classes: app/Providers/AppServiceProvider.php

## dgt_report
- Laravel: yes
- PHP: `^8.2`
- laravel/framework: `^11.31`
- Paquetes clave: spatie/laravel-medialibrary, livewire/livewire, laravel/horizon, spatie/laravel-cookie-consent, spatie/laravel-google-fonts, spatie/laravel-honeypot, spatie/laravel-stripe-webhooks, spatie/schema-org
- Frontend stack hints: alpinejs, axios, laravel-vite-plugin, tailwindcss, vite
- Estructura detectada: app, app/Http/Controllers, routes, database/migrations, resources/views, resources/js, tests
- Patrones detectados:
  - FormRequest validation: app/Http/Requests/ProfileUpdateRequest.php, app/Http/Requests/Auth/LoginRequest.php
  - Service classes: app/Providers/AppServiceProvider.php, app/Providers/HorizonServiceProvider.php, app/Providers/GoogleAdsServiceProvider.php
  - Jobs/dispatch: app/Livewire/UploadInformation.php, app/Livewire/Admin/DgtReports/View.php, app/Console/Commands/Remarketing.php
  - HTTP client: app/Rules/GoogleRecaptcha.php

## laravel-remarketing
- Laravel: unknown/no
- PHP: `^8.2`
- Paquetes clave: spatie/laravel-package-tools
- Estructura detectada: database/migrations, resources/views

## laravel-support-center
- Laravel: unknown/no
- PHP: `^8.2`
- Paquetes clave: spatie/laravel-medialibrary, livewire/livewire, spatie/laravel-package-tools
- Estructura detectada: routes, database/migrations, resources/views, tests

## notasimple
- Laravel: yes
- PHP: `^8.2`
- laravel/framework: `^11.31`
- Paquetes clave: spatie/laravel-medialibrary, livewire/livewire, laravel/horizon, spatie/laravel-cookie-consent, spatie/laravel-google-fonts, spatie/laravel-honeypot, spatie/laravel-stripe-webhooks, spatie/schema-org
- Frontend stack hints: alpinejs, axios, laravel-vite-plugin, tailwindcss, vite
- Estructura detectada: app, app/Http/Controllers, routes, database/migrations, resources/views, resources/js, tests
- Patrones detectados:
  - FormRequest validation: app/Http/Requests/ProfileUpdateRequest.php, app/Http/Requests/Auth/LoginRequest.php
  - Service classes: app/Providers/AppServiceProvider.php, app/Providers/HorizonServiceProvider.php, app/Providers/GoogleAdsServiceProvider.php
  - Jobs/dispatch: app/Livewire/UploadInformation.php, app/Livewire/Admin/SimpleNotes/View.php, app/Console/Commands/Remarketing.php
  - HTTP client: app/Rules/GoogleRecaptcha.php

## spryker-docs
- Laravel: unknown/no
