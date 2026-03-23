# Panel de Personal Médico — Árbol AVL

El Árbol AVL es la estructura central del sistema de autenticación y gestión del personal médico. Almacena todos los usuarios departamentales ordenados por número de colegio profesional, garantizando búsquedas en O(log n) en todo momento gracias al auto-balanceo.

---

## ¿Qué es un Árbol AVL?

Un **Árbol AVL** (Adelson-Velsky y Landis) es un árbol binario de búsqueda que se autobalancea en cada inserción y eliminación. La propiedad de balance establece que:

```
|altura(subárbol_izquierdo) - altura(subárbol_derecho)| ≤ 1
```

Este factor de balance se mantiene mediante **rotaciones** simples y dobles que se ejecutan automáticamente.

```
       COL-20567               COL-20567
      /          \            /          \
 COL-10245    COL-30412  →  COL-10245  COL-30412
                    \                  /
                  COL-50456       COL-50456
                  
  Factor: +2 (desbalanceado)    Factor: 0 (balanceado tras rotación)
```

| Operación | Complejidad garantizada |
|-----------|:-----------------------:|
| Insertar  | O(log n) |
| Buscar    | O(log n) |
| Eliminar  | O(log n) |

---

## Estructura de un nodo de usuario

```perl
my $nodo = {
    numero_colegio  => "COL-10245",   # Clave de ordenamiento
    nombre_completo => "Ana Ramírez",
    tipo_usuario    => "TIPO-01",
    departamento    => "DEP-MED",
    especialidad    => "Medicina General",
    contrasena      => "medgen2026",  # Se recomienda almacenar hash en producción
    altura          => 1,             # Para calcular factor de balance
    izquierdo       => undef,
    derecho         => undef,
};
```

---

## Rotaciones de balance

### Rotación simple derecha (caso LL)
Se aplica cuando el desbalance ocurre en el subárbol izquierdo del hijo izquierdo.

```
    C (FB=+2)          B
   /                  / \
  B (FB=+1)    →     A   C
 /
A
```

### Rotación simple izquierda (caso RR)
Se aplica cuando el desbalance ocurre en el subárbol derecho del hijo derecho.

```
A (FB=-2)              B
  \                   / \
   B (FB=-1)   →     A   C
     \
      C
```

### Rotación doble izquierda-derecha (caso LR)
```perl
sub rotacion_lr {
    my ($self, $nodo) = @_;
    $nodo->{izquierdo} = $self->rotacion_izquierda($nodo->{izquierdo});
    return $self->rotacion_derecha($nodo);
}
```

### Rotación doble derecha-izquierda (caso RL)
```perl
sub rotacion_rl {
    my ($self, $nodo) = @_;
    $nodo->{derecho} = $self->rotacion_derecha($nodo->{derecho});
    return $self->rotacion_izquierda($nodo);
}
```

---

## Operaciones del panel

### Función 5 — Registrar Usuario Departamental

El administrador llena el siguiente formulario en GTK3:

| Campo | Tipo | Notas |
|-------|------|-------|
| Número de colegio | String (`COL-NNNNN`) | Clave única; se verifica duplicado en AVL |
| Nombre completo | String | |
| Tipo de usuario | Desplegable TIPO-01 a TIPO-04 | |
| Departamento | Desplegable DEP-xxx | |
| Especialidad | String | Solo requerido para TIPO-01 y TIPO-02 |
| Contraseña | String (enmascarado) | |

Si el número de colegio ya existe en el AVL, se muestra una notificación y se cancela el registro.

---

### 6.1 Visualizar tabla de personal

Genera un recorrido **In-Orden** del AVL y presenta los resultados en una tabla GTK3 con las columnas:

| Nº Colegio | Nombre Completo | Tipo | Especialidad | Departamento |
|------------|----------------|------|-------------|--------------|

La tabla incluye **filtros** por departamento, especialidad y tipo de usuario.

---

### 6.2 Buscar usuario por número de colegio

Búsqueda eficiente O(log n) en el AVL. Retorna la ficha completa del usuario o un mensaje de "usuario no encontrado".

```perl
sub buscar {
    my ($self, $colegio, $nodo) = @_;
    $nodo //= $self->{raiz};
    return undef unless defined $nodo;
    if    ($colegio eq $nodo->{numero_colegio}) { return $nodo }
    elsif ($colegio lt $nodo->{numero_colegio}) { return $self->buscar($colegio, $nodo->{izquierdo}) }
    else                                         { return $self->buscar($colegio, $nodo->{derecho}) }
}
```

---

### 6.3 Eliminar usuario del sistema

El administrador ingresa el número de colegio a eliminar. El sistema:
1. Localiza el nodo en el AVL.
2. Aplica el algoritmo de eliminación estándar de BST.
3. Recalcula los factores de balance desde el punto de eliminación hacia la raíz.
4. Ejecuta las rotaciones necesarias (simples o dobles) para restaurar el balance.

---

### 6.4 Visualizar personal por recorridos

Disponibles los tres recorridos estándar:

| Recorrido | Orden de visita |
|-----------|----------------|
| **In-Orden** | Ascendente por número de colegio (por defecto en la tabla) |
| **Pre-Orden** | Raíz → izquierdo → derecho |
| **Post-Orden** | Izquierdo → derecho → raíz |

---

## Autenticación con el AVL

Cuando un usuario departamental inicia sesión, el sistema ejecuta `buscar(numero_colegio)` en el AVL y verifica la contraseña en el nodo encontrado. El flujo es:

```
Ingresa número de colegio + contraseña
            │
     buscar() en AVL
            │
   ┌────────┴──────────┐
   │                   │
Encontrado         No encontrado → "Credenciales incorrectas"
   │
Verificar contraseña
   │
  ┌┴──────────────────┐
  │                   │
Correcta          Incorrecta → "Credenciales incorrectas"
  │
Cargar perfil + permisos del departamento
  │
  ▼
Vista de usuario médico
```

---

## Reporte gráfico

Ver [Reporte Árbol AVL](../reportes/ReportesGraficos.md#reporte-árbol-avl).

---

### Regresar al panel de administración

[← Administrador](Administrador.md)
