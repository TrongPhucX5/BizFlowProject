import { Sidebar } from "@/components/layout/sidebar";
import { AiChatBox } from "@/components/ai-chat-box";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex min-h-screen bg-[#F8F9FC]">
      <Sidebar />

      <div className="flex-1 ml-64 flex flex-col transition-all duration-300">
        {/* ❌ ĐÃ XÓA DÒNG <Header /> Ở ĐÂY */}

        {/* Main content area */}
        <main className="flex-1 p-8 overflow-y-auto relative">
          {children}
          <AiChatBox />
        </main>
      </div>
    </div>
  );
}
