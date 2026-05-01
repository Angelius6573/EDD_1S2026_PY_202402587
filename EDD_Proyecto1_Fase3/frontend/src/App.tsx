import {
  BrowserRouter as Router,
  Navigate,
  Route,
  Routes,
} from "react-router-dom";
import { Toaster } from "react-hot-toast";
import { AuthProvider } from "../hooks/useAuth";
import PrivateRoute from "./components/PrivateRoute";
import Layout from "./components/Layout";
import Login from "./pages/Login";
import AdminDashboard from "./pages/admin/Dashboard";
import PendingUsers from "./pages/admin/PendingUsers";
import AdminRequests from "./pages/admin/Requests";
import AdminReports from "./pages/admin/Reports";
import UserDashboard from "./pages/user/Dashboard";
import UserProfile from "./pages/user/Profile";
import Inventory from "./pages/user/Inventory";
import Collaboration from "./pages/user/Collaboration";
import Chat from "./pages/user/Chat";
import History from "./pages/user/History";

function App() {
  return (
    <Router>
      <AuthProvider>
        <Toaster position="top-right" />
        <Routes>
          <Route path="/login" element={<Login />} />

          {/* Admin Routes */}
          <Route
            path="/admin"
            element={
              <PrivateRoute allowedTypes={["ADMIN"]}>
                <Layout />
              </PrivateRoute>
            }
          >
            <Route index element={<AdminDashboard />} />
            <Route path="usuarios-pendientes" element={<PendingUsers />} />
            <Route path="solicitudes" element={<AdminRequests />} />
            <Route path="reportes" element={<AdminReports />} />
          </Route>

          {/* User Routes */}
          <Route
            path="/user"
            element={
              <PrivateRoute
                allowedTypes={["TIPO-01", "TIPO-02", "TIPO-03", "TIPO-04"]}
              >
                <Layout />
              </PrivateRoute>
            }
          >
            <Route index element={<UserDashboard />} />
            <Route path="perfil" element={<UserProfile />} />
            <Route path="inventario" element={<Inventory />} />
            <Route path="colaboracion" element={<Collaboration />} />
            <Route path="chat" element={<Chat />} />
            <Route path="historial" element={<History />} />
          </Route>

          <Route path="/" element={<Navigate to="/login" />} />
        </Routes>
      </AuthProvider>
    </Router>
  );
}

export default App;
