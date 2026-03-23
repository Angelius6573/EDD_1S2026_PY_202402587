#!/usr/bin/perl
package interfaz::admin::visor_imagen;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use FindBin;
use lib $FindBin::Bin;
use Gtk3;
use Glib qw(TRUE FALSE);

# Valores de eventos de Gdk (constantes numéricas)
use constant {
    GDK_BUTTON_PRESS_MASK   => 1 << 2,    # 4
    GDK_BUTTON_RELEASE_MASK => 1 << 3,    # 8
    GDK_POINTER_MOTION_MASK => 1 << 1,    # 2
};

sub crear_visor {
    my ( $ruta_archivo, $titulo ) = @_;

    my $win = Gtk3::Window->new('toplevel');
    $win->set_title( $titulo // 'Visor de Imagen' );
    $win->set_default_size( 900, 700 );
    $win->set_position('center');

    my $vbox = Gtk3::Box->new( 'vertical', 0 );

    my $toolbar = Gtk3::Toolbar->new();
    $toolbar->set_style('icons');

    my $zoom_in   = Gtk3::ToolButton->new_from_stock('zoom-in');
    my $zoom_out  = Gtk3::ToolButton->new_from_stock('zoom-out');
    my $zoom_fit  = Gtk3::ToolButton->new_from_stock('zoom-fit');
    my $zoom_100  = Gtk3::ToolButton->new_from_stock('zoom-100');
    my $separator = Gtk3::SeparatorToolItem->new();
    my $btn_abrir = Gtk3::ToolButton->new_from_stock('open');

    $toolbar->insert( $zoom_in,   -1 );
    $toolbar->insert( $zoom_out,  -1 );
    $toolbar->insert( $zoom_fit,  -1 );
    $toolbar->insert( $zoom_100,  -1 );
    $toolbar->insert( $separator, -1 );
    $toolbar->insert( $btn_abrir, -1 );

    my $scrolled = Gtk3::ScrolledWindow->new();
    $scrolled->set_policy( 'automatic', 'automatic' );
    $scrolled->set_hexpand(TRUE);
    $scrolled->set_vexpand(TRUE);

    my $viewport  = Gtk3::Viewport->new( undef, undef );
    my $event_box = Gtk3::EventBox->new();
    my $imagen    = Gtk3::Image->new();

    $event_box->add($imagen);
    $viewport->add($event_box);
    $scrolled->add($viewport);

    my $zoom_actual = 1.0;
    my $pixbuf_original;

    # Cargar la imagen
    if ( $ruta_archivo =~ /\.svg$/i ) {
        eval {
            $pixbuf_original = Gtk3::Gdk::Pixbuf->new_from_file($ruta_archivo);
        };
        if ($@) {
            $imagen->set_from_stock( 'gtk-missing-image', 'menu' );
            $imagen->set_tooltip_text("No se pudo cargar la imagen SVG\n$@");
            $pixbuf_original = undef;
        }
    }
    else {
        eval {
            $pixbuf_original = Gtk3::Gdk::Pixbuf->new_from_file($ruta_archivo);
        };
        if ($@) {
            $imagen->set_from_stock( 'gtk-missing-image', 'menu' );
            $imagen->set_tooltip_text("No se pudo cargar la imagen\n$@");
            $pixbuf_original = undef;
        }
    }

    my $actualizar_zoom = sub {
        return unless $pixbuf_original;
        my $ancho = int( $pixbuf_original->get_width() * $zoom_actual );
        my $alto  = int( $pixbuf_original->get_height() * $zoom_actual );
        $ancho = 1 if $ancho < 1;
        $alto  = 1 if $alto < 1;
        my $escalado =
          $pixbuf_original->scale_simple( $ancho, $alto, 'bilinear' );
        $imagen->set_from_pixbuf($escalado);
        $event_box->set_size_request( $ancho, $alto );
    };

    my $ajustar_ventana = sub {
        return unless $pixbuf_original;
        my ($alloc)  = $scrolled->get_allocation();
        my $factor_x = ( $alloc->width - 20 ) / $pixbuf_original->get_width();
        my $factor_y = ( $alloc->height - 20 ) / $pixbuf_original->get_height();
        $zoom_actual = ( $factor_x < $factor_y ) ? $factor_x : $factor_y;
        $zoom_actual = 0.1 if $zoom_actual < 0.1;
        $zoom_actual = 5.0 if $zoom_actual > 5.0;
        $actualizar_zoom->();
    };

    $zoom_in->signal_connect(
        clicked => sub {
            $zoom_actual *= 1.2;
            $zoom_actual = 5.0 if $zoom_actual > 5.0;
            $actualizar_zoom->();
        }
    );

    $zoom_out->signal_connect(
        clicked => sub {
            $zoom_actual /= 1.2;
            $zoom_actual = 0.1 if $zoom_actual < 0.1;
            $actualizar_zoom->();
        }
    );

    $zoom_fit->signal_connect(
        clicked => sub {
            $ajustar_ventana->();
        }
    );

    $zoom_100->signal_connect(
        clicked => sub {
            $zoom_actual = 1.0;
            $actualizar_zoom->();
        }
    );

    $btn_abrir->signal_connect(
        clicked => sub {
            system("xdg-open '$ruta_archivo' &");
        }
    );

    # Arrastrar con el mouse
    my ( $drag_x, $drag_y );
    my $dragging = FALSE;

    $event_box->signal_connect(
        button_press_event => sub {
            my ( $widget, $event ) = @_;
            if ( $event->button == 1 ) {
                $dragging = TRUE;
                ( $drag_x, $drag_y ) = ( $event->x, $event->y );
                $widget->get_window()
                  ->set_cursor( Gtk3::Gdk::Cursor->new('fleur') );
                return TRUE;
            }
            return FALSE;
        }
    );

    $event_box->signal_connect(
        motion_notify_event => sub {
            my ( $widget, $event ) = @_;
            if ($dragging) {
                my $hadjust = $scrolled->get_hadjustment();
                my $vadjust = $scrolled->get_vadjustment();
                $hadjust->set_value(
                    $hadjust->get_value() - ( $event->x - $drag_x ) );
                $vadjust->set_value(
                    $vadjust->get_value() - ( $event->y - $drag_y ) );
                ( $drag_x, $drag_y ) = ( $event->x, $event->y );
                return TRUE;
            }
            return FALSE;
        }
    );

    $event_box->signal_connect(
        button_release_event => sub {
            $dragging = FALSE;
            $event_box->get_window()->set_cursor(undef);
            return TRUE;
        }
    );

    # Configurar eventos usando constantes numéricas
    $event_box->set_events(
        GDK_BUTTON_PRESS_MASK | GDK_BUTTON_RELEASE_MASK |
          GDK_POINTER_MOTION_MASK );

    $scrolled->signal_connect( size_allocate => $ajustar_ventana );

    if ($pixbuf_original) {
        $actualizar_zoom->();
    }
    else {
        $event_box->set_size_request( 400, 300 );
    }

    $vbox->pack_start( $toolbar,  FALSE, FALSE, 0 );
    $vbox->pack_start( $scrolled, TRUE,  TRUE,  0 );
    $win->add($vbox);

    $win->show_all();
    return $win;
}

1;
