package com.bizflow.backend.config;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.data.domain.Sort;

@JsonIgnoreProperties(ignoreUnknown = true)
public abstract class SortOrderMixin {

    @JsonCreator
    public SortOrderMixin(@JsonProperty("direction") Sort.Direction direction,
            @JsonProperty("property") String property,
            @JsonProperty("ignoreCase") boolean ignoreCase,
            @JsonProperty("nullHandling") Sort.NullHandling nullHandling) {
    }
}
