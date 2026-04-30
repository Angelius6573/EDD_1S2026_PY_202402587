package utilidades::carga_masiva_relaciones;
use strict;
use warnings;
use utf8;
use JSON::PP;
use Encode qw(decode);
use persistencia::relaciones;

sub procesar_archivo {
    my ( $ruta, $ctx ) = @_;

    my ( $datos, $error ) = _leer_json_con_encoding($ruta);
    return "Error leyendo JSON: $error" if $error;

    unless ( ref($datos) eq 'ARRAY' ) {
        return "Error: el JSON debe contener un array de relaciones";
    }

    my $ok  = 0;
    my $err = 0;
    my @advertencias;

    for my $rel (@$datos) {
        my $sol    = $rel->{solicitante} // $rel->{colegio_a};
        my $rec    = $rel->{receptor}    // $rel->{colegio_b};
        my $estado = uc( $rel->{estado} // 'PENDIENTE' );

        unless ( $sol && $rec && $estado =~ /^(ACTIVA|PENDIENTE|RECHAZADA)$/ ) {
            push @advertencias,
"Relación ignorada: faltan campos o estado inválido ($sol -> $rec)";
            $err++;
            next;
        }

        # Verificar que ambos colegios existan en el AVL
        my $usuario_sol = $ctx->{avl}->buscar($sol);
        my $usuario_rec = $ctx->{avl}->buscar($rec);
        unless ( $usuario_sol && $usuario_rec ) {
            push @advertencias,
              "Relación ignorada: uno de los colegios no existe ($sol, $rec)";
            $err++;
            next;
        }

        # Guardar relación (normalizada)
        persistencia::relaciones::guardar_relacion( $sol, $rec, $estado );
        $ok++;
    }

    # Reconstruir el grafo desde cero con las nuevas relaciones
    persistencia::relaciones::inicializar_grafo_desde_relaciones( $ctx->{grafo},
        $ctx->{avl} );

    my $resumen = "Relaciones procesadas: $ok insertadas, $err ignoradas.\n";
    $resumen .= "Advertencias:\n" . join( "\n", @advertencias )
      if @advertencias;
    return $resumen;
}

sub _leer_json_con_encoding {
    my ($ruta) = @_;
    return ( undef, "Archivo no existe" ) unless -e $ruta;
    open my $fh, '<:raw', $ruta or return ( undef, "No se pudo abrir: $!" );
    local $/;
    my $bytes = <$fh>;
    close $fh;
    if ( $bytes =~ /^\xEF\xBB\xBF/ ) { substr( $bytes, 0, 3 ) = ''; }
    my $texto = decode( 'UTF-8', $bytes, Encode::FB_DEFAULT );
    my $json  = JSON::PP->new->allow_nonref->relaxed;
    my $datos;
    eval { $datos = $json->decode($texto) };
    return ( undef,  "JSON inválido: $@" ) if $@;
    return ( $datos, undef );
}

1;
