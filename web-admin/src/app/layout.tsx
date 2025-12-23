import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import QueryProvider from "@/providers/query-provider";

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
        {children}
      </QueryProvider>
      </body>
      </html>
  );
}