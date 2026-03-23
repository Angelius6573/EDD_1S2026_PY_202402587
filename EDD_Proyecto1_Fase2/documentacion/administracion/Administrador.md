# Administrador — Panel de Control

El administrador accede al sistema con las credenciales especiales (`AdminHospital` / `MedTrack2025`), las cuales **no** forman parte del Árbol AVL de personal médico. Al autenticarse, se despliega el panel principal con acceso a todas las funciones del sistema.

---

## Funciones disponibles

| # | Función | Enlace |
|---|---------|--------|
| 1 | Carga Masiva de Inventario (JSON) | [Ver documentación](carga_masiva_inventario.md) |
| 2 | Gestionar Inventario de Equipos (Árbol BST) | [Ver documentación](gestionar_equipos_bst.md) |
| 3 | Gestionar Inventario de Suministros (Árbol B) | [Ver documentación](gestionar_suministros_arbolb.md) |
| 4 | Carga Masiva de Usuarios Departamentales (JSON) | [Ver documentación](carga_masiva_usuarios.md) |
| 5 | Registrar Usuario Departamental | [Ver documentación](registrar_usuario.md) |
| 6 | Panel de Personal Médico (Árbol AVL) | [Ver documentación](panel_personal_avl.md) |
| 7 | Consultar y Comparar por Proveedor/Fabricante (Matriz Dispersa) | [Ver documentación](matriz_dispersa_proveedores.md) |
| 8 | Ver Reportes Gráficos | [Ver documentación](../reportes/ReportesGraficos.md) |

> Las funciones heredadas de la Fase 1 (registrar medicamento individual, gestionar proveedores, procesar solicitudes de reabastecimiento) se mantienen en el panel bajo sus mismas opciones.

---

## Vista general del panel (GTK3)

El panel del administrador se organiza en dos columnas:

- **Columna izquierda:** tabla dinámica del personal médico autorizado (recorrido In-Orden del AVL), con filtros por departamento, especialidad y tipo de usuario.
- **Columna derecha:** botones de acción agrupados en *Recorridos*, *Reportes* y *Carga Masiva*.

El encabezado muestra `Bienvenido Administrador` y la barra de navegación permite acceder a las distintas secciones.

---

## Tabla de permisos departamentales

El administrador es el único que puede ver esta tabla completa. Los usuarios departamentales solo acceden al inventario permitido por su departamento.

| Código | Departamento | Tipos de Usuario Permitidos | Acceso a Inventario |
|--------|-------------|----------------------------|---------------------|
| DEP-ADM | Administración General | TIPO-05 | TOTAL |
| DEP-MED | Medicina General y Consulta Externa | TIPO-01, TIPO-03 | MEDICAMENTOS + SUMINISTROS |
| DEP-CIR | Cirugía y Quirófanos | TIPO-02, TIPO-03 | EQUIPO + SUMINISTROS |
| DEP-LAB | Laboratorio Clínico | TIPO-04 | EQUIPO |
| DEP-FAR | Farmacia Hospitalaria | TIPO-03 | MEDICAMENTOS |

---

## Recorridos de árbol disponibles

Para el **Árbol AVL** y el **Árbol BST**, el administrador puede visualizar tres tipos de recorrido desde el panel:

| Recorrido | Descripción |
|-----------|-------------|
| **In-Orden** | Muestra los nodos en orden ascendente por clave (por defecto) |
| **Pre-Orden** | Raíz → subárbol izquierdo → subárbol derecho |
| **Post-Orden** | Subárbol izquierdo → subárbol derecho → raíz |

Para el **Árbol B de Orden 4**, solo se ofrece recorrido **In-Orden**.

---

## Regresar al índice

[← Volver al README principal](../../README.md)
