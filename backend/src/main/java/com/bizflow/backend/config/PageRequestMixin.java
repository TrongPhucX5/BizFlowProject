package com.bizflow.backend.config;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;

@JsonIgnoreProperties(ignoreUnknown = true)
public abstract class PageRequestMixin {

    @JsonCreator
    public static PageRequest of(@JsonProperty("pageNumber") int page,
            @JsonProperty("pageSize") int size,
            @JsonProperty("sort") Sort sort) {
        return null;
    }
}
