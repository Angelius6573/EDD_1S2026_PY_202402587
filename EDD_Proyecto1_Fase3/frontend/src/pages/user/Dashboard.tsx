import { useEffect, useState } from "react";
import { useAuth } from "../../../hooks/useAuth";
import { api, Colaborador, Solicitud } from "../../../services/api";
import { ClipboardList, MessageCircle, Package, Users } from "lucide-react";
import toast from "react-hot-toast";

export default function UserDashboard() {
  const { user } = useAuth();
  const [colaboradores, setColaboradores] = useState<Colaborador[]>([]);
  const [solicitudes, setSolicitudes] = useState<Solicitud[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    cargarDatos();
  }, []);

  const cargarDatos = async () => {
    try {
      const [colabRes, histRes] = await Promise.all([
        api.getColaboradores(),
        api.getHistorialSolicitudes(),
      ]);
      setColaboradores(colabRes.colaboradores || []);
      setSolicitudes(histRes.solicitudes || []);
    } catch (error) {
      toast.error("Error al cargar datos");
    } finally {
      setLoading(false);
    }
  };

  const stats = [
    {
      titulo: "Colaboradores",
      valor: colaboradores.length,
      icono: Users,
      color: "bg-primary-500",
      descripcion: "En tu red de colaboración",
    },
    {
      titulo: "Solicitudes Realizadas",
      valor: solicitudes.length,
      icono: ClipboardList,
      color: "bg-blue-500",
      descripcion: "Historial de solicitudes",
    },
    {
      titulo: "Departamento",
      valor: user?.departamento || "Sin asignar",
      icono: Package,
      color: "bg-green-500",
      descripcion: "Tu área de trabajo",
    },
    {
      titulo: "Tipo de Usuario",
      valor: user?.tipo || "-",
      icono: MessageCircle,
      color: "bg-purple-500",
      descripcion: "Rol en el sistema",
    },
  ];

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
      <h1 className="text-2xl font-bold text-gray-900 mb-2">
        Bienvenido, {user?.nombre}
      </h1>
      <p className="text-gray-600 mb-6">Panel de control de usuario</p>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {stats.map((stat, index) => {
          const Icono = stat.icono;
          return (
            <div key={index} className="bg-white rounded-xl shadow-md p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-500 mb-1">{stat.titulo}</p>
                  <p className="text-2xl font-bold text-gray-900">
                    {stat.valor}
                  </p>
                  <p className="text-xs text-gray-400 mt-2">
                    {stat.descripcion}
                  </p>
                </div>
                <div className={`${stat.color} p-3 rounded-lg`}>
                  <Icono className="h-6 w-6 text-white" />
                </div>
              </div>
            </div>
          );
        })}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-xl shadow-md p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Tus Colaboradores
          </h2>
          {colaboradores.length === 0
            ? (
              <p className="text-gray-500 text-center py-8">
                No tienes colaboradores aún. Envía solicitudes de colaboración.
              </p>
            )
            : (
              <div className="space-y-3">
                {colaboradores.slice(0, 5).map((colab) => (
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

        <div className="bg-white rounded-xl shadow-md p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Solicitudes Recientes
          </h2>
          {solicitudes.length === 0
            ? (
              <p className="text-gray-500 text-center py-8">
                No has realizado solicitudes aún
              </p>
            )
            : (
              <div className="space-y-3">
                {solicitudes.slice(0, 5).map((solicitud) => (
                  <div
                    key={solicitud.uuid}
                    className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                  >
                    <div>
                      <p className="font-medium text-gray-900">
                        {solicitud.tipo} - {solicitud.codigo}
                      </p>
                      <p className="text-sm text-gray-500">
                        {solicitud.cantidad} unidades • {solicitud.fecha}
                      </p>
                    </div>
                    <span className="px-2 py-1 text-xs rounded-full bg-yellow-100 text-yellow-800">
                      Pendiente
                    </span>
                  </div>
                ))}
              </div>
            )}
        </div>
      </div>
    </div>
  );
}
