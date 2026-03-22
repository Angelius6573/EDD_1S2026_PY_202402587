#!/usr/bin/perl
package interfaz::usuario::perfil;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use FindBin;
use lib $FindBin::Bin;
use Gtk3;
use Glib qw(TRUE FALSE);
use interfaz::usuario::common;
use utilidades::leer_json;

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

sub crear_tab {
    my ($ctx) = @_;
    my $nodo  = $ctx->{nodo};
    my $avl   = $ctx->{avl};

    my $scroll = Gtk3::ScrolledWindow->new();
    $scroll->set_policy( 'never', 'automatic' );

    my $vbox = Gtk3::Box->new( 'vertical', 10 );
    $vbox->set_margin_start(40);
    $vbox->set_margin_end(40);
    $vbox->set_margin_top(18);
    $vbox->set_margin_bottom(18);

    my $titulo = Gtk3::Label->new('Mi Perfil de Usuario');
    $titulo->get_style_context()->add_class('login-titulo');
    $titulo->set_halign('start');
    $vbox->pack_start( $titulo, FALSE, FALSE, 0 );

    my $sub = Gtk3::Label->new(
        'Informacion recuperada del nodo correspondiente en el Arbol AVL.');
    $sub->get_style_context()->add_class('login-subtitulo');
    $sub->set_halign('start');
    $vbox->pack_start( $sub,                               FALSE, FALSE, 0 );
    $vbox->pack_start( Gtk3::Separator->new('horizontal'), FALSE, FALSE, 4 );

    my $lbl_sec1 = Gtk3::Label->new('Datos del registro');
    $lbl_sec1->get_style_context()->add_class('tarjeta-titulo');
    $lbl_sec1->set_halign('start');
    $vbox->pack_start( $lbl_sec1, FALSE, FALSE, 0 );

    my $grid = Gtk3::Grid->new();
    $grid->set_column_spacing(20);
    $grid->set_row_spacing(8);

    my $dep_full = $NOMBRE_DEP{ $nodo->{departamento} // '' }
      // ( $nodo->{departamento} // '' );
    my $tipo_full = $NOMBRE_TIPO{ $nodo->{tipo} // '' }
      // ( $nodo->{tipo} // '' );

    my @ro = (
        [ 'Numero de Colegio:', $nodo->{colegio} // '' ],
        [ 'Tipo de Usuario:', "$tipo_full (" . ( $nodo->{tipo} // '' ) . ")" ],
        [
            'Departamento:',
            "$dep_full (" . ( $nodo->{departamento} // '' ) . ")"
        ],
        [ 'Especialidad:', $nodo->{especialidad} // 'No aplica' ],
    );

    for my $i ( 0 .. $#ro ) {
        my ( $lt, $lv ) = @{ $ro[$i] };
        my $lbl_campo = Gtk3::Label->new($lt);
        $lbl_campo->set_halign('start');
        $lbl_campo->get_style_context()->add_class('campo-label');
        my $lbl_val = Gtk3::Label->new($lv);
        $lbl_val->set_halign('start');
        $lbl_val->get_style_context()->add_class('valor-label');
        $lbl_val->set_selectable(TRUE);
        $grid->attach( $lbl_campo, 0, $i, 1, 1 );
        $grid->attach( $lbl_val,   1, $i, 1, 1 );
    }
    $vbox->pack_start( $grid,                              FALSE, FALSE, 0 );
    $vbox->pack_start( Gtk3::Separator->new('horizontal'), FALSE, FALSE, 4 );

    my $lbl_sec2 = Gtk3::Label->new('Editar Informacion Personal');
    $lbl_sec2->get_style_context()->add_class('tarjeta-titulo');
    $lbl_sec2->set_halign('start');
    $vbox->pack_start( $lbl_sec2, FALSE, FALSE, 0 );

    my $nota = Gtk3::Label->new(
        'Puedes modificar tu nombre completo y tu contrasena de acceso.');
    $nota->get_style_context()->add_class('login-subtitulo');
    $nota->set_halign('start');
    $vbox->pack_start( $nota, FALSE, FALSE, 0 );

    $vbox->pack_start(
        interfaz::usuario::common::campo_label('Nombre Completo:'),
        FALSE, FALSE, 4 );
    my $e_nombre = Gtk3::Entry->new();
    $e_nombre->set_text( $nodo->{nombre} // '' );
    $e_nombre->set_max_length(120);
    $vbox->pack_start( $e_nombre, FALSE, FALSE, 0 );

    $vbox->pack_start(
        interfaz::usuario::common::campo_label(
            'Nueva Contrasena (dejar vacio para no cambiar):'),
        FALSE, FALSE, 4
    );
    my $e_c1 = Gtk3::Entry->new();
    $e_c1->set_visibility(FALSE);
    $e_c1->set_placeholder_text('Nueva contrasena...');
    $vbox->pack_start( $e_c1, FALSE, FALSE, 0 );

    $vbox->pack_start(
        interfaz::usuario::common::campo_label('Confirmar Nueva Contrasena:'),
        FALSE, FALSE, 4 );
    my $e_c2 = Gtk3::Entry->new();
    $e_c2->set_visibility(FALSE);
    $e_c2->set_placeholder_text('Repetir contrasena...');
    $vbox->pack_start( $e_c2, FALSE, FALSE, 0 );

    my $btn_guardar =
      interfaz::usuario::common::boton( 'Guardar Cambios', 'boton-primario' );
    $btn_guardar->set_halign('start');
    $vbox->pack_start( $btn_guardar, FALSE, FALSE, 8 );

    my $lbl_msg = Gtk3::Label->new('');
    $lbl_msg->set_halign('start');
    $vbox->pack_start( $lbl_msg, FALSE, FALSE, 0 );

    $btn_guardar->signal_connect(
        clicked => sub {
            my $nom = $e_nombre->get_text();
            my $c1  = $e_c1->get_text();
            my $c2  = $e_c2->get_text();

            unless ( $nom && length($nom) > 1 ) {
                interfaz::usuario::common::mensaje( $lbl_msg,
                    'El nombre no puede estar vacio.', 1 );
                return;
            }
            if ( $c1 ne '' && $c1 ne $c2 ) {
                interfaz::usuario::common::mensaje( $lbl_msg,
                    'Las contrasenas no coinciden.', 1 );
                return;
            }
            if ( $c1 ne '' && length($c1) < 6 ) {
                interfaz::usuario::common::mensaje( $lbl_msg,
                    'La contrasena debe tener al menos 6 caracteres.', 1 );
                return;
            }

            $nodo->{nombre}     = $nom;
            $nodo->{contrasena} = $c1 if $c1 ne '';

            $avl->insertar(
                colegio      => $nodo->{colegio},
                nombre       => $nodo->{nombre},
                tipo         => $nodo->{tipo},
                departamento => $nodo->{departamento},
                especialidad => $nodo->{especialidad} // '',
                contrasena   => $nodo->{contrasena}
            );

            eval {
                utilidades::leer_json::guardar_json( 'datos/usuarios.json',
                    $avl->a_array_json() );
            };
            if ($@) {
                interfaz::usuario::common::mensaje( $lbl_msg,
                    "Guardado en memoria (error al escribir disco: $@)", 1 );
            }
            else {
                interfaz::usuario::common::mensaje( $lbl_msg,
                    'Perfil actualizado correctamente.', 0 );
            }
            $e_c1->set_text('');
            $e_c2->set_text('');
        }
    );

    $scroll->add($vbox);
    return $scroll;
}

1;
