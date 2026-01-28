"use client";

import React from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import {
  Github,
  ListChecks,
  Zap,
  ShieldCheck,
  LineChart,
  MousePointerClick,
  ArrowRight,
  Store,
  CheckCircle2
} from "lucide-react";
import styles from "@/styles/about/page.module.css";
import ecoStyles from "@/styles/about/ecosystem.module.css";
import VideoNoFullscreen from "@/components/video-no-fullscreen";

const VIDEO_SRC = "/BizFlow.mp4";

export default function AboutPage() {
  const router = useRouter();

  const handleStartRegistration = () => {
    router.push("/auth/register");
  };

  return (
    <div className={`${styles.container} bg-[#0f172a] text-white min-h-screen selection:bg-blue-500/30`}>
      {/* 1. HERO SECTION - Điểm chạm đầu tiên */}
      <section className={`${styles.hero} relative overflow-hidden pt-20 pb-32`}>
        {/* Hiệu ứng đèn nền (Glow effect) */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-full h-full bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-blue-500/10 via-transparent to-transparent -z-10" />
        
        <div className={styles.heroLeft}>
          <Badge className="bg-blue-500/10 text-blue-400 border-blue-500/20 mb-6 px-4 py-1.5 text-sm rounded-full animate-fade-in">
            🚀 Hệ thống quản lý thế hệ mới v1.0.0
          </Badge>
          
          <h1 className="text-5xl md:text-7xl font-black text-white leading-[1.1] mb-8 tracking-tight">
            Vận hành <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-cyan-300">thông minh</span>,<br />
            Kinh doanh bứt phá.
          </h1>
          
          <p className="text-slate-400 text-xl leading-relaxed mb-10 max-w-xl">
            BizFlow hợp nhất POS, Kho hàng và CRM vào một nền tảng duy nhất. 
            Giúp bạn quản lý từ xa, chống thất thoát và tối ưu lợi nhuận hiệu quả.
          </p>

          <div className="flex flex-wrap gap-4 items-center">
            <Button 
              size="lg"
              onClick={handleStartRegistration}
              className="bg-blue-600 hover:bg-blue-700 text-white rounded-full px-8 h-14 text-lg font-bold shadow-lg shadow-blue-500/20 group transition-all"
            >
              Trải nghiệm miễn phí
              <ArrowRight className="ml-2 group-hover:translate-x-1 transition-transform" />
            </Button>
            
            <Button 
              variant="outline"
              size="lg"
              className="border-white/10 hover:bg-white/5 text-white rounded-full px-8 h-14 text-lg font-semibold"
              asChild
            >
              <Link href="https://github.com/" target="_blank">
                <Github className="mr-2" size={20} /> GitHub
              </Link>
            </Button>
          </div>
        </div>

        <div className={styles.rightMock}>
          <div className="relative p-2 bg-white/5 rounded-[2.5rem] border border-white/10 backdrop-blur-sm shadow-2xl overflow-hidden group">
            <VideoNoFullscreen
              src={VIDEO_SRC}
              poster="/images/about/hero.png"
              className="w-full h-full rounded-[2rem] object-cover transition-transform duration-700 group-hover:scale-[1.02]"
              autoPlay
              muted
              loop
              preload="metadata"
            />
          </div>
        </div>
      </section>

      {/* 2. THÁCH THỨC & RỦI RO - Phần đánh vào tâm lý người dùng */}
      <section className="py-32 bg-[#0a0f1a] relative">
        <div className="container mx-auto px-4 grid lg:grid-cols-2 gap-20 items-center">
          <div>
            <h4 className="text-blue-500 font-bold tracking-widest uppercase text-sm mb-6 flex items-center gap-2">
              <span className="w-8 h-[2px] bg-blue-500" /> Vấn đề cốt lõi
            </h4>
            <h2 className="text-4xl md:text-5xl font-extrabold text-white mb-8 leading-tight">
              Tại sao quản lý truyền thống <br />
              <span className="text-red-500">đang làm bạn lỗ vốn?</span>
            </h2>

            <div className="space-y-6">
              {[
                { icon: ListChecks, color: "text-red-400", bg: "bg-red-500/10", title: "Thất thoát không rõ nguyên nhân", desc: "Ghi chép thủ công khiến 5-10% doanh thu bị biến mất do sai sót." },
                { icon: Zap, color: "text-amber-400", bg: "bg-amber-500/10", title: "Quy trình rời rạc", desc: "Mất quá nhiều thời gian để đối soát giữa kho và hóa đơn bán hàng." },
                { icon: LineChart, color: "text-orange-400", bg: "bg-orange-500/10", title: "Quyết định dựa trên cảm tính", desc: "Không có dữ liệu báo cáo real-time dẫn đến nhập hàng sai thời điểm." }
              ].map((item, i) => (
                <div key={i} className="flex gap-5 p-4 rounded-2xl hover:bg-white/5 transition-all border border-transparent hover:border-white/5">
                  <div className={`p-3 ${item.bg} ${item.color} rounded-xl shrink-0`}>
                    <item.icon size={28} />
                  </div>
                  <div>
                    <h5 className="text-white font-bold text-lg mb-1">{item.title}</h5>
                    <p className="text-slate-400 leading-relaxed">{item.desc}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Widget cảnh báo rủi ro */}
          <div className="bg-white/5 backdrop-blur-2xl rounded-[3rem] p-10 border border-white/10 shadow-3xl relative overflow-hidden">
             <div className="absolute -bottom-10 -left-10 w-40 h-40 bg-red-500/10 blur-[80px]" />
             
             <div className="flex items-center justify-between mb-12">
                <div className="flex items-center gap-3">
                  <span className="relative flex h-3 w-3">
                    <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-500 opacity-75"></span>
                    <span className="relative inline-flex rounded-full h-3 w-3 bg-red-500"></span>
                  </span>
                  <span className="text-red-500 font-black text-xs tracking-widest uppercase">Cảnh báo vận hành</span>
                </div>
                <Badge variant="outline" className="text-slate-400 border-white/10 uppercase text-[10px]">Real-time Monitor</Badge>
             </div>

             <div className="space-y-10">
                <div className="space-y-4">
                  <div className="flex justify-between text-sm font-bold tracking-tight">
                    <span className="text-slate-300">Sai lệch tồn kho (Inventory Gap)</span>
                    <span className="text-red-500">+24.8%</span>
                  </div>
                  <div className="h-3 bg-white/5 rounded-full overflow-hidden">
                    <div className="h-full bg-gradient-to-r from-red-600 to-red-400 w-[85%] rounded-full shadow-[0_0_15px_rgba(239,68,68,0.5)]" />
                  </div>
                </div>

                <div className="space-y-4">
                  <div className="flex justify-between text-sm font-bold tracking-tight">
                    <span className="text-slate-300">Thất thoát doanh thu ẩn</span>
                    <span className="text-red-500">12,500,000đ</span>
                  </div>
                  <div className="h-3 bg-white/5 rounded-full overflow-hidden">
                    <div className="h-full bg-gradient-to-r from-orange-600 to-red-500 w-[65%] rounded-full shadow-[0_0_15px_rgba(249,115,22,0.4)]" />
                  </div>
                </div>
             </div>

             <div className="mt-12 pt-8 border-t border-white/5 flex items-center justify-between">
                <div className="text-xs text-slate-500 italic font-medium">Cần hành động ngay để tối ưu!</div>
                <CheckCircle2 size={20} className="text-slate-700" />
             </div>
          </div>
        </div>
      </section>

      {/* 3. GIẢI PHÁP - CORE SOLUTIONS */}
      <section className="py-32 container mx-auto px-4">
        <div className="text-center max-w-3xl mx-auto mb-20">
          <h4 className="text-green-400 font-bold tracking-[0.2em] uppercase text-sm mb-4">Giải pháp từ BizFlow</h4>
          <h2 className="text-4xl md:text-5xl font-black text-white mb-6">Đơn giản hóa mọi quy trình</h2>
          <p className="text-slate-400 text-lg">Chúng tôi cung cấp bộ công cụ mạnh mẽ để bạn quản lý cửa hàng nhẹ nhàng như đang đi du lịch.</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {[
            { icon: ShieldCheck, color: "text-green-400", title: "Số hóa chống thất thoát", desc: "Tự động đồng bộ đơn hàng và cập nhật tồn kho theo thời gian thực 24/7." },
            { icon: LineChart, color: "text-blue-400", title: "Báo cáo thông minh", desc: "Hệ thống tự động tổng hợp dữ liệu, dự báo xu hướng nhập hàng chính xác." },
            { icon: MousePointerClick, color: "text-purple-400", title: "Dễ dùng cho mọi người", desc: "Giao diện tinh gọn, không cần biết quá nhiều về công nghệ vẫn sử dụng tốt." }
          ].map((card, i) => (
            <Card key={i} className="bg-white/5 border-white/10 hover:bg-white/10 hover:-translate-y-2 transition-all duration-300 group overflow-hidden">
              <CardHeader className="pt-10">
                <card.icon className={`${card.color} mb-6 transition-transform group-hover:scale-110`} size={40} />
                <CardTitle className="text-white text-2xl font-bold">{card.title}</CardTitle>
              </CardHeader>
              <CardContent className="text-slate-400 text-lg leading-relaxed pb-10">
                {card.desc}
              </CardContent>
            </Card>
          ))}
        </div>
      </section>

      {/* 4. TEAM SECTION */}
      <section className="py-24 bg-white/5 backdrop-blur-md border-y border-white/5">
        <div className="container mx-auto px-4">
          <h2 className="text-3xl font-bold mb-16 text-white flex items-center gap-3">
            <Store size={32} className="text-blue-500" /> Đội ngũ phát triển dự án
          </h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {[
              { name: "Lê Trọng Phúc", role: "Product Owner", fb: "LP" },
              { name: "Như Nhât Anh", role: "Developer", fb: "NA" },
              { name: "Trần Ghi Đông", role: "Developer", fb: "GD" },
              { name: "Lâm Khiêm", role: "Developer", fb: "LK" },
              { name: "Nguyễn Quốc Bảo", role: "Developer", fb: "QB" },
              { name: "Phạm Minh Dũng", role: "Developer", fb: "MD" },
              { name: "Võ Minh Quân", role: "Developer", fb: "MQ" },
            ].map((member, index) => (
              <div key={index} className="flex items-center gap-4 p-4 rounded-2xl bg-[#0f172a] border border-white/5 hover:border-blue-500/30 transition-all">
                <Avatar className="h-12 w-12 border border-white/10">
                  <AvatarFallback className="bg-gradient-to-br from-blue-600 to-indigo-600 text-white font-bold">
                    {member.fb}
                  </AvatarFallback>
                </Avatar>
                <div>
                  <div className="font-bold text-white">{member.name}</div>
                  <div className="text-xs text-slate-500 uppercase font-bold tracking-tighter italic">{member.role}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* 5. CTA FOOTER - Chốt hạ */}
      <section className="py-40 text-center relative overflow-hidden">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-blue-600/10 blur-[120px] -z-10" />
        
        <h3 className="text-4xl md:text-6xl font-black mb-8 text-white tracking-tight">
          Sẵn sàng để số hóa <br /> cửa hàng của bạn?
        </h3>
        <p className="text-slate-400 mb-12 max-w-2xl mx-auto text-xl font-medium px-4">
          Tham gia cùng hàng trăm hộ kinh doanh đã chuyển đổi số thành công cùng BizFlow. 
          Đăng ký ngay, không cần thẻ tín dụng.
        </p>
        
        <div className="flex flex-col sm:flex-row items-center justify-center gap-6 px-4">
          <Button 
            size="lg" 
            onClick={handleStartRegistration}
            className="bg-blue-600 hover:bg-blue-700 text-white px-12 h-16 rounded-full shadow-[0_0_40px_rgba(37,99,235,0.4)] transition-all font-black text-xl w-full sm:w-auto"
          >
            Bắt đầu ngay bây giờ
            <ArrowRight className="ml-2" size={24} />
          </Button>

          <Button size="lg" variant="ghost" className="text-slate-300 hover:text-white hover:bg-white/10 h-16 px-10 rounded-full font-bold text-lg w-full sm:w-auto" asChild>
            <Link href="https://github.com/" target="_blank">Tìm hiểu thêm</Link>
          </Button>
        </div>
      </section>

      {/* Footer nhỏ */}
      <footer className="py-10 border-t border-white/5 text-center text-slate-600 text-sm">
        © 2024 BizFlow. All rights reserved. Phát triển bởi đội ngũ đam mê công nghệ.
      </footer>
    </div>
  );
}