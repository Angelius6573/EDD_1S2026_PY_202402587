import { useState } from "react";
import { useNavigate } from "react-router-dom";
import toast from "react-hot-toast";
import { useAuth } from "../../hooks/useAuth";
import { Activity } from "lucide-react";

export default function Login() {
  const [colegio, setColegio] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const user = await login(colegio, password);
      if (user.tipo === "ADMIN") {
        navigate("/admin");
      } else {
        navigate("/user");
      }
      toast.success(`Bienvenido, ${user.nombre}`);
    } catch (error: any) {
      toast.error(error.message || "Error al iniciar sesión");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-primary-100 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8 bg-white rounded-2xl shadow-xl p-8">
        <div className="text-center">
          <div className="mx-auto h-16 w-16 bg-primary-600 rounded-2xl flex items-center justify-center">
            <Activity className="h-8 w-8 text-white" />
          </div>
          <h2 className="mt-6 text-3xl font-extrabold text-gray-900">
            EDD MedTrack
          </h2>
          <p className="mt-2 text-sm text-gray-600">
            Sistema de Gestión Hospitalaria
          </p>
        </div>

        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          <div className="space-y-4">
            <div>
              <label htmlFor="colegio" className="label">
                Número de Colegio
              </label>
              <input
                id="colegio"
                type="text"
                required
                value={colegio}
                onChange={(e) => setColegio(e.target.value)}
                className="input"
                placeholder="Ej: COL-10245"
              />
            </div>

            <div>
              <label htmlFor="password" className="label">
                Contraseña
              </label>
              <input
                id="password"
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="input"
                placeholder="••••••"
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="btn-primary w-full disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? "Iniciando sesión..." : "Iniciar Sesión"}
          </button>

          <div className="text-center text-xs text-gray-500">
            <p>Administrador: AdminHospital / MedTrack2026</p>
            <p className="mt-1">Usuarios regulares usar sus credenciales</p>
          </div>
        </form>
      </div>
    </div>
  );
}
