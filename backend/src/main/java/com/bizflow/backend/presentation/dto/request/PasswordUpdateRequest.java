package com.bizflow.backend.presentation.dto.request;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PasswordUpdateRequest {
    private String oldPassword;
    private String newPassword;
}