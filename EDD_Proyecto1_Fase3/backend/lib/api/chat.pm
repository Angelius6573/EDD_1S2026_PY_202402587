#!/usr/bin/perl
package api::chat;
use strict;
use warnings;
use utf8;
use JSON::PP;
use persistencia::chats;

sub _usuario_actual {
    my ($ctx) = @_;
    return $ctx->{session}->{user};
}

sub enviar_mensaje {
    my ( $ctx, $params ) = @_;
    my $user = _usuario_actual($ctx);
    return { error => 'No autenticado' } unless $user;
    my $receptor  = $params->{receptor};
    my $contenido = $params->{contenido};
    return { error => 'Contenido vacío' } unless $contenido;
    return { error => 'No puede enviarse mensaje a sí mismo' }
      if $receptor eq $user->{colegio};
    my $son_vecinos = $ctx->{grafo}->son_vecinos( $user->{colegio}, $receptor );
    return {
        error => 'Solo puede enviar mensajes a sus colaboradores directos' }
      unless $son_vecinos;
    my $timestamp = time();
    my $mensaje   = {
        remitente => $user->{colegio},
        receptor  => $receptor,
        contenido => $contenido,
        timestamp => $timestamp
    };
    persistencia::chats::agregar_mensaje( $user->{colegio}, $receptor,
        $mensaje );
    persistencia::chats::agregar_mensaje( $receptor, $user->{colegio},
        $mensaje );
    return { success => 1 };
}

sub obtener_mensajes {
    my ( $ctx, $params ) = @_;
    my $user = _usuario_actual($ctx);
    return { error => 'No autenticado' } unless $user;
    my $receptor = $params->{receptor};
    my $desde    = $params->{desde} // 0;
    my $mensajes =
      persistencia::chats::obtener_conversacion( $user->{colegio}, $receptor );
    my @nuevos = grep { $_->{timestamp} > $desde } @$mensajes;
    return { mensajes => \@nuevos };
}

sub conversaciones_recientes {
    my ($ctx) = @_;
    my $user = _usuario_actual($ctx);
    return { error => 'No autenticado' } unless $user;
    my $chats = persistencia::chats::cargar_chats( $user->{colegio} );
    my @conversaciones;
    for my $otro ( keys %$chats ) {
        my $ultimo = $chats->{$otro}->[-1];
        push @conversaciones,
          {
            colegio        => $otro,
            ultimo_mensaje => $ultimo->{contenido},
            timestamp      => $ultimo->{timestamp}
          };
    }
    @conversaciones =
      sort { $b->{timestamp} <=> $a->{timestamp} } @conversaciones;
    return { conversaciones => \@conversaciones };
}

1;
