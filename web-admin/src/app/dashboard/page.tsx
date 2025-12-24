"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { userService } from "@/services/user.service";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Plus } from "lucide-react";

// --- Interfaces ---
interface User {
    id: number;
    username: string;
    fullName: string;
    role: string;
}

interface ApiResponse {
    result: User[];
}

// --- Component Chính ---
export default function DashboardPage() {
    const router = useRouter();
    const [isChecking, setIsChecking] = useState(true);

    // 1. Kiểm tra đăng nhập (Auth Check)
    useEffect(() => {
        const token = localStorage.getItem("accessToken"); // Hoặc nơi bạn lưu token
        if (!token) {
            router.push("/auth/login"); // Redirect nếu chưa login
        } else {
            setIsChecking(false); // Đã login, tắt loading check
        }
    }, [router]);

    // 2. Lấy dữ liệu user
    const { data: apiResponse, isLoading } = useQuery<ApiResponse>({
        queryKey: ["users"],
        queryFn: userService.getUsers, // Đảm bảo hàm này trả về đúng format
        enabled: !isChecking, // Chỉ fetch khi đã check auth xong
    });

    const users: User[] = apiResponse?.result || [];

    // 3. Màn hình Loading khi đang check auth
    if (isChecking) {
        return (
            <div className="flex items-center justify-center h-screen">
                <p>Đang kiểm tra đăng nhập...</p>
            </div>
        );
    }

    // 4. Màn hình chính
    return (
        <div className="p-6 space-y-6">
            <h1 className="text-2xl font-bold">Dashboard</h1>

            {/* Thống kê nhanh */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <Card className="bg-blue-600 text-white">
                    <CardHeader className="pb-2">
                        <CardTitle className="text-sm font-medium">
                            Tổng người dùng
                        </CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="text-3xl font-bold">{users.length}</div>
                    </CardContent>
                </Card>
            </div>

            {/* Bảng danh sách User */}
            <Card>
                <CardHeader className="flex flex-row items-center justify-between">
                    <CardTitle>Danh sách nhân viên</CardTitle>
                    <Button size="sm" className="bg-blue-600 hover:bg-blue-700">
                        <Plus className="mr-2 h-4 w-4" /> Thêm mới
                    </Button>
                </CardHeader>
                <CardContent>
                    {isLoading ? (
                        <p className="text-center py-4 text-slate-500">
                            Đang tải dữ liệu...
                        </p>
                    ) : (
                        <Table>
                            <TableHeader>
                                <TableRow>
                                    <TableHead>ID</TableHead>
                                    <TableHead>Tên đăng nhập</TableHead>
                                    <TableHead>Họ và tên</TableHead>
                                    <TableHead>Vai trò</TableHead>
                                    <TableHead className="text-right">Hành động</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {users.length > 0 ? (
                                    users.map((user: User) => (
                                        <TableRow key={user.id}>
                                            <TableCell className="font-medium">#{user.id}</TableCell>
                                            <TableCell>{user.username}</TableCell>
                                            <TableCell>{user.fullName}</TableCell>
                                            <TableCell>
                                                <Badge
                                                    variant={
                                                        user.role === "OWNER" ? "default" : "secondary"
                                                    }
                                                >
                                                    {user.role}
                                                </Badge>
                                            </TableCell>
                                            <TableCell className="text-right">
                                                <Button
                                                    variant="ghost"
                                                    size="sm"
                                                    className="text-blue-600"
                                                >
                                                    Sửa
                                                </Button>
                                            </TableCell>
                                        </TableRow>
                                    ))
                                ) : (
                                    <TableRow>
                                        <TableCell colSpan={5} className="text-center py-4">
                                            Chưa có nhân viên nào
                                        </TableCell>
                                    </TableRow>
                                )}
                            </TableBody>
                        </Table>
                    )}
                </CardContent>
            </Card>
        </div>
    );
}