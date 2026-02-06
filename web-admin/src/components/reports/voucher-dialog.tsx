import React, { useState, useEffect } from "react";
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogFooter,
    DialogDescription,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { format } from "date-fns";

interface VoucherDialogProps {
    open: boolean;
    onOpenChange: (open: boolean) => void;
    type: "receipt" | "payment";
}

import { readNumber } from "@/lib/number-utils";
import { HelpCircle } from "lucide-react";

// ... existing imports

export function VoucherDialog({ open, onOpenChange, type }: VoucherDialogProps) {
    const [formData, setFormData] = useState({
        date: format(new Date(), "yyyy-MM-dd"),
        bookNo: "01",
        voucherNo: "",
        personName: "",
        address: "Tp. Hồ Chí Minh",
        reason: "",
        amount: "",
        amountInWords: "",
        attachedDocs: "0",
        directorName: "Nguyễn Văn A", // Should be loaded from context/store
        preparerName: "Trần Văn B",
        cashierName: "Lê Thị C",
        status: "DRAFT",
    });

    useEffect(() => {
        if (open) {
            const today = format(new Date(), "yyyyMMdd");
            const randomSuffix = Math.floor(Math.random() * 900 + 100);
            const prefix = type === "receipt" ? "PT" : "PC";
            setFormData({
                date: format(new Date(), "yyyy-MM-dd"),
                bookNo: "01",
                voucherNo: `${prefix}${today}-${randomSuffix}`,
                personName: "",
                address: "Tp. Hồ Chí Minh",
                reason: type === "receipt" ? "Thu tiền bán hàng" : "Chi mua văn phòng phẩm",
                amount: "",
                amountInWords: "",
                attachedDocs: "0",
                directorName: "Nguyễn Văn A",
                preparerName: "Trần Văn B",
                cashierName: "Lê Thị C",
                status: "DRAFT",
            });
        }
    }, [open, type]);

    // Auto-convert amount to words
    useEffect(() => {
        if (formData.amount) {
            const num = parseInt(formData.amount);
            if (!isNaN(num)) {
                setFormData(prev => ({ ...prev, amountInWords: readNumber(num) }));
            }
        }
    }, [formData.amount]);

    const handlePrint = () => {
        // ... (existing logic)
        const params = new URLSearchParams({
            // ... (existing params)
            type,
            date: formData.date,
            bookNo: formData.bookNo,
            voucherNo: formData.voucherNo,
            personName: formData.personName,
            address: formData.address,
            reason: formData.reason,
            amount: formData.amount,
            amountInWords: formData.amountInWords,
            attachedDocs: formData.attachedDocs,
            directorName: formData.directorName,
            preparerName: formData.preparerName,
            cashierName: formData.cashierName,
            payerName: type === "receipt" ? formData.personName : "",
            receiverName: type === "payment" ? formData.personName : "",
            status: formData.status,
        });

        window.open(`/print?${params.toString()}`, "_blank", "width=850,height=700");
        onOpenChange(false);
    };



    // ... inside VoucherDialog ...

    const isPrintable = true; // Allow printing all statuses, as watermark handles context
    const isValid = formData.personName && formData.reason && Number(formData.amount) > 0;

    const getButtonText = () => {
        if (!isValid) return "Điền thông tin bắt buộc (*)";
        if (formData.status === "DRAFT") return "In (Bản Nháp)";
        if (formData.status === "CANCELED") return "In (Đã Hủy)";
        return "In Phiếu";
    }

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className="sm:max-w-[700px] max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle>{type === "receipt" ? "Phiếu Thu (Mẫu 01-TT)" : "Phiếu Chi (Mẫu 02-TT)"}</DialogTitle>
                    <DialogDescription>
                        Nhập thông tin chi tiết cho phiếu {type === "receipt" ? "thu" : "chi"}.
                    </DialogDescription>
                </DialogHeader>

                <div className="grid gap-4 py-4">
                    <div className="grid grid-cols-2 gap-4">
                        <div className="grid gap-2">
                            <Label>Trạng thái</Label>
                            <Select
                                value={formData.status}
                                onValueChange={(val) =>
                                    setFormData({ ...formData, status: val })
                                }
                            >
                                <SelectTrigger>
                                    <SelectValue />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="DRAFT">
                                        <div className="flex items-center gap-2">
                                            <div className="h-2 w-2 rounded-full bg-gray-400"></div>
                                            <span>Bản nháp (Draft)</span>
                                        </div>
                                    </SelectItem>
                                    <SelectItem value="CONFIRMED">
                                        <div className="flex items-center gap-2">
                                            <div className="h-2 w-2 rounded-full bg-green-500"></div>
                                            <span>Đã xác nhận (Official)</span>
                                        </div>
                                    </SelectItem>
                                    <SelectItem value="CANCELED">
                                        <div className="flex items-center gap-2">
                                            <div className="h-2 w-2 rounded-full bg-red-400"></div>
                                            <span>Đã hủy (Canceled)</span>
                                        </div>
                                    </SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                        {/* ... Date ... */}
                        <div className="grid gap-2">
                            <Label>Ngày lập</Label>
                            <Input
                                type="date"
                                value={formData.date}
                                onChange={(e) =>
                                    setFormData({ ...formData, date: e.target.value })
                                }
                            />
                        </div>
                        {/* Book No with Tooltip */}
                        <div className="grid gap-2">
                            <div className="flex items-center gap-2">
                                <Label>Quyển số</Label>
                                <div title="Quyển số dùng để quản lý tập chứng từ theo năm hoặc theo đợt in">
                                    <HelpCircle className="h-4 w-4 text-gray-400 cursor-help" />
                                </div>
                            </div>
                            <Input
                                value={formData.bookNo}
                                onChange={(e) =>
                                    setFormData({ ...formData, bookNo: e.target.value })
                                }
                            />
                        </div>
                        {/* ... VoucherNo ... */}
                        <div className="grid gap-2">
                            <Label>Số phiếu</Label>
                            <Input
                                value={formData.voucherNo}
                                onChange={(e) =>
                                    setFormData({ ...formData, voucherNo: e.target.value })
                                }
                            />
                        </div>
                    </div>

                    {/* ... Rest of form... */}
                    <div className="border-t pt-4 grid gap-4">
                        <div className="grid grid-cols-4 items-center gap-4">
                            <Label className="text-right">
                                {type === "receipt" ? "Người nộp tiền" : "Người nhận tiền"} <span className="text-red-500">*</span>
                            </Label>
                            <Input
                                className="col-span-3"
                                value={formData.personName}
                                onChange={(e) =>
                                    setFormData({ ...formData, personName: e.target.value })
                                }
                                placeholder="Nguyễn Văn A"
                            />
                        </div>
                        {/* Address */}
                        <div className="grid grid-cols-4 items-center gap-4">
                            <Label className="text-right">Địa chỉ</Label>
                            <Input
                                className="col-span-3"
                                value={formData.address}
                                onChange={(e) =>
                                    setFormData({ ...formData, address: e.target.value })
                                }
                            />
                        </div>
                        {/* Reason */}
                        <div className="grid grid-cols-4 items-center gap-4">
                            <Label className="text-right">Lý do <span className="text-red-500">*</span></Label>
                            <Input
                                className="col-span-3"
                                value={formData.reason}
                                onChange={(e) =>
                                    setFormData({ ...formData, reason: e.target.value })
                                }
                                placeholder={
                                    type === "receipt"
                                        ? "Thu tiền bán hàng"
                                        : "Chi mua văn phòng phẩm"
                                }
                            />
                        </div>
                        {/* Amount */}
                        <div className="grid grid-cols-4 items-center gap-4">
                            <Label className="text-right">Số tiền <span className="text-red-500">*</span></Label>
                            <Input
                                type="number"
                                className="col-span-3"
                                value={formData.amount}
                                onChange={(e) =>
                                    setFormData({ ...formData, amount: e.target.value })
                                }
                            />
                        </div>
                        {/* Amount Words */}
                        <div className="grid grid-cols-4 items-center gap-4">
                            <Label className="text-right">Viết bằng chữ</Label>
                            <Input
                                className="col-span-3"
                                value={formData.amountInWords}
                                onChange={(e) =>
                                    setFormData({ ...formData, amountInWords: e.target.value })
                                }
                                placeholder="Tự động"
                            />
                        </div>
                        {/* Attached Docs */}
                        <div className="grid grid-cols-4 items-center gap-4">
                            <Label className="text-right">Kèm theo</Label>
                            <div className="col-span-3 flex items-center gap-2">
                                <Input
                                    type="number"
                                    className="w-20"
                                    value={formData.attachedDocs}
                                    onChange={(e) =>
                                        setFormData({ ...formData, attachedDocs: e.target.value })
                                    }
                                />
                                <span>Chứng từ gốc</span>
                            </div>
                        </div>
                    </div>
                    {/* ... Signatures can stay same ... */}
                    <div className="border-t pt-4 grid grid-cols-3 gap-4">
                        <div className="grid gap-2">
                            <Label>Giám đốc/Chủ hộ</Label>
                            <Input
                                value={formData.directorName}
                                onChange={(e) =>
                                    setFormData({ ...formData, directorName: e.target.value })
                                }
                            />
                        </div>
                        <div className="grid gap-2">
                            <Label>Người lập biểu</Label>
                            <Input
                                value={formData.preparerName}
                                onChange={(e) =>
                                    setFormData({ ...formData, preparerName: e.target.value })
                                }
                            />
                        </div>
                        <div className="grid gap-2">
                            <Label>Thủ quỹ</Label>
                            <Input
                                value={formData.cashierName}
                                onChange={(e) =>
                                    setFormData({ ...formData, cashierName: e.target.value })
                                }
                            />
                        </div>
                    </div>
                </div>

                <DialogFooter>
                    <Button variant="outline" onClick={() => onOpenChange(false)}>
                        Hủy
                    </Button>
                    <Button
                        type="submit"
                        disabled={!isValid}
                        onClick={handlePrint}
                        className="bg-indigo-600 hover:bg-indigo-700"
                    >
                        {getButtonText()}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog >
    );
}
