import axios from "axios";

const apiClient = axios.create({
  baseURL: "http://localhost:3000",
  withCredentials: true,
  headers: {
    "Content-Type": "application/json",
  },
});

export interface User {
  colegio: string;
  nombre: string;
  tipo: string;
  departamento?: string;
  especialidad?: string;
  contrasena?: string;
}

export interface Medicamento {
  codigo: string;
  nombre: string;
  cantidad: number;
  precio_unitario: number;
  fecha_vencimiento: string;
  nivel_minimo: number;
  principio_activo?: string;
  laboratorio?: string;
}

export interface Equipo {
  codigo: string;
  nombre: string;
  cantidad: number;
  fabricante: string;
  precio_unitario: number;
  fecha_ingreso: string;
  nivel_minimo: number;
}

export interface Suministro {
  codigo: string;
  nombre: string;
  cantidad: number;
  fabricante: string;
  precio_unitario: number;
  fecha_vencimiento: string;
  nivel_minimo: number;
}

export interface Solicitud {
  uuid: string;
  tipo: string;
  codigo: string;
  cantidad: number;
  motivo: string;
  departamento: string;
  solicitante: string;
  fecha: string;
}

export interface UsuarioPendiente {
  colegio: string;
  nombre: string;
  tipo: string;
  especialidad: string;
}

export interface Colaborador {
  colegio: string;
  nombre: string;
  departamento: string;
  especialidad: string;
}

export interface Sugerencia extends Colaborador {
  comunes: number;
}

export interface Mensaje {
  remitente: string;
  receptor: string;
  contenido: string;
  timestamp: number;
}

export interface Conversacion {
  colegio: string;
  ultimo_mensaje: string;
  timestamp: number;
}

export const api = {
  // Auth
  login: async (colegio: string, contrasena: string) => {
    const response = await apiClient.post("/api/login", {
      colegio,
      contrasena,
    });
    return response.data;
  },

  logout: async () => {
    const response = await apiClient.post("/api/logout");
    return response.data;
  },

  verificarSesion: async () => {
    const response = await apiClient.get("/api/verificar");
    return response.data;
  },

  // Admin
  getUsuariosPendientes: async () => {
    const response = await apiClient.get("/api/admin/usuarios-pendientes");
    return response.data;
  },

  asignarDepartamento: async (colegio: string, departamento: string) => {
    const response = await apiClient.post("/api/admin/asignar-departamento", {
      colegio,
      departamento,
    });
    return response.data;
  },

  getSolicitudes: async () => {
    const response = await apiClient.get("/api/admin/solicitudes");
    return response.data;
  },

  aprobarSolicitud: async (uuid: string) => {
    const response = await apiClient.post("/api/admin/aprobar-solicitud", {
      uuid,
    });
    return response.data;
  },

  // User Profile
  getPerfil: async () => {
    const response = await apiClient.get("/api/user/perfil");
    return response.data;
  },

  actualizarPerfil: async (data: { nombre?: string; password?: string }) => {
    const response = await apiClient.post("/api/user/actualizar-perfil", data);
    return response.data;
  },

  // Inventory
  getInventarioMedicamentos: async (filtro?: string) => {
    const response = await apiClient.get("/api/user/inventario-medicamentos", {
      params: { filtro: filtro || "" },
    });
    return response.data;
  },

  getInventarioEquipos: async (filtro?: string) => {
    const response = await apiClient.get("/api/user/inventario-equipos", {
      params: { filtro: filtro || "" },
    });
    return response.data;
  },

  getInventarioSuministros: async (filtro?: string) => {
    const response = await apiClient.get("/api/user/inventario-suministros", {
      params: { filtro: filtro || "" },
    });
    return response.data;
  },

  // Requests
  solicitarInsumo: async (
    data: { tipo: string; codigo: string; cantidad: number; motivo: string },
  ) => {
    const response = await apiClient.post("/api/user/solicitar-insumo", data);
    return response.data;
  },

  getHistorialSolicitudes: async () => {
    const response = await apiClient.get("/api/user/historial-solicitudes");
    return response.data;
  },

  // Collaboration
  getColaboradores: async () => {
    const response = await apiClient.get("/api/colaboracion/colaboradores");
    return response.data;
  },

  getSugerencias: async () => {
    const response = await apiClient.get("/api/colaboracion/sugerencias");
    return response.data;
  },

  enviarSolicitudColaboracion: async (colegioDestino: string) => {
    const response = await apiClient.post(
      "/api/colaboracion/enviar-solicitud",
      { colegio_destino: colegioDestino },
    );
    return response.data;
  },

  getSolicitudesRecibidas: async () => {
    const response = await apiClient.get(
      "/api/colaboracion/solicitudes-recibidas",
    );
    return response.data;
  },

  responderSolicitud: async (
    colegioRemitente: string,
    accion: "aceptar" | "rechazar",
  ) => {
    const response = await apiClient.post(
      "/api/colaboracion/responder-solicitud",
      {
        colegio_remitente: colegioRemitente,
        accion,
      },
    );
    return response.data;
  },

  // Chat
  enviarMensaje: async (receptor: string, contenido: string) => {
    const response = await apiClient.post("/api/chat/enviar", {
      receptor,
      contenido,
    });
    return response.data;
  },

  getMensajes: async (receptor: string, desde?: number) => {
    const response = await apiClient.get("/api/chat/mensajes", {
      params: { receptor, desde: desde || 0 },
    });
    return response.data;
  },

  getConversaciones: async () => {
    const response = await apiClient.get("/api/chat/conversaciones");
    return response.data;
  },

  // Reports
  getReporteGrafo: async () => {
    const response = await apiClient.get("/api/reportes/grafo");
    return response.data;
  },

  getReporteListaAdyacencia: async () => {
    const response = await apiClient.get("/api/reportes/lista-adyacencia");
    return response.data;
  },

  getReporteTablaHash: async () => {
    const response = await apiClient.get("/api/reportes/tabla-hash");
    return response.data;
  },

  getReporteCompresion: async () => {
    const response = await apiClient.get("/api/reportes/compresion");
    return response.data;
  },
};

export default api;
