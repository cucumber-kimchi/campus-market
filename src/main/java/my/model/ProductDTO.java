package my.model;

import java.sql.Timestamp;

public class ProductDTO {
    private int id;
    private String sellerId;
    private String sellerName;
    private String title;
    private int price;
    private String category;      // digital / book / living / etc
    private String itemCondition; // 새상품 / 거의 새것 / 사용감 있음 / 하자 있음
    private String description;
    private String image;
    private String status;        // SALE / RESERVED / DONE
    private int viewCount;
    private int wishCount;
    private Timestamp createdAt;

    /* ===== 화면 표시용 라벨 ===== */
    public String getCategoryLabel() {
        if (category == null) return "기타";
        switch (category) {
            case "digital": return "디지털기기";
            case "book":    return "도서・교재";
            case "living":  return "생활용품";
            default:        return "기타";
        }
    }

    public String getStatusLabel() {
        if ("RESERVED".equals(status)) return "예약중";
        if ("DONE".equals(status))     return "거래완료";
        return "판매중";
    }

    /** "3분 전", "2일 전" 같은 상대 시간 */
    public String getTimeAgo() {
        if (createdAt == null) return "";
        long diff = (System.currentTimeMillis() - createdAt.getTime()) / 1000;
        if (diff < 60) return "방금 전";
        if (diff < 3600) return (diff / 60) + "분 전";
        if (diff < 86400) return (diff / 3600) + "시간 전";
        if (diff < 86400 * 30) return (diff / 86400) + "일 전";
        return new java.text.SimpleDateFormat("yyyy.MM.dd").format(createdAt);
    }

    /* ===== getter / setter ===== */
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getSellerId() { return sellerId; }
    public void setSellerId(String sellerId) { this.sellerId = sellerId; }
    public String getSellerName() { return sellerName; }
    public void setSellerName(String sellerName) { this.sellerName = sellerName; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getItemCondition() { return itemCondition; }
    public void setItemCondition(String itemCondition) { this.itemCondition = itemCondition; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getViewCount() { return viewCount; }
    public void setViewCount(int viewCount) { this.viewCount = viewCount; }
    public int getWishCount() { return wishCount; }
    public void setWishCount(int wishCount) { this.wishCount = wishCount; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
