# Iniciar Sesión

El usuario ingresa su **número de colegio profesional** y **contraseña** en el formulario de login de la pantalla de inicio.

## Flujo de autenticación

```
Pantalla de inicio (GTK3)
│
├── Campo: Número de colegio  (ej. COL-10245)
└── Campo: Contraseña         (enmascarada)
        │
        ▼
  buscar(numero_colegio) en Árbol AVL
        │
   ┌────┴──────────┐
   │               │
Encontrado     No encontrado
   │               └── ⚠ "Credenciales incorrectas"
   │
Verificar contraseña
   │
  ┌┴──────────────────┐
  │                   │
Correcta          Incorrecta → ⚠ "Credenciales incorrectas"
  │
Cargar tipo_usuario + departamento del nodo AVL
  │
  ▼
Renderizar vista personalizada
```

El mensaje de error siempre es genérico ("Credenciales incorrectas") para no revelar si el número de colegio existe o no.

---

[← Volver a Usuarios](Usuarios.md)
