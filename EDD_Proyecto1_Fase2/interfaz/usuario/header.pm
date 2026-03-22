#!/usr/bin/perl
package interfaz::usuario::header;
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
use interfaz::usuario::common;

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

my %PERMISOS = (
    'DEP-ADM' => { med    => 1, equipo     => 1, suministro => 1 },
    'DEP-MED' => { med    => 1, suministro => 1 },
    'DEP-CIR' => { equipo => 1, suministro => 1 },
    'DEP-LAB' => { equipo => 1 },
    'DEP-FAR' => { med    => 1 },
);

sub construir_header {
    my ($nodo) = @_;
    my $dep    = $nodo->{departamento} // 'DEP-MED';
    my $tipo   = $nodo->{tipo}         // 'TIPO-01';

    my $header = Gtk3::Box->new( 'horizontal', 16 );
    interfaz::estilos::agregar_clase( $header, 'barra-titulo' );
    $header->set_margin_start(16);
    $header->set_margin_end(16);
    $header->set_margin_top(8);
    $header->set_margin_bottom(8);

    my $lbl_app = Gtk3::Label->new('EDD MEDTRACK');
    $lbl_app->set_halign('start');

    my $nombre_dep  = $NOMBRE_DEP{$dep}   // $dep;
    my $nombre_tipo = $NOMBRE_TIPO{$tipo} // $tipo;
    my $lbl_user    = Gtk3::Label->new(
        "Bienvenido, $nombre_tipo $nodo->{nombre} | $nombre_dep");
    $lbl_user->get_style_context()->add_class('bienvenida-label');
    $lbl_user->set_halign('end');

    my $spacer = Gtk3::Label->new('');
    $header->pack_start( $lbl_app,  FALSE, FALSE, 0 );
    $header->pack_start( $spacer,   TRUE,  TRUE,  0 );
    $header->pack_start( $lbl_user, FALSE, FALSE, 0 );
    return $header;
}

sub obtener_permisos {
    my ($nodo) = @_;
    my $dep    = $nodo->{departamento} // 'DEP-MED';
    return $PERMISOS{$dep} // { med => 1 };
}

sub construir_sidebar_resumen {
    my ($ctx) = @_;
    my $perms = $ctx->{perms};

    my $vbox = Gtk3::Box->new( 'vertical', 8 );
    $vbox->set_margin_start(10);
    $vbox->set_margin_end(10);
    $vbox->set_margin_top(12);
    $vbox->set_margin_bottom(12);
    $vbox->set_size_request( 215, -1 );

    my $titulo = Gtk3::Label->new('Estado del Inventario');
    $titulo->get_style_context()->add_class('tarjeta-titulo');
    $titulo->set_halign('start');
    $titulo->set_margin_bottom(4);
    $vbox->pack_start( $titulo,                            FALSE, FALSE, 0 );
    $vbox->pack_start( Gtk3::Separator->new('horizontal'), FALSE, FALSE, 2 );

    if ( $perms->{med} ) {
        my ( $t, $c, $v ) = _stats_med( $ctx->{med} );
        _sidebar_bloque( $vbox, 'Medicamentos', $t, $c, $v );
    }
    if ( $perms->{equipo} ) {
        my ( $t, $c ) = _stats_bst( $ctx->{bst} );
        _sidebar_bloque( $vbox, 'Equipos', $t, $c, 0 );
    }
    if ( $perms->{suministro} ) {
        my ( $t, $c, $v ) = _stats_btree( $ctx->{btree} );
        _sidebar_bloque( $vbox, 'Suministros', $t, $c, $v );
    }

    $vbox->pack_start( Gtk3::Separator->new('horizontal'), FALSE, FALSE, 4 );
    my $hora     = strftime( '%H:%M %d/%m/%Y', localtime );
    my $lbl_hora = Gtk3::Label->new("Actualizado: $hora");
    $lbl_hora->get_style_context()->add_class('valor-label');
    $lbl_hora->set_halign('start');
    $vbox->pack_start( $lbl_hora, FALSE, FALSE, 0 );

    return $vbox;
}

sub _stats_med {
    my ($lista) = @_;
    my $datos = $lista->almacenar_array_simple();
    my ( $total, $criticos, $vencidos ) = ( scalar @$datos, 0, 0 );
    my $hoy = interfaz::usuario::common::fecha_hoy();
    for my $d (@$datos) {
        $criticos++ if ( $d->{cantidad} // 0 ) < ( $d->{nivel_minimo} // 0 );
        $vencidos++
          if ( ( $d->{fecha_vencimiento} // '' ) lt $hoy
            && ( $d->{fecha_vencimiento} // '' ) ne '' );
    }
    return ( $total, $criticos, $vencidos );
}

sub _stats_bst {
    my ($bst) = @_;
    my ( $total, $criticos ) = ( 0, 0 );
    $bst->en_orden(
        sub {
            my ($n) = @_;
            $total++;
            $criticos++
              if ( $n->{cantidad} // 0 ) < ( $n->{nivel_minimo} // 0 );
        }
    );
    return ( $total, $criticos );
}

sub _stats_btree {
    my ($btree) = @_;
    my ( $total, $criticos, $vencidos ) = ( 0, 0, 0 );
    my $hoy = interfaz::usuario::common::fecha_hoy();
    $btree->en_orden(
        sub {
            my ($d) = @_;
            $total++;
            $criticos++
              if ( $d->{cantidad} // 0 ) < ( $d->{nivel_minimo} // 0 );
            $vencidos++
              if ( ( $d->{fecha_vencimiento} // '' ) lt $hoy
                && ( $d->{fecha_vencimiento} // '' ) ne '' );
        }
    );
    return ( $total, $criticos, $vencidos );
}

sub _sidebar_bloque {
    my ( $vbox, $titulo_txt, $total, $criticos, $vencidos ) = @_;
    my $frame = Gtk3::Frame->new();
    $frame->set_margin_bottom(4);
    my $inner = Gtk3::Box->new( 'vertical', 3 );
    $inner->set_margin_start(8);
    $inner->set_margin_end(8);
    $inner->set_margin_top(5);
    $inner->set_margin_bottom(5);

    my $lbl_t = Gtk3::Label->new($titulo_txt);
    $lbl_t->get_style_context()->add_class('campo-label');
    $lbl_t->set_halign('start');
    $inner->pack_start( $lbl_t, FALSE, FALSE, 0 );

    my $lbl_total = Gtk3::Label->new("Total: $total");
    $lbl_total->get_style_context()->add_class('valor-label');
    $lbl_total->set_halign('start');
    $inner->pack_start( $lbl_total, FALSE, FALSE, 0 );

    if ( $criticos > 0 ) {
        my $lbl_c = Gtk3::Label->new("Stock critico: $criticos");
        $lbl_c->get_style_context()->add_class('alerta-stock');
        $lbl_c->set_halign('start');
        $inner->pack_start( $lbl_c, FALSE, FALSE, 0 );
    }
    if ( $vencidos > 0 ) {
        my $lbl_v = Gtk3::Label->new("Prox. vencer: $vencidos");
        $lbl_v->get_style_context()->add_class('alerta-vencimiento');
        $lbl_v->set_halign('start');
        $inner->pack_start( $lbl_v, FALSE, FALSE, 0 );
    }
    if ( $criticos == 0 && $vencidos == 0 ) {
        my $lbl_ok = Gtk3::Label->new('Sin alertas');
        $lbl_ok->get_style_context()->add_class('estado-ok');
        $lbl_ok->set_halign('start');
        $inner->pack_start( $lbl_ok, FALSE, FALSE, 0 );
    }

    $frame->add($inner);
    $vbox->pack_start( $frame, FALSE, FALSE, 0 );
}

1;
