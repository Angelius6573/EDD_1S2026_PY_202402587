#!/usr/bin/perl
package interfaz::admin::recorridos;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use FindBin;
use lib $FindBin::Bin;
use Gtk3;
use Glib qw(TRUE FALSE);
use interfaz::admin::common;

sub crear_tab {
    my ($ctx) = @_;

    my $vbox = Gtk3::Box->new( 'vertical', 12 );
    $vbox->set_margin_start(12);
    $vbox->set_margin_end(12);
    $vbox->set_margin_top(10);
    $vbox->set_margin_bottom(10);

    my $hsel = Gtk3::Box->new( 'horizontal', 12 );
    $hsel->set_margin_bottom(12);
    my $lsel = Gtk3::Label->new('Arbol:');
    $lsel->get_style_context()->add_class('campo-label');
    my $combo = Gtk3::ComboBoxText->new();
    $combo->append_text('AVL — Personal Medico');
    $combo->append_text('BST — Equipos Medicos');
    $combo->append_text('Arbol B — Suministros (In-Orden)');
    $combo->set_active(0);
    my $btn_ver =
      interfaz::admin::common::boton( 'Ver Recorridos', 'boton-primario' );
    $hsel->pack_start( $lsel,    FALSE, FALSE, 0 );
    $hsel->pack_start( $combo,   FALSE, FALSE, 0 );
    $hsel->pack_start( $btn_ver, FALSE, FALSE, 0 );

    my $grid = Gtk3::Grid->new();
    $grid->set_column_spacing(12);
    $grid->set_row_spacing(8);
    $grid->set_hexpand(TRUE);
    $grid->set_vexpand(TRUE);

    my @col_names = ( 'Pre-Orden', 'Post-Orden', 'In-Orden' );
    my @text_views;
    for my $i ( 0 .. 2 ) {
        my $frame = Gtk3::Frame->new( $col_names[$i] );
        $frame->get_style_context()->add_class('tarjeta');

        my $tv = Gtk3::TextView->new();
        $tv->set_editable(FALSE);
        $tv->set_monospace(TRUE);
        $tv->set_wrap_mode('word');
        $tv->set_margin_start(8);
        $tv->set_margin_end(8);
        $tv->set_margin_top(8);
        $tv->set_margin_bottom(8);

        my $font_desc = Pango::FontDescription->from_string('Monospace 11');
        $tv->override_font($font_desc);

        my $sc = Gtk3::ScrolledWindow->new();
        $sc->set_policy( 'automatic', 'automatic' );
        $sc->set_vexpand(TRUE);
        $sc->set_hexpand(TRUE);
        $sc->set_min_content_height(450);
        $sc->add($tv);

        $frame->add($sc);
        $grid->attach( $frame, $i, 0, 1, 1 );
        push @text_views, $tv;
    }

    $btn_ver->signal_connect(
        clicked => sub {
            my $sel = $combo->get_active();
            my ( $pre, $post, $ino ) = ( '', '', '' );

            if ( $sel == 0 ) {
                $ctx->{avl}->pre_orden(
                    sub {
                        $pre .=
"$_[0]{colegio}: $_[0]{nombre} ($_[0]{tipo} | $_[0]{departamento})\n";
                    }
                );
                $ctx->{avl}->post_orden(
                    sub {
                        $post .=
"$_[0]{colegio}: $_[0]{nombre} ($_[0]{tipo} | $_[0]{departamento})\n";
                    }
                );
                $ctx->{avl}->en_orden(
                    sub {
                        $ino .=
"$_[0]{colegio}: $_[0]{nombre} ($_[0]{tipo} | $_[0]{departamento})\n";
                    }
                );
            }
            elsif ( $sel == 1 ) {
                $ctx->{bst}->pre_orden(
                    sub {
                        $pre .=
"$_[0]{codigo}: $_[0]{nombre} | Stock: $_[0]{cantidad}\n";
                    }
                );
                $ctx->{bst}->post_orden(
                    sub {
                        $post .=
"$_[0]{codigo}: $_[0]{nombre} | Stock: $_[0]{cantidad}\n";
                    }
                );
                $ctx->{bst}->en_orden(
                    sub {
                        $ino .=
"$_[0]{codigo}: $_[0]{nombre} | Stock: $_[0]{cantidad}\n";
                    }
                );
            }
            else {
                $pre  = "(El Arbol B solo soporta recorrido In-Orden)";
                $post = "(El Arbol B solo soporta recorrido In-Orden)";
                $ctx->{btree}->en_orden(
                    sub {
                        my ($d) = @_;
                        return unless defined $d;
                        $ino .=
"$d->{codigo}: $d->{nombre} | Stock: $d->{cantidad}\n";
                    }
                );
            }

            $text_views[0]->get_buffer()->set_text( $pre  || "(arbol vacio)" );
            $text_views[1]->get_buffer()->set_text( $post || "(arbol vacio)" );
            $text_views[2]->get_buffer()->set_text( $ino  || "(arbol vacio)" );
        }
    );

    $vbox->pack_start( $hsel, FALSE, FALSE, 0 );
    $vbox->pack_start( $grid, TRUE,  TRUE,  0 );
    return $vbox;
}

1;
