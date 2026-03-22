#!/usr/bin/perl
package interfaz::estilos;
use strict;
use warnings;
use utf8;
use Encode qw(encode_utf8);
use Gtk3;

my $CSS = <<'END_CSS';

* {
    font-family: "Ubuntu", "Noto Sans", "Liberation Sans", sans-serif;
    font-size: 10pt;
}

window {
    background-color: #ffffff;
    color: #4a1d6d;
}

/* ── Barra superior ───────────────────────────────────────────────────── */
.barra-titulo {
    background-color: #4a1d6d;
    color: #ffffff;
    padding: 12px 20px;
    border-bottom: 2px solid #d4af37;
}
.barra-titulo label {
    color: #ffffff;
    font-weight: bold;
}
.bienvenida-label {
    color: #d4af37;
    font-style: italic;
}

/* ── Sidebar ──────────────────────────────────────────────────────────── */
.sidebar {
    background-color: #faf5ff;
    color: #4a1d6d;
    padding: 12px 0px;
    border-right: 2px solid #d4af37;
}
.sidebar-boton {
    background-color: transparent;
    color: #4a1d6d;
    border: none;
    padding: 12px 20px;
    font-weight: 500;
}
.sidebar-boton:hover {
    background-color: #e9d5ff;
    color: #4a1d6d;
}
.sidebar-boton:active,
.sidebar-boton.activo {
    background-color: #4a1d6d;
    color: #d4af37;
    font-weight: bold;
    border-left: 4px solid #d4af37;
}

/* ── Tarjetas ─────────────────────────────────────────────────────────── */
.tarjeta {
    background-color: #ffffff;
    border-radius: 12px;
    border: 1px solid #e9d5ff;
    padding: 16px;
}
.tarjeta-titulo {
    font-weight: bold;
    color: #4a1d6d;
    padding-bottom: 10px;
    border-bottom: 2px solid #d4af37;
    margin-bottom: 12px;
}

/* ── Frames ───────────────────────────────────────────────────────────── */
frame {
    background-color: #ffffff;
    border: 1px solid #e9d5ff;
    border-radius: 8px;
    margin: 4px;
}
frame > border {
    border: none;
}
frame label {
    color: #4a1d6d;
}

/* ── Botones principales ──────────────────────────────────────────────── */
.boton-primario {
    background-color: #4a1d6d;
    color: #d4af37;
    border-radius: 8px;
    border: none;
    padding: 8px 20px;
    font-weight: 600;
}
.boton-primario:hover {
    background-color: #5a2d7d;
    color: #e5c75e;
}
.boton-primario:active {
    background-color: #3a0d5d;
    color: #c9aa2f;
}

/* ── Botones peligro ──────────────────────────────────────────────────── */
.boton-peligro {
    background-color: #dc2626;
    color: #ffffff;
    border-radius: 8px;
    border: none;
    padding: 8px 20px;
    font-weight: 600;
}
.boton-peligro:hover {
    background-color: #b91c1c;
    color: #ffffff;
}
.boton-peligro:active {
    background-color: #991b1b;
    color: #ffffff;
}

/* ── Botones secundarios ──────────────────────────────────────────────── */
.boton-secundario {
    background-color: #9b4dff;
    color: #ffffff;
    border-radius: 8px;
    border: none;
    padding: 8px 20px;
    font-weight: 500;
}
.boton-secundario:hover {
    background-color: #ad6eff;
    color: #ffffff;
}
.boton-secundario:active {
    background-color: #8a2be2;
    color: #ffffff;
}

/* ── Entradas de texto ────────────────────────────────────────────────── */
entry {
    border: 2px solid #c4b0d8;
    border-radius: 8px;
    padding: 8px 12px;
    background-color: #faf5ff;
    color: #2d0a4a;
    caret-color: #4a1d6d;
}
entry:focus {
    border-color: #9b4dff;
    background-color: #ffffff;
}
entry:disabled {
    background-color: #f0e8f8;
    color: #7a6090;
    border-color: #d0b8e8;
}

/* ── SpinButton (cantidad a pedir) ────────────────────────────────────── */
spinbutton {
    border: 2px solid #c4b0d8;
    border-radius: 8px;
    background-color: #faf5ff;
    color: #2d0a4a;
}
spinbutton entry {
    border: none;
    background-color: transparent;
    color: #2d0a4a;
    font-weight: 600;
    min-width: 60px;
}
spinbutton button {
    background-color: #9b4dff;
    color: #ffffff;
    border-radius: 4px;
    border: none;
    min-width: 28px;
    min-height: 28px;
}
spinbutton button:hover {
    background-color: #ad6eff;
}
spinbutton button:active {
    background-color: #7a2fd6;
}

/* ── ComboBoxText / ComboBox ──────────────────────────────────────────── */
combobox button,
combobox button.combo {
    background-color: #faf5ff;
    color: #2d0a4a;
    border: 2px solid #c4b0d8;
    border-radius: 8px;
    padding: 6px 12px;
    font-weight: 500;
}
combobox button:hover,
combobox button.combo:hover {
    background-color: #e9d5ff;
    border-color: #9b4dff;
    color: #2d0a4a;
}
combobox button:focus,
combobox button.combo:focus {
    border-color: #9b4dff;
    background-color: #f0e6ff;
}
/* Flecha del combo */
combobox arrow {
    color: #4a1d6d;
    min-width: 16px;
    min-height: 16px;
}
/* Menú desplegable */
menu {
    background-color: #ffffff;
    border: 1px solid #c4b0d8;
    border-radius: 8px;
    padding: 4px;
}
menuitem {
    color: #2d0a4a;
    padding: 6px 12px;
    border-radius: 4px;
}
menuitem:hover {
    background-color: #e9d5ff;
    color: #2d0a4a;
}

/* ── TreeView / tabla ─────────────────────────────────────────────────── */
treeview {
    background-color: #ffffff;
    color: #2d0a4a;
}
treeview:selected {
    background-color: #9b4dff;
    color: #ffffff;
}
treeview header button {
    background-color: #faf5ff;
    color: #4a1d6d;
    font-weight: bold;
    border-bottom: 2px solid #d4af37;
    padding: 8px 6px;
}
treeview:hover {
    background-color: #faf5ff;
}

/* ── Notebook / Tabs ──────────────────────────────────────────────────── */
notebook tab {
    background-color: #faf5ff;
    color: #4a1d6d;
    padding: 8px 20px;
    border: 1px solid #e9d5ff;
    border-bottom: none;
    font-weight: 500;
}
notebook tab:checked {
    background-color: #4a1d6d;
    color: #d4af37;
    font-weight: bold;
    border-top: 2px solid #d4af37;
}
notebook {
    background-color: #ffffff;
}

/* ── TextView (áreas de texto / logs / recorridos) ────────────────────── */
textview {
    background-color: #faf5ff;
    color: #2d0a4a;
    border-radius: 6px;
    border: 1px solid #c4b0d8;
}
textview text {
    background-color: #faf5ff;
    color: #2d0a4a;
}
textview:focus text {
    background-color: #ffffff;
}

/* ── ScrolledWindow ───────────────────────────────────────────────────── */
scrolledwindow {
    border: 1px solid #e9d5ff;
    border-radius: 8px;
    background-color: #ffffff;
}

/* ── Login ────────────────────────────────────────────────────────────── */
.login-titulo {
    font-weight: bold;
    color: #4a1d6d;
}
.login-subtitulo {
    color: #9b4dff;
    font-style: italic;
}
.login-caja {
    background-color: #ffffff;
    border-radius: 16px;
    border: 2px solid #e9d5ff;
    padding: 40px;
}

/* ── Etiquetas de estado ──────────────────────────────────────────────── */
.alerta-stock {
    color: #dc2626;
    font-weight: bold;
    background-color: #fee2e2;
    padding: 4px 8px;
    border-radius: 6px;
}
.alerta-vencimiento {
    color: #d97706;
    font-weight: bold;
    background-color: #fffbeb;
    padding: 4px 8px;
    border-radius: 6px;
}
.estado-ok {
    color: #10b981;
    background-color: #d1fae5;
    padding: 4px 8px;
    border-radius: 6px;
}
.campo-label {
    font-weight: 600;
    color: #4a1d6d;
    margin-bottom: 4px;
}
.valor-label {
    color: #2d0a4a;
}

/* ── Contenedores generales ───────────────────────────────────────────── */
grid {
    background-color: #ffffff;
}
box {
    background-color: #ffffff;
}

/* ── Transiciones ─────────────────────────────────────────────────────── */
button {
    transition: all 0.15s ease;
}

END_CSS

sub aplicar {
    my $provider = Gtk3::CssProvider->new();
    $provider->load_from_data( encode_utf8($CSS) );
    my $screen = Gtk3::Gdk::Screen::get_default();
    Gtk3::StyleContext::add_provider_for_screen( $screen, $provider,
        Gtk3::STYLE_PROVIDER_PRIORITY_APPLICATION );
}

sub agregar_clase {
    my ( $widget, $clase ) = @_;
    $widget->get_style_context()->add_class($clase);
}

sub quitar_clase {
    my ( $widget, $clase ) = @_;
    $widget->get_style_context()->remove_class($clase);
}

1;
