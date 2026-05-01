import { Navigate } from "react-router-dom";
import { useAuth } from "../../hooks/useAuth";

interface PrivateRouteProps {
  children: React.ReactNode;
  allowedTypes?: string[];
}

export default function PrivateRoute(
  { children, allowedTypes }: PrivateRouteProps,
) {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto">
          </div>
          <p className="mt-4 text-gray-600">Cargando...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/login" />;
  }

  if (allowedTypes && !allowedTypes.includes(user.tipo)) {
    // Redirigir según el tipo
    if (user.tipo === "ADMIN") {
      return <Navigate to="/admin" />;
    }
    return <Navigate to="/user" />;
  }

  return <>{children}</>;
}
