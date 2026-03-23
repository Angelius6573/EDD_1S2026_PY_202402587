# EDD MedTrack - Fase 2
## Primer Semestre 2026 | Estructura de Datos

[![Perl](https://img.shields.io/badge/Perl-39457E?style=flat&logo=perl&logoColor=white)](https://www.perl.org/)
[![GTK](https://img.shields.io/badge/GTK-3.0-7BA23F?style=flat&logo=gtk&logoColor=white)](https://www.gtk.org/)
[![Graphviz](https://img.shields.io/badge/Graphviz-DOT-5A7E3E?style=flat&logo=graphviz&logoColor=white)](https://graphviz.org/)
[![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)](https://www.kernel.org/)
[![FIUSAC](https://img.shields.io/badge/FIUSAC-Facultad%20de%20Ingenieria-blue?style=flat)](https://portal.ingenieria.usac.edu.gt/)
[![Licencia MIT](https://img.shields.io/badge/Licencia-MIT-blue?style=flat)](LICENSE)

El **Hospital General San Carlos** requiere una segunda fase del sistema **EDD MedTrack** para gestionar su inventario hospitalario de manera robusta y escalable. Esta versión incorpora estructuras de datos no lineales, un sistema de permisos por departamento y una interfaz gráfica completa con GTK3.

---
## Documentación principal

| Módulo | Descripción |
|--------|-------------|
| [Administrador](documentacion/administracion/Administrador.md) | Panel del administrador: inventario, personal médico, reportes y carga masiva |
| [Usuario Médico](documentacion/usuarios/Usuarios.md) | Funcionalidades del personal médico autenticado |
| [Estructuras de Datos](documentacion/estructuras/README.md) | Árbol BST, AVL, B de Orden 4, Matriz Dispersa y Listas |
| [Interfaz Gráfica](documentacion/gui/InterfazGrafica.md) | Componentes GTK3 y flujo de la aplicación |
| [Reportes con Graphviz](documentacion/reportes/ReportesGraficos.md) | Generación de diagramas DOT y visualización |

---

## Tecnología
- **Perl 5** — lenguaje principal
- **GTK3** vía módulo `Gtk3` — interfaz gráfica
- **Graphviz** (`dot`) — reportes visuales en PNG/SVG
- **JSON** — persistencia y carga masiva de datos
- **Sin librerías externas de estructuras** — todo implementado manualmente

---
## Instalación

### Arch Linux / Manjaro
```bash
sudo pacman -S perl perl-gtk3 graphviz
```

### Debian / Ubuntu y derivados
```bash
sudo apt update
sudo apt install perl libgtk3-perl graphviz
```

### macOS (Homebrew)
```bash
brew install perl graphviz
cpan Gtk3
```

### Windows 11
1. Instalar [Strawberry Perl](https://strawberryperl.com/) y agregar al PATH.
2. Instalar [Graphviz](https://graphviz.org/download/) y agregar al PATH.
3. Desde CPAN: `cpan Gtk3`

---
## Ejecución
```bash
perl main.pl
```
La aplicación inicia directamente en la ventana de login de GTK3. No existe modo consola; toda la interacción es gráfica.

---

<p align="center">
Copyright © 2026 Angel Raúl Herrera Chilel.
</p>
<p align="center">
El contenido de terceros utilizado en este proyecto se emplea únicamente con fines educativos.
Todos los derechos pertenecen a sus respectivos propietarios.
</p>
