#!/usr/bin/perl
package interfaz::admin::common;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use FindBin;
use lib $FindBin::Bin;
use Gtk3;
use Glib qw(TRUE FALSE);
use interfaz::estilos;

sub boton {
    my ( $texto, $clase ) = @_;
    my $btn = Gtk3::Button->new($texto);
    $btn->get_style_context()->add_class($clase);
    return $btn;
}

sub campo_entry {
    my ( $texto, $es_contra ) = @_;
    my $lbl = Gtk3::Label->new($texto);
    $lbl->set_halign('start');
    $lbl->get_style_context()->add_class('campo-label');
    my $e = Gtk3::Entry->new();
    $e->set_visibility(FALSE) if $es_contra;
    $e->set_hexpand(TRUE);
    return ( $e, $lbl );
}

sub tab_label {
    my ($texto) = @_;
    return Gtk3::Label->new($texto);
}

sub msg_info {
    my ($msg) = @_;
    my $dlg = Gtk3::MessageDialog->new( undef, ['modal'], 'info', 'ok', $msg );
    $dlg->run();
    $dlg->destroy();
}

sub confirmar_y_ejecutar {
    my ( $msg, $cb ) = @_;
    my $dlg =
      Gtk3::MessageDialog->new( undef, ['modal'], 'question', 'yes-no', $msg );
    my $resp = $dlg->run();
    $dlg->destroy();
    $cb->() if $resp eq 'yes';
}

sub crear_vista_generica {
    my ( $store, $headers_ref ) = @_;
    my $view = Gtk3::TreeView->new($store);
    $view->set_hexpand(TRUE);
    $view->get_selection()->set_mode('single');

    for my $i ( 0 .. $#$headers_ref ) {
        my $col =
          Gtk3::TreeViewColumn->new_with_attributes( $headers_ref->[$i],
            Gtk3::CellRendererText->new(),
            text => $i );
        $col->set_resizable(TRUE);
        $col->set_sort_column_id($i);
        $view->append_column($col);
    }
    return $view;
}

# Agregar al final de interfaz/admin/common.pm
sub mensaje {
    my ( $lbl, $txt, $error ) = @_;
    if ($error) {
        $lbl->get_style_context()->remove_class('estado-ok');
        $lbl->get_style_context()->add_class('alerta-stock');
    }
    else {
        $lbl->get_style_context()->remove_class('alerta-stock');
        $lbl->get_style_context()->add_class('estado-ok');
    }
    $lbl->set_text($txt);
}

1;
