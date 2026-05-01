import { useEffect, useState } from "react";
import { api, Colaborador, Sugerencia } from "../../../services/api";
import toast from "react-hot-toast";
import { Check, Lightbulb, Send, UserPlus, Users, X } from "lucide-react";

export default function Collaboration() {
  const [colaboradores, setColaboradores] = useState<Colaborador[]>([]);
  const [sugerencias, setSugerencias] = useState<Sugerencia[]>([]);
  const [solicitudesRecibidas, setSolicitudesRecibidas] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [enviando, setEnviando] = useState<string | null>(null);
  const [respondiendo, setRespondiendo] = useState<string | null>(null);
  const [colegioDestino, setColegioDestino] = useState("");
  const [mostrarModal, setMostrarModal] = useState(false);

  useEffect(() => {
    cargarDatos();
  }, []);

  const cargarDatos = async () => {
    try {
      const [colabRes, sugerenciasRes, solicitudesRes] = await Promise.all([
        api.getColaboradores(),
        api.getSugerencias(),
        api.getSolicitudesRecibidas(),
      ]);
      setColaboradores(colabRes.colaboradores || []);
      setSugerencias(sugerenciasRes.sugerencias || []);
      setSolicitudesRecibidas(solicitudesRes.solicitudes || []);
    } catch (error) {
      toast.error("Error al cargar datos de colaboración");
    } finally {
      setLoading(false);
    }
  };

  const enviarSolicitud = async (colegio: string) => {
    setEnviando(colegio);
    try {
      await api.enviarSolicitudColaboracion(colegio);
      toast.success(`Solicitud enviada a ${colegio}`);
      setMostrarModal(false);
      setColegioDestino("");
    } catch (error: any) {
      toast.error(error.response?.data?.error || "Error al enviar solicitud");
    } finally {
      setEnviando(null);
    }
  };

  const responderSolicitud = async (
    colegio: string,
    accion: "aceptar" | "rechazar",
  ) => {
    setRespondiendo(colegio);
    try {
      await api.responderSolicitud(colegio, accion);
      toast.success(
        `Solicitud ${accion === "aceptar" ? "aceptada" : "rechazada"}`,
      );
      cargarDatos();
    } catch (error) {
      toast.error("Error al responder solicitud");
    } finally {
      setRespondiendo(null);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600">
        </div>
      </div>
    );
  }

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 mb-6">
        Red de Colaboración
      </h1>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <button
          onClick={() => setMostrarModal(true)}
          className="card flex items-center justify-between hover:shadow-lg transition-shadow"
        >
          <div className="flex items-center space-x-4">
            <div className="p-3 bg-primary-100 rounded-lg">
              <UserPlus className="h-6 w-6 text-primary-600" />
            </div>
            <div className="text-left">
              <h3 className="font-semibold text-gray-900">
                Nueva Colaboración
              </h3>
              <p className="text-sm text-gray-500">
                Enviar solicitud a otro profesional
              </p>
            </div>
          </div>
          <Send className="h-5 w-5 text-gray-400" />
        </button>
      </div>

      {solicitudesRecibidas.length > 0 && (
        <div className="card mb-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
            <Users className="h-5 w-5 mr-2 text-primary-600" />
            Solicitudes Recibidas
          </h2>
          <div className="space-y-3">
            {solicitudesRecibidas.map((solicitud) => (
              <div
                key={solicitud.colegio}
                className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
              >
                <div>
                  <p className="font-medium text-gray-900">
                    {solicitud.nombre}
                  </p>
                  <p className="text-sm text-gray-500">
                    {solicitud.colegio} • {solicitud.departamento}
                  </p>
                </div>
                <div className="flex space-x-2">
                  <button
                    onClick={() =>
                      responderSolicitud(solicitud.colegio, "aceptar")}
                    disabled={respondiendo === solicitud.colegio}
                    className="p-2 text-green-600 hover:bg-green-100 rounded-lg transition-colors"
                  >
                    <Check size={18} />
                  </button>
                  <button
                    onClick={() =>
                      responderSolicitud(solicitud.colegio, "rechazar")}
                    disabled={respondiendo === solicitud.colegio}
                    className="p-2 text-red-600 hover:bg-red-100 rounded-lg transition-colors"
                  >
                    <X size={18} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="card">
          <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
            <Users className="h-5 w-5 mr-2 text-primary-600" />
            Mis Colaboradores ({colaboradores.length})
          </h2>
          {colaboradores.length === 0
            ? (
              <p className="text-gray-500 text-center py-8">
                No tienes colaboradores aún
              </p>
            )
            : (
              <div className="space-y-3">
                {colaboradores.map((colab) => (
                  <div
                    key={colab.colegio}
                    className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                  >
                    <div>
                      <p className="font-medium text-gray-900">
                        {colab.nombre}
                      </p>
                      <p className="text-sm text-gray-500">
                        {colab.departamento} • {colab.especialidad}
                      </p>
                    </div>
                    <span className="px-2 py-1 text-xs rounded-full bg-green-100 text-green-800">
                      Colaborador
                    </span>
                  </div>
                ))}
              </div>
            )}
        </div>

        <div className="card">
          <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
            <Lightbulb className="h-5 w-5 mr-2 text-yellow-600" />
            Sugerencias de Colaboración
          </h2>
          {sugerencias.length === 0
            ? (
              <p className="text-gray-500 text-center py-8">
                No hay sugerencias disponibles
              </p>
            )
            : (
              <div className="space-y-3">
                {sugerencias.map((sug) => (
                  <div
                    key={sug.colegio}
                    className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                  >
                    <div>
                      <p className="font-medium text-gray-900">{sug.nombre}</p>
                      <p className="text-sm text-gray-500">
                        {sug.departamento} • {sug.especialidad}
                      </p>
                      <p className="text-xs text-gray-400 mt-1">
                        {sug.comunes} colaborador(es) en común
                      </p>
                    </div>
                    <button
                      onClick={() => enviarSolicitud(sug.colegio)}
                      disabled={enviando === sug.colegio}
                      className="btn-primary text-sm py-1 px-3"
                    >
                      {enviando === sug.colegio ? "Enviando..." : "Solicitar"}
                    </button>
                  </div>
                ))}
              </div>
            )}
        </div>
      </div>

      {/* Modal para enviar solicitud manual */}
      {mostrarModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl shadow-xl w-full max-w-md p-6">
            <h2 className="text-xl font-bold text-gray-900 mb-4">
              Enviar Solicitud de Colaboración
            </h2>
            <p className="text-gray-600 mb-4">
              Ingresa el número de colegio del profesional con quien deseas
              colaborar
            </p>

            <div className="mb-6">
              <label className="label">Número de Colegio</label>
              <input
                type="text"
                value={colegioDestino}
                onChange={(e) => setColegioDestino(e.target.value)}
                className="input"
                placeholder="Ej: COL-10245"
              />
            </div>

            <div className="flex space-x-3">
              <button
                onClick={() => enviarSolicitud(colegioDestino)}
                disabled={enviando === colegioDestino || !colegioDestino}
                className="btn-primary flex-1"
              >
                {enviando === colegioDestino ? "Enviando..." : "Enviar"}
              </button>
              <button
                onClick={() => {
                  setMostrarModal(false);
                  setColegioDestino("");
                }}
                className="btn-secondary"
              >
                Cancelar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
