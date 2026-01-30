"use client";

import { useState, useEffect } from "react";
import {
  User,
  Mail,
  Shield,
  Store,
  Save,
  Camera,
  Phone,
  AtSign,
  BadgeCheck,
  Loader2,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export default function AccountPage() {
  const [isLoading, setIsLoading] = useState(false);
  const [profile, setProfile] = useState({
    username: "",
    fullName: "",
    email: "",
    phone: "",
    storeName: "BizFlow Store",
    role: "EMPLOYEE",
  });

  // Load dữ liệu từ localStorage khi vào trang
  useEffect(() => {
    setProfile({
      username: localStorage.getItem("username") || "n/a",
      fullName: localStorage.getItem("userFullName") || "Người dùng",
      email: localStorage.getItem("userEmail") || "chưa cập nhật",
      phone: localStorage.getItem("userPhone") || "chưa cập nhật",
      storeName: localStorage.getItem("storeName") || "BizFlow Store",
      role: localStorage.getItem("userRole") || "EMPLOYEE",
    });
  }, []);

  const handleUpdate = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    // Giả lập gọi API cập nhật
    setTimeout(() => {
      localStorage.setItem("userFullName", profile.fullName);
      localStorage.setItem("userPhone", profile.phone);

      // Kích hoạt sự kiện để Sidebar cập nhật theo
      window.dispatchEvent(new Event("storage"));
      setIsLoading(false);
      alert("Đã lưu thay đổi thành công!");
    }, 1000);
  };

  return (
    <div className="p-4 md:p-8 max-w-5xl mx-auto space-y-6">
      <div className="mb-8">
        <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">
          Cài đặt tài khoản
        </h1>
        <p className="text-slate-500 mt-1">
          Quản lý thông tin cá nhân và thiết lập quyền hạn của bạn.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* BÊN TRÁI: AVATAR CARD */}
        <Card className="lg:col-span-1 border-none shadow-sm ring-1 ring-slate-200">
          <CardContent className="pt-8 flex flex-col items-center">
            <div className="relative group cursor-pointer">
              <Avatar className="h-32 w-32 border-4 border-white shadow-2xl transition-transform group-hover:scale-105">
                <AvatarImage src="https://github.com/shadcn.png" />
                <AvatarFallback className="text-3xl bg-blue-700 text-white font-bold">
                  {profile.fullName.substring(0, 2).toUpperCase()}
                </AvatarFallback>
              </Avatar>
              <div className="absolute bottom-1 right-1 p-2 bg-blue-700 rounded-full text-white border-2 border-white shadow-lg">
                <Camera size={16} />
              </div>
            </div>

            <div className="mt-6 text-center">
              <h3 className="text-xl font-bold text-slate-800">
                {profile.fullName}
              </h3>
              <div className="flex items-center justify-center gap-1.5 mt-1">
                <span className="text-xs font-bold text-slate-400 uppercase tracking-widest">
                  {profile.role}
                </span>
                <BadgeCheck size={14} className="text-blue-500" />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* BÊN PHẢI: FORM CHI TIẾT */}
        <Card className="lg:col-span-2 border-none shadow-sm ring-1 ring-slate-200">
          <CardHeader>
            <CardTitle className="text-lg">Thông tin chi tiết</CardTitle>
            <CardDescription>
              Cập nhật tên hiển thị và địa chỉ liên lạc của bạn.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleUpdate} className="space-y-5">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                {/* Họ tên */}
                <div className="space-y-2">
                  <label className="text-sm font-bold text-slate-700 flex items-center gap-2">
                    <User size={15} className="text-blue-600" /> Họ và tên
                  </label>
                  <Input
                    value={profile.fullName}
                    onChange={(e) =>
                      setProfile({ ...profile, fullName: e.target.value })
                    }
                    className="h-11 rounded-lg border-slate-200 focus:ring-blue-600"
                  />
                </div>

                {/* Email */}
                <div className="space-y-2">
                  <label className="text-sm font-bold text-slate-700 flex items-center gap-2">
                    <Mail size={15} className="text-blue-600" /> Email
                  </label>
                  <Input
                    value={profile.email}
                    readOnly
                    className="h-11 rounded-lg bg-slate-50 text-slate-500 border-slate-200"
                  />
                </div>

                {/* Tên đăng nhập */}
                <div className="space-y-2">
                  <label className="text-sm font-bold text-slate-700 flex items-center gap-2">
                    <AtSign size={15} className="text-blue-600" /> Tên đăng nhập
                  </label>
                  <Input
                    value={profile.username}
                    readOnly
                    className="h-11 rounded-lg bg-slate-50 text-slate-500 border-slate-200"
                  />
                </div>

                {/* Số điện thoại */}
                <div className="space-y-2">
                  <label className="text-sm font-bold text-slate-700 flex items-center gap-2">
                    <Phone size={15} className="text-blue-600" /> Số điện thoại
                  </label>
                  <Input
                    value={profile.phone}
                    onChange={(e) =>
                      setProfile({ ...profile, phone: e.target.value })
                    }
                    className="h-11 rounded-lg border-slate-200 focus:ring-blue-600"
                  />
                </div>

                {/* Cửa hàng */}
                <div className="space-y-2">
                  <label className="text-sm font-bold text-slate-700 flex items-center gap-2">
                    <Store size={15} className="text-blue-600" /> Cửa hàng
                  </label>
                  <Input
                    value={profile.storeName}
                    readOnly
                    className="h-11 rounded-lg bg-slate-50 text-slate-500 border-slate-200"
                  />
                </div>

                {/* Vai trò */}
                <div className="space-y-2">
                  <label className="text-sm font-bold text-slate-700 flex items-center gap-2">
                    <Shield size={15} className="text-blue-600" /> Vai trò
                  </label>
                  <div className="h-11 px-3 flex items-center bg-blue-50 text-blue-700 rounded-lg text-xs font-black border border-blue-100 uppercase">
                    {profile.role}
                  </div>
                </div>
              </div>

              <div className="flex justify-end pt-4 border-t border-slate-100">
                <Button
                  disabled={isLoading}
                  className="bg-blue-700 hover:bg-blue-800 text-white px-8 h-11 rounded-xl shadow-lg shadow-blue-200 transition-all active:scale-95"
                >
                  {isLoading ? (
                    <>
                      {" "}
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Đang
                      lưu...{" "}
                    </>
                  ) : (
                    <>
                      {" "}
                      <Save className="mr-2 h-4 w-4" /> Lưu thay đổi{" "}
                    </>
                  )}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
