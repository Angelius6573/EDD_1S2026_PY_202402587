#!/usr/bin/perl
package api::colaboracion;
use strict;
use warnings;
use utf8;
use JSON::PP;
use persistencia::relaciones;

sub _usuario_actual {
    my ($ctx) = @_;
    return $ctx->{session}->{user};
}

sub colaboradores_actuales {
    my ($ctx) = @_;
    my $user = _usuario_actual($ctx);
    return { error => 'No autenticado' } unless $user;
    my $vecinos = $ctx->{grafo}->obtener_vecinos( $user->{colegio} );
    my @detalles;
    for my $v (@$vecinos) {
        my $nodo = $ctx->{grafo}->obtener_nodo($v);
        if ($nodo) {
            push @detalles,
              {
                colegio      => $v,
                nombre       => $nodo->{nombre},
                departamento => $nodo->{departamento},
                especialidad => $nodo->{especialidad} // ''
              };
        }
    }
    return { colaboradores => \@detalles };
}

sub sugerencias {
    my ($ctx) = @_;
    my $user = _usuario_actual($ctx);
    return { error => 'No autenticado' } unless $user;
    my $sugerencias = $ctx->{grafo}->sugerencias_bfs( $user->{colegio} );
    my @detalles;
    for my $sug (@$sugerencias) {
        my $nodo = $ctx->{grafo}->obtener_nodo($sug);
        if ($nodo) {
            push @detalles,
              {
                colegio      => $sug,
                nombre       => $nodo->{nombre},
                departamento => $nodo->{departamento},
                especialidad => $nodo->{especialidad} // '',
                comunes      => $sugerencias->{$sug}  // 1
              };
        }
    }
    @detalles = sort { $b->{comunes} <=> $a->{comunes} } @detalles;
    return { sugerencias => \@detalles };
}

sub enviar_solicitud_colaboracion {
    my ( $ctx, $params ) = @_;
    my $user = _usuario_actual($ctx);
    return { error => 'No autenticado' } unless $user;
    my $destino = $params->{colegio_destino};
    return { error => 'No puede solicitarse colaboración a sí mismo' }
      if $destino eq $user->{colegio};
    my $nodo_destino = $ctx->{grafo}->obtener_nodo($destino);
    return { error => 'El profesional destino no existe en el sistema' }
      unless $nodo_destino;
    my $activas = $ctx->{grafo}->son_vecinos( $user->{colegio}, $destino );
    return { error => 'Ya son colaboradores' } if $activas;
    persistencia::relaciones::guardar_relacion( $user->{colegio}, $destino,
        'PENDIENTE' );
    return { success => 1 };
}

sub solicitudes_recibidas {
    my ($ctx) = @_;
    my $user = _usuario_actual($ctx);
    return { error => 'No autenticado' } unless $user;
    my $pendientes =
      persistencia::relaciones::obtener_pendientes_para( $user->{colegio} );
    my @detalles;
    for my $sol (@$pendientes) {
        my $nodo = $ctx->{grafo}->obtener_nodo($sol);
        if ($nodo) {
            push @detalles,
              {
                colegio      => $sol,
                nombre       => $nodo->{nombre},
                departamento => $nodo->{departamento},
                especialidad => $nodo->{especialidad} // ''
              };
        }
    }
    return { solicitudes => \@detalles };
}

sub responder_solicitud {
    my ( $ctx, $params ) = @_;
    my $user = _usuario_actual($ctx);
    return { error => 'No autenticado' } unless $user;
    my $remitente  = $params->{colegio_remitente};
    my $accion     = $params->{accion};
    my $relaciones = persistencia::relaciones::cargar_relaciones();
    my $encontrada = 0;
    for my $rel (@$relaciones) {
        if (   $rel->{colegio_a} eq $remitente
            && $rel->{colegio_b} eq $user->{colegio}
            && $rel->{estado} eq 'PENDIENTE' )
        {
            $encontrada = 1;
            if ( $accion eq 'aceptar' ) {
                $rel->{estado} = 'ACTIVA';
                $ctx->{grafo}->agregar_arista( $remitente, $user->{colegio} );
            }
            else {
                $rel->{estado} = 'RECHAZADA';
            }
            last;
        }
    }
    return { error => 'Solicitud no encontrada' } unless $encontrada;

    # Reescribir todo el archivo (método público)
    require persistencia::relaciones;
    persistencia::relaciones::_guardar_relaciones($relaciones);
    return { success => 1 };
}

1;
