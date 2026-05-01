#!/usr/bin/perl
package api::auth;
use strict;
use warnings;
use utf8;
use JSON::PP;

sub login {
    my ( $ctx, $params ) = @_;

    # Validar que params sea un hashref
    unless ( $params && ref($params) eq 'HASH' ) {
        return { success => 0, error => 'Solicitud inválida' };
    }

    my $colegio = $params->{colegio} // '';

    # Aceptar tanto 'contrasena' como 'password'
    my $password = $params->{contrasena} // $params->{password} // '';

    # Verificar credenciales del administrador
    if ( $colegio eq 'admin' && $password eq '1234' ) {
        my $admin_user = {
            tipo    => 'ADMIN',
            nombre  => 'Administrador',
            colegio => 'AdminHospital'
        };
        $ctx->{session}->{user} = $admin_user;
        return { success => 1, tipo => 'ADMIN', usuario => $admin_user };
    }

    # Buscar en el AVL
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
        return {
            success => 1,
            tipo    => $usuario->{tipo},
            usuario => $user_data
        };
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
    if ( $ctx->{session}->{user} ) {
        return { autenticado => 1, usuario => $ctx->{session}->{user} };
    }
    return { autenticado => 0, error => 'No autenticado' };
}

1;
