#!/usr/bin/perl
package api::admin;
use strict;
use warnings;
use utf8;
use JSON::PP;
use persistencia::relaciones;

sub solo_admin {
    my ($ctx) = @_;
    my $user = $ctx->{session}->{user};
    return { error => 'Acceso denegado' }
      unless $user && $user->{tipo} eq 'ADMIN';
    return undef;
}

sub usuarios_pendientes {
    my ($ctx) = @_;
    my $denied = solo_admin($ctx);
    return $denied if $denied;
    my $avl = $ctx->{avl};
    my @pendientes;
    $avl->en_orden(
        sub {
            my ($n) = @_;
            if ( !defined $n->{departamento} || $n->{departamento} eq '' ) {
                push @pendientes,
                  {
                    colegio      => $n->{colegio},
                    nombre       => $n->{nombre},
                    tipo         => $n->{tipo},
                    especialidad => $n->{especialidad} // ''
                  };
            }
        }
    );
    return { usuarios => \@pendientes };
}

sub asignar_departamento {
    my ( $ctx, $params ) = @_;
    my $denied = solo_admin($ctx);
    return $denied if $denied;
    my $colegio   = $params->{colegio};
    my $nuevo_dep = $params->{departamento};
    my $avl       = $ctx->{avl};
    my $usuario   = $avl->buscar($colegio);
    return { error => 'Usuario no encontrado' } unless $usuario;
    $usuario->{departamento} = $nuevo_dep;
    $avl->insertar(%$usuario);
    $ctx->{tabla_hash}->insertar($usuario);
    $ctx->{grafo}->actualizar_departamento( $colegio, $nuevo_dep );
    require utilidades::leer_json;
    utilidades::leer_json::guardar_json( 'datos/usuarios.json',
        $avl->a_array_json() );
    return { success => 1 };
}

sub solicitudes_reabastecimiento {
    my ($ctx) = @_;
    my $denied = solo_admin($ctx);
    return $denied if $denied;
    my $solicitudes = $ctx->{solicitudes}->almacenar_array_simple();
    return { solicitudes => $solicitudes };
}

sub aprobar_solicitud {
    my ( $ctx, $params ) = @_;
    my $denied = solo_admin($ctx);
    return $denied if $denied;
    my $uuid        = $params->{uuid};
    my $solicitudes = $ctx->{solicitudes};
    my $encontrada  = undef;
    my $actual      = $solicitudes->{cabeza};
    while ($actual) {
        if ( $actual->{datos}->{uuid} eq $uuid ) {
            $encontrada = $actual->{datos};
            last;
        }
        $actual = $actual->{siguiente};
    }
    return { error => 'Solicitud no encontrada' } unless $encontrada;
    my $tipo     = $encontrada->{tipo};
    my $codigo   = $encontrada->{codigo};
    my $cantidad = $encontrada->{cantidad};
    my $stock_ok = 0;
    if ( $tipo eq 'MEDICAMENTO' ) {
        my $med = $ctx->{med}->buscar_por_codigo($codigo);
        if ( $med && $med->{cantidad} >= $cantidad ) {
            $med->{cantidad} -= $cantidad;
            $stock_ok = 1;
        }
    }
    elsif ( $tipo eq 'EQUIPO' ) {
        my $equipo = $ctx->{bst}->buscar($codigo);
        if ( $equipo && $equipo->{cantidad} >= $cantidad ) {
            $equipo->{cantidad} -= $cantidad;
            $stock_ok = 1;
        }
    }
    elsif ( $tipo eq 'SUMINISTRO' ) {
        my $sum = $ctx->{btree}->buscar($codigo);
        if ( $sum && $sum->{cantidad} >= $cantidad ) {
            $sum->{cantidad} -= $cantidad;
            $stock_ok = 1;
        }
    }
    unless ($stock_ok) {
        return { error => 'Stock insuficiente para aprobar la solicitud' };
    }
    $solicitudes->eliminar_multi_parametro( { uuid => $uuid } );
    return { success => 1 };
}

1;
