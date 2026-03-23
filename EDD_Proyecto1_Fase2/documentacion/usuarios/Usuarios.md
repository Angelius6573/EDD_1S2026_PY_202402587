# Usuarios Médicos — Panel de Funciones

Un usuario departamental es aquel cuyas credenciales (número de colegio + contraseña) están registradas en el **Árbol AVL** del sistema. Al autenticarse, accede a una interfaz personalizada según su tipo y departamento.

---

## Tipos de usuario y acceso al inventario

| Código | Rol | Departamento | Inventario accesible |
|--------|-----|-------------|---------------------|
| TIPO-01 | Médico General | DEP-MED | Medicamentos + Suministros |
| TIPO-02 | Médico Especialista / Cirujano | DEP-CIR | Equipos + Suministros |
| TIPO-03 | Enfermero/a | DEP-FAR, DEP-MED, DEP-CIR | Según departamento |
| TIPO-04 | Técnico de Laboratorio | DEP-LAB | Equipos |

---

## Funciones disponibles

| # | Función | Enlace |
|---|---------|--------|
| 1 | Iniciar Sesión | [Ver documentación](iniciar_sesion.md) |
| 2 | Consultar Disponibilidad de Medicamentos | [Ver documentación](consultar_medicamentos.md) |
| 3 | Consultar Disponibilidad de Equipos Médicos | [Ver documentación](consultar_equipos.md) |
| 4 | Consultar Disponibilidad de Suministros | [Ver documentación](consultar_suministros.md) |
| 5 | Perfil de Usuario | [Ver documentación](perfil_usuario.md) |

> Las funciones visibles en el menú dependen del tipo y departamento del usuario. Por ejemplo, un TIPO-04 en DEP-LAB solo verá la opción de consulta de equipos.

---

## Vista principal

La vista principal del usuario incluye:

- **Encabezado:** `Bienvenido/a, {cargo} {nombre}` (ej. `Bienvenido/a, Dr. Ana Ramírez`)
- **Resumen de inventario** según su tipo de usuario (stock disponible de las categorías a las que tiene acceso)
- **Alertas activas:** ítems con stock por debajo del nivel mínimo o próximos a vencer
- **Barra de búsqueda** para localizar ítems rápidamente por código o nombre

---

### Regresar al índice

[← Volver al README principal](../../README.md)
