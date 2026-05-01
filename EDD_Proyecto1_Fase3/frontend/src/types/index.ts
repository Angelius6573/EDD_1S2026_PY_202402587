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

export interface TablaHashStats {
  "TIPO-01": { ocupacion: number; colisiones: number };
  "TIPO-02": { ocupacion: number; colisiones: number };
  "TIPO-03": { ocupacion: number; colisiones: number };
  "TIPO-04": { ocupacion: number; colisiones: number };
  "TIPO-05": { ocupacion: number; colisiones: number };
  total_ocupacion: number;
  total_colisiones: number;
}
