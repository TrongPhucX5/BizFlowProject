// src/app/customers/layout.tsx
import { Sidebar } from "@/components/layout/sidebar";
import { Header } from "@/components/layout/header"; 

export default function CustomersLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex min-h-screen bg-slate-50">
      {/* Sidebar cố định bên trái */}
      <aside className="fixed inset-y-0 left-0 z-50 hidden w-64 border-r border-slate-200 bg-[#0f172a] md:block">
        <Sidebar />
      </aside>

      {/* Nội dung bên phải: Header + Page Content */}
      <div className="flex flex-1 flex-col md:pl-64">
        <Header />
        <main className="flex-1 overflow-y-auto">
          {children}
        </main>
      </div>
    </div>
  );
}