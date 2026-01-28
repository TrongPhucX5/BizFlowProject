"use client";

import React, { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  Github,
  ListChecks,
  Zap,
  Headphones,
  ShieldCheck,
  LineChart,
  MousePointerClick,
  User,
  Mail,
  Store,
  ArrowRight
} from "lucide-react";
import styles from "@/styles/about/page.module.css";
import ecoStyles from "@/styles/about/ecosystem.module.css";
import VideoNoFullscreen from "@/components/video-no-fullscreen";

const VIDEO_SRC = "/BizFlow.mp4";

export default function AboutPage() {
  const router = useRouter();
  const [isOpen, setIsOpen] = useState(false);
  
  // State quản lý thông tin đăng ký
  const [formData, setFormData] = useState({
    fullName: "",
    email: "",
    storeName: ""
  });

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  // Hàm xử lý lưu thông tin và chuyển hướng
  const handleFinalRegister = (e: React.FormEvent) => {
    e.preventDefault();
    
    // Lưu tất cả thông tin vào localStorage để Sidebar/Profile sử dụng
    localStorage.setItem("userFullName", formData.fullName);
    localStorage.setItem("userEmail", formData.email);
    localStorage.setItem("storeName", formData.storeName);
    localStorage.setItem("userRole", "Chủ cửa hàng");
    
    setIsOpen(false);
    // Chuyển hướng sang dashboard
    router.push("/dashboard");
  };

  return (
    <div className={styles.container}>
      {/* 1. HERO SECTION */}
      <section className={styles.hero}>
        <div className={styles.heroLeft}>
          <h1 className={styles.title}>
            BizFlow — Quản lý cửa hàng thông minh
          </h1>
          <p className={styles.lead}>
            Giải pháp POS + Inventory + CRM giúp chủ cửa hàng tự động hoá tác vụ
            hàng ngày, tối ưu tồn kho và chăm sóc khách hàng bằng các tính năng
            thông minh.
          </p>

          <div className={styles.ctaRow}>
            <Badge variant="outline" className="border-green-500/50 text-green-500">
              v1.0.0
            </Badge>

            <Button variant="outline" className={styles.btnPrimary} asChild>
              <Link href="https://github.com/" target="_blank" rel="noopener noreferrer">
                <Github size={16} /> Mã nguồn
              </Link>
            </Button>
          </div>
        </div>

        <div className={styles.rightMock}>
          <VideoNoFullscreen
            src={VIDEO_SRC}
            poster="/images/about/hero.png"
            className="w-full h-full rounded-2xl"
            autoPlay
            muted
            loop
            preload="metadata"
          />
        </div>
      </section>

      {/* 2. THÁCH THỨC */}
      <section className={ecoStyles.ecosystemSection}>
        <div className={ecoStyles.content}>
          <h4 className={ecoStyles.subTitle}>VẤN ĐỀ CỦA DOANH NGHIỆP</h4>
          <h2 className={ecoStyles.mainTitle}>
            Hộ kinh doanh truyền thống <br /> đang đối mặt với hàng loạt vấn đề
          </h2>

          <div className={ecoStyles.featureList}>
            <div className={ecoStyles.featureItem}>
              <div className={ecoStyles.iconWrapper}>
                <ListChecks className="text-red-500" size={20} />
              </div>
              <div className={ecoStyles.featureText}>
                <h5>Ghi chép thủ công & Quản lý rối rắm</h5>
                <p>Lạm dụng sổ sách và Excel khiến việc quản lý công nợ trở nên phức tạp.</p>
              </div>
            </div>
            <div className={ecoStyles.featureItem}>
              <div className={ecoStyles.iconWrapper}>
                <Zap className="text-amber-500" size={20} />
              </div>
              <div className={ecoStyles.featureText}>
                <h5>Thiếu báo cáo & Rủi ro pháp lý</h5>
                <p>Không đáp ứng được các yêu cầu khắt khe về kế toán và thuế.</p>
              </div>
            </div>
          </div>
        </div>

        <div className={ecoStyles.mockupContainer}>
          <div className={ecoStyles.visualCard} style={{ border: "1px solid rgba(239, 68, 68, 0.2)" }}>
            <div className="p-8">
              <div className="text-red-500 text-xs font-bold mb-4 flex items-center gap-2">
                <span className="relative flex h-2 w-2">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                  <span className="relative inline-flex rounded-full h-2 w-2 bg-red-500"></span>
                </span>
                CẢNH BÁO RỦI RO VẬN HÀNH
              </div>
              <div className="bg-red-500/5 rounded-xl border border-red-500/10 p-4">
                <div className="flex justify-between items-center mb-2">
                  <span className="text-gray-400 text-xs">Sai lệch tồn kho</span>
                  <span className="text-red-400 text-xs">+24%</span>
                </div>
                <div className="w-full h-1.5 bg-white/5 rounded-full overflow-hidden">
                  <div className="bg-red-500 w-[85%] h-full" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 3. CORE SOLUTIONS */}
      <section className="py-20">
        <div className="text-center mb-16">
          <h4 className="text-green-500 font-bold tracking-[0.2em] uppercase text-sm mb-4">LỜI GIẢI TỪ BIZFLOW</h4>
          <h2 className="text-3xl md:text-4xl font-bold text-white mb-6">Hệ sinh thái giải quyết triệt để rào cản</h2>
        </div>

        <div className={styles.features}>
          <Card className="bg-white/5 border-white/10 hover:border-green-500/50 transition-all duration-300">
            <CardHeader>
              <ShieldCheck className="text-green-500 mb-4" size={26} />
              <CardTitle className="text-white">Số hóa chống thất thoát</CardTitle>
            </CardHeader>
            <CardContent className="text-slate-400">Tự động đồng bộ đơn hàng và cập nhật tồn kho theo thời gian thực.</CardContent>
          </Card>

          <Card className="bg-white/5 border-white/10 hover:border-blue-500/50 transition-all duration-300">
            <CardHeader>
              <LineChart className="text-blue-500 mb-4" size={26} />
              <CardTitle className="text-white">Báo cáo chuẩn pháp lý</CardTitle>
            </CardHeader>
            <CardContent className="text-slate-400">Tự động tổng hợp dữ liệu kinh doanh thành báo cáo chuẩn quy định.</CardContent>
          </Card>

          <Card className="bg-white/5 border-white/10 hover:border-purple-500/50 transition-all duration-300">
            <CardHeader>
              <MousePointerClick className="text-purple-500 mb-4" size={26} />
              <CardTitle className="text-white">Công nghệ cho mọi người</CardTitle>
            </CardHeader>
            <CardContent className="text-slate-400">Giao diện cực kỳ đơn giản, tối ưu cho cả điện thoại và máy tính.</CardContent>
          </Card>
        </div>
      </section>

      {/* 4. TEAM SECTION */}
      <section className="bg-white/5 rounded-2xl border border-white/10 p-8 my-12">
        <h2 className="text-2xl font-semibold mb-8 text-white">Đội ngũ phát triển</h2>
        <div className={styles.teamGrid}>
          {[
            { name: "Lê Trọng Phúc", role: "Product Owner", fallback: "LP" },
            { name: "Nguyễn Thanh", role: "Frontend", fallback: "NT" },
            { name: "Phạm Tùng", role: "Backend", fallback: "PT" },
          ].map((member, index) => (
            <div key={index} className={styles.teamItem}>
              <Avatar className="h-12 w-12 border border-white/10">
                <AvatarFallback className="bg-green-500/20 text-green-500">{member.fallback}</AvatarFallback>
              </Avatar>
              <div>
                <div className="font-medium text-white">{member.name}</div>
                <div className="text-sm text-slate-400">{member.role}</div>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* 6. CTA FOOTER - NÚT ĐĂNG KÝ VỚI FORM ĐẦY ĐỦ */}
      <section className="text-center py-16">
        <h3 className="text-2xl font-bold mb-3 text-white">Muốn dùng thử hoặc đóng góp?</h3>
        <p className="text-slate-400 mb-8 max-w-md mx-auto">
          Khởi tạo hệ thống quản lý demo của riêng bạn chỉ trong vài giây.
        </p>
        
        <div className="flex items-center justify-center gap-4">
          <Dialog open={isOpen} onOpenChange={setIsOpen}>
            <DialogTrigger asChild>
              <Button size="lg" className="bg-blue-600 hover:bg-blue-700 px-8 rounded-full shadow-lg shadow-blue-500/20">
                Đăng ký Demo
              </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[400px] bg-[#0f172a] border-white/10 text-white shadow-2xl">
              <DialogHeader>
                <DialogTitle className="text-xl">Thông tin Demo</DialogTitle>
                <DialogDescription className="text-slate-400">
                  Vui lòng cung cấp thông tin để cá nhân hóa cửa hàng của bạn.
                </DialogDescription>
              </DialogHeader>
              
              <form onSubmit={handleFinalRegister} className="space-y-4 py-4">
                {/* Họ tên */}
                <div className="relative">
                  <User className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500" size={18} />
                  <Input
                    name="fullName"
                    placeholder="Họ và tên của bạn..."
                    className="pl-10 bg-white/5 border-white/10 focus:border-blue-500 h-12 text-white"
                    value={formData.fullName}
                    onChange={handleInputChange}
                    required
                  />
                </div>

                {/* Email */}
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500" size={18} />
                  <Input
                    name="email"
                    type="email"
                    placeholder="Địa chỉ Email..."
                    className="pl-10 bg-white/5 border-white/10 focus:border-blue-500 h-12 text-white"
                    value={formData.email}
                    onChange={handleInputChange}
                    required
                  />
                </div>

                {/* Tên cửa hàng */}
                <div className="relative">
                  <Store className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500" size={18} />
                  <Input
                    name="storeName"
                    placeholder="Tên cửa hàng / Doanh nghiệp..."
                    className="pl-10 bg-white/5 border-white/10 focus:border-blue-500 h-12 text-white"
                    value={formData.storeName}
                    onChange={handleInputChange}
                    required
                  />
                </div>

                <Button type="submit" className="w-full bg-blue-600 hover:bg-blue-700 h-12 text-lg font-medium group mt-2">
                  Bắt đầu ngay <ArrowRight className="ml-2 group-hover:translate-x-1 transition-transform" size={18} />
                </Button>
              </form>
            </DialogContent>
          </Dialog>

          <Button size="lg" variant="outline" className="border-white/10 text-white hover:bg-white/5 rounded-full" asChild>
            <Link href="https://github.com/" target="_blank">GitHub</Link>
          </Button>
        </div>
      </section>
    </div>
  );
}