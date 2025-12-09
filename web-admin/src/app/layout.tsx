import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import QueryProvider from "@/providers/query-provider";
import { Sidebar } from "@/components/layout/sidebar"; // Import Sidebar
import { Header } from "@/components/layout/header"; // Import Header

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "BizFlow Admin",
  description: "Hệ thống quản lý BizFlow",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="vi">
      <body className={`${inter.className} bg-slate-50`}>
        <QueryProvider>
          <div className="flex min-h-screen">
            {/* Sidebar cố định bên trái */}
            <Sidebar />

            {/* Khu vực nội dung chính bên phải */}
            <div className="flex-1 ml-64 flex flex-col">
              <Header />
              <main className="flex-1 p-6 overflow-auto">{children}</main>
            </div>
          </div>
        </QueryProvider>
      </body>
    </html>
  );
}
