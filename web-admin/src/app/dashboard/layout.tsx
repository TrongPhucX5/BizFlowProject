import { Sidebar } from "@/components/layout/sidebar";
import { Header } from "@/components/layout/header";
import { AiChatBox } from "@/components/ai-chat-box"; // <--- Import vào

export default function DashboardLayout({
                                            children,
                                        }: {
    children: React.ReactNode;
}) {
    return (
        <div className="flex min-h-screen">
            <Sidebar />
            <div className="flex-1 ml-64 flex flex-col">
                <Header />
                <main className="flex-1 p-6 overflow-auto bg-slate-50 relative">
                    {children}

                    {/* Đặt Chat Box ở đây */}
                    <AiChatBox />
                </main>
            </div>
        </div>
    );
}