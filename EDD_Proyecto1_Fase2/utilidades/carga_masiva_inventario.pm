#!/usr/bin/perl
package utilidades::carga_masiva_inventario;
use strict;
use warnings;
use utf8;
use JSON::PP;
use Encode qw(decode);
use utilidades::validar_json;

sub procesar_archivo {
    my ( $ruta, $ctx ) = @_;

    my ( $datos, $error ) = _leer_json_con_encoding($ruta);
    if ($error) {
        return "Error leyendo JSON: $error";
    }

    if ( !defined $datos ) {
        return "Error: El archivo JSON esta vacio o no contiene datos validos";
    }

    return "Error: el JSON no contiene la estructura 'proveedor'."
      unless ref( $datos->{proveedor} ) eq 'ARRAY';

    my ( $ok, $err, $total ) = ( 0, 0, 0 );
    my @advertencias;

    for my $prov ( @{ $datos->{proveedor} } ) {
        my $prov_validacion = _validar_proveedor($prov);

        if ( $prov_validacion->{error} ) {
            push @advertencias, "PROVEEDOR ignorado: $prov_validacion->{error}";
            next;
        }

        my @entregas_prov;

        for my $item ( @{ $prov->{entrega} // [] } ) {
            $total++;
            my $item_validacion = _validar_item($item);

            if ( $item_validacion->{error} ) {
                push @advertencias, "ITEM ignorado: $item_validacion->{error}";
                $err++;
                next;
            }

            my $item_limpio = $item_validacion->{datos};

            if ( $item_limpio->{tipo} eq 'MEDICAMENTO' ) {
                my $cod_completo = "MED-" . $item_limpio->{codigo};
                $item_limpio->{codigo} = $cod_completo;
                $ctx->{med}->insertar_final($item_limpio);
                push @entregas_prov, $item_limpio;
                $ok++;
            }
            elsif ( $item_limpio->{tipo} eq 'EQUIPO' ) {
                my $cod_completo = "EQU-" . $item_limpio->{codigo};
                $item_limpio->{codigo} = $cod_completo;
                $ctx->{bst}->insertar(%$item_limpio);
                push @entregas_prov, $item_limpio;
                $ok++;
            }
            elsif ( $item_limpio->{tipo} eq 'SUMINISTRO' ) {
                my $cod_completo = "SUM-" . $item_limpio->{codigo};
                $item_limpio->{codigo} = $cod_completo;
                $ctx->{btree}->insertar(%$item_limpio);
                push @entregas_prov, $item_limpio;
                $ok++;
            }
        }

        if (@entregas_prov) {
            $ctx->{prov}->insertar_final(
                {
                    nit            => $prov_validacion->{datos}{nit},
                    nombre         => $prov_validacion->{datos}{nombre},
                    telefono       => $prov_validacion->{datos}{telefono},
                    direccion      => $prov_validacion->{datos}{direccion},
                    fecha_entrega  => $prov_validacion->{datos}{fecha_entrega},
                    numero_factura => $prov_validacion->{datos}{numero_factura},
                    entregas       => \@entregas_prov
                }
            );
        }
    }

    _guardar_estructuras($ctx);

    my $resumen =
"Carga completada:\n  $ok insertados\n  $err ignorados\n  Total procesados: $total";
    if (@advertencias) {
        $resumen .= "\n\nAdvertencias:\n" . join( "\n", @advertencias );
    }
    return $resumen;
}

sub _leer_json_con_encoding {
    my ($ruta) = @_;

    return ( undef, "Archivo no existe" ) unless -e $ruta;

    open my $fh, '<:raw', $ruta or return ( undef, "No se pudo abrir: $!" );
    local $/;
    my $bytes = <$fh>;
    close $fh;

    return ( undef, "Archivo vacio" )
      unless defined $bytes && length($bytes) > 0;

    # Eliminar BOM si existe
    if ( $bytes =~ /^\xEF\xBB\xBF/ ) {
        substr( $bytes, 0, 3 ) = '';
    }

    my $texto;
    my $decodificado = 0;

    eval {
        $texto        = decode( 'UTF-8', $bytes, Encode::FB_CROAK );
        $decodificado = 1;
    };

    if ( !$decodificado ) {
        eval {
            $texto        = decode( 'UTF-8', $bytes, Encode::FB_DEFAULT );
            $decodificado = 1;
        };
    }

    if ( !$decodificado ) {
        eval {
            $texto        = decode( 'ISO-8859-1', $bytes );
            $decodificado = 1;
        };
    }

    if ( !$decodificado ) {
        return ( undef,
            "No se pudo decodificar el archivo (codificacion desconocida)" );
    }

    $texto =~ s/[\x{2013}\x{2014}]/-/g;
    $texto =~ s/[\x{2018}\x{2019}]/'/g;
    $texto =~ s/[\x{201C}\x{201D}]/"/g;
    $texto =~ s/[\x00-\x08\x0B\x0C\x0E-\x1F]//g;

  # Nota: $texto ya es un string Perl interno (decodificado de UTF-8).
  # decode_json() espera bytes crudos, por lo que causaría doble decodificacion.
  # Se usa JSON::PP->decode() sin la bandera ->utf8, que acepta strings Perl.
    my $json = JSON::PP->new->allow_nonref->relaxed;
    my $datos;
    eval { $datos = $json->decode($texto) };
    if ($@) {
        return ( undef, "JSON invalido: $@" );
    }

    return ( $datos, undef );
}

sub _validar_proveedor {
    my ($prov) = @_;

    my $result = { datos => {}, error => undef };

    my $nit =
      utilidades::validar_json::limpiar_campo( $prov->{nit}, 'nit', 'texto' );
    unless ( defined $nit ) {
        $result->{error} = "NIT invalido o vacio";
        return $result;
    }
    $result->{datos}{nit} = $nit;

    my $nombre =
      utilidades::validar_json::limpiar_campo( $prov->{nombre}, 'nombre',
        'texto' );
    unless ( defined $nombre ) {
        $result->{error} = "Nombre del proveedor invalido o vacio";
        return $result;
    }
    $result->{datos}{nombre} = $nombre;

    my $telefono =
      utilidades::validar_json::limpiar_campo( $prov->{telefono}, 'telefono',
        'texto' );
    $result->{datos}{telefono} = defined $telefono ? $telefono : '';

    my $direccion =
      utilidades::validar_json::limpiar_campo( $prov->{direccion}, 'direccion',
        'texto' );
    $result->{datos}{direccion} = defined $direccion ? $direccion : '';

    my $fecha_entrega =
      utilidades::validar_json::limpiar_campo( $prov->{fecha_entrega},
        'fecha_entrega', 'fecha' );
    $result->{datos}{fecha_entrega} =
      defined $fecha_entrega ? $fecha_entrega : '';

    my $numero_factura =
      utilidades::validar_json::limpiar_campo( $prov->{numero_factura},
        'numero_factura', 'texto' );
    $result->{datos}{numero_factura} =
      defined $numero_factura ? $numero_factura : '';

    return $result;
}

sub _validar_item {
    my ($item) = @_;

    my $result = { datos => {}, error => undef };

    my $tipo = utilidades::validar_json::limpiar_campo( $item->{tipo}, 'tipo',
        'tipo_producto' );
    unless ( defined $tipo ) {
        $result->{error} =
          "Tipo invalido (debe ser MEDICAMENTO, EQUIPO o SUMINISTRO)";
        return $result;
    }
    $result->{datos}{tipo} = $tipo;

    my $codigo =
      utilidades::validar_json::limpiar_campo( $item->{codigo}, 'codigo',
        'codigo' );
    unless ( defined $codigo ) {
        $result->{error} = "Codigo invalido (formato: XXX-001)";
        return $result;
    }
    $result->{datos}{codigo} = $codigo;

    my $nombre =
      utilidades::validar_json::limpiar_campo( $item->{nombre}, 'nombre',
        'texto' );
    unless ( defined $nombre ) {
        $result->{error} = "Nombre invalido o vacio";
        return $result;
    }
    $result->{datos}{nombre} = $nombre;

    my $cantidad =
      utilidades::validar_json::limpiar_campo( $item->{cantidad}, 'cantidad',
        'cantidad' );
    unless ( defined $cantidad ) {
        $result->{error} = "Cantidad invalida (debe ser numero positivo)";
        return $result;
    }
    $result->{datos}{cantidad} = $cantidad;

    my $precio =
      utilidades::validar_json::limpiar_campo( $item->{precio_unitario},
        'precio_unitario', 'precio' );
    unless ( defined $precio ) {
        $result->{error} =
          "Precio unitario invalido (debe ser numero positivo)";
        return $result;
    }
    $result->{datos}{precio_unitario} = $precio;

    my $nivel_minimo =
      utilidades::validar_json::limpiar_campo( $item->{nivel_minimo},
        'nivel_minimo', 'cantidad' );
    unless ( defined $nivel_minimo ) {
        $result->{error} = "Nivel minimo invalido (debe ser numero positivo)";
        return $result;
    }
    $result->{datos}{nivel_minimo} = $nivel_minimo;

    my $fabricante =
      utilidades::validar_json::limpiar_campo( $item->{fabricante},
        'fabricante', 'texto' );
    $result->{datos}{fabricante} = defined $fabricante ? $fabricante : '';

    if ( $tipo eq 'MEDICAMENTO' ) {
        my $principio =
          utilidades::validar_json::limpiar_campo( $item->{principio_activo},
            'principio_activo', 'texto' );
        $result->{datos}{principio_activo} =
          defined $principio ? $principio : '';

        my $laboratorio =
          utilidades::validar_json::limpiar_campo( $item->{laboratorio},
            'laboratorio', 'texto' );
        $result->{datos}{laboratorio} =
          defined $laboratorio ? $laboratorio : ( $fabricante // '' );

        my $fecha_vencimiento =
          utilidades::validar_json::limpiar_campo( $item->{fecha_vencimiento},
            'fecha_vencimiento', 'fecha' );
        $result->{datos}{fecha_vencimiento} =
          defined $fecha_vencimiento ? $fecha_vencimiento : '';
    }
    elsif ( $tipo eq 'EQUIPO' ) {
        my $fecha_ingreso =
          utilidades::validar_json::limpiar_campo( $item->{fecha_ingreso},
            'fecha_ingreso', 'fecha' );
        $result->{datos}{fecha_ingreso} =
          defined $fecha_ingreso ? $fecha_ingreso : '';
    }
    elsif ( $tipo eq 'SUMINISTRO' ) {
        my $fecha_vencimiento =
          utilidades::validar_json::limpiar_campo( $item->{fecha_vencimiento},
            'fecha_vencimiento', 'fecha' );
        $result->{datos}{fecha_vencimiento} =
          defined $fecha_vencimiento ? $fecha_vencimiento : '';
    }

    return $result;
}

sub _guardar_estructuras {
    my ($ctx) = @_;

    require utilidades::leer_json;

    utilidades::leer_json::guardar_json( 'datos/equipos.json',
        $ctx->{bst}->a_array_json() );
    utilidades::leer_json::guardar_json( 'datos/suministros.json',
        $ctx->{btree}->a_array_json() );
    utilidades::leer_json::guardar_json( 'datos/proveedores.json',
        $ctx->{prov}->almacenar_array_simple() );

    my $inventario = $ctx->{med}->almacenar_array_simple();
    utilidades::leer_json::guardar_json( 'datos/inventario.json', $inventario );
}

1;
