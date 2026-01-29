package com.bizflow.backend.core.usecase;

import com.bizflow.backend.presentation.dto.response.AdminDashboardStatsResponse;
import java.time.LocalDateTime;

public interface AdminDashboardService {
    AdminDashboardStatsResponse getDashboardStats(String period);
}
