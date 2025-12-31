import type { Metadata } from "next";
import Link from "next/link";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import {
  Github,
  ListChecks,
  Zap,
  Headphones,
  LayoutDashboard,
  Send,
  BarChart3,
  ShieldCheck,
  LineChart,
  MousePointerClick,
} from "lucide-react";
import styles from "@/styles/about/page.module.css";
import ecoStyles from "@/styles/about/ecosystem.module.css";
import VideoNoFullscreen from "@/components/video-no-fullscreen";

const VIDEO_SRC = "/BizFlow.mp4";

export const metadata: Metadata = {
  title: "Giới thiệu - BizFlow",
  description: "Giới thiệu dự án BizFlow — giải pháp quản lý cửa hàng",
  openGraph: {
    title: "BizFlow — Quản lý cửa hàng thông minh",
    description:
      "Giải pháp POS + Inventory + CRM giúp tối ưu tồn kho và tự động hóa bán hàng.",
    images: ["/images/about/og-image.png"],
  },
};

export default function AboutPage() {
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
            <Badge
              variant="outline"
              className="border-green-500/50 text-green-500"
            >
              v1.0.0
            </Badge>

            <Button className={styles.btnPrimary} asChild>
              <Link href="/auth/register">Dùng thử miễn phí</Link>
            </Button>

            <Button variant="outline" className={styles.btnPrimary} asChild>
              <Link
                href="https://github.com/"
                target="_blank"
                rel="noopener noreferrer"
              >
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

      {/* 2. THÁCH THỨC CỦA HỘ KINH DOANH TRUYỀN THỐNG */}
      <section className={ecoStyles.ecosystemSection}>
        <div className={ecoStyles.content}>
          <h4 className={ecoStyles.subTitle}>VẤN ĐỀ CỦA DOANH NGHIỆP</h4>
          <h2 className={ecoStyles.mainTitle}>
            Hộ kinh doanh truyền thống <br /> đang đối mặt với hàng loạt vấn đề
          </h2>

          <div className={ecoStyles.featureList}>
            {/* Vấn đề 1: Vận hành thủ công */}
            <div className={ecoStyles.featureItem}>
              <div className={ecoStyles.iconWrapper}>
                <ListChecks className="text-red-500" size={20} />
              </div>
              <div className={ecoStyles.featureText}>
                <h5>Ghi chép thủ công & Quản lý rối rắm</h5>
                <p>
                  Lạm dụng sổ sách và Excel khiến việc quản lý công nợ trở nên
                  phức tạp, dễ sai sót và không thể kiểm soát chính xác lượng
                  tồn kho thực tế.
                </p>
              </div>
            </div>

            {/* Vấn đề 2: Kế toán và Thuế */}
            <div className={ecoStyles.featureItem}>
              <div className={ecoStyles.iconWrapper}>
                <Zap className="text-amber-500" size={20} />
              </div>
              <div className={ecoStyles.featureText}>
                <h5>Thiếu báo cáo & Rủi ro pháp lý</h5>
                <p>
                  Thiếu hệ thống báo cáo kinh doanh kịp thời, không đáp ứng được
                  các yêu cầu khắt khe về kế toán và thuế theo quy định mới của
                  nhà nước.
                </p>
              </div>
            </div>

            {/* Vấn đề 3: Công nghệ và Chi phí */}
            <div className={ecoStyles.featureItem}>
              <div className={ecoStyles.iconWrapper}>
                <Headphones className="text-blue-500" size={20} />
              </div>
              <div className={ecoStyles.featureText}>
                <h5>Rào cản công nghệ & Chi phí lớn</h5>
                <p>
                  Chi phí chuyển đổi số quá cao trong khi trình độ tiếp cận công
                  nghệ còn hạn chế, khiến hoạt động kinh doanh kém hiệu quả và
                  khó mở rộng dài hạn.
                </p>
              </div>
            </div>
          </div>

          {/* Footer: Kết luận về hệ quả */}
          <div className={ecoStyles.footerIcons}>
            <div className={ecoStyles.footerIconItem}>
              <span className="w-2 h-2 rounded-full bg-red-500 animate-pulse" />
              Kinh doanh kém hiệu quả
            </div>
            <div className={ecoStyles.footerIconItem}>
              <span className="w-2 h-2 rounded-full bg-red-500 animate-pulse" />
              Rủi ro thất thoát cao
            </div>
            <div className={ecoStyles.footerIconItem}>
              <span className="w-2 h-2 rounded-full bg-red-500 animate-pulse" />
              Khó khăn trong mở rộng
            </div>
          </div>
        </div>

        {/* Phần Mockup Visual - Hiển thị trạng thái "Báo động" */}
        <div className={ecoStyles.mockupContainer}>
          <div
            className={ecoStyles.visualCard}
            style={{ border: "1px solid rgba(239, 68, 68, 0.2)" }}
          >
            <div className="p-4 border-b border-white/5 bg-red-500/5 flex gap-2">
              <div className="w-3 h-3 rounded-full bg-red-500" />
              <div className="w-3 h-3 rounded-full bg-red-500/50" />
              <div className="w-3 h-3 rounded-full bg-red-500/20" />
            </div>
            <div className="p-8">
              <div className="text-red-500 text-xs font-bold mb-4 flex items-center gap-2">
                <span className="relative flex h-2 w-2">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                  <span className="relative inline-flex rounded-full h-2 w-2 bg-red-500"></span>
                </span>
                CẢNH BÁO RỦI RO VẬN HÀNH
              </div>
              <div className="grid grid-cols-1 gap-4">
                <div className="bg-red-500/5 rounded-xl border border-red-500/10 p-4">
                  <div className="flex justify-between items-center mb-2">
                    <span className="text-gray-400 text-xs uppercase">
                      Sai lệch tồn kho
                    </span>
                    <span className="text-red-400 text-xs">+24%</span>
                  </div>
                  <div className="w-full h-1.5 bg-white/5 rounded-full overflow-hidden">
                    <div className="bg-red-500 w-[85%] h-full" />
                  </div>
                </div>
                <div className="bg-amber-500/5 rounded-xl border border-amber-500/10 p-4">
                  <div className="flex justify-between items-center mb-2">
                    <span className="text-gray-400 text-xs uppercase">
                      Công nợ quá hạn
                    </span>
                    <span className="text-amber-400 text-xs">Tăng cao</span>
                  </div>
                  <div className="w-full h-1.5 bg-white/5 rounded-full overflow-hidden">
                    <div className="bg-amber-500 w-[60%] h-full" />
                  </div>
                </div>
              </div>
              <div className="mt-8 pt-6 border-t border-white/5 space-y-3">
                <div className="w-full h-2 bg-white/5 rounded" />
                <div className="w-2/3 h-2 bg-white/5 rounded" />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 3. CORE SOLUTIONS SECTION - GIẢI PHÁP CHO HỘ KINH DOANH */}
      <section className="py-20" aria-label="solutions">
        <div className="text-center mb-16">
          <h4 className="text-green-500 font-bold tracking-[0.2em] uppercase text-sm mb-4">
            LỜI GIẢI TỪ BIZFLOW
          </h4>
          <h2 className="text-3xl md:text-4xl font-bold text-white mb-6">
            Hệ sinh thái giải quyết triệt để <br /> rào cản vận hành
          </h2>
          <p className="text-slate-400 max-w-2xl mx-auto">
            Chúng tôi thay thế sự rối rắm của mô hình truyền thống bằng quy
            trình số hóa tinh gọn, dễ tiếp cận và minh bạch.
          </p>
        </div>

        <div className={styles.features}>
          {/* Giải pháp 1: Chống sai sót & Thất thoát */}
          <Card className="bg-white/5 border-white/10 hover:border-green-500/50 transition-all duration-300 group">
            <CardHeader>
              <div className="w-12 h-12 bg-green-500/10 rounded-xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                <ShieldCheck className="text-green-500" size={26} />
              </div>
              <CardTitle className="text-xl text-white">
                Số hóa chống thất thoát
              </CardTitle>
            </CardHeader>
            <CardContent className="text-slate-400 leading-relaxed">
              Thay thế hoàn toàn sổ sách tay. Hệ thống tự động đồng bộ đơn hàng,
              cập nhật tồn kho theo thời gian thực và quản lý công nợ chặt chẽ,
              loại bỏ 99% sai sót do con người.
            </CardContent>
          </Card>

          {/* Giải pháp 2: Minh bạch Thuế & Kế toán */}
          <Card className="bg-white/5 border-white/10 hover:border-blue-500/50 transition-all duration-300 group">
            <CardHeader>
              <div className="w-12 h-12 bg-blue-500/10 rounded-xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                <LineChart className="text-blue-500" size={26} />
              </div>
              <CardTitle className="text-xl text-white">
                Báo cáo chuẩn pháp lý
              </CardTitle>
            </CardHeader>
            <CardContent className="text-slate-400 leading-relaxed">
              Tự động tổng hợp dữ liệu kinh doanh thành các biểu đồ và báo cáo
              chuẩn quy định. Giúp hộ kinh doanh chủ động kiểm soát dòng tiền và
              dễ dàng đáp ứng các yêu cầu về kế toán - thuế.
            </CardContent>
          </Card>

          {/* Giải pháp 3: Tối ưu chi phí & Dễ sử dụng */}
          <Card className="bg-white/5 border-white/10 hover:border-purple-500/50 transition-all duration-300 group">
            <CardHeader>
              <div className="w-12 h-12 bg-purple-500/10 rounded-xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                <MousePointerClick className="text-purple-500" size={26} />
              </div>
              <CardTitle className="text-xl text-white">
                Công nghệ cho mọi người
              </CardTitle>
            </CardHeader>
            <CardContent className="text-slate-400 leading-relaxed">
              Giao diện cực kỳ đơn giản, tối ưu cho cả điện thoại và máy tính.
              Không yêu cầu trình độ kỹ thuật cao, giúp giảm chi phí chuyển đổi
              số và đào tạo nhân sự xuống mức thấp nhất.
            </CardContent>
          </Card>
        </div>
      </section>

      {/* 4. TEAM SECTION */}
      <section className="bg-white/5 rounded-2xl border border-white/10 p-8 my-12">
        <h2 className="text-2xl font-semibold mb-8 text-white">
          Đội ngũ phát triển
        </h2>
        <div className={styles.teamGrid}>
          {[
            {
              name: "Lê Trọng Phúc",
              role: "Product Owner",
              fallback: "LP",
              img: "team-1.jpg",
            },
            {
              name: "Nguyễn Thanh",
              role: "Frontend",
              fallback: "NT",
              img: "team-2.jpg",
            },
            {
              name: "Phạm Tùng",
              role: "Backend",
              fallback: "PT",
              img: "team-3.jpg",
            },
          ].map((member, index) => (
            <div key={index} className={styles.teamItem}>
              <Avatar className="h-12 w-12">
                <AvatarImage src={`/images/about/${member.img}`} />
                <AvatarFallback className="bg-green-500/20 text-green-500">
                  {member.fallback}
                </AvatarFallback>
              </Avatar>
              <div>
                <div className="font-medium text-white">{member.name}</div>
                <div className="text-sm text-slate-400">{member.role}</div>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* 5. GET STARTED SECTION */}
      <section className="getStarted p-8 bg-gradient-to-r from-blue-600/10 to-purple-600/10 rounded-2xl border border-white/10">
        <h3 className="text-lg font-semibold mb-2 text-white">Bắt đầu nhanh</h3>
        <p className="text-sm text-slate-400 mb-6">
          Clone repo, cài dependencies và chạy dev server:
        </p>
        <pre className="bg-black/40 text-green-400 rounded-xl p-4 overflow-auto text-sm border border-white/5">
          {`git clone <repo-url>\ncd web-admin\nnpm install\nnpm run dev`}
        </pre>
      </section>

      {/* 6. CTA FOOTER */}
      <section className="text-center py-16">
        <h3 className="text-2xl font-bold mb-3 text-white">
          Muốn dùng thử hoặc đóng góp?
        </h3>
        <p className="text-slate-400 mb-8 max-w-md mx-auto">
          Liên hệ để được demo trực tiếp các tính năng nâng cao hoặc đóng góp mã
          nguồn trên GitHub.
        </p>
        <div className="flex items-center justify-center gap-4">
          <Button
            size="lg"
            className="bg-blue-600 hover:bg-blue-700 px-8 rounded-full"
            asChild
          >
            <Link href="/auth/register">Đăng ký Demo</Link>
          </Button>
          <Button
            size="lg"
            variant="outline"
            className={styles.btnPrimary}
            asChild
          >
            <Link
              href="https://github.com/"
              target="_blank"
              rel="noopener noreferrer"
            >
              GitHub
            </Link>
          </Button>
        </div>
      </section>
    </div>
  );
}
