package com.bizflow.backend.core.usecase;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * ReportService: Business analytics and reporting
 * 
 * RESPONSIBILITIES:
 * 1. Generate sales reports (daily, monthly, yearly)
 * 2. Calculate KPIs (revenue, profit, conversion)
 * 3. Generate dashboard metrics
 * 4. Analyze trends and patterns
 * 5. Export reports
 * 
 * PATTERN:
 * - Aggregate data from repositories → Calculate metrics → Format report
 * 
 * SECURITY:
 * - All operations enforce store_id isolation (UserContext)
 * - Only OWNER/MANAGER can view reports
 * - Reports include only store's data
 */
public interface ReportService {

    /**
     * Get dashboard metrics (overview)
     * Includes:
     * - Total sales (today, this month, this year)
     * - Total revenue
     * - Number of orders
     * - Number of customers
     * - Inventory value
     * - Outstanding debt
     * 
     * @param storeId Store ID
     * @return Dashboard metrics map
     */
    Map<String, Object> getDashboardMetrics(Long storeId);

    /**
     * Get sales report for date range
     * 
     * @param storeId Store ID
     * @param startDate Start date
     * @param endDate End date
     * @return Sales data (total, count, by category, by customer segment)
     */
    Map<String, Object> getSalesReport(Long storeId, LocalDateTime startDate, LocalDateTime endDate);

    /**
     * Get revenue report by category
     * 
     * @param storeId Store ID
     * @param startDate Start date
     * @param endDate End date
     * @return Revenue by product category
     */
    Map<String, Double> getRevenueByCategory(Long storeId, LocalDateTime startDate, LocalDateTime endDate);

    /**
     * Get revenue report by customer segment
     * 
     * @param storeId Store ID
     * @param startDate Start date
     * @param endDate End date
     * @return Revenue by customer segment
     */
    Map<String, Double> getRevenueBySegment(Long storeId, LocalDateTime startDate, LocalDateTime endDate);

    /**
     * Get top selling products
     * 
     * @param storeId Store ID
     * @param limit Number of products to return
     * @param startDate Start date
     * @param endDate End date
     * @return Top products with quantities sold
     */
    Map<String, Object> getTopProducts(Long storeId, Integer limit, LocalDateTime startDate, LocalDateTime endDate);

    /**
     * Get inventory valuation report
     * Total value = quantity * current_price for all products
     * 
     * @param storeId Store ID
     * @return Inventory value by category + total
     */
    Map<String, Object> getInventoryValuation(Long storeId);

    /**
     * Get accounts receivable report
     * Shows outstanding debts summary
     * 
     * @param storeId Store ID
     * @return AR summary (total, count, aging buckets)
     */
    Map<String, Object> getAccountsReceivable(Long storeId);

    /**
     * Get customer analysis report
     * 
     * @param storeId Store ID
     * @return Customer count by segment, average order value, repeat rate
     */
    Map<String, Object> getCustomerAnalysis(Long storeId);

    /**
     * Get daily sales trend (last 30 days)
     * 
     * @param storeId Store ID
     * @return Daily sales data
     */
    Map<String, Object> getDailySalesTrend(Long storeId);

    /**
     * Get monthly sales trend (last 12 months)
     * 
     * @param storeId Store ID
     * @return Monthly sales data
     */
    Map<String, Object> getMonthlySalesTrend(Long storeId);

    /**
     * Export sales report to CSV format
     * 
     * @param storeId Store ID
     * @param startDate Start date
     * @param endDate End date
     * @return CSV content as string
     */
    String exportSalesReportToCsv(Long storeId, LocalDateTime startDate, LocalDateTime endDate);

    /**
     * Get business health score (0-100)
     * Based on revenue growth, debt levels, inventory turnover
     * 
     * @param storeId Store ID
     * @return Score 0-100 (higher is better)
     */
    Integer getBusinessHealthScore(Long storeId);
}
