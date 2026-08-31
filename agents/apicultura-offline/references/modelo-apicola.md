# Modelo de dominio apícola

Usa IDs UUID y fechas con zona horaria. Cada registro debe llevar `created_at`, `updated_at`, `created_by`, `device_id` y un estado de sincronización.

## Entidades

| Entidad | Campos esenciales |
| --- | --- |
| `apiary` | nombre, ubicación, propietario, notas, estado |
| `hive` | apiary_id, código visible, QR/NFC, tipo, fecha de alta, estado, procedencia |
| `inspection` | hive_id, inicio, fin, inspector, ubicación, clima, estado I/II/III, nota transcrita |
| `queen_observation` | inspection_id, vista, marcada, postura, celdas reales, evidencia |
| `frame_observation` | inspection_id, cantidad total, con cría, huevos, miel, polen, calidad |
| `health_observation` | inspection_id, signos de enfermedad, varroa, método de medición, conteo, mortalidad, plagas |
| `management_event` | hive_id, inspection_id opcional, tipo, cantidades, detalle, realizado_en |
| `treatment` | hive_id, producto, principio activo, dosis, lote, inicio, fin, período de retiro |
| `task` | hive_id, tipo, descripción, prioridad, fecha objetivo, responsable, estado |
| `harvest` | hive_id, fecha, cuadros, peso/cantidad, calidad, lote, destino |
| `material_condition` | inspection_id, alza, techo, piso, piquera, madera, observación |
| `ambient_audio` | inspection_id, duración máxima 60 s, hash, ruta cifrada, consentimiento |

## Catálogo inicial de manejo

- Unión o división de colmenas; incorporación de cuadro con huevos; inserción de reina; captura y establecimiento de enjambre.
- Alimentación con jarabe, cuadro de miel o torta proteica.
- Agregado/retiro de alza; cambio de cuadros, alza, techo, piso, partes de madera y ajuste de piquera.
- Tratamiento contra varroa y medición asociada.
- Cosecha de cuadros con cantidad y calidad.

## Observaciones iniciales

- Reina, zánganos, postura, celdas reales, comportamiento higiénico y agresividad.
- Miel, polen, cría, mortalidad en suelo y estado del material.
- Enfermedades, varroa, chaqueta amarilla, pillaje y otros ataques.

No limites el modelo a estas opciones: los catálogos deben ser configurables por apiario o instalación.

## Reglas de integridad

- Una inspección se asocia a una sola colmena; puede originar muchas observaciones, eventos y tareas.
- El historial no se sobrescribe: una corrección conserva referencia al evento corregido y su motivo.
- La reina activa es una proyección del historial, no una edición destructiva del pasado.
- La medición de varroa requiere método y unidad; no infieras prevalencia sin denominador/método.
- Cada evento de manejo puede asociarse a inventario y costo, aunque esas funciones se implementen más adelante.
