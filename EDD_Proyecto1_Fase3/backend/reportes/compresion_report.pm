#!/usr/bin/perl
package reportes::compresion_report;
use strict;
use warnings;
use utf8;
use File::Find;

sub generar_reporte {
    my ( $ruta_chats, $ruta_txt ) = @_;
    my @archivos;
    if ( -d $ruta_chats ) {
        find( sub { push @archivos, $File::Find::name if /\.lzw$/ },
            $ruta_chats );
    }
    open( my $fh, '>:encoding(UTF-8)', $ruta_txt )
      or die "No se pudo abrir $ruta_txt: $!";
    print $fh "Reporte de Archivos de Compresión LZW\n";
    print $fh "=====================================\n\n";
    if (@archivos) {
        for my $arch (@archivos) {
            my $size = -s $arch;
            print $fh "$arch: " . ( $size / 1024 ) . " KB\n";
        }
    }
    else {
        print $fh "No hay archivos .lzw en la carpeta $ruta_chats\n";
    }
    close($fh);
}

1;
