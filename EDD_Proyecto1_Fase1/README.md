# EDD MedTrack
## Inicio de Sesión
La interfaz de inicio de sesión se conforma por cuatro elementos importantes:
1. Iniciar Sesión: Comprueba el nombre de usuario y su contraseña en un archivo "[./interfaz_usuario/usuarios.json](./interfaz_usuario/usuarios.json)", si los datos coinciden le deja pasar, ya sea un usuario normal o el administrador.
2. Crear usuario: En este apartado se solicitan cuatro partes, el nombre y correo del usuario, se solicita ingresar y confirmar la contraseña, además, se debe mandar un ticket de solicitud al administrador, el cual debe aceptar al nuevo usuario, si ocurre, se actualiza el previamente mencionado archivo "usuarios.json" y le deja pasar al usuario nuevo en el apartado 1.
3. Recuperar contraseña: Se debe ingresar el nombre y correo de la cuenta, si los datos coinciden, se puede cambiar la contraseña, si falla tres veces se deberá contactar al administrador.
4. Salir: Finaliza el programa de forma segura.


---
Copyright (c) 2026 Angel Raúl Herrera Chilel.
