#!/usr/bin/perl
package interfaz::usuario::common;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use FindBin;
use lib $FindBin::Bin;
use Gtk3;
use Glib  qw(TRUE FALSE);
use POSIX qw(strftime);
use interfaz::estilos;

sub boton {
    my ( $texto, $clase ) = @_;
    my $btn = Gtk3::Button->new($texto);
    $btn->get_style_context()->add_class($clase);
    return $btn;
}

sub campo_label {
    my ($texto) = @_;
    my $lbl = Gtk3::Label->new($texto);
    $lbl->set_halign('start');
    $lbl->get_style_context()->add_class('campo-label');
    return $lbl;
}

sub tab_label {
    my ($texto) = @_;
    return Gtk3::Label->new($texto);
}

sub treeview_generico {
    my ( $store, $headers_ref, $col_estado ) = @_;
    my $view = Gtk3::TreeView->new($store);
    $view->get_selection()->set_mode('single');
    $view->set_rules_hint(TRUE);

    for my $i ( 0 .. $#$headers_ref ) {
        my $r = Gtk3::CellRendererText->new();
        my $col =
          Gtk3::TreeViewColumn->new_with_attributes( $headers_ref->[$i], $r,
            text => $i );
        $col->set_resizable(TRUE);
        $col->set_min_width(70);

        if ( defined $col_estado && $i == $col_estado ) {
            $col->set_cell_data_func(
                $r,
                sub {
                    my ( $c, $r2, $m, $it ) = @_;
                    my $e = $m->get_value( $it, $col_estado );
                    if ( $e =~ /BAJO/ ) {
                        $r2->set( foreground => '#dc2626' );
                    }
                    elsif ( $e =~ /VENCE/ || $e =~ /Pendiente/ ) {
                        $r2->set( foreground => '#d97706' );
                    }
                    elsif ( $e =~ /VENC/ ) {
                        $r2->set( foreground => '#b91c1c' );
                    }
                    else {
                        $r2->set( foreground => '#15803d' );
                    }
                }
            );
        }
        $view->append_column($col);
    }
    return $view;
}

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

sub fecha_hoy {
    return strftime( '%Y-%m-%d', localtime );
}

sub fecha_limite_vencimiento {
    my @tl = localtime( time + 30 * 86400 );
    return strftime( '%Y-%m-%d', @tl );
}

1;
