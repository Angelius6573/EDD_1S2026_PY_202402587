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

    # Verificar que ctx tenga las claves necesarias
    unless ( $ctx && ref($ctx) eq 'HASH' ) {
        return "Error: Contexto invalido o no definido";
    }

    # Inicializar proveedores si no existe
    unless ( $ctx->{prov} ) {
        require gestion_datos::lista_circular_doblemente_enlazada;
        $ctx->{prov} =
          gestion_datos::lista_circular_doblemente_enlazada->nuevo();
    }

    my ( $datos, $error ) = _leer_json_con_encoding($ruta);
    if ($error) {
        return "Error leyendo JSON: $error";
    }

    if ( !defined $datos ) {
        return "Error: El archivo JSON esta vacio o no contiene datos validos";
    }

    # Verificar si tiene la estructura 'proveedor' o es un array directo
    my @items_a_procesar;
    my @proveedores_a_guardar;

    if ( ref($datos) eq 'ARRAY' ) {

        # Es un array directo de items (sin proveedor)
        @items_a_procesar = @$datos;
    }
    elsif ( ref( $datos->{proveedor} ) eq 'ARRAY' ) {

        # Es la estructura con proveedor
        for my $prov ( @{ $datos->{proveedor} } ) {
            my $prov_validacion = _validar_proveedor($prov);
            if ( $prov_validacion->{error} ) {
                warn "PROVEEDOR ignorado: $prov_validacion->{error}\n";
                next;
            }

            my @entregas_prov;
            for my $item ( @{ $prov->{entrega} // [] } ) {
                my $item_validacion = _validar_item($item);
                if ( $item_validacion->{error} ) {
                    warn "ITEM ignorado: $item_validacion->{error}\n";
                    next;
                }
                push @entregas_prov,    $item_validacion->{datos};
                push @items_a_procesar, $item_validacion->{datos};
            }

            if (@entregas_prov) {
                push @proveedores_a_guardar,
                  {
                    nit           => $prov_validacion->{datos}{nit},
                    nombre        => $prov_validacion->{datos}{nombre},
                    telefono      => $prov_validacion->{datos}{telefono}  // '',
                    direccion     => $prov_validacion->{datos}{direccion} // '',
                    fecha_entrega => $prov_validacion->{datos}{fecha_entrega}
                      // '',
                    numero_factura => $prov_validacion->{datos}{numero_factura}
                      // '',
                    entregas => \@entregas_prov
                  };
            }
        }
    }
    else {
        return
"Error: el JSON no contiene la estructura esperada (array o proveedor[])";
    }

    my ( $ok, $err, $total ) = ( 0, 0, 0 );
    my @advertencias;

    # Procesar items
    for my $item (@items_a_procesar) {
        $total++;

        my $tipo   = $item->{tipo}   // '';
        my $codigo = $item->{codigo} // '';

        if ( $tipo eq 'MEDICAMENTO' ) {
            if ( $codigo !~ /^MED-/i ) {
                $codigo = "MED-" . $codigo;
            }
            $item->{codigo} = uc($codigo);

            my $existente = $ctx->{med}->buscar_por_codigo( $item->{codigo} );
            if ($existente) {
                $existente->{cantidad} += $item->{cantidad};
                push @advertencias,
                  "ITEM actualizado (suma stock): $item->{codigo}";
            }
            else {
                $ctx->{med}->insertar_final($item);
            }
            $ok++;
        }
        elsif ( $tipo eq 'EQUIPO' ) {
            if ( $codigo !~ /^EQU-/i ) {
                $codigo = "EQU-" . $codigo;
            }
            $item->{codigo} = uc($codigo);

            my $existente = $ctx->{bst}->buscar( $item->{codigo} );
            if ($existente) {
                $existente->{cantidad} += $item->{cantidad};
                push @advertencias,
                  "ITEM actualizado (suma stock): $item->{codigo}";
            }
            else {
                $ctx->{bst}->insertar(%$item);
            }
            $ok++;
        }
        elsif ( $tipo eq 'SUMINISTRO' ) {
            if ( $codigo !~ /^SUM-/i ) {
                $codigo = "SUM-" . $codigo;
            }
            $item->{codigo} = uc($codigo);

            my $existente = $ctx->{btree}->buscar( $item->{codigo} );
            if ($existente) {
                $existente->{cantidad} += $item->{cantidad};
                push @advertencias,
                  "ITEM actualizado (suma stock): $item->{codigo}";
            }
            else {
                $ctx->{btree}->insertar(%$item);
            }
            $ok++;
        }
        else {
            push @advertencias,
              "ITEM ignorado: Tipo desconocido '$tipo' para $codigo";
            $err++;
        }
    }

    # Guardar proveedores
    for my $prov (@proveedores_a_guardar) {
        $ctx->{prov}->insertar_final($prov);
    }

    _guardar_estructuras($ctx);

    my $resumen = sprintf(
"Carga completada:\n  %d insertados/actualizados\n  %d ignorados\n  Total procesados: %d",
        $ok, $err, $total );
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

    my $texto = '';

    # Intentar decodificar UTF-8 con manejo de errores
    eval { $texto = decode( 'UTF-8', $bytes, Encode::FB_DEFAULT ); };
    if ($@) {
        eval { $texto = decode( 'ISO-8859-1', $bytes, Encode::FB_DEFAULT ); };
    }
    if ( $@ || $texto eq '' ) {

        # Último recurso: eliminar caracteres no ASCII
        $bytes =~ s/[^\x20-\x7E\n\r\t]//g;
        $texto = $bytes;
    }

    # Limpiar caracteres problemáticos
    $texto =~ s/[\x{2013}\x{2014}]/-/g;
    $texto =~ s/[\x{2018}\x{2019}]/'/g;
    $texto =~ s/[\x{201C}\x{201D}]/"/g;
    $texto =~ s/[\x00-\x08\x0B\x0C\x0E-\x1F]//g;

    # Decodificar JSON
    my $json = JSON::PP->new->allow_nonref->relaxed->utf8(0);
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

    my $nit = $prov->{nit} // '';
    $nit =~ s/^\s+|\s+$//g;
    if ( $nit eq '' ) {
        $result->{error} = "NIT invalido o vacio";
        return $result;
    }
    $result->{datos}{nit} = $nit;

    my $nombre = $prov->{nombre} // '';
    $nombre =~ s/^\s+|\s+$//g;
    if ( $nombre eq '' ) {
        $result->{error} = "Nombre del proveedor invalido o vacio";
        return $result;
    }
    $result->{datos}{nombre} = $nombre;

    my $telefono = $prov->{telefono} // '';
    $telefono =~ s/^\s+|\s+$//g;
    $result->{datos}{telefono} = $telefono;

    my $direccion = $prov->{direccion} // '';
    $direccion =~ s/^\s+|\s+$//g;
    $result->{datos}{direccion} = $direccion;

    my $fecha_entrega = $prov->{fecha_entrega} // '';
    $fecha_entrega =~ s/^\s+|\s+$//g;
    $result->{datos}{fecha_entrega} = $fecha_entrega;

    my $numero_factura = $prov->{numero_factura} // '';
    $numero_factura =~ s/^\s+|\s+$//g;
    $result->{datos}{numero_factura} = $numero_factura;

    return $result;
}

sub _validar_item {
    my ($item) = @_;
    my $result = { datos => {}, error => undef };

    my $tipo = $item->{tipo} // '';
    $tipo = uc($tipo);
    unless ( $tipo eq 'MEDICAMENTO'
        || $tipo eq 'EQUIPO'
        || $tipo eq 'SUMINISTRO' )
    {
        $result->{error} =
          "Tipo invalido (debe ser MEDICAMENTO, EQUIPO o SUMINISTRO)";
        return $result;
    }
    $result->{datos}{tipo} = $tipo;

    my $codigo = $item->{codigo} // '';
    $codigo =~ s/^\s+|\s+$//g;
    if ( $codigo eq '' ) {
        $result->{error} = "Codigo invalido o vacio";
        return $result;
    }

    # Limpiar prefijos existentes para normalizar
    $codigo =~ s/^(MED|EQU|SUM)-//i;
    $result->{datos}{codigo} = $codigo;

    my $nombre = $item->{nombre} // '';
    $nombre =~ s/^\s+|\s+$//g;
    if ( $nombre eq '' ) {
        $result->{error} = "Nombre invalido o vacio";
        return $result;
    }
    $result->{datos}{nombre} = $nombre;

    my $cantidad = $item->{cantidad} // 0;
    if ( $cantidad !~ /^\d+$/ || $cantidad <= 0 ) {
        $result->{error} = "Cantidad invalida (debe ser numero positivo)";
        return $result;
    }
    $result->{datos}{cantidad} = $cantidad + 0;

    my $precio = $item->{precio_unitario} // 0;
    if ( $precio !~ /^\d+(?:\.\d+)?$/ || $precio < 0 ) {
        $result->{error} =
          "Precio unitario invalido (debe ser numero no negativo)";
        return $result;
    }
    $result->{datos}{precio_unitario} = $precio + 0;

    my $nivel_minimo = $item->{nivel_minimo} // 0;
    if ( $nivel_minimo !~ /^\d+$/ || $nivel_minimo < 0 ) {
        $result->{error} =
          "Nivel minimo invalido (debe ser numero no negativo)";
        return $result;
    }
    $result->{datos}{nivel_minimo} = $nivel_minimo + 0;

    my $fabricante = $item->{fabricante} // '';
    $fabricante =~ s/^\s+|\s+$//g;
    $result->{datos}{fabricante} = $fabricante;

    if ( $tipo eq 'MEDICAMENTO' ) {
        my $principio = $item->{principio_activo} // '';
        $principio =~ s/^\s+|\s+$//g;
        $result->{datos}{principio_activo} = $principio;

        my $laboratorio = $item->{laboratorio} // $fabricante;
        $laboratorio =~ s/^\s+|\s+$//g;
        $result->{datos}{laboratorio} = $laboratorio;

        my $fecha_vencimiento = $item->{fecha_vencimiento} // '';
        $fecha_vencimiento =~ s/^\s+|\s+$//g;
        $result->{datos}{fecha_vencimiento} = $fecha_vencimiento;
    }
    elsif ( $tipo eq 'EQUIPO' ) {
        my $fecha_ingreso = $item->{fecha_ingreso} // '';
        $fecha_ingreso =~ s/^\s+|\s+$//g;
        $result->{datos}{fecha_ingreso} = $fecha_ingreso;
    }
    elsif ( $tipo eq 'SUMINISTRO' ) {
        my $fecha_vencimiento = $item->{fecha_vencimiento} // '';
        $fecha_vencimiento =~ s/^\s+|\s+$//g;
        $result->{datos}{fecha_vencimiento} = $fecha_vencimiento;
    }

    return $result;
}

sub _guardar_estructuras {
    my ($ctx) = @_;

    require utilidades::leer_json if $ctx->{bst};

    if ( $ctx->{bst} ) {
        utilidades::leer_json::guardar_json( 'datos/equipos.json',
            $ctx->{bst}->a_array_json() );
    }
    if ( $ctx->{btree} ) {
        utilidades::leer_json::guardar_json( 'datos/suministros.json',
            $ctx->{btree}->a_array_json() );
    }
    if ( $ctx->{prov} ) {
        utilidades::leer_json::guardar_json( 'datos/proveedores.json',
            $ctx->{prov}->almacenar_array_simple() );
    }
    if ( $ctx->{med} ) {
        my $inventario = $ctx->{med}->almacenar_array_simple();
        utilidades::leer_json::guardar_json( 'datos/inventario.json',
            $inventario );
    }
}

1;
