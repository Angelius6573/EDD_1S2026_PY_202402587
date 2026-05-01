#!/usr/bin/perl
package api::user;
use strict;
use warnings;
use utf8;
use JSON::PP;

sub solo_usuario {
    my ($ctx) = @_;
    my $user = $ctx->{session}->{user};
    return { error => 'Acceso denegado' }
      unless $user && $user->{tipo} ne 'ADMIN';
    return undef;
}

sub perfil {
    my ($ctx) = @_;
    my $user = $ctx->{session}->{user};
    return { error  => 'No autenticado' } unless $user;
    return { perfil => $user };
}

sub actualizar_perfil {
    my ( $ctx, $params ) = @_;
    my $user = $ctx->{session}->{user};
    return { error => 'No autenticado' } unless $user;
    my $avl     = $ctx->{avl};
    my $usuario = $avl->buscar( $user->{colegio} );
    return { error => 'Usuario no encontrado en sistema' } unless $usuario;
    if ( $params->{nombre} ) {
        $usuario->{nombre} = $params->{nombre};
        $user->{nombre}    = $params->{nombre};
    }
    if ( $params->{password} ) {
        $usuario->{contrasena} = $params->{password};
    }
    $avl->insertar(%$usuario);
    $ctx->{tabla_hash}->insertar($usuario);
    require utilidades::leer_json;
    utilidades::leer_json::guardar_json( 'datos/usuarios.json',
        $avl->a_array_json() );
    $ctx->{session}->{user} = $user;
    return { success => 1, perfil => $user };
}

sub solicitar_insumo {
    my ( $ctx, $params ) = @_;
    my $user = $ctx->{session}->{user};
    return { error => 'No autenticado' } unless $user;
    my $tipo         = $params->{tipo};
    my $codigo       = $params->{codigo};
    my $cantidad     = $params->{cantidad};
    my $motivo       = $params->{motivo};
    my $departamento = $user->{departamento};
    my $permisos     = $ctx->{permisos_departamento}->{$departamento} // {};
    return { error => 'Departamento sin acceso a este tipo de insumo' }
      unless $permisos->{ lc($tipo) };
    my $solicitudes = $ctx->{solicitudes};
    my $uuid        = time() . int( rand(10000) );
    $solicitudes->insertar_final(
        {
            uuid         => $uuid,
            tipo         => $tipo,
            codigo       => $codigo,
            cantidad     => $cantidad,
            motivo       => $motivo,
            departamento => $departamento,
            solicitante  => $user->{nombre},
            fecha        => scalar( localtime() )
        }
    );
    return { success => 1, uuid => $uuid };
}

sub historial_solicitudes_usuario {
    my ($ctx) = @_;
    my $user = $ctx->{session}->{user};
    return { error => 'No autenticado' } unless $user;
    my $solicitudes = $ctx->{solicitudes}->almacenar_array_simple();
    my @mis_solicitudes =
      grep { $_->{departamento} eq $user->{departamento} } @$solicitudes;
    return { solicitudes => \@mis_solicitudes };
}

sub inventario_medicamentos {
    my ( $ctx, $params ) = @_;
    my $user = $ctx->{session}->{user};
    return { error => 'No autenticado' } unless $user;
    my $dep      = $user->{departamento};
    my $permisos = $ctx->{permisos_departamento}->{$dep} // {};
    return { error => 'Acceso denegado' } unless $permisos->{medicamentos};
    my $filtro = $params->{filtro} // '';
    my $lista  = $ctx->{med}->almacenar_array_simple();

    if ($filtro) {
        $lista = [
            grep {
                ( $_->{codigo} =~ /$filtro/i ) || ( $_->{nombre} =~ /$filtro/i )
            } @$lista
        ];
    }
    return { medicamentos => $lista };
}

sub inventario_equipos {
    my ( $ctx, $params ) = @_;
    my $user = $ctx->{session}->{user};
    return { error => 'No autenticado' } unless $user;
    my $dep      = $user->{departamento};
    my $permisos = $ctx->{permisos_departamento}->{$dep} // {};
    return { error => 'Acceso denegado' } unless $permisos->{equipos};
    my $filtro = $params->{filtro} // '';
    my @equipos;
    $ctx->{bst}->en_orden(
        sub {
            my ($n) = @_;
            if (  !$filtro
                || $n->{codigo} =~ /$filtro/i
                || $n->{nombre} =~ /$filtro/i )
            {
                push @equipos, $n;
            }
        }
    );
    return { equipos => \@equipos };
}

sub inventario_suministros {
    my ( $ctx, $params ) = @_;
    my $user = $ctx->{session}->{user};
    return { error => 'No autenticado' } unless $user;
    my $dep      = $user->{departamento};
    my $permisos = $ctx->{permisos_departamento}->{$dep} // {};
    return { error => 'Acceso denegado' } unless $permisos->{suministros};
    my $filtro = $params->{filtro} // '';
    my @suministros;
    $ctx->{btree}->en_orden(
        sub {
            my ($d) = @_;
            if (  !$filtro
                || $d->{codigo} =~ /$filtro/i
                || $d->{nombre} =~ /$filtro/i )
            {
                push @suministros, $d;
            }
        }
    );
    return { suministros => \@suministros };
}

1;
