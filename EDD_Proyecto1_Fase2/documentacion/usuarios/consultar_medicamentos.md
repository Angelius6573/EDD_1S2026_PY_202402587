# Consultar Disponibilidad de Medicamentos

**Disponible para:** TIPO-01 (DEP-MED), TIPO-03 (DEP-MED, DEP-FAR)

El usuario busca un medicamento por su código (`MED-XXX`) en la **lista doblemente enlazada** heredada de la Fase 1.

## Información mostrada

| Campo | Descripción |
|-------|-------------|
| Código | Identificador único del medicamento |
| Nombre | Nombre comercial |
| Principio activo | Componente farmacológico |
| Fabricante | Empresa fabricante |
| Cantidad disponible | Stock actual en unidades |
| Precio unitario | Precio en quetzales |
| Fecha de vencimiento | Fecha límite de uso |
| Nivel mínimo | Stock mínimo recomendado |
| **Alerta de stock** | Se muestra si `cantidad < nivel_minimo` |

## Alerta de stock crítico

Si la cantidad disponible está por debajo del nivel mínimo, se muestra un indicador visual en rojo:

```
⚠ STOCK CRÍTICO — Tylenol (MED-001)
   Disponible: 320 unidades
   Nivel mínimo: 500 unidades
```

---

[← Volver a Usuarios](Usuarios.md)
