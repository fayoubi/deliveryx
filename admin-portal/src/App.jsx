import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import StoresList from './pages/StoresList';
import StoreDetails from './pages/StoreDetails';

function App() {
  return (
    <BrowserRouter basename="/admin">
      <div className="min-h-screen bg-gray-50">
        {/* Toast Notifications */}
        <Toaster
          position="top-right"
          toastOptions={{
            duration: 4000,
            style: {
              background: '#fff',
              color: '#1a1a1a',
              borderRadius: '0.75rem',
              boxShadow: '0 4px 12px rgba(0, 0, 0, 0.15)',
            },
            success: {
              iconTheme: {
                primary: '#06C167',
                secondary: '#fff',
              },
            },
            error: {
              iconTheme: {
                primary: '#DC2626',
                secondary: '#fff',
              },
            },
          }}
        />

        {/* Main Content */}
        <Routes>
          <Route path="/" element={<Navigate to="/stores" replace />} />
          <Route path="/stores" element={<StoresList />} />
          <Route path="/stores/:storeId" element={<StoreDetails />} />
        </Routes>
      </div>
    </BrowserRouter>
  );
}

export default App;
