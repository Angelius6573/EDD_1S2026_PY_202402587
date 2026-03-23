# Interfaz Gráfica — GTK3 con Perl

La interfaz de EDD MedTrack Fase 2 está construida íntegramente en GTK3 mediante el módulo `Gtk3` de Perl. No existe modo consola; toda la interacción ocurre a través de ventanas y formularios gráficos.

---
## Componentes GTK3 utilizados

| Widget GTK3 | Uso |
|-------------|-----|
| `Gtk3::Window` | Ventana principal de cada vista |
| `Gtk3::Notebook` | Pestañas en la pantalla de login |
| `Gtk3::Entry` | Campos de texto y contraseña |
| `Gtk3::Button` | Botones de acción |
| `Gtk3::TreeView` + `Gtk3::ListStore` | Tablas de datos (personal, inventario) |
| `Gtk3::ComboBoxText` | Listas desplegables (filtros, tipo usuario) |
| `Gtk3::FileChooserDialog` | Selector de archivos JSON |
| `Gtk3::MessageDialog` | Mensajes de error, advertencia y confirmación |
| `Gtk3::Image` | Visualización de reportes Graphviz (PNG) |
| `Gtk3::ScrolledWindow` | Contenedor con scroll para tablas y reportes |
| `Gtk3::Grid` | Organización en cuadrícula de formularios |
| `Gtk3::Label` | Etiquetas descriptivas |
| `Gtk3::ProgressBar` | Indicador durante la carga masiva |

---

## Patrón de inicialización

```perl
use Gtk3 '-init';

# Crear la ventana principal
my $ventana = Gtk3::Window->new('toplevel');
$ventana->set_title('EDD MedTrack');
$ventana->set_default_size(900, 600);
$ventana->signal_connect(destroy => sub { Gtk3->main_quit });

# Construir contenido y mostrar
_construir_login($ventana);
$ventana->show_all;
Gtk3->main;
```

---

## Manejo de errores en la interfaz

Los errores se comunican al usuario mediante `Gtk3::MessageDialog`:

```perl
sub mostrar_error {
    my ($padre, $mensaje) = @_;
    my $dialogo = Gtk3::MessageDialog->new(
        $padre,
        'destroy-with-parent',
        'error',
        'ok',
        $mensaje
    );
    $dialogo->run;
    $dialogo->destroy;
}
```

Los tipos de diálogo usados son:
- `'error'` — credenciales incorrectas, campo inválido, código duplicado.
- `'warning'` — ítem descartado en carga masiva.
- `'info'` — operación completada con éxito.
- `'question'` — confirmación antes de eliminar un usuario o equipo.

---

[← Volver al README principal](../../README.md)
