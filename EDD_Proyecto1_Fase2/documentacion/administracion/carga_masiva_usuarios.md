# Carga Masiva de Usuarios Departamentales

Esta función permite incorporar múltiples miembros del personal médico al sistema en una sola operación cargando un archivo JSON desde la interfaz GTK3.

---

## Estructura del archivo JSON

```json
{
  "usuarios": [
    {
      "numero_colegio": "COL-10245",
      "nombre_completo": "Ana Ramírez",
      "tipo_usuario": "TIPO-01",
      "departamento": "DEP-MED",
      "especialidad": "Medicina General",
      "contrasena": "medgen2026"
    },
    {
      "numero_colegio": "COL-20134",
      "nombre_completo": "María Paz",
      "tipo_usuario": "TIPO-03",
      "departamento": "DEP-FAR",
      "especialidad": "",
      "contrasena": "enf2026far"
    }
  ]
}
```

### Campos y validaciones

| Campo | Tipo | Requerido | Validación |
|-------|------|:---------:|------------|
| `numero_colegio` | String (`COL-NNNNN`) | ✓ | No debe existir ya en el AVL |
| `nombre_completo` | String | ✓ | No vacío |
| `tipo_usuario` | String | ✓ | Debe ser TIPO-01 a TIPO-04 |
| `departamento` | String | ✓ | Debe ser DEP-MED, DEP-CIR, DEP-LAB o DEP-FAR |
| `especialidad` | String | Solo TIPO-01 y TIPO-02 | Puede ser `""` o `null` para TIPO-03 y TIPO-04 |
| `contrasena` | String | ✓ | No vacío |

### Tipos de usuario válidos

| Código | Rol |
|--------|-----|
| TIPO-01 | Médico General |
| TIPO-02 | Médico Especialista / Cirujano |
| TIPO-03 | Enfermero/a |
| TIPO-04 | Técnico de Laboratorio |

> **TIPO-05 (Personal Administrativo)** no se puede cargar mediante este método. Solo el administrador maestro existe con ese nivel.

---

## Flujo de procesamiento

```
Seleccionar archivo JSON
        │
        ▼
  Parsear JSON con decode_json()
        │
        ▼
  Para cada usuario:
    ├── Validar campos obligatorios
    ├── Verificar que tipo_usuario y departamento sean compatibles
    ├── Buscar numero_colegio en el Árbol AVL
    │       ├── Ya existe → Descartar + advertencia
    │       └── No existe → Insertar en AVL + rotaciones de balance
        │
        ▼
  Mostrar resumen: X insertados, Y descartados
```

---

## Compatibilidad tipo-departamento

La carga masiva verifica que el tipo de usuario sea compatible con el departamento indicado (según la tabla de permisos). Si hay incompatibilidad, el usuario se descarta con una advertencia.

| Departamento | Tipos permitidos |
|-------------|-----------------|
| DEP-MED | TIPO-01, TIPO-03 |
| DEP-CIR | TIPO-02, TIPO-03 |
| DEP-LAB | TIPO-04 |
| DEP-FAR | TIPO-03 |

---

### Regresar al panel de administración

[← Administrador](Administrador.md)
