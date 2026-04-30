#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/lib";
use Mojolicious::Lite;
use Mojo::JSON qw(encode_json decode_json);
use File::Path qw(make_path);
use utilidades::leer_json;
use gestion_datos::avl;
use gestion_datos::bst;
use gestion_datos::btree_orden4;
use gestion_datos::lista_doblemente_enlazada;
use gestion_datos::lista_circular_doblemente_enlazada;
use gestion_datos::grafo;
use gestion_datos::tabla_hash;
use gestion_datos::matriz_dispersa;
use gestion_datos::merkle;
use persistencia::relaciones;
use api::auth;
use api::admin;
use api::user;
use api::colaboracion;
use api::chat;
use api::reportes;
use api::upload;    # ← Asegurar que existe

app->secrets( ['eddtrack_secret_2026_para_sesiones'] );

my $PORT        = $ENV{PORT} // 3000;
my $SESSION_DIR = 'datos/sessions';
make_path($SESSION_DIR) unless -d $SESSION_DIR;

# Inicializar todas las estructuras de datos
my $avl          = gestion_datos::avl->nuevo();
my $bst          = gestion_datos::bst->nuevo();
my $btree        = gestion_datos::btree_orden4->nuevo();
my $medicamentos = gestion_datos::lista_doblemente_enlazada->nuevo();
my $solicitudes  = gestion_datos::lista_circular_doblemente_enlazada->nuevo();
my $grafo        = gestion_datos::grafo->nuevo();
my $tabla_hash   = gestion_datos::tabla_hash->nuevo();
my $matriz =
  gestion_datos::matriz_dispersa->nuevo( 0, 0 );    # ← Inicializar matriz vacía

my %PERMISOS_DEPARTAMENTO = (
    'DEP-ADM' => { medicamentos => 1, equipos     => 1, suministros => 1 },
    'DEP-MED' => { medicamentos => 1, suministros => 1 },
    'DEP-CIR' => { equipos      => 1, suministros => 1 },
    'DEP-LAB' => { equipos      => 1 },
    'DEP-FAR' => { medicamentos => 1 },
    'SIN-DEP' => {},
);

# Cargar datos desde archivos JSON
my $usuarios_data =
  utilidades::leer_json::parsear_json_posiblemente_vacio('datos/usuarios.json');
$avl->cargar_desde_array($usuarios_data);

my $equipos_data =
  utilidades::leer_json::parsear_json_posiblemente_vacio('datos/equipos.json');
$bst->cargar_desde_array($equipos_data);

my $suministros_data = utilidades::leer_json::parsear_json_posiblemente_vacio(
    'datos/suministros.json');
$btree->cargar_desde_array($suministros_data);

my $inventario_data = utilidades::leer_json::parsear_json_posiblemente_vacio(
    'datos/inventario.json');
for my $item (@$inventario_data) {
    $medicamentos->insertar_final($item);
}

my $proveedores_data = utilidades::leer_json::parsear_json_posiblemente_vacio(
    'datos/proveedores.json');
my $lista_prov = gestion_datos::lista_circular_doblemente_enlazada->nuevo();
for my $prov (@$proveedores_data) {
    $lista_prov->insertar_final($prov);
}

$tabla_hash->reconstruir_desde_avl($avl);
persistencia::relaciones::inicializar_grafo_desde_relaciones( $grafo, $avl );

# Helper ctx (incluye todas las estructuras)
helper ctx => sub {
    my $c    = shift;
    my $user = $c->session('user');
    return {
        avl                   => $avl,
        bst                   => $bst,
        btree                 => $btree,
        med                   => $medicamentos,
        solicitudes           => $solicitudes,
        grafo                 => $grafo,
        tabla_hash            => $tabla_hash,
        prov                  => $lista_prov,
        matriz                => $matriz,
        permisos_departamento => \%PERMISOS_DEPARTAMENTO,
        session               => { user => $user },
    };
};

# Middleware CORS
hook before_dispatch => sub {
    my $c      = shift;
    my $origin = $c->req->headers->origin;
    if (
        $origin
        && (   $origin eq 'http://localhost:4321'
            || $origin eq 'http://127.0.0.1:4321' )
      )
    {
        $c->res->headers->header( 'Access-Control-Allow-Origin' => $origin );
    }
    $c->res->headers->header( 'Access-Control-Allow-Credentials' => 'true' );
    $c->res->headers->header(
        'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS' );
    $c->res->headers->header(
        'Access-Control-Allow-Headers' => 'Content-Type, X-Requested-With' );
    if ( $c->req->method eq 'OPTIONS' ) {
        $c->res->code(200);
        $c->rendered;
        return;
    }
};

# Servir archivos estáticos desde reportes/
# # Servir archivos estáticos desde la carpeta reportes/
get '/reportes/*file' => sub {
    my $c         = shift;
    my $file      = $c->stash('file');
    my $full_path = "reportes/$file";
    if ( -e $full_path && -f $full_path ) {
        $c->reply->file($full_path);
    }
    else {
        $c->render( text => "Archivo no encontrado: $file", status => 404 );
    }
};

# ---------- Endpoints de autenticación ----------
post '/api/login' => sub {
    my $c      = shift;
    my $params = $c->req->json;
    my $result = api::auth::login( $c->ctx, $params );
    if ( $result->{success} ) {
        $c->session( user => $result->{usuario} );
        $c->render( json => $result );
    }
    else {
        $c->render( json => $result, status => 401 );
    }
};

post '/api/logout' => sub {
    my $c = shift;
    $c->session( expires => 1 );
    $c->render( json => { success => 1 } );
};

post '/api/admin/rechazar-solicitud' => sub {
    my $c      = shift;
    my $params = $c->req->json;
    my $result = api::admin::rechazar_solicitud( $c->ctx, $params );
    $c->render( json => $result );
};

get '/api/verificar' => sub {
    my $c      = shift;
    my $result = api::auth::verificar_sesion( $c->ctx );
    $c->render( json => $result );
};

# ---------- Endpoints de administrador ----------
get '/api/admin/usuarios-pendientes' => sub {
    my $c      = shift;
    my $result = api::admin::usuarios_pendientes( $c->ctx );
    $c->render( json => $result );
};

post '/api/admin/asignar-departamento' => sub {
    my $c      = shift;
    my $params = $c->req->json;
    my $result = api::admin::asignar_departamento( $c->ctx, $params );
    $c->render( json => $result );
};

get '/api/admin/solicitudes' => sub {
    my $c      = shift;
    my $result = api::admin::solicitudes_reabastecimiento( $c->ctx );
    $c->render( json => $result );
};

post '/api/admin/aprobar-solicitud' => sub {
    my $c      = shift;
    my $params = $c->req->json;
    my $result = api::admin::aprobar_solicitud( $c->ctx, $params );
    $c->render( json => $result );
};

# Carga masiva de inventario y usuarios
post '/api/admin/cargar-inventario' => sub {
    my $c      = shift;
    my $result = api::upload::procesar_inventario( $c, $c->ctx );
    if ( $result->{error} ) {
        $c->render( json => { error => $result->{error} }, status => 400 );
    }
    else {
        $c->render( json => { success => 1, mensaje => $result->{mensaje} } );
    }
};

post '/api/admin/cargar-usuarios' => sub {
    my $c      = shift;
    my $result = api::upload::procesar_usuarios( $c, $c->ctx );
    if ( $result->{error} ) {
        $c->render( json => { error => $result->{error} }, status => 400 );
    }
    else {
        $c->render( json => { success => 1, mensaje => $result->{mensaje} } );
    }
};

# ---------- Endpoints de usuario ----------
get '/api/user/perfil' => sub {
    my $c      = shift;
    my $result = api::user::perfil( $c->ctx );
    $c->render( json => $result );
};

post '/api/user/actualizar-perfil' => sub {
    my $c      = shift;
    my $params = $c->req->json;
    my $result = api::user::actualizar_perfil( $c->ctx, $params );
    $c->render( json => $result );
};

post '/api/user/solicitar-insumo' => sub {
    my $c      = shift;
    my $params = $c->req->json;
    my $result = api::user::solicitar_insumo( $c->ctx, $params );
    $c->render( json => $result );
};

get '/api/user/historial-solicitudes' => sub {
    my $c      = shift;
    my $result = api::user::historial_solicitudes_usuario( $c->ctx );
    $c->render( json => $result );
};

get '/api/user/inventario-medicamentos' => sub {
    my $c      = shift;
    my $filtro = $c->param('filtro') // '';
    my $result =
      api::user::inventario_medicamentos( $c->ctx, { filtro => $filtro } );
    $c->render( json => $result );
};

get '/api/user/inventario-equipos' => sub {
    my $c      = shift;
    my $filtro = $c->param('filtro') // '';
    my $result =
      api::user::inventario_equipos( $c->ctx, { filtro => $filtro } );
    $c->render( json => $result );
};

get '/api/user/inventario-suministros' => sub {
    my $c      = shift;
    my $filtro = $c->param('filtro') // '';
    my $result =
      api::user::inventario_suministros( $c->ctx, { filtro => $filtro } );
    $c->render( json => $result );
};

# ---------- Endpoints de colaboración ----------
get '/api/colaboracion/colaboradores' => sub {
    my $c      = shift;
    my $result = api::colaboracion::colaboradores_actuales( $c->ctx );
    $c->render( json => $result );
};

get '/api/colaboracion/sugerencias' => sub {
    my $c      = shift;
    my $result = api::colaboracion::sugerencias( $c->ctx );
    $c->render( json => $result );
};

post '/api/colaboracion/enviar-solicitud' => sub {
    my $c      = shift;
    my $params = $c->req->json;
    my $result =
      api::colaboracion::enviar_solicitud_colaboracion( $c->ctx, $params );
    $c->render( json => $result );
};

get '/api/colaboracion/solicitudes-recibidas' => sub {
    my $c      = shift;
    my $result = api::colaboracion::solicitudes_recibidas( $c->ctx );
    $c->render( json => $result );
};

post '/api/colaboracion/responder-solicitud' => sub {
    my $c      = shift;
    my $params = $c->req->json;
    my $result = api::colaboracion::responder_solicitud( $c->ctx, $params );
    $c->render( json => $result );
};

get '/api/colaboracion/solicitudes-enviadas' => sub {
    my $c      = shift;
    my $result = api::colaboracion::solicitudes_enviadas( $c->ctx );
    $c->render( json => $result );
};

# ---------- Endpoints de chat ----------
post '/api/chat/enviar' => sub {
    my $c      = shift;
    my $params = $c->req->json;
    my $result = api::chat::enviar_mensaje( $c->ctx, $params );
    $c->render( json => $result );
};

get '/api/chat/mensajes' => sub {
    my $c        = shift;
    my $receptor = $c->param('receptor');
    my $desde    = $c->param('desde') // 0;
    my $result   = api::chat::obtener_mensajes( $c->ctx,
        { receptor => $receptor, desde => $desde } );
    $c->render( json => $result );
};

get '/api/chat/conversaciones' => sub {
    my $c      = shift;
    my $result = api::chat::conversaciones_recientes( $c->ctx );
    $c->render( json => $result );
};

# ---------- Endpoints de reportes ----------
get '/api/reportes/grafo' => sub {
    my $c      = shift;
    my $result = api::reportes::grafo_colaboraciones( $c->ctx );
    $c->render( json => $result );
};

get '/api/reportes/merkle' => sub {
    my $c      = shift;
    my $result = api::reportes::merkle_tree( $c->ctx );
    $c->render( json => $result );
};

get '/api/reportes/lista-adyacencia' => sub {
    my $c      = shift;
    my $result = api::reportes::lista_adyacencia( $c->ctx );
    $c->render( json => $result );
};

get '/api/reportes/tabla-hash' => sub {
    my $c      = shift;
    my $result = api::reportes::tabla_hash_estado( $c->ctx );
    $c->render( json => $result );
};

get '/api/reportes/compresion' => sub {
    my $c      = shift;
    my $result = api::reportes::reporte_compresion( $c->ctx );
    $c->render( json => $result );
};

get '/api/reportes/matriz' => sub {
    my $c      = shift;
    my $result = api::reportes::matriz_dispersa( $c->ctx );
    $c->render( json => $result );
};

# Medicamentos (lista doblemente enlazada)
get '/api/admin/medicamentos' => sub {
    my $c      = shift;
    my $result = api::admin::listar_medicamentos( $c->ctx );
    $c->render( json => $result );
};

post '/api/admin/medicamentos' => sub {
    my $c      = shift;
    my $params = $c->req->json;
    my $result = api::admin::agregar_medicamento( $c->ctx, $params );
    $c->render( json => $result );
};

put '/api/admin/medicamentos/:codigo' => sub {
    my $c      = shift;
    my $codigo = $c->param('codigo');
    my $params = $c->req->json;
    my $result =
      api::admin::actualizar_medicamento( $c->ctx, $codigo, $params );
    $c->render( json => $result );
};

del '/api/admin/medicamentos/:codigo' => sub {
    my $c      = shift;
    my $codigo = $c->param('codigo');
    my $result = api::admin::eliminar_medicamento( $c->ctx, $codigo );
    $c->render( json => $result );
};

# Equipos (BST)
get '/api/admin/equipos' => sub {
    my $c      = shift;
    my $result = api::admin::listar_equipos( $c->ctx );
    $c->render( json => $result );
};

post '/api/admin/equipos' => sub {
    my $c      = shift;
    my $params = $c->req->json;
    my $result = api::admin::agregar_equipo( $c->ctx, $params );
    $c->render( json => $result );
};

put '/api/admin/equipos/:codigo' => sub {
    my $c      = shift;
    my $codigo = $c->param('codigo');
    my $params = $c->req->json;
    my $result = api::admin::actualizar_equipo( $c->ctx, $codigo, $params );
    $c->render( json => $result );
};

del '/api/admin/equipos/:codigo' => sub {
    my $c      = shift;
    my $codigo = $c->param('codigo');
    my $result = api::admin::eliminar_equipo( $c->ctx, $codigo );
    $c->render( json => $result );
};

# Suministros (árbol B)
get '/api/admin/suministros' => sub {
    my $c      = shift;
    my $result = api::admin::listar_suministros( $c->ctx );
    $c->render( json => $result );
};

post '/api/admin/suministros' => sub {
    my $c      = shift;
    my $params = $c->req->json;
    my $result = api::admin::agregar_suministro( $c->ctx, $params );
    $c->render( json => $result );
};

put '/api/admin/suministros/:codigo' => sub {
    my $c      = shift;
    my $codigo = $c->param('codigo');
    my $params = $c->req->json;
    my $result = api::admin::actualizar_suministro( $c->ctx, $codigo, $params );
    $c->render( json => $result );
};

del '/api/admin/suministros/:codigo' => sub {
    my $c      = shift;
    my $codigo = $c->param('codigo');
    my $result = api::admin::eliminar_suministro( $c->ctx, $codigo );
    $c->render( json => $result );
};

# Carga masiva de relaciones (grafo)
post '/api/admin/cargar-relaciones' => sub {
    my $c      = shift;
    my $result = api::upload::procesar_relaciones( $c, $c->ctx );
    if ( $result->{error} ) {
        $c->render( json => { error => $result->{error} }, status => 400 );
    }
    else {
        $c->render( json => { success => 1, mensaje => $result->{mensaje} } );
    }
};

# Ruta para el frontend (servir index.html)
any '/' => sub {
    my $c = shift;
    $c->render_static('index.html');
};

app->start;
