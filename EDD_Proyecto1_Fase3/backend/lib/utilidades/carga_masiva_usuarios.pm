#!/usr/bin/perl
package utilidades::carga_masiva_usuarios;
use strict;
use warnings;
use utf8;
use JSON::PP;
use Encode qw(decode encode);
use utilidades::validar_json;

sub procesar_archivo {
    my ( $ruta, $avl ) = @_;

    my ( $datos, $error ) = _leer_json_con_encoding($ruta);
    if ($error) {
        return "Error leyendo JSON: $error";
    }

    my $usuarios = $datos->{usuarios} // $datos;
    $usuarios = [$datos] unless ref($usuarios) eq 'ARRAY';

    my ( $ok, $dup, $inv ) = ( 0, 0, 0 );
    my @advertencias;

    for my $u (@$usuarios) {
        my $validacion = _validar_usuario($u);

        if ( $validacion->{error} ) {
            push @advertencias, "USUARIO ignorado: $validacion->{error}";
            $inv++;
            next;
        }

        my $usuario_limpio = $validacion->{datos};

        # Verificar si ya existe en el AVL
        if ( $avl->buscar( $usuario_limpio->{numero_colegio} ) ) {
            push @advertencias,
"USUARIO ignorado: Colegio $usuario_limpio->{numero_colegio} ya existe";
            $dup++;
            next;
        }

        $avl->insertar(
            colegio      => $usuario_limpio->{numero_colegio},
            nombre       => $usuario_limpio->{nombre_completo},
            tipo         => $usuario_limpio->{tipo_usuario},
            departamento => $usuario_limpio->{departamento} // '',
            especialidad => $usuario_limpio->{especialidad} // '',
            contrasena   => $usuario_limpio->{contrasena}
        );
        $ok++;
    }

    require utilidades::leer_json;
    utilidades::leer_json::guardar_json( 'datos/usuarios.json',
        $avl->a_array_json() );

    my $resumen =
      "Usuarios cargados: $ok nuevos, $dup duplicados, $inv invalidos.";
    if (@advertencias) {
        $resumen .= "\n\nAdvertencias:\n" . join( "\n", @advertencias );
    }
    return $resumen;
}

sub _leer_json_con_encoding {
    my ($ruta) = @_;

    return ( undef, "Archivo no existe" ) unless -e $ruta;
    return ( undef, "Archivo vacio" ) if -z $ruta;

    # Leer archivo como binario
    open my $fh, '<:raw', $ruta or return ( undef, "No se pudo abrir: $!" );
    local $/;
    my $bytes = <$fh>;
    close $fh;

    # Eliminar BOM si existe
    if ( $bytes =~ /^\xEF\xBB\xBF/ ) {
        substr( $bytes, 0, 3 ) = '';
    }

    # Intentar diferentes codificaciones
    my $texto        = '';
    my $decodificado = 0;

    # Primero intentar UTF-8 (es la más común)
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

    # Fallback a ISO-8859-1 (Latin1) que maneja acentos
    if ( !$decodificado ) {
        eval {
            $texto        = decode( 'ISO-8859-1', $bytes );
            $decodificado = 1;
        };
    }

    # Último recurso: eliminar caracteres problemáticos
    if ( !$decodificado ) {
        $bytes =~ s/[^\x09\x0A\x0D\x20-\x7E\xA0-\xFF]//g;
        $texto        = decode( 'UTF-8', $bytes, Encode::FB_DEFAULT );
        $decodificado = 1;
    }

    # Normalizar caracteres Unicode problemáticos
    $texto =~ s/[\x{2013}\x{2014}]/-/g;    # Em dash, En dash
    $texto =~ s/[\x{2018}\x{2019}]/'/g;    # Smart quotes
    $texto =~ s/[\x{201C}\x{201D}]/"/g;    # Smart double quotes
    $texto =~ s/[\x{00E1}]/á/g;            # a con acento
    $texto =~ s/[\x{00E9}]/é/g;            # e con acento
    $texto =~ s/[\x{00ED}]/í/g;            # i con acento
    $texto =~ s/[\x{00F3}]/ó/g;            # o con acento
    $texto =~ s/[\x{00FA}]/ú/g;            # u con acento
    $texto =~ s/[\x{00F1}]/ñ/g;            # n con tilde
    $texto =~ s/[\x{00C1}]/Á/g;            # A con acento
    $texto =~ s/[\x{00C9}]/É/g;            # E con acento
    $texto =~ s/[\x{00CD}]/Í/g;            # I con acento
    $texto =~ s/[\x{00D3}]/Ó/g;            # O con acento
    $texto =~ s/[\x{00DA}]/Ú/g;            # U con acento
    $texto =~ s/[\x{00D1}]/Ñ/g;            # N con tilde

    # Eliminar caracteres de control
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

sub _validar_usuario {
    my ($u) = @_;
    my $result = { datos => {}, error => undef };

    # Validar número de colegio
    my $colegio = $u->{numero_colegio} // '';
    $colegio =~ s/^\s+|\s+$//g;
    if ( $colegio !~ /^COL-\d+$/i ) {
        $result->{error} =
          "Numero de colegio invalido (formato: COL-XXXXX). Recibido: $colegio";
        return $result;
    }
    $result->{datos}{numero_colegio} = uc($colegio);

    # Validar nombre completo
    my $nombre = $u->{nombre_completo} // '';
    $nombre =~ s/^\s+|\s+$//g;
    if ( $nombre eq '' ) {
        $result->{error} = "Nombre completo invalido o vacio";
        return $result;
    }
    $result->{datos}{nombre_completo} = $nombre;

    # Validar contraseña
    my $contrasena = $u->{contrasena} // '';
    $contrasena =~ s/^\s+|\s+$//g;
    if ( length($contrasena) < 4 ) {
        $result->{error} =
          "Contrasena invalida (debe tener al menos 4 caracteres)";
        return $result;
    }
    $result->{datos}{contrasena} = $contrasena;

    # Validar tipo de usuario
    my $tipo = $u->{tipo_usuario} // '';
    $tipo = uc($tipo);
    my %tipos_validos =
      map { $_ => 1 } ( 'TIPO-01', 'TIPO-02', 'TIPO-03', 'TIPO-04', 'TIPO-05' );
    unless ( $tipos_validos{$tipo} ) {
        $result->{error} =
"Tipo de usuario invalido (debe ser TIPO-01 a TIPO-05). Recibido: $tipo";
        return $result;
    }
    $result->{datos}{tipo_usuario} = $tipo;

    # Validar departamento
    my $departamento = $u->{departamento} // '';
    if ( defined $departamento && $departamento ne '' ) {
        $departamento = uc($departamento);
        my %deptos_validos = map { $_ => 1 }
          ( 'DEP-ADM', 'DEP-MED', 'DEP-CIR', 'DEP-LAB', 'DEP-FAR' );
        unless ( $deptos_validos{$departamento} ) {
            $result->{error} =
"Departamento invalido (debe ser DEP-ADM, DEP-MED, DEP-CIR, DEP-LAB, DEP-FAR). Recibido: $departamento";
            return $result;
        }
        $result->{datos}{departamento} = $departamento;
    }
    else {
        $result->{datos}{departamento} = undef;
    }

    # Validar especialidad (opcional)
    my $especialidad = $u->{especialidad} // '';
    $especialidad =~ s/^\s+|\s+$//g;
    $result->{datos}{especialidad} = $especialidad ne '' ? $especialidad : '';

    return $result;
}

1;
