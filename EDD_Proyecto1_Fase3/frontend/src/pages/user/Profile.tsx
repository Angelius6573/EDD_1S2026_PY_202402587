import { useEffect, useState } from "react";
import { useAuth } from "../../../hooks/useAuth";
import { api } from "../../../services/api";
import toast from "react-hot-toast";
import { Key, Save, UserCircle } from "lucide-react";

export default function UserProfile() {
  const { user, login } = useAuth();
  const [nombre, setNombre] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (user) {
      setNombre(user.nombre || "");
    }
  }, [user]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (password && password !== confirmPassword) {
      toast.error("Las contraseñas no coinciden");
      return;
    }

    setLoading(true);
    try {
      const data: { nombre?: string; password?: string } = {};
      if (nombre !== user?.nombre) {
        data.nombre = nombre;
      }
      if (password) {
        data.password = password;
      }

      if (Object.keys(data).length > 0) {
        const response = await api.actualizarPerfil(data);
        if (response.success && response.perfil) {
          await login(user!.colegio, password || user!.contrasena || "");
          toast.success("Perfil actualizado correctamente");
          setPassword("");
          setConfirmPassword("");
        }
      } else {
        toast("No se realizaron cambios", { icon: "ℹ️" });
      }
    } catch (error) {
      toast.error("Error al actualizar perfil");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto">
      <h1 className="text-2xl font-bold text-gray-900 mb-6">Mi Perfil</h1>

      <div className="bg-white rounded-xl shadow-md overflow-hidden">
        <div className="bg-gradient-to-r from-primary-500 to-primary-600 px-6 py-8">
          <div className="flex items-center space-x-4">
            <div className="bg-white p-3 rounded-full">
              <UserCircle className="h-12 w-12 text-primary-600" />
            </div>
            <div>
              <h2 className="text-xl font-bold text-white">{user?.nombre}</h2>
              <p className="text-primary-100">{user?.colegio}</p>
            </div>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-6">
          <div>
            <label className="label">Número de Colegio</label>
            <input
              type="text"
              value={user?.colegio || ""}
              disabled
              className="input bg-gray-100 cursor-not-allowed"
            />
            <p className="text-xs text-gray-500 mt-1">
              El número de colegio no puede modificarse
            </p>
          </div>

          <div>
            <label className="label">Nombre Completo</label>
            <input
              type="text"
              value={nombre}
              onChange={(e) => setNombre(e.target.value)}
              className="input"
              placeholder="Ingrese su nombre completo"
            />
          </div>

          <div>
            <label className="label">Tipo de Usuario</label>
            <input
              type="text"
              value={user?.tipo || ""}
              disabled
              className="input bg-gray-100 cursor-not-allowed"
            />
          </div>

          <div>
            <label className="label">Departamento</label>
            <input
              type="text"
              value={user?.departamento || "Sin asignar"}
              disabled
              className="input bg-gray-100 cursor-not-allowed"
            />
          </div>

          <div>
            <label className="label">Especialidad</label>
            <input
              type="text"
              value={user?.especialidad || "No especificada"}
              disabled
              className="input bg-gray-100 cursor-not-allowed"
            />
          </div>

          <div className="border-t border-gray-200 pt-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
              <Key className="h-5 w-5 mr-2 text-gray-500" />
              Cambiar Contraseña
            </h3>

            <div className="space-y-4">
              <div>
                <label className="label">Nueva Contraseña</label>
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="input"
                  placeholder="Ingrese nueva contraseña"
                />
              </div>

              <div>
                <label className="label">Confirmar Contraseña</label>
                <input
                  type="password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  className="input"
                  placeholder="Confirme la nueva contraseña"
                />
              </div>
            </div>
          </div>

          <div className="flex justify-end">
            <button
              type="submit"
              disabled={loading}
              className="btn-primary flex items-center space-x-2"
            >
              <Save size={18} />
              <span>{loading ? "Guardando..." : "Guardar Cambios"}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
