#!/usr/bin/perl
package usuario::historial_solicitudes;
use strict;
use warnings;
use JSON::PP;

sub obtener_historial {
    my ($nodo_usuario) = @_;
    my $departamento   = $nodo_usuario->{departamento};
    my $ruta           = "datos/solicitudes/$departamento/solicitudes.json";

    return [] unless -e $ruta;

    open my $fh, '<:encoding(UTF-8)', $ruta or return [];
    local $/;
    my $texto = <$fh>;
    close $fh;

    eval { return decode_json($texto) };
    return [];
}

sub obtener_estado_color {
    my ($estado) = @_;
    if ( $estado eq 'Aprobado' ) {
        return 'estado-ok';
    }
    elsif ( $estado eq 'Rechazado' ) {
        return 'alerta-stock';
    }
    else {
        return 'alerta-vencimiento';
    }
}

1;
