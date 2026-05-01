import { useEffect, useState } from "react";
import { api, UsuarioPendiente } from "../../../services/api";
import toast from "react-hot-toast";
import { UserCheck, UserX } from "lucide-react";

export default function PendingUsers() {
  const [usuarios, setUsuarios] = useState<UsuarioPendiente[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedUser, setSelectedUser] = useState<UsuarioPendiente | null>(
    null,
  );
  const [departamento, setDepartamento] = useState("");
  const [asignando, setAsignando] = useState(false);

  const departamentos = [
    { codigo: "DEP-ADM", nombre: "Administración General" },
    { codigo: "DEP-MED", nombre: "Medicina General" },
    { codigo: "DEP-CIR", nombre: "Cirugía" },
    { codigo: "DEP-LAB", nombre: "Laboratorio Clínico" },
    { codigo: "DEP-FAR", nombre: "Farmacia" },
  ];

  useEffect(() => {
    cargarUsuarios();
  }, []);

  const cargarUsuarios = async () => {
    try {
      const response = await api.getUsuariosPendientes();
      setUsuarios(response.usuarios || []);
    } catch (error) {
      toast.error("Error al cargar usuarios pendientes");
    } finally {
      setLoading(false);
    }
  };

  const handleAsignar = async () => {
    if (!selectedUser || !departamento) {
      toast.error("Seleccione un departamento");
      return;
    }

    setAsignando(true);
    try {
      await api.asignarDepartamento(selectedUser.colegio, departamento);
      toast.success(
        `Departamento ${departamento} asignado a ${selectedUser.nombre}`,
      );
      setSelectedUser(null);
      setDepartamento("");
      cargarUsuarios();
    } catch (error) {
      toast.error("Error al asignar departamento");
    } finally {
      setAsignando(false);
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
        Usuarios Pendientes de Asignación
      </h1>

      <div className="bg-white rounded-xl shadow-md overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Número de Colegio
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Nombre Completo
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Tipo
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Especialidad
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {usuarios.length === 0
                ? (
                  <tr>
                    <td
                      colSpan={5}
                      className="px-6 py-8 text-center text-gray-500"
                    >
                      No hay usuarios pendientes de asignación
                    </td>
                  </tr>
                )
                : (
                  usuarios.map((user) => (
                    <tr key={user.colegio} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {user.colegio}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                        {user.nombre}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                        {user.tipo}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                        {user.especialidad || "-"}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm">
                        <button
                          onClick={() =>
                            setSelectedUser(user)}
                          className="text-primary-600 hover:text-primary-800 font-medium"
                        >
                          Asignar
                        </button>
                      </td>
                    </tr>
                  ))
                )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal de asignación */}
      {selectedUser && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl shadow-xl w-full max-w-md p-6">
            <h2 className="text-xl font-bold text-gray-900 mb-4">
              Asignar Departamento
            </h2>
            <p className="text-gray-600 mb-4">
              Usuario:{" "}
              <span className="font-medium">{selectedUser.nombre}</span>
            </p>

            <div className="mb-6">
              <label className="label">Departamento</label>
              <select
                value={departamento}
                onChange={(e) => setDepartamento(e.target.value)}
                className="input"
              >
                <option value="">Seleccione...</option>
                {departamentos.map((dep) => (
                  <option key={dep.codigo} value={dep.codigo}>
                    {dep.nombre} ({dep.codigo})
                  </option>
                ))}
              </select>
            </div>

            <div className="flex space-x-3">
              <button
                onClick={handleAsignar}
                disabled={asignando || !departamento}
                className="btn-primary flex-1 flex items-center justify-center space-x-2"
              >
                <UserCheck size={18} />
                <span>{asignando ? "Asignando..." : "Asignar"}</span>
              </button>
              <button
                onClick={() => {
                  setSelectedUser(null);
                  setDepartamento("");
                }}
                className="btn-secondary flex items-center space-x-2"
              >
                <UserX size={18} />
                <span>Cancelar</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
