package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.presentation.dto.response.ApiResponse;
import com.bizflow.backend.presentation.dto.response.UnitDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;
import java.util.List;

@RestController
@RequestMapping("/v1/units")
@RequiredArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
public class UnitController {

    @GetMapping
    public ResponseEntity<ApiResponse<List<UnitDTO>>> getUnits() {
        // Tạm thời trả về dữ liệu cứng để Frontend hiển thị Dropdown
        List<UnitDTO> units = Arrays.asList(
                new UnitDTO(1L, "Cái"),
                new UnitDTO(2L, "Hộp"),
                new UnitDTO(3L, "Thùng"),
                new UnitDTO(4L, "Bao"),
                new UnitDTO(5L, "Chai"),
                new UnitDTO(6L, "Lốc"),
                new UnitDTO(7L, "Kg"),
                new UnitDTO(8L, "Mét"),
                new UnitDTO(9L, "Bộ"),
                new UnitDTO(10L, "Cuộn"));
        return ResponseEntity.ok(ApiResponse.success(units, "Units retrieved successfully"));
    }
}
