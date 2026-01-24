package com.bizflow.backend.config;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.util.List;

/**
 * Mixin to help Jackson deserialize Spring Data's PageImpl.
 * Required because PageImpl does not have a default constructor.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public abstract class PageImplMixin<T> {

    @JsonCreator
    public PageImplMixin(@JsonProperty("content") List<T> content,
            @JsonProperty("pageable") Pageable pageable,
            @JsonProperty("totalElements") long total) {
    }
}
