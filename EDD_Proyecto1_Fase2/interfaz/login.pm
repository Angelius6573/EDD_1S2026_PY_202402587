#!/usr/bin/perl
package interfaz::login;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use FindBin;
use lib $FindBin::Bin;
use Gtk3;
use Glib qw(TRUE FALSE);
use interfaz::estilos;
use utilidades::leer_json;

sub mostrar {
    my ( $avl_usuarios, $cb_admin, $cb_usuario ) = @_;

    my $win = Gtk3::Window->new('toplevel');
    $win->set_title('EDD MedTrack — Hospital General San Carlos');
    $win->set_default_size( 520, 620 );
    $win->set_resizable(FALSE);
    $win->set_position('center');
    $win->signal_connect( destroy => sub { Gtk3->main_quit } );

    my $stack = Gtk3::Stack->new();
    $stack->set_transition_type('slide-left-right');
    $stack->set_transition_duration(200);

    my $switcher = Gtk3::StackSwitcher->new();
    $switcher->set_stack($stack);
    $switcher->set_halign('center');

    my $vbox = Gtk3::Box->new( 'vertical', 0 );

    my $header = Gtk3::Box->new( 'vertical', 4 );
    interfaz::estilos::agregar_clase( $header, 'barra-titulo' );
    my $h_label = Gtk3::Label->new('EDD MEDTRACK');
    my $h_sub   = Gtk3::Label->new('Hospital General San Carlos');
    $h_sub->get_style_context()->add_class('bienvenida-label');
    $header->pack_start( $h_label, FALSE, FALSE, 4 );
    $header->pack_start( $h_sub,   FALSE, FALSE, 2 );

    my $centro = Gtk3::Box->new( 'vertical', 16 );
    $centro->set_margin_start(60);
    $centro->set_margin_end(60);
    $centro->set_margin_top(20);
    $centro->set_margin_bottom(20);
    $centro->pack_start( $switcher, FALSE, FALSE, 0 );
    $centro->pack_start( $stack,    TRUE,  TRUE,  0 );

    $vbox->pack_start( $header, FALSE, FALSE, 0 );
    $vbox->pack_start( $centro, TRUE,  TRUE,  0 );
    $win->add($vbox);

    my $pag_login =
      _pagina_login( $win, $stack, $avl_usuarios, $cb_admin, $cb_usuario );
    $stack->add_titled( $pag_login, 'login', 'Iniciar Sesion' );

    my $pag_reg = _pagina_registro( $win, $stack, $avl_usuarios );
    $stack->add_titled( $pag_reg, 'registro', 'Registro' );

    my $pag_info = _pagina_info();
    $stack->add_titled( $pag_info, 'info', 'Informacion' );

    $win->show_all();
    return $win;
}

sub _pagina_login {
    my ( $win, $stack, $avl, $cb_admin, $cb_usuario ) = @_;

    my $caja = Gtk3::Box->new( 'vertical', 12 );
    $caja->set_margin_top(16);

    my $titulo = Gtk3::Label->new('Bienvenido');
    $titulo->get_style_context()->add_class('login-titulo');
    $titulo->set_halign('center');

    my $subtit = Gtk3::Label->new('Ingresa tus credenciales institucionales');
    $subtit->get_style_context()->add_class('login-subtitulo');
    $subtit->set_halign('center');

    my ( $f_usuario, $l_usuario ) = _campo_entry('Numero de Colegio / Usuario');
    my ( $f_contra,  $l_contra )  = _campo_entry( 'Contrasena', 1 );

    my $btn = Gtk3::Button->new('Ingresar');
    interfaz::estilos::agregar_clase( $btn, 'boton-primario' );

    my $msg_error = Gtk3::Label->new('');
    $msg_error->get_style_context()->add_class('alerta-stock');
    $msg_error->set_halign('center');

    my $accion_login = sub {
        my $usuario = $f_usuario->get_text();
        my $contra  = $f_contra->get_text();
        $msg_error->set_text('');

        $usuario =~ s/^\s+|\s+$//g;
        $contra  =~ s/^\s+|\s+$//g;

        if ( $usuario eq 'Admin' && $contra eq '1234' ) {
            $win->destroy();
            $cb_admin->( { tipo => 'ADMIN', nombre => 'Administrador' } );
            return;
        }

        my $nodo = $avl->buscar($usuario);
        if ( defined $nodo && $nodo->{contrasena} eq $contra ) {
            $win->destroy();
            $cb_usuario->($nodo);
            return;
        }

        $msg_error->set_text('Credenciales incorrectas. Intenta de nuevo.');
        $f_contra->set_text('');
    };

    $btn->signal_connect( clicked => $accion_login );
    $f_contra->signal_connect( activate => $accion_login );
    $f_usuario->signal_connect( activate => sub { $f_contra->grab_focus() } );

    $caja->pack_start( $titulo,    FALSE, FALSE, 0 );
    $caja->pack_start( $subtit,    FALSE, FALSE, 0 );
    $caja->pack_start( $l_usuario, FALSE, FALSE, 4 );
    $caja->pack_start( $f_usuario, FALSE, FALSE, 0 );
    $caja->pack_start( $l_contra,  FALSE, FALSE, 4 );
    $caja->pack_start( $f_contra,  FALSE, FALSE, 0 );
    $caja->pack_start( $btn,       FALSE, FALSE, 8 );
    $caja->pack_start( $msg_error, FALSE, FALSE, 0 );

    return $caja;
}

sub _pagina_registro {
    my ( $win, $stack, $avl ) = @_;

    my $caja = Gtk3::Box->new( 'vertical', 8 );
    $caja->set_margin_top(8);

    my $titulo = Gtk3::Label->new('Solicitud de Registro');
    $titulo->get_style_context()->add_class('login-titulo');
    $titulo->set_halign('center');

    my $nota = Gtk3::Label->new(
        'El administrador debe registrar usuarios con su numero de colegio.');
    $nota->set_line_wrap(TRUE);
    $nota->set_max_width_chars(40);
    $nota->get_style_context()->add_class('login-subtitulo');
    $nota->set_halign('center');

    my ( $f_colegio, $l_colegio ) =
      _campo_entry('Numero de Colegio (COL-XXXXX)');
    my ( $f_nombre, $l_nombre ) = _campo_entry('Nombre Completo');
    my ( $f_contra,  $l_contra )  = _campo_entry( 'Contrasena',           1 );
    my ( $f_contra2, $l_contra2 ) = _campo_entry( 'Confirmar Contrasena', 1 );

    my $msg = Gtk3::Label->new('');
    $msg->set_halign('center');

    my $btn = Gtk3::Button->new('Registrar');
    interfaz::estilos::agregar_clase( $btn, 'boton-secundario' );

    $btn->signal_connect(
        clicked => sub {
            my $col = $f_colegio->get_text();
            my $nom = $f_nombre->get_text();
            my $c1  = $f_contra->get_text();
            my $c2  = $f_contra2->get_text();

            if ( !$col || !$nom || !$c1 ) {
                $msg->get_style_context()->add_class('alerta-stock');
                $msg->set_text('Completa todos los campos.');
                return;
            }
            if ( $c1 ne $c2 ) {
                $msg->get_style_context()->add_class('alerta-stock');
                $msg->set_text('Las contrasenas no coinciden.');
                return;
            }
            if ( $avl->buscar($col) ) {
                $msg->get_style_context()->add_class('alerta-stock');
                $msg->set_text("El colegio $col ya esta registrado.");
                return;
            }
            $msg->get_style_context()->remove_class('alerta-stock');
            $msg->get_style_context()->add_class('estado-ok');
            $msg->set_text(
"Solicitud recibida. El admin debe completar el registro con tipo y departamento."
            );
        }
    );

    $caja->pack_start( $titulo,    FALSE, FALSE, 0 );
    $caja->pack_start( $nota,      FALSE, FALSE, 4 );
    $caja->pack_start( $l_colegio, FALSE, FALSE, 2 );
    $caja->pack_start( $f_colegio, FALSE, FALSE, 0 );
    $caja->pack_start( $l_nombre,  FALSE, FALSE, 2 );
    $caja->pack_start( $f_nombre,  FALSE, FALSE, 0 );
    $caja->pack_start( $l_contra,  FALSE, FALSE, 2 );
    $caja->pack_start( $f_contra,  FALSE, FALSE, 0 );
    $caja->pack_start( $l_contra2, FALSE, FALSE, 2 );
    $caja->pack_start( $f_contra2, FALSE, FALSE, 0 );
    $caja->pack_start( $btn,       FALSE, FALSE, 8 );
    $caja->pack_start( $msg,       FALSE, FALSE, 0 );

    return $caja;
}

sub _pagina_info {
    my $caja = Gtk3::Box->new( 'vertical', 12 );
    $caja->set_margin_top(16);

    my $titulo = Gtk3::Label->new('Informacion del Sistema');
    $titulo->get_style_context()->add_class('login-titulo');
    $titulo->set_halign('center');

    my $info =
      Gtk3::Label->new( "EDD MedTrack — Fase 2\n\n"
          . "Estructuras de Datos — 1S 2026\n"
          . "Facultad de Ingenieria — ECYS\n"
          . "Universidad San Carlos de Guatemala\n\n"
          . "Estructuras implementadas:\n"
          . "  • Arbol AVL — Personal Medico\n"
          . "  • Arbol BST — Equipos Medicos\n"
          . "  • Arbol B Orden 4 — Suministros\n"
          . "  • Lista Doble — Medicamentos\n"
          . "  • Lista Circular Doble — Proveedores\n"
          . "  • Matriz Dispersa — Proveedor/Fabricante\n\n"
          . "Lenguaje: Perl + GTK3\n"
          . "Reportes: Graphviz" );
    $info->set_line_wrap(TRUE);
    $info->set_halign('start');
    $info->set_margin_start(16);
    $info->get_style_context()->add_class('valor-label');

    $caja->pack_start( $titulo, FALSE, FALSE, 0 );
    $caja->pack_start( $info,   FALSE, FALSE, 8 );

    return $caja;
}

sub _campo_entry {
    my ( $texto, $es_contra ) = @_;
    my $label = Gtk3::Label->new($texto);
    $label->set_halign('start');
    $label->get_style_context()->add_class('campo-label');
    my $entry = Gtk3::Entry->new();
    $entry->set_visibility(FALSE) if $es_contra;
    return ( $entry, $label );
}

1;
