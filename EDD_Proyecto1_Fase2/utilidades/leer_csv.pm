#!/usr/bin/perl
package utilidades::leer_csv;
use strict;
use warnings;

## Usa librería externa
# Para instalar hacer
# sudo pacman -S perl-text-csv
# O con cpanm, aunque ahí tendrías que mover el registro de descarga a /usr/share/perl5/vendor_perl/Text/CSV.pm
use Text::CSV;

sub parsear_csv {
    my ($ruta) = @_;
    my @datos;

    my $csv = Text::CSV->new({ binary => 1, auto_diag => 1 });
    open my $fh, "<", $ruta 
      or die "No se pudo abrir el archivo en $ruta";

    # Leer la primera línea del archivo
    my $encabezado = $csv->getline($fh);

    while (my $fila = $csv->getline($fh)) {
        my %dato;
        @dato{@$encabezado} = @$fila;  # Crear hash en memoria para cada encabezado
        push @datos, \%dato;
    }

    close $fh;
    return \@datos;
}

1;

