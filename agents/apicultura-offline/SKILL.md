---
name: apicultura-offline
description: "Diseña y desarrolla una plataforma apícola multiplataforma y offline-first: registro de colmenas, inspecciones, voz, sanidad y sincronización. Úsala al planificar, implementar o revisar este producto."
---

# Apicultura Offline

Construye un cuaderno de campo apícola confiable sin conexión para teléfonos, relojes y equipos de escritorio. Prioriza registrar una inspección rápidamente, con datos estructurados, trazabilidad y sincronización posterior.

## Principios de producto

- La base local es la fuente inmediata de verdad: ninguna inspección depende de red.
- Modela acontecimientos históricos inmutables o auditables, no solo el estado actual de una colmena.
- El dictado del apicultor se transcribe a campos y nota; no se conserva su audio. La muestra acústica ambiental de la colmena se limita a 60 segundos y requiere consentimiento/indicador visible.
- Confirma por UI los datos sanitarios, tratamientos, cantidades y acciones que puedan haberse reconocido mal por voz.
- Presenta incertidumbre: distingue valores medidos, observados, dictados, estimados y completados luego desde una fuente meteorológica.
- Usa identificadores estables (UUID) para apiarios, colmenas, inspecciones y dispositivos; permite etiquetas QR/NFC como identificador físico.

## Plataformas

Propón Flutter/Dart como base compartida para iOS, Android, macOS, Windows y Linux. Mantén adaptadores nativos para GPS, clima, micrófono, reconocimiento de voz, cámara, QR/NFC y conectividad. El teléfono realiza las operaciones complejas; Apple Watch y Wear OS ofrecen comandos breves, consulta de tareas e inicio/fin de inspecciones.

No supongas reconocimiento de voz offline universal: comprueba la capacidad del dispositivo, ofrece formulario rápido y permite dictado online solo con consentimiento. No mantengas escucha continua.

## Modelo y sincronización

Para el catálogo de eventos, relaciones y campos recomendados, lee [references/modelo-apicola.md](references/modelo-apicola.md) antes de crear migraciones, APIs o pantallas de captura.

Guarda las operaciones localmente en SQLite y encola cambios para sincronizarlos cuando exista conectividad. Conserva los eventos concurrentes; resuelve conflictos explícitamente para atributos singulares, como la reina activa. Nunca descarta silenciosamente una inspección de campo.

## Interacción de inspección

Diseña un flujo de una mano y apto para guantes:

1. Elegir/escuchar la colmena y comenzar inspección.
2. Capturar hora, ubicación y datos ambientales disponibles.
3. Registrar estado, observaciones y acciones por frases breves o botones grandes.
4. Opcionalmente grabar la muestra acústica ambiental de un minuto.
5. Revisar resumen, corregir y finalizar.

Mantén siempre accesibles: guardar sin red, pausa/finalización de cronómetro, nota libre, tarea pendiente y deshacer la última entrada.

## Seguridad y calidad

- Protege las cuentas, datos de ubicación y audios en tránsito y en reposo.
- Registra quién creó o modificó cada evento y cuándo.
- Para tratamientos, incluye producto, principio activo, dosis, lote, fecha y período de retiro cuando corresponda; la aplicación informa, pero no sustituye el asesoramiento veterinario ni la normativa local.
- Diseña pruebas para migraciones, almacenamiento offline, reintentos de sincronización, conflictos, permisos denegados y pérdida de batería durante una inspección.
