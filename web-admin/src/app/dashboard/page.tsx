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

interface User {
    id: number;
    username: string;
    fullName: string;
    role: string;
}

interface ApiResponse {
    result: User[];
}

export default function DashboardPage() {
    const router = useRouter();
    const [isAuthenticated, setIsAuthenticated] = useState(false);
    const [isChecking, setIsChecking] = useState(true);

    // Check token khi component mount
    useEffect(() => {
        // Chỉ chạy ở client-side
        if (typeof window !== "undefined") {
            const token = localStorage.getItem("accessToken");
            if (!token) {
                router.push("/auth/login");
                return;
            }
            setIsAuthenticated(true);
        }
        setIsChecking(false);
    }, [router]);

    const { data: apiResponse, isLoading } = useQuery<ApiResponse>({
        queryKey: ["users"],
        queryFn: userService.getUsers,
        enabled: isAuthenticated, // Chỉ gọi API khi đã login
    });

    const users: User[] = apiResponse?.result || [];

    if (isChecking) {
        return (
            <div className="flex items-center justify-center h-full">
                <p className="text-slate-500">Đang tải...</p>
            </div>
        );
    }

    return (
        <div className="space-y-6">
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