package com.bizflow.backend.presentation.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserActivityDTO {
    private String time;
    private String device;
    private String ip;
    private String location;
    private String status;
}