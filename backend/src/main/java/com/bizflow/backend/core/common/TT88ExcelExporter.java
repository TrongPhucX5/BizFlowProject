package com.bizflow.backend.core.common;

import com.bizflow.backend.presentation.dto.response.TT88DebtRow;
import com.bizflow.backend.presentation.dto.response.TT88RevenueRow;
import com.bizflow.backend.presentation.dto.response.TT88StockRow;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.OutputStream;
import java.util.List;

public class TT88ExcelExporter {

    public static void exportRevenue(
            List<TT88RevenueRow> data,
            OutputStream out) throws Exception {

        Workbook wb = new XSSFWorkbook();
        Sheet sheet = wb.createSheet("SoDoanhThu");

        CellStyle headerStyle = createHeaderStyle(wb);
        CellStyle cellStyle = createCellStyle(wb);

        // ====== TITLE ======
        Row titleRow = sheet.createRow(0);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("SỔ DOANH THU BÁN HÀNG (TT88)");
        titleCell.setCellStyle(headerStyle);
        sheet.addMergedRegion(new CellRangeAddress(0,0,0,5));

        // ====== HEADER ======
        Row header = sheet.createRow(2);
        String[] cols = {
            "STT", "Ngày", "Số HĐ/Đơn", "Khách hàng", "Doanh thu", "Ghi chú"
        };

        for (int i = 0; i < cols.length; i++) {
            Cell c = header.createCell(i);
            c.setCellValue(cols[i]);
            c.setCellStyle(headerStyle);
            sheet.setColumnWidth(i, 4000);
        }

        // ====== DATA ======
        int rowIdx = 3;
        for (TT88RevenueRow r : data) {
            Row row = sheet.createRow(rowIdx++);

            row.createCell(0).setCellValue(r.getStt());
            row.createCell(1).setCellValue(r.getDate().toString());
            row.createCell(2).setCellValue(r.getOrderCode());
            row.createCell(3).setCellValue(r.getCustomerName());
            row.createCell(4).setCellValue(r.getAmount().doubleValue());
            row.createCell(5).setCellValue(r.getNote());

            for (int i = 0; i <= 5; i++) {
                row.getCell(i).setCellStyle(cellStyle);
            }
        }

        wb.write(out);
        wb.close();
    }

    public static void exportDebt(
            List<TT88DebtRow> data,
            OutputStream out) throws Exception {

        Workbook wb = new XSSFWorkbook();
        Sheet sheet = wb.createSheet("SoCongNo");

        CellStyle headerStyle = createHeaderStyle(wb);
        CellStyle cellStyle = createCellStyle(wb);

        // TITLE
        Row titleRow = sheet.createRow(0);
        Cell title = titleRow.createCell(0);
        title.setCellValue("SỔ CÔNG NỢ PHẢI THU (TT88)");
        title.setCellStyle(headerStyle);
        sheet.addMergedRegion(new CellRangeAddress(0,0,0,6));

        // HEADER
        Row header = sheet.createRow(2);
        String[] cols = {
          "STT","Khách hàng","SĐT","Nợ đầu kỳ",
          "Phát sinh","Đã trả","Nợ cuối kỳ"
        };

        for (int i = 0; i < cols.length; i++) {
            Cell c = header.createCell(i);
            c.setCellValue(cols[i]);
            c.setCellStyle(headerStyle);
            sheet.setColumnWidth(i, 4000);
        }

        int rowIdx = 3;
        for (TT88DebtRow r : data) {
            Row row = sheet.createRow(rowIdx++);

            row.createCell(0).setCellValue(r.getStt());
            row.createCell(1).setCellValue(r.getCustomerName());
            row.createCell(2).setCellValue(r.getPhone());
            row.createCell(3).setCellValue(r.getOpeningDebt().doubleValue());
            row.createCell(4).setCellValue(r.getNewDebt().doubleValue());
            row.createCell(5).setCellValue(r.getPaid().doubleValue());
            row.createCell(6).setCellValue(r.getClosingDebt().doubleValue());

            for (int i = 0; i <= 6; i++) {
                row.getCell(i).setCellStyle(cellStyle);
            }
        }

        wb.write(out);
        wb.close();
    }

    public static void exportStock(
            List<TT88StockRow> data,
            OutputStream out) throws Exception {

        Workbook wb = new XSSFWorkbook();
        Sheet sheet = wb.createSheet("SoTonKho");

        CellStyle headerStyle = createHeaderStyle(wb);
        CellStyle cellStyle = createCellStyle(wb);

        // TITLE
        Row titleRow = sheet.createRow(0);
        Cell title = titleRow.createCell(0);
        title.setCellValue("SỔ THEO DÕI TỒN KHO (TT88)");
        title.setCellStyle(headerStyle);
        sheet.addMergedRegion(new CellRangeAddress(0,0,0,6));

        // HEADER
        Row header = sheet.createRow(2);
        String[] cols = {
          "STT","Mã SP","Tên sản phẩm",
          "Tồn đầu","Nhập","Xuất","Tồn cuối"
        };

        for (int i = 0; i < cols.length; i++) {
            Cell c = header.createCell(i);
            c.setCellValue(cols[i]);
            c.setCellStyle(headerStyle);
            sheet.setColumnWidth(i, 4200);
        }

        int rowIdx = 3;
        for (TT88StockRow r : data) {
            Row row = sheet.createRow(rowIdx++);

            row.createCell(0).setCellValue(r.getStt());
            row.createCell(1).setCellValue(r.getProductCode());
            row.createCell(2).setCellValue(r.getProductName());
            row.createCell(3).setCellValue(r.getOpeningStock());
            row.createCell(4).setCellValue(r.getImported());
            row.createCell(5).setCellValue(r.getExported());
            row.createCell(6).setCellValue(r.getClosingStock());

            for (int i = 0; i <= 6; i++) {
                row.getCell(i).setCellStyle(cellStyle);
            }
        }

        wb.write(out);
        wb.close();
    }

    private static CellStyle createHeaderStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        Font bold = wb.createFont();
        bold.setBold(true);
        style.setFont(bold);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        return style;
    }

    private static CellStyle createCellStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        return style;
    }
}
