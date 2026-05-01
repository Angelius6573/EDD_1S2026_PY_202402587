#!/usr/bin/perl
package api::auth;
use strict;
use warnings;
use utf8;
use JSON::PP;

sub login {
    my ( $ctx, $params ) = @_;
    my $colegio  = $params->{colegio};
    my $password = $params->{password};
    if ( $colegio eq 'AdminHospital' && $password eq 'MedTrack2026' ) {
        my $admin_user = {
            tipo    => 'ADMIN',
            nombre  => 'Administrador',
            colegio => 'AdminHospital'
        };
        $ctx->{session}->{user} = $admin_user;
        return { success => 1, tipo => 'ADMIN', user => $admin_user };
    }
    my $usuario = $ctx->{avl}->buscar($colegio);
    if ( $usuario && $usuario->{contrasena} eq $password ) {
        my $user_data = {
            colegio      => $usuario->{colegio},
            nombre       => $usuario->{nombre},
            tipo         => $usuario->{tipo},
            departamento => $usuario->{departamento} // 'SIN-DEP',
            especialidad => $usuario->{especialidad} // ''
        };
        $ctx->{session}->{user} = $user_data;
        return { success => 1, tipo => $usuario->{tipo}, user => $user_data };
    }
    return { success => 0, error => 'Credenciales incorrectas' };
}

sub logout {
    my ($ctx) = @_;
    delete $ctx->{session}->{user};
    return { success => 1 };
}

sub verificar_sesion {
    my ($ctx) = @_;
    return { success => 1, user => $ctx->{session}->{user} }
      if $ctx->{session}->{user};
    return { success => 0, error => 'No autenticado' };
}

1;
