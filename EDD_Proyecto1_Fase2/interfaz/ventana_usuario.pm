#!/usr/bin/perl
package interfaz::ventana_usuario;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use FindBin;
use lib $FindBin::Bin;
use Gtk3;
use Glib qw(TRUE FALSE);
use interfaz::estilos;
use interfaz::usuario::common;
use interfaz::usuario::header;
use interfaz::usuario::medicamentos;
use interfaz::usuario::equipos;
use interfaz::usuario::suministros;
use interfaz::usuario::perfil;
use interfaz::usuario::solicitudes;

sub mostrar {
    my ( $nodo_usuario, $avl, $bst, $btree, $lista_med, $callback_volver ) = @_;

    my $perms = interfaz::usuario::header::obtener_permisos($nodo_usuario);

    my $win = Gtk3::Window->new('toplevel');
    $win->set_title('EDD MedTrack — Panel Medico');
    $win->set_default_size( 1150, 740 );
    $win->set_position('center');
    $win->signal_connect( destroy => sub { Gtk3->main_quit } );

    my $vbox_root = Gtk3::Box->new( 'vertical', 0 );

    # Barra superior con título y botón de cerrar sesión
    my $header = Gtk3::Box->new( 'horizontal', 16 );
    interfaz::estilos::agregar_clase( $header, 'barra-titulo' );
    $header->set_margin_start(16);
    $header->set_margin_end(16);
    $header->set_margin_top(8);
    $header->set_margin_bottom(8);

    my $lbl_app = Gtk3::Label->new('EDD MEDTRACK');
    $lbl_app->set_halign('start');

    my $dep        = $nodo_usuario->{departamento} // 'DEP-MED';
    my $tipo       = $nodo_usuario->{tipo}         // 'TIPO-01';
    my %NOMBRE_DEP = (
        'DEP-ADM' => 'Administracion General',
        'DEP-MED' => 'Medicina General y Consulta Externa',
        'DEP-CIR' => 'Cirugia y Quirofanos',
        'DEP-LAB' => 'Laboratorio Clinico',
        'DEP-FAR' => 'Farmacia Hospitalaria',
    );
    my %NOMBRE_TIPO = (
        'TIPO-01' => 'Medico General',
        'TIPO-02' => 'Medico Especialista / Cirujano',
        'TIPO-03' => 'Enfermero/a',
        'TIPO-04' => 'Tecnico de Laboratorio',
        'TIPO-05' => 'Personal Administrativo',
    );
    my $nombre_dep  = $NOMBRE_DEP{$dep}   // $dep;
    my $nombre_tipo = $NOMBRE_TIPO{$tipo} // $tipo;
    my $lbl_user    = Gtk3::Label->new(
        "Bienvenido, $nombre_tipo $nodo_usuario->{nombre} | $nombre_dep");
    $lbl_user->get_style_context()->add_class('bienvenida-label');
    $lbl_user->set_halign('end');

    # Botón de cerrar sesión
    my $btn_cerrar_sesion = Gtk3::Button->new('Cerrar Sesion');
    interfaz::estilos::agregar_clase( $btn_cerrar_sesion, 'boton-peligro' );
    $btn_cerrar_sesion->set_size_request( 120, 30 );

    my $spacer = Gtk3::Label->new('');
    $header->pack_start( $lbl_app,           FALSE, FALSE, 0 );
    $header->pack_start( $spacer,            TRUE,  TRUE,  0 );
    $header->pack_start( $lbl_user,          FALSE, FALSE, 0 );
    $header->pack_start( $btn_cerrar_sesion, FALSE, FALSE, 10 );

    $vbox_root->pack_start( $header, FALSE, FALSE, 0 );

    my %ctx = (
        win   => $win,
        avl   => $avl,
        bst   => $bst,
        btree => $btree,
        med   => $lista_med,
        nodo  => $nodo_usuario,
        perms => $perms
    );

    my $hbox_main = Gtk3::Box->new( 'horizontal', 0 );
    $hbox_main->pack_start(
        interfaz::usuario::header::construir_sidebar_resumen( \%ctx ),
        FALSE, FALSE, 0 );
    $hbox_main->pack_start( Gtk3::Separator->new('vertical'), FALSE, FALSE, 0 );

    my $vbox_right = Gtk3::Box->new( 'vertical', 0 );
    my ( $barra_busqueda, $cb_ref ) = _construir_barra_busqueda_global();
    $vbox_right->pack_start( $barra_busqueda, FALSE, FALSE, 0 );

    my $nb = Gtk3::Notebook->new();
    $nb->set_margin_start(4);
    $nb->set_margin_end(4);
    $nb->set_margin_bottom(4);

    my @tabs_info;

    if ( $perms->{med} ) {
        my ( $tab, $cb ) = interfaz::usuario::medicamentos::crear_tab( \%ctx );
        $nb->append_page( $tab,
            interfaz::usuario::common::tab_label('Medicamentos') );
        push @tabs_info, { cb => $cb };
    }

    if ( $perms->{equipo} ) {
        my ( $tab, $cb ) = interfaz::usuario::equipos::crear_tab( \%ctx );
        $nb->append_page( $tab,
            interfaz::usuario::common::tab_label('Equipos Medicos') );
        push @tabs_info, { cb => $cb };
    }

    if ( $perms->{suministro} ) {
        my ( $tab, $cb ) = interfaz::usuario::suministros::crear_tab( \%ctx );
        $nb->append_page( $tab,
            interfaz::usuario::common::tab_label('Suministros') );
        push @tabs_info, { cb => $cb };
    }

    $nb->append_page(
        interfaz::usuario::perfil::crear_tab( \%ctx ),
        interfaz::usuario::common::tab_label('Mi Perfil')
    );
    push @tabs_info, { cb => sub { } };

    if ( $perms->{med} ) {
        my $tab_solicitudes =
          interfaz::usuario::solicitudes::crear_tab( \%ctx );
        $nb->append_page( $tab_solicitudes,
            interfaz::usuario::common::tab_label('Solicitar Reabastecimiento')
        );
        push @tabs_info, { cb => sub { } };
    }

    $$cb_ref = sub {
        my ($texto) = @_;
        my $pag = $nb->get_current_page();
        $tabs_info[$pag]{cb}->($texto) if defined $tabs_info[$pag]{cb};
    };

    $vbox_right->pack_start( $nb, TRUE, TRUE, 0 );
    $hbox_main->pack_start( $vbox_right, TRUE, TRUE, 0 );
    $vbox_root->pack_start( $hbox_main,  TRUE, TRUE, 0 );
    $win->add($vbox_root);

    # Conectar el botón de cerrar sesión
    $btn_cerrar_sesion->signal_connect(
        clicked => sub {
            $win->destroy();
            if ($callback_volver) {
                $callback_volver->();
            }
            else {
                Gtk3->main_quit();
            }
        }
    );

    $win->show_all();
    return $win;
}

sub _construir_barra_busqueda_global {
    my $hbox = Gtk3::Box->new( 'horizontal', 8 );
    $hbox->set_margin_start(10);
    $hbox->set_margin_end(10);
    $hbox->set_margin_top(8);
    $hbox->set_margin_bottom(4);

    my $lbl = Gtk3::Label->new('Busqueda rapida:');
    $lbl->get_style_context()->add_class('campo-label');

    my $entry = Gtk3::Entry->new();
    $entry->set_placeholder_text(
        'Buscar por codigo o nombre en la pestana activa...');
    $entry->set_hexpand(TRUE);

    my $btn_buscar =
      interfaz::usuario::common::boton( 'Buscar', 'boton-secundario' );
    my $btn_limpiar =
      interfaz::usuario::common::boton( 'Limpiar', 'boton-secundario' );

    $hbox->pack_start( $lbl,         FALSE, FALSE, 0 );
    $hbox->pack_start( $entry,       TRUE,  TRUE,  0 );
    $hbox->pack_start( $btn_buscar,  FALSE, FALSE, 0 );
    $hbox->pack_start( $btn_limpiar, FALSE, FALSE, 0 );

    my $cb_ref = \my $cb;

    $btn_buscar->signal_connect(
        clicked => sub { $$cb_ref->( $entry->get_text() ) if $$cb_ref } );
    $entry->signal_connect(
        activate => sub { $$cb_ref->( $entry->get_text() ) if $$cb_ref } );
    $btn_limpiar->signal_connect(
        clicked => sub {
            $entry->set_text('');
            $$cb_ref->('') if $$cb_ref;
        }
    );

    return ( $hbox, \$cb );
}

1;
