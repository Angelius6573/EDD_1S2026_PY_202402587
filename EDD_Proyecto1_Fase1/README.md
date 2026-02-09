# EDD MedTrack
## Primer Semestre 2026 - Proyecto 1 | Estructura de Datos
[![Perl](https://img.shields.io/badge/Perl-39457E?style=flat&logo=perl&logoColor=white)](https://www.perl.org/) [![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)](https://www.kernel.org/) [![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=arch-linux&logoColor=white)](https://archlinux.org/) [![Graphviz](https://img.shields.io/badge/Graphviz-DOT-5A7E3E?style=flat&logo=graphviz&logoColor=white)](https://graphviz.org/) [![SVG](https://img.shields.io/badge/SVG-Images-FFB13B?style=flat&logo=svg&logoColor=black)](https://www.w3.org/Graphics/SVG/) [![FIUSAC](https://img.shields.io/badge/FIUSAC-Facultad%20de%20Ingenieria-blue?style=flat)](https://portal.ingenieria.usac.edu.gt/) [![Licencia MIT](https://img.shields.io/badge/Licencia-MIT-blue?style=flat)](../LICENSE)

El Hospital General San Carlos necesita implementar el sistema **EDD MedTrack** para automatizar la gestión de su inventario de medicamentos y equipos, actualmente basada en registros manuales que causan desabastecimiento, pérdida de información de vencimientos y falta de trazabilidad. 

- El sistema permitirá un control integral del stock, gestionará solicitudes de reabastecimiento por departamento.
- Mantendrá un historial completo de todas las transacciones y generará reportes automáticos.
- Los administradores podrán gestionar las transacciones, mientras los usuarios podrán hacer consultas y solicitudes.

## Documentación
- [Administración](documentacion/administracion/Administrador.md)
- [Usuarios](documentacion/usuarios/Usuarios.md)
- [Reportes](documentacion/reportes/Reportes.md)

## Tecnología
La **EDD MedTrack** esta enteramente desarrollada con el lenguaje de programación Perl, el entorno de desarrollo fue una computadora portátil con ArchLinux y NeoVim como IDE. El uso de librerías externas se redujo únicamente a dos, **Text::CSV** y **Graphviz**, que son útiles para la lectura de archivos **.csv** con mayor facilidad y a la generación de reportes gráficos respectivamente.

## Instalación en Linux
Descarga del repositorio:
```sh
mkdir -p ~/Desktop/EDD && git clone https://github.com/Angelius6573/EDD_1S2026_PY_202402587
```

### ArchLinux y derivados (Manjaro, EndeavourOS, Garuda Linux, CachyOS)
Descarga e instalación de las dependencias necesarias:
```sh
sudo pacman -S perl perl-text-csv graphviz
```

### Debian/Ubuntu y derivados (Linux Mint, Xubuntu, Pop! OS, Zorin OS, Kali Linux, Elementary OS)
```bash
sudo apt update
sudo apt install perl libtext-csv-perl graphviz
```

### RHEL y derivados (Fedora, Rocky Linux, AlmaLinux)
```bash
sudo dnf install perl perl-Text-CSV graphviz
```

### Alpine Linux y derivados (PorsmarketOS, Wolfi Linux)
```bash
sudo apk add perl perl-text-csv graphviz
```

### Gentoo y derivados (Chrome OS, Calculate Linux)
```bash
sudo emerge --ask dev-lang/perl dev-perl/Text-CSV media-gfx/graphviz
```

## Instalación en MacOS
Descarga del repositorio sin **Homebrew**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Descarga e instalación de las dependencias necesarias:
```bash
brew install perl graphviz
cpan Text::CSV
```

## Instalación en Windows 11
- Descargar e instalar [Strawberry Perl](https://strawberryperl.com/)
- Agregar a Perl al PATH
- Instalar dependencias desde cpan
```bash
cpan Text::CSV
```
- Descargar e instalar [Graphviz](https://graphviz.org/download/)
- Agregar Graphviz al PATH

---
<p align="center">
Copyright (c) 2026 Angel Raúl Herrera Chilel.
</p>
<p align="center">
El contenido de terceros utilizado en este proyecto se emplea únicamente con fines educativos. Todos los derechos pertenecen a sus respectivos propietarios.
</p>
