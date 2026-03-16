#!/usr/bin/perl
package administrador::Ver_Inventario::modulos::verificar_caducidad;
use warnings;
use strict;
use Time::Piece;

sub verificar_caducidad {
  my ($fecha_vencimiento) = @_;

  return "Fecha no proporcionada" unless defined $fecha_vencimiento && $fecha_vencimiento ne '';

  my $fecha_hoy = Time::Piece->new();
  my $fecha_venc;
  eval {
    if ($fecha_vencimiento =~ m|^(\d{4})-(\d{2})-(\d{2})$|) {
      # Comprobamos que el formato sea: YYYY-MM-DD
      $fecha_venc = Time::Piece->strptime($fecha_vencimiento, "%Y-%m-%d");
    } elsif ($fecha_vencimiento =~ m|^(\d{4})/(\d{2})/(\d{2})$|) {
      # Formato manual: YYYY/MM/DD
      $fecha_venc = Time::Piece->strptime($fecha_vencimiento, "%Y/%m/%d");
    } elsif ($fecha_vencimiento =~ m|^(\d{2})/(\d{2})/(\d{4})$|) {
      # Formateamos a: DD/MM/YYYY
      $fecha_venc = Time::Piece->strptime($fecha_vencimiento, "%d/%m/%Y");
    } else {
      return "Formato de fecha inválido";
    }
  };

  if ($@ || !defined $fecha_venc) {
    return "Formato de fecha inválido";
  }

  return "Error al procesar fecha" if $@;

  my $diferencia_dias = int(($fecha_venc->epoch - $fecha_hoy->epoch) / 86400);

  my @rangos = (
    { dias => 0 ,   tiempo => "Caducado" },
    { dias => 7 ,   tiempo => "Vence en 7 días" },
    { dias => 15 ,  tiempo => "Vence en 15 días" },
    { dias => 30 ,  tiempo => "Vence en 1 mes" },
    { dias => 60 ,  tiempo => "Vence en 2 meses" },
    { dias => 90 ,  tiempo => "Vence en 3 meses" },
    { dias => 180 , tiempo => "Vence en 6 meses" }
  );
  foreach my $rango ( @rangos ) {
    if ( $diferencia_dias <= $rango->{dias} ) {
      return $rango->{tiempo};
    }
  }
  return "Vence en +6 meses";
}

1;
