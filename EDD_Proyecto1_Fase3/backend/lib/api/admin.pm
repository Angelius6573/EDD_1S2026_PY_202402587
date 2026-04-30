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

sub rechazar_solicitud {
    my ( $ctx, $params ) = @_;
    my $denied = solo_admin($ctx);
    return $denied if $denied;
    my $uuid        = $params->{uuid};
    my $solicitudes = $ctx->{solicitudes};
    my $eliminado = $solicitudes->eliminar_multi_parametro( { uuid => $uuid } );
    return { error   => 'Solicitud no encontrada' } unless $eliminado;
    return { success => 1 };
}

# ==================== Gestión de medicamentos ====================
sub listar_medicamentos {
    my ($ctx) = @_;
    my $denied = solo_admin($ctx);
    return $denied if $denied;
    my $medicamentos = $ctx->{med}->almacenar_array_simple();
    return { medicamentos => $medicamentos };
}

sub agregar_medicamento {
    my ( $ctx, $params ) = @_;
    my $denied = solo_admin($ctx);
    return $denied if $denied;

    my $codigo = $params->{codigo} // '';
    return { error => 'Código requerido' } unless $codigo;

    # Validar formato MED-XXX
    if ( $codigo !~ /^MED-\d+$/ ) {
        return { error => 'Formato de código inválido. Debe ser MED-XXX' };
    }

    # Verificar si ya existe
    my $existente = $ctx->{med}->buscar_por_codigo($codigo);
    if ($existente) {
        return { error => 'Ya existe un medicamento con ese código' };
    }

    my $nuevo = {
        codigo            => $codigo,
        nombre            => $params->{nombre}            // '',
        principio_activo  => $params->{principio_activo}  // '',
        laboratorio       => $params->{laboratorio}       // '',
        fabricante        => $params->{fabricante}        // '',
        precio_unitario   => $params->{precio_unitario}   // 0,
        cantidad          => $params->{cantidad}          // 0,
        fecha_vencimiento => $params->{fecha_vencimiento} // '',
        nivel_minimo      => $params->{nivel_minimo}      // 0,
    };
    $ctx->{med}->insertar_final($nuevo);
    _guardar_inventario($ctx);
    return { success => 1, medicamento => $nuevo };
}

sub actualizar_medicamento {
    my ( $ctx, $codigo, $params ) = @_;
    my $denied = solo_admin($ctx);
    return $denied if $denied;

    my $med = $ctx->{med}->buscar_por_codigo($codigo);
    return { error => 'Medicamento no encontrado' } unless $med;

    # Actualizar campos
    $med->{nombre}           = $params->{nombre} // $med->{nombre};
    $med->{principio_activo} = $params->{principio_activo}
      // $med->{principio_activo};
    $med->{laboratorio}     = $params->{laboratorio} // $med->{laboratorio};
    $med->{fabricante}      = $params->{fabricante}  // $med->{fabricante};
    $med->{precio_unitario} = $params->{precio_unitario}
      // $med->{precio_unitario};
    $med->{cantidad}          = $params->{cantidad} // $med->{cantidad};
    $med->{fecha_vencimiento} = $params->{fecha_vencimiento}
      // $med->{fecha_vencimiento};
    $med->{nivel_minimo} = $params->{nivel_minimo} // $med->{nivel_minimo};

    _guardar_inventario($ctx);
    return { success => 1, medicamento => $med };
}

sub eliminar_medicamento {
    my ( $ctx, $codigo ) = @_;
    my $denied = solo_admin($ctx);
    return $denied if $denied;

    my $eliminado =
      $ctx->{med}->eliminar_multi_parametro( { codigo => $codigo } );
    if ($eliminado) {
        _guardar_inventario($ctx);
        return { success => 1 };
    }
    return { error => 'Medicamento no encontrado' };
}

# ==================== Gestión de equipos (BST) ====================
sub listar_equipos {
    my ($ctx) = @_;
    my $denied = solo_admin($ctx);
    return $denied if $denied;
    my @equipos;
    $ctx->{bst}->en_orden( sub { push @equipos, $_[0] } );
    return { equipos => \@equipos };
}

sub agregar_equipo {
    my ( $ctx, $params ) = @_;
    my $denied = solo_admin($ctx);
    return $denied if $denied;

    my $codigo = $params->{codigo} // '';
    return { error => 'Código requerido' } unless $codigo;
    if ( $codigo !~ /^EQU-\d+$/ ) {
        return { error => 'Formato de código inválido. Debe ser EQU-XXX' };
    }

    my $existente = $ctx->{bst}->buscar($codigo);
    if ($existente) {
        return { error => 'Ya existe un equipo con ese código' };
    }

    my $nuevo = {
        codigo          => $codigo,
        nombre          => $params->{nombre}          // '',
        fabricante      => $params->{fabricante}      // '',
        precio_unitario => $params->{precio_unitario} // 0,
        cantidad        => $params->{cantidad}        // 0,
        fecha_ingreso   => $params->{fecha_ingreso}   // '',
        nivel_minimo    => $params->{nivel_minimo}    // 0,
    };
    $ctx->{bst}->insertar(%$nuevo);
    _guardar_equipos($ctx);
    return { success => 1, equipo => $nuevo };
}

sub actualizar_equipo {
    my ( $ctx, $codigo, $params ) = @_;
    my $denied = solo_admin($ctx);
    return $denied if $denied;

    my $equipo = $ctx->{bst}->buscar($codigo);
    return { error => 'Equipo no encontrado' } unless $equipo;

    $equipo->{nombre}          = $params->{nombre}     // $equipo->{nombre};
    $equipo->{fabricante}      = $params->{fabricante} // $equipo->{fabricante};
    $equipo->{precio_unitario} = $params->{precio_unitario}
      // $equipo->{precio_unitario};
    $equipo->{cantidad}      = $params->{cantidad} // $equipo->{cantidad};
    $equipo->{fecha_ingreso} = $params->{fecha_ingreso}
      // $equipo->{fecha_ingreso};
    $equipo->{nivel_minimo} = $params->{nivel_minimo}
      // $equipo->{nivel_minimo};

    _guardar_equipos($ctx);
    return { success => 1, equipo => $equipo };
}

sub eliminar_equipo {
    my ( $ctx, $codigo ) = @_;
    my $denied = solo_admin($ctx);
    return $denied if $denied;

    my $equipo = $ctx->{bst}->buscar($codigo);
    return { error => 'Equipo no encontrado' } unless $equipo;
    $ctx->{bst}->eliminar($codigo);
    _guardar_equipos($ctx);
    return { success => 1 };
}

# ==================== Gestión de suministros (árbol B) ====================
sub listar_suministros {
    my ($ctx) = @_;
    my $denied = solo_admin($ctx);
    return $denied if $denied;
    my @suministros;
    $ctx->{btree}->en_orden( sub { push @suministros, $_[0] } );
    return { suministros => \@suministros };
}

sub agregar_suministro {
    my ( $ctx, $params ) = @_;
    my $denied = solo_admin($ctx);
    return $denied if $denied;

    my $codigo = $params->{codigo} // '';
    return { error => 'Código requerido' } unless $codigo;
    if ( $codigo !~ /^SUM-\d+$/ ) {
        return { error => 'Formato de código inválido. Debe ser SUM-XXX' };
    }

    my $existente = $ctx->{btree}->buscar($codigo);
    if ($existente) {
        return { error => 'Ya existe un suministro con ese código' };
    }

    my $nuevo = {
        codigo            => $codigo,
        nombre            => $params->{nombre}            // '',
        fabricante        => $params->{fabricante}        // '',
        precio_unitario   => $params->{precio_unitario}   // 0,
        cantidad          => $params->{cantidad}          // 0,
        fecha_vencimiento => $params->{fecha_vencimiento} // '',
        nivel_minimo      => $params->{nivel_minimo}      // 0,
    };
    $ctx->{btree}->insertar(%$nuevo);
    _guardar_suministros($ctx);
    return { success => 1, suministro => $nuevo };
}

sub actualizar_suministro {
    my ( $ctx, $codigo, $params ) = @_;
    my $denied = solo_admin($ctx);
    return $denied if $denied;

    my $sum = $ctx->{btree}->buscar($codigo);
    return { error => 'Suministro no encontrado' } unless $sum;

    $sum->{nombre}          = $params->{nombre}     // $sum->{nombre};
    $sum->{fabricante}      = $params->{fabricante} // $sum->{fabricante};
    $sum->{precio_unitario} = $params->{precio_unitario}
      // $sum->{precio_unitario};
    $sum->{cantidad}          = $params->{cantidad} // $sum->{cantidad};
    $sum->{fecha_vencimiento} = $params->{fecha_vencimiento}
      // $sum->{fecha_vencimiento};
    $sum->{nivel_minimo} = $params->{nivel_minimo} // $sum->{nivel_minimo};

    _guardar_suministros($ctx);
    return { success => 1, suministro => $sum };
}

sub eliminar_suministro {
    my ( $ctx, $codigo ) = @_;
    my $denied = solo_admin($ctx);
    return $denied if $denied;

    my $sum = $ctx->{btree}->buscar($codigo);
    return { error => 'Suministro no encontrado' } unless $sum;
    $ctx->{btree}->eliminar($codigo);
    _guardar_suministros($ctx);
    return { success => 1 };
}

# Funciones auxiliares de persistencia
sub _guardar_inventario {
    my ($ctx) = @_;
    require utilidades::leer_json;
    my $inventario = $ctx->{med}->almacenar_array_simple();
    utilidades::leer_json::guardar_json( 'datos/inventario.json', $inventario );
}

sub _guardar_equipos {
    my ($ctx) = @_;
    require utilidades::leer_json;
    utilidades::leer_json::guardar_json( 'datos/equipos.json',
        $ctx->{bst}->a_array_json() );
}

sub _guardar_suministros {
    my ($ctx) = @_;
    require utilidades::leer_json;
    utilidades::leer_json::guardar_json( 'datos/suministros.json',
        $ctx->{btree}->a_array_json() );
}

1;
