#!/usr/bin/perl
package persistencia::relaciones;
use strict;
use warnings;
use utf8;
use JSON::PP;
use File::Path qw(make_path);

my $RUTA_RELACIONES = 'datos/relaciones.json';

sub _asegurar_directorio {
    my $dir = shift;
    unless ( -d $dir ) {
        make_path($dir);
    }
}

sub _leer_relaciones {
    return [] unless -e $RUTA_RELACIONES;
    open my $fh, '<:encoding(UTF-8)', $RUTA_RELACIONES or return [];
    local $/;
    my $texto = <$fh>;
    close $fh;
    my $datos = eval { decode_json($texto); };
    return []     if $@;
    return $datos if ref($datos) eq 'ARRAY';
    return [];
}

sub _guardar_relaciones {
    my ($relaciones) = @_;
    _asegurar_directorio('datos');
    my $json = JSON::PP->new->utf8->pretty->canonical;
    open my $fh, '>:encoding(UTF-8)', $RUTA_RELACIONES
      or die "No se pudo escribir $RUTA_RELACIONES";
    print $fh $json->encode($relaciones);
    close $fh;
}

sub cargar_relaciones {
    return _leer_relaciones();
}

sub guardar_relacion {
    my ( $colegio_a, $colegio_b, $estado ) = @_;
    my $relaciones = _leer_relaciones();
    my $normalizada =
      ( $colegio_a lt $colegio_b )
      ? "$colegio_a|$colegio_b"
      : "$colegio_b|$colegio_a";
    my ( $nuevo_a, $nuevo_b ) = split /\|/, $normalizada;
    my $encontrada = 0;
    for my $rel (@$relaciones) {
        if ( $rel->{colegio_a} eq $nuevo_a && $rel->{colegio_b} eq $nuevo_b ) {
            $rel->{estado} = $estado;
            $encontrada = 1;
            last;
        }
    }
    unless ($encontrada) {
        push @$relaciones,
          {
            colegio_a => $nuevo_a,
            colegio_b => $nuevo_b,
            estado    => $estado
          };
    }
    _guardar_relaciones($relaciones);
    return 1;
}

sub eliminar_relacion {
    my ( $colegio_a, $colegio_b ) = @_;
    my $relaciones = _leer_relaciones();
    my $normalizada =
      ( $colegio_a lt $colegio_b )
      ? "$colegio_a|$colegio_b"
      : "$colegio_b|$colegio_a";
    my ( $nuevo_a, $nuevo_b ) = split /\|/, $normalizada;
    @$relaciones =
      grep { !( $_->{colegio_a} eq $nuevo_a && $_->{colegio_b} eq $nuevo_b ) }
      @$relaciones;
    _guardar_relaciones($relaciones);
    return 1;
}

sub obtener_pendientes_para {
    my ($colegio) = @_;
    my $relaciones = _leer_relaciones();
    my @pendientes;
    for my $rel (@$relaciones) {
        if ( $rel->{estado} eq 'PENDIENTE' && $rel->{colegio_b} eq $colegio ) {
            push @pendientes, $rel->{colegio_a};
        }
    }
    return \@pendientes;
}

sub obtener_activas_para {
    my ($colegio) = @_;
    my $relaciones = _leer_relaciones();
    my @activas;
    for my $rel (@$relaciones) {
        if (
            $rel->{estado} eq 'ACTIVA'
            && (   $rel->{colegio_a} eq $colegio
                || $rel->{colegio_b} eq $colegio )
          )
        {
            my $otro =
              ( $rel->{colegio_a} eq $colegio )
              ? $rel->{colegio_b}
              : $rel->{colegio_a};
            push @activas, $otro;
        }
    }
    return \@activas;
}

sub inicializar_grafo_desde_relaciones {
    my ( $grafo, $avl ) = @_;
    my $relaciones = _leer_relaciones();
    my %nodos_agregados;
    $avl->en_orden(
        sub {
            my ($n) = @_;
            $grafo->agregar_nodo(
                $n->{colegio}, $n->{nombre}, $n->{departamento},
                $n->{tipo},    $n->{especialidad}
            );
            $nodos_agregados{ $n->{colegio} } = 1;
        }
    );
    for my $rel (@$relaciones) {
        if ( $rel->{estado} eq 'ACTIVA' ) {
            next
              unless $nodos_agregados{ $rel->{colegio_a} }
              && $nodos_agregados{ $rel->{colegio_b} };
            $grafo->agregar_arista( $rel->{colegio_a}, $rel->{colegio_b} );
        }
    }
}

1;
