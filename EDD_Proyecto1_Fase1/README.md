# EDD MedTrack
## Menú de inicio
La interfaz de inicio de sesión se conforma por cuatro elementos importantes:
1. Iniciar Sesión: Comprueba el nombre de usuario y su contraseña en un archivo "[./interfaz_usuario/usuarios.json](./interfaz_usuario/usuarios.json)", si los datos coinciden le deja pasar, ya sea un usuario normal o el administrador.
2. Crear usuario: En este apartado se solicitan cuatro partes, el nombre y correo del usuario, se solicita ingresar y confirmar la contraseña, además, se debe mandar un ticket de solicitud al administrador, el cual debe aceptar al nuevo usuario, si ocurre, se actualiza el previamente mencionado archivo "usuarios.json" y le deja pasar usando el apartado del inciso 1.
3. Recuperar contraseña: Se debe ingresar el nombre y correo de la cuenta, si los datos coinciden, se puede cambiar la contraseña, si falla tres veces se deberá contactar al administrador, esta es una decisión de interfaz (puede estar sujeta a cambios).
4. Salir: Finaliza el programa de forma segura.


## Interfaz del administrador
La interfaz del administrador es el módulo de gestión de mas alta categoría en el sistema, tiene la capacidad de leer, editar y eliminar datos de la "EDD MedTrack", así como el control total sobre la gestión de los usuarios. Para nuestro sistema hospitalario es vital contar con el inventario necesario para atender las necesidades del paciente, es por esto que el administrador tiene este nivel de control. Además su interfaz se divide en nueve puntos clave que facilitan la visualización de la gestión:
1. Registrar medicamento: El administrador debe llenar un formulario con datos apropiados para el código de medicamento, nombre comercial, principio activo, laboratorio del fabricante, cantidad disponible, fecha de vencimiento, precio y cantidad mínima de inventario, respectivamente, estos datos son ingresados en una lista doblemente enlazada de forma dinámica.
2. Carga masiva de medicamentos: Al igual que en el punto anterior, el administrador debe cargar el mismo listado de datos, pero además, aquí se deben cargar archivos .csv, este sistema de gestión en tablas permite la carga masiva de datos. Los datos recibidos de esta manera son almacenados en la misma lista doblemente enlazada del punto anterior.
3. Gestionar proveedores: 
9. Cerrar sesión: Finaliza la interfaz del administrador y le devuelve al menú de inicio.


## Interfaz del usuario
4. Cerrar sesión: Finaliza la interfaz del usuario y le devuelve al menú de inicio.

## Reportes


---
Copyright (c) 2026 Angel Raúl Herrera Chilel.
