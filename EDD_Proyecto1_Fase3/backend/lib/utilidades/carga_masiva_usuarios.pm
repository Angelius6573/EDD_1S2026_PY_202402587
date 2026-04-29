#!/usr/bin/perl
package utilidades::carga_masiva_usuarios;
use strict;
use warnings;
use utf8;
use JSON::PP;
use Encode qw(decode);
use utilidades::validar_json;

sub procesar_archivo {
    my ( $ruta, $avl ) = @_;

    my ( $datos, $error ) = _leer_json_con_encoding($ruta);
    if ($error) {
        return "Error leyendo JSON: $error";
    }

    if ( !defined $datos ) {
        return "Error: El archivo JSON esta vacio o no contiene datos validos";
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
            departamento => $usuario_limpio->{departamento},
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

    # Primero intentar con UTF-8 estricto
    my $texto;
    my $decodificado = 0;

    eval {
        $texto        = decode( 'UTF-8', $bytes, Encode::FB_CROAK );
        $decodificado = 1;
    };

    if ( !$decodificado ) {

        # Intentar con UTF-8 permisivo (reemplaza caracteres invalidos)
        eval {
            $texto        = decode( 'UTF-8', $bytes, Encode::FB_DEFAULT );
            $decodificado = 1;
        };
    }

    if ( !$decodificado ) {

        # Intentar con Latin-1 (ISO-8859-1)
        eval {
            $texto        = decode( 'ISO-8859-1', $bytes );
            $decodificado = 1;
        };
    }

    if ( !$decodificado ) {
        return ( undef,
            "No se pudo decodificar el archivo (codificacion desconocida)" );
    }

    # Normalizar caracteres especiales
    $texto =~ s/[\x{2013}\x{2014}]/-/g;    # Convertir guiones largos a normal
    $texto =~ s/[\x{2018}\x{2019}]/'/g;    # Convertir comillas curvas a simples
    $texto =~
      s/[\x{201C}\x{201D}]/"/g;    # Convertir comillas dobles curvas a normales

# Limpiar caracteres de control no deseados (excepto tab, newline, carriage return)
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

sub _validar_usuario {
    my ($u) = @_;

    my $result = { datos => {}, error => undef };

    my $colegio = utilidades::validar_json::limpiar_campo( $u->{numero_colegio},
        'numero_colegio', 'codigo' );
    unless ( defined $colegio ) {
        $result->{error} = "Numero de colegio invalido (formato: COL-XXXXX)";
        return $result;
    }
    $result->{datos}{numero_colegio} = $colegio;

    my $nombre = utilidades::validar_json::limpiar_campo( $u->{nombre_completo},
        'nombre_completo', 'texto' );
    unless ( defined $nombre ) {
        $result->{error} = "Nombre completo invalido o vacio";
        return $result;
    }
    $result->{datos}{nombre_completo} = $nombre;

    my $contrasena =
      utilidades::validar_json::limpiar_campo( $u->{contrasena}, 'contrasena',
        'texto' );
    unless ( defined $contrasena && length($contrasena) >= 4 ) {
        $result->{error} =
          "Contrasena invalida (debe tener al menos 4 caracteres)";
        return $result;
    }
    $result->{datos}{contrasena} = $contrasena;

    my $tipo = utilidades::validar_json::limpiar_campo( $u->{tipo_usuario},
        'tipo_usuario', 'texto' );
    my %tipos_validos =
      map { $_ => 1 } ( 'TIPO-01', 'TIPO-02', 'TIPO-03', 'TIPO-04', 'TIPO-05' );
    unless ( defined $tipo && $tipos_validos{ uc($tipo) } ) {
        $result->{error} =
          "Tipo de usuario invalido (debe ser TIPO-01 a TIPO-05)";
        return $result;
    }
    $result->{datos}{tipo_usuario} = uc($tipo);

    my $departamento =
      utilidades::validar_json::limpiar_campo( $u->{departamento},
        'departamento', 'texto' );
    my %deptos_validos =
      map { $_ => 1 } ( 'DEP-ADM', 'DEP-MED', 'DEP-CIR', 'DEP-LAB', 'DEP-FAR' );
    unless ( defined $departamento && $deptos_validos{ uc($departamento) } ) {
        $result->{error} =
"Departamento invalido (debe ser DEP-ADM, DEP-MED, DEP-CIR, DEP-LAB, DEP-FAR)";
        return $result;
    }
    $result->{datos}{departamento} = uc($departamento);

    my $especialidad =
      utilidades::validar_json::limpiar_campo( $u->{especialidad},
        'especialidad', 'texto' );
    $result->{datos}{especialidad} = defined $especialidad ? $especialidad : '';

    return $result;
}

1;
