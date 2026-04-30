import { Link, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../../hooks/useAuth";
import {
  BarChart3,
  Clipboard,
  ClipboardList,
  LayoutDashboard,
  LogOut,
  MessageCircle,
  Package,
  ShoppingCart,
  Upload,
  UserCircle,
  Users,
} from "lucide-react";

export default function Navbar() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const isAdmin = user?.tipo === "ADMIN";

  const handleLogout = async () => {
    await logout();
    navigate("/login");
  };

  const adminLinks = [
    { path: "/admin", icon: LayoutDashboard, label: "Dashboard" },
    {
      path: "/admin/usuarios-pendientes",
      icon: Users,
      label: "Usuarios Pendientes",
    },
    { path: "/admin/solicitudes", icon: ShoppingCart, label: "Solicitudes" },
    { path: "/admin/reportes", icon: BarChart3, label: "Reportes" },
    { path: "/admin/carga-masiva", icon: Upload, label: "Carga Masiva" },
    { path: "/admin/inventario", icon: Package, label: "Inventario" },
    {
      path: "/admin/cargar-relaciones",
      icon: Users,
      label: "Cargar Relaciones",
    },
  ];

  const userLinks = [
    { path: "/user", icon: LayoutDashboard, label: "Dashboard" },
    { path: "/user/perfil", icon: UserCircle, label: "Mi Perfil" },
    { path: "/user/inventario", icon: Package, label: "Inventario" },
    { path: "/user/colaboracion", icon: Users, label: "Colaboración" },
    { path: "/user/chat", icon: MessageCircle, label: "Chat" },
    { path: "/user/historial", icon: ClipboardList, label: "Historial" },
    { path: "/user/solicitar", icon: Clipboard, label: "Solicitar Insumo" },
  ];

  const links = isAdmin ? adminLinks : userLinks;

  return (
    <nav className="bg-white shadow-md">
      <div className="container mx-auto px-4">
        <div className="flex justify-between items-center h-16">
          <div className="flex items-center space-x-8">
            <Link
              to={isAdmin ? "/admin" : "/user"}
              className="flex items-center space-x-2"
            >
              <div className="w-8 h-8 bg-primary-600 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-lg">E</span>
              </div>
              <span className="font-bold text-xl text-gray-800">
                EDD MedTrack
              </span>
            </Link>

            <div className="hidden md:flex space-x-4">
              {links.map((link) => {
                const Icon = link.icon;
                const isActive = location.pathname === link.path;
                return (
                  <Link
                    key={link.path}
                    to={link.path}
                    className={`flex items-center space-x-2 px-3 py-2 rounded-lg transition-colors ${
                      isActive
                        ? "bg-primary-50 text-primary-700"
                        : "text-gray-600 hover:bg-gray-100"
                    }`}
                  >
                    <Icon size={18} />
                    <span>{link.label}</span>
                  </Link>
                );
              })}
            </div>
          </div>

          <div className="flex items-center space-x-4">
            <div className="text-right hidden sm:block">
              <p className="text-sm font-medium text-gray-900">
                {user?.nombre}
              </p>
              <p className="text-xs text-gray-500">{user?.colegio}</p>
            </div>
            <button
              onClick={handleLogout}
              className="flex items-center space-x-2 px-3 py-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
            >
              <LogOut size={18} />
              <span className="hidden sm:inline">Salir</span>
            </button>
          </div>
        </div>
      </div>
    </nav>
  );
}
