"use client";

import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Activity, Store, ShoppingBag, Download, Calendar as CalendarIcon, Wallet, TrendingUp } from "lucide-react";
import { OverviewChart } from "@/components/dashboard/overview-chart";
import { RecentTenants } from "@/components/dashboard/recent-tenants";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { formatVND } from "@/lib/utils";
import * as XLSX from "xlsx";
import { toast } from "sonner";

export default function AdminDashboardPage() {
  const [period, setPeriod] = useState("this-month");
  const [isExporting, setIsExporting] = useState(false);

  // States cho dữ liệu thực tế (khởi tạo trống)
  const [stats, setStats] = useState({
    revenue: 0,
    newStores: 0,
    activeTenants: 0,
    totalOrders: 0,
  });
  const [revenueData, setRevenueData] = useState([]);
  const [recentTenants, setRecentTenants] = useState([]);

  const handleExport = () => {
    try {
      if (recentTenants.length === 0 && stats.revenue === 0) {
        toast.error("Không có dữ liệu để xuất báo cáo.");
        return;
      }
      setIsExporting(true);

      const dataToExport = [
        { "Hạng mục": "Tổng doanh thu", "Giá trị": formatVND(stats.revenue) },
        { "Hạng mục": "Cửa hàng mới", "Giá trị": stats.newStores },
        { "Hạng mục": "Tenant hoạt động", "Giá trị": stats.activeTenants },
        { "Hạng mục": "Tổng đơn hàng", "Giá trị": stats.totalOrders },
        {}, // Dòng trống
        { "Hạng mục": "DANH SÁCH TENANT MỚI", "Giá trị": "" },
        ...recentTenants.map(t => ({
          "Hạng mục": t.name,
          "Giá trị": formatVND(t.amount),
          "Email": t.email,
          "Trạng thái": t.status
        }))
      ];

      const worksheet = XLSX.utils.json_to_sheet(dataToExport);
      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, worksheet, "Báo cáo SaaS");

      const fileName = `Bao_cao_BizFlow_${period}_${new Date().toISOString().split('T')[0]}.xlsx`;
      XLSX.writeFile(workbook, fileName);

      toast.success("Đã xuất báo cáo thành công!");
    } catch (error) {
      console.error("Export error:", error);
      toast.error("Có lỗi xảy ra khi xuất báo cáo.");
    } finally {
      setIsExporting(false);
    }
  };

  return (
    <div className="p-8 space-y-8 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-slate-900">Dashboard SaaS</h1>
          <p className="text-slate-500">Chào mừng trở lại! Đây là tổng quan hệ thống BizFlow Master hôm nay.</p>
        </div>
        <div className="flex items-center gap-2">
           <Select value={period} onValueChange={setPeriod}>
             <SelectTrigger className="w-[180px] bg-white">
               <CalendarIcon className="mr-2 h-4 w-4 text-slate-500" />
               <SelectValue placeholder="Chọn thời gian" />
             </SelectTrigger>
             <SelectContent>
               <SelectItem value="today">Hôm nay</SelectItem>
               <SelectItem value="this-week">Tuần này</SelectItem>
               <SelectItem value="this-month">Tháng này</SelectItem>
               <SelectItem value="this-quarter">Quý này</SelectItem>
               <SelectItem value="this-year">Năm nay</SelectItem>
             </SelectContent>
           </Select>

           <Button
             onClick={handleExport}
             disabled={isExporting}
             className="bg-blue-600 hover:bg-blue-700 text-white shadow-sm transition-all active:scale-95"
           >
             <Download className={`mr-2 h-4 w-4 ${isExporting ? 'animate-bounce' : ''}`} />
             {isExporting ? "Đang xuất..." : "Xuất báo cáo"}
           </Button>
        </div>
      </div>

      {/* OVERVIEW CARDS */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card className="hover:shadow-md transition-shadow border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-semibold text-slate-600">Tổng Doanh thu</CardTitle>
            <div className="p-2 bg-blue-50 rounded-lg">
              <Wallet className="h-4 w-4 text-blue-600" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">{formatVND(stats.revenue)}</div>
            <div className="flex items-center gap-1 text-xs text-green-600 font-medium mt-1">
              <TrendingUp className="h-3 w-3" />
              <span>0% so với tháng trước</span>
            </div>
          </CardContent>
        </Card>
        <Card className="hover:shadow-md transition-shadow border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-semibold text-slate-600">Cửa hàng mới</CardTitle>
            <div className="p-2 bg-purple-50 rounded-lg">
              <Store className="h-4 w-4 text-purple-600" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">+{stats.newStores}</div>
            <p className="text-xs text-muted-foreground mt-1">0% so với tháng trước</p>
          </CardContent>
        </Card>
        <Card className="hover:shadow-md transition-shadow border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-semibold text-slate-600">Tenant Hoạt động</CardTitle>
            <div className="p-2 bg-orange-50 rounded-lg">
              <Activity className="h-4 w-4 text-orange-600" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">{stats.activeTenants}</div>
            <p className="text-xs text-muted-foreground mt-1">0% so với tháng trước</p>
          </CardContent>
        </Card>
        <Card className="hover:shadow-md transition-shadow border-slate-200">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-semibold text-slate-600">Tổng Đơn hàng</CardTitle>
            <div className="p-2 bg-pink-50 rounded-lg">
              <ShoppingBag className="h-4 w-4 text-pink-600" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-slate-900">{stats.totalOrders.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground mt-1">0% so với tuần trước</p>
          </CardContent>
        </Card>
      </div>

      {/* CHARTS SECTION */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
        <Card className="col-span-4 border-slate-200">
          <CardHeader>
            <CardTitle className="text-lg font-bold text-slate-800">Tổng quan doanh thu</CardTitle>
          </CardHeader>
          <CardContent className="pl-2">
            <OverviewChart data={revenueData} />
          </CardContent>
        </Card>
        <Card className="col-span-3 border-slate-200">
          <CardHeader>
            <CardTitle className="text-lg font-bold text-slate-800">Tenant Mới</CardTitle>
          </CardHeader>
          <CardContent>
            <RecentTenants data={recentTenants} />
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
