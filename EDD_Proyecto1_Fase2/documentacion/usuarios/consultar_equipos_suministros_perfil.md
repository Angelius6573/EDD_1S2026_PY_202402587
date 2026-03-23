# Consultar Disponibilidad de Equipos Médicos

**Disponible para:** TIPO-02 (DEP-CIR), TIPO-04 (DEP-LAB)

El usuario busca un equipo por su código (`EQU-XXX`) en el **Árbol BST**. Esta función es especialmente útil para cirujanos que deben verificar la disponibilidad de equipos quirúrgicos antes de un procedimiento.

## Información mostrada

| Campo | Descripción |
|-------|-------------|
| Código | Identificador único del equipo |
| Nombre | Nombre del equipo |
| Fabricante | Empresa fabricante |
| Precio unitario | Valor en quetzales |
| Cantidad disponible | Unidades en inventario |
| Nivel mínimo | Stock mínimo recomendado |
| Fecha de ingreso | Fecha de incorporación al inventario |
| **Alerta de stock** | Se muestra si `cantidad < nivel_minimo` |

La búsqueda recorre el BST en O(log n) comparando el código ingresado con las claves del árbol.

---

[← Volver a Usuarios](Usuarios.md)

---

# Consultar Disponibilidad de Suministros

**Disponible para:** TIPO-01 y TIPO-03 (DEP-MED), TIPO-02 y TIPO-03 (DEP-CIR)

El usuario busca un suministro por su código (`SUM-XXX`) en el **Árbol B de Orden 4**.

## Información mostrada

| Campo | Descripción |
|-------|-------------|
| Código | Identificador único del suministro |
| Nombre | Nombre del suministro |
| Fabricante | Empresa fabricante |
| Precio unitario | Valor en quetzales |
| Cantidad disponible | Unidades en inventario |
| Fecha de vencimiento | Fecha límite (si aplica) |
| Nivel mínimo | Stock mínimo recomendado |
| **Alerta de stock** | Se muestra si `cantidad < nivel_minimo` |

La búsqueda desciende por el Árbol B comparando la clave en cada nodo hasta encontrar el suministro o confirmar que no existe.

---

[← Volver a Usuarios](Usuarios.md)

---

# Perfil de Usuario

El usuario puede consultar y editar su información registrada en el sistema. Los datos se leen directamente del nodo correspondiente en el **Árbol AVL**.

## Información visible

| Campo | Editable |
|-------|:--------:|
| Número de colegio | ✗ |
| Nombre completo | ✓ |
| Tipo de usuario | ✗ |
| Departamento | ✗ |
| Especialidad | ✗ |
| Contraseña | ✓ |

Al guardar cambios de nombre o contraseña, el nodo en el AVL se actualiza directamente sin necesidad de reinserción (las claves de ordenamiento no cambian).

---

[← Volver a Usuarios](Usuarios.md)
