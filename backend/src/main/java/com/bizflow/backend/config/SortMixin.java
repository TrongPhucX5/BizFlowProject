package com.bizflow.backend.config;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.data.domain.Sort;

import java.util.List;

@JsonFormat(shape = JsonFormat.Shape.OBJECT)
@JsonIgnoreProperties(ignoreUnknown = true)
public abstract class SortMixin {

    @JsonCreator
    public static Sort by(@JsonProperty("orders") List<Sort.Order> orders) {
        return null;
    }

    @JsonProperty("orders")
    abstract List<Sort.Order> toList();
}
