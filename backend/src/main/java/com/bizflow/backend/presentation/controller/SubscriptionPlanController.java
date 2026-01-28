package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.domain.Subscription;
import com.bizflow.backend.core.domain.SubscriptionPlan;
import com.bizflow.backend.infrastructure.persistence.repository.StoreRepository;
import com.bizflow.backend.infrastructure.persistence.repository.SubscriptionPlanRepository;
import com.bizflow.backend.infrastructure.persistence.repository.SubscriptionRepository;
import com.bizflow.backend.presentation.dto.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/v1/subscription-plans")
@RequiredArgsConstructor
public class SubscriptionPlanController {

    private final SubscriptionPlanRepository planRepository;
    private final SubscriptionRepository subscriptionRepository;
    private final StoreRepository storeRepository;

    @GetMapping("/{id}/subscriptions")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getPlanSubscriptions(@PathVariable Long id) {
        List<Subscription> subscriptions = subscriptionRepository.findByPlanId(id);
        List<Map<String, Object>> result = subscriptions.stream().map(sub -> {
            Map<String, Object> map = new HashMap<>();
            map.put("subscriptionId", sub.getId());
            map.put("startDate", sub.getStartDate());
            map.put("endDate", sub.getEndDate());
            map.put("status", sub.getStatus());
            
            storeRepository.findById(sub.getStoreId()).ifPresent(store -> {
                map.put("storeName", store.getName());
                map.put("storeEmail", store.getEmail());
                map.put("storePhone", store.getPhone());
            });
            
            return map;
        }).toList();
        return ResponseEntity.ok(ApiResponse.success(result, "Lấy danh sách đăng ký thành công"));
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<java.util.Map<String, Object>>>> getAllPlans() {
        List<SubscriptionPlan> plans = planRepository.findAll();
        List<java.util.Map<String, Object>> result = plans.stream().map(plan -> {
            long usageCount = planRepository.countSubscriptionsByPlanId(plan.getId());
            java.util.Map<String, Object> map = new java.util.HashMap<>();
            map.put("id", plan.getId());
            map.put("name", plan.getName());
            map.put("description", plan.getDescription());
            map.put("price", plan.getPrice());
            map.put("durationMonths", plan.getDurationMonths());
            map.put("features", plan.getFeatures());
            map.put("status", plan.getStatus());
            map.put("createdAt", plan.getCreatedAt());
            map.put("usageCount", usageCount);
            return map;
        }).toList();
        return ResponseEntity.ok(ApiResponse.success(result, "Lấy danh sách gói dịch vụ thành công"));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<SubscriptionPlan>> createPlan(@RequestBody SubscriptionPlan plan) {
        SubscriptionPlan savedPlan = planRepository.save(plan);
        return ResponseEntity.ok(ApiResponse.success(savedPlan, "Tạo gói dịch vụ thành công"));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<SubscriptionPlan>> updatePlan(@PathVariable Long id, @RequestBody SubscriptionPlan planDetails) {
        return planRepository.findById(id).map(plan -> {
            plan.setName(planDetails.getName());
            plan.setDescription(planDetails.getDescription());
            plan.setPrice(planDetails.getPrice());
            plan.setDurationMonths(planDetails.getDurationMonths());
            plan.setFeatures(planDetails.getFeatures());
            plan.setStatus(planDetails.getStatus());
            SubscriptionPlan updatedPlan = planRepository.save(plan);
            return ResponseEntity.ok(ApiResponse.success(updatedPlan, "Cập nhật thành công"));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Object>> deletePlan(@PathVariable Long id) {
        return planRepository.findById(id).map(plan -> {
            planRepository.delete(plan);
            return ResponseEntity.ok(ApiResponse.success(null, "Xóa gói dịch vụ thành công"));
        }).orElse(ResponseEntity.notFound().build());
    }
}
