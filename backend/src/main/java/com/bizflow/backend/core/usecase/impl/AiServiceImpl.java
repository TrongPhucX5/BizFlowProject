package com.bizflow.backend.core.usecase.impl;

import com.bizflow.backend.core.domain.Product;
import com.bizflow.backend.core.usecase.AiService;
import com.bizflow.backend.core.common.UserContext;
import com.bizflow.backend.infrastructure.persistence.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
public class AiServiceImpl implements AiService {

    private final ProductRepository productRepository;

    @Override
    public Map<String, Object> analyzeText(String text, String intent) {
        Long storeId = UserContext.getCurrentStoreId();
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> items = new ArrayList<>();

        // Pre-processing natural language
        String cleanText = text.toLowerCase()
                .replace("tôi muốn mua", "")
                .replace("lấy cho tôi", "")
                .replace("bán cho tôi", "")
                .replace("bán", "")
                .replace("mua", "")
                .replace("cho", "")
                .trim();

        // Split by separators to handle multiple products
        // "10 xi măng và 50 gạch" -> ["10 xi măng", "50 gạch"]
        String[] parts = cleanText.split("(?i)\\s+(và|với|thêm|rồi|mới|cho)\\s+|[,.]");

        // Pattern to find the first number in each part
        Pattern pattern = Pattern.compile("(\\d+)\\s+(.*)");

        List<String> units = List.of("cây", "con", "chiếc", "cái", "bộ", "kg", "tấn", "tạ", "yến", "lạng", "gram",
                "mét", "m", "lit", "l", "hộp", "thùng", "bao", "gói", "viên", "khối");

        int countFound = 0;

        for (String part : parts) {
            part = part.trim();
            if (part.isEmpty())
                continue;

            Matcher matcher = pattern.matcher(part);
            if (matcher.find()) {
                try {
                    int quantity = Integer.parseInt(matcher.group(1));
                    String keyword = matcher.group(2).trim();

                    // Strip leading units
                    for (String u : units) {
                        if (keyword.startsWith(u + " ")) {
                            keyword = keyword.substring(u.length() + 1).trim();
                            break;
                        }
                    }

                    if (keyword.isEmpty())
                        continue;

                    // Search product in DB
                    List<Product> products = productRepository.findByStoreIdAndNameContainingIgnoreCase(storeId,
                            keyword);

                    if (!products.isEmpty()) {
                        Product p = products.get(0);
                        Map<String, Object> item = new HashMap<>();
                        item.put("productId", p.getId());
                        item.put("productName", p.getName());
                        item.put("quantity", quantity);
                        item.put("price", p.getPrice());
                        item.put("unit", p.getUnitName());
                        items.add(item);
                        countFound++;
                    }
                } catch (Exception e) {
                    // Skip parts that can't be parsed
                }
            }
        }

        if (countFound > 0) {
            result.put("reply", "Đã tìm thấy " + countFound + " sản phẩm.");
        } else {
            result.put("reply", "Chưa tìm thấy sản phẩm trong kho. (Lưu ý: Nói dạng 'Số lượng + Tên')");
        }

        Map<String, Object> draftOrder = new HashMap<>();
        draftOrder.put("items", items);

        result.put("draftOrder", draftOrder);
        return result;
    }
}
