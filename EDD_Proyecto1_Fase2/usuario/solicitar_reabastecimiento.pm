#!/usr/bin/perl
package usuario::solicitar_reabastecimiento;
use strict;
use warnings;
use utf8;
use Time::Piece;
use File::Path qw(make_path);
use JSON::PP;
use Data::UUID;

sub solicitar_medicamento {
    my ( $nodo_usuario, $codigo_medicamento, $cantidad, $prioridad, $razon ) =
      @_;

    my $departamento    = $nodo_usuario->{departamento};
    my $fecha_solicitud = localtime->strftime("%Y-%m-%d %H:%M:%S");
    my $ug              = Data::UUID->new;
    my $uuid            = $ug->create_str;

    my $ruta_base    = "datos/solicitudes";
    my $ruta_dep     = "$ruta_base/$departamento";
    my $ruta_archivo = "$ruta_dep/solicitudes.json";
    my $ruta_admin   = "$ruta_base/todas_solicitudes.json";

    unless ( -d $ruta_dep ) {
        make_path($ruta_dep) or die "No se pudo crear directorio: $!";
    }

    my $solicitudes_existentes = [];
    if ( -e $ruta_archivo ) {
        $solicitudes_existentes = _leer_json($ruta_archivo);
    }

    my $nueva_solicitud = {
        uuid               => $uuid,
        codigo_medicamento => $codigo_medicamento,
        cantidad           => $cantidad,
        prioridad          => $prioridad,
        razon              => $razon,
        estado             => "Pendiente",
        fecha_solicitud    => $fecha_solicitud,
        departamento       => $departamento,
        solicitante        => $nodo_usuario->{nombre},
        colegio            => $nodo_usuario->{colegio}
    };

    push @$solicitudes_existentes, $nueva_solicitud;
    _guardar_json( $ruta_archivo, $solicitudes_existentes );

    my $todas_solicitudes = [];
    if ( -e $ruta_admin ) {
        $todas_solicitudes = _leer_json($ruta_admin);
    }
    push @$todas_solicitudes, $nueva_solicitud;
    _guardar_json( $ruta_admin, $todas_solicitudes );

    return 1;
}

sub _leer_json {
    my ($ruta) = @_;
    open my $fh, '<:encoding(UTF-8)', $ruta or return [];
    local $/;
    my $texto = <$fh>;
    close $fh;
    eval { return decode_json($texto) };
    return [];
}

sub _guardar_json {
    my ( $ruta, $datos ) = @_;
    my $json = JSON::PP->new->utf8->pretty->canonical(1);
    open my $fh, '>:encoding(UTF-8)', $ruta or die "No se pudo escribir: $!";
    print $fh $json->encode($datos);
    close $fh;
}

1;
