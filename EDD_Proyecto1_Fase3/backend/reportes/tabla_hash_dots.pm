#!/usr/bin/perl
package reportes::tabla_hash_dots;
use strict;
use warnings;
use utf8;

sub generar_reporte {
    my ( $tabla_hash, $ruta_txt ) = @_;
    my $stats = $tabla_hash->obtener_estadisticas();
    open( my $fh, '>:encoding(UTF-8)', $ruta_txt )
      or die "No se pudo abrir $ruta_txt: $!";
    print $fh "Estado de la Tabla Hash (por tipo de usuario)\n";
    print $fh "==============================================\n\n";
    for my $tipo (qw(TIPO-01 TIPO-02 TIPO-03 TIPO-04 TIPO-05)) {
        my $data = $stats->{$tipo};
        print $fh "$tipo:\n";
        print $fh "  Ocupación: $data->{ocupacion} usuario(s)\n";
        print $fh "  Colisiones: "
          . ( $data->{colisiones} ? 'Sí' : 'No' ) . "\n\n";
    }
    print $fh "Total ocupación: $stats->{total_ocupacion} usuarios\n";
    print $fh "Total colisiones: $stats->{total_colisiones}\n";
    close($fh);
}

1;
