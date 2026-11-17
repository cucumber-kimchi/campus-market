<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- 최근 본 상품 윙배너 (detail.jsp에서 recentItems 쿠키 저장: "id:image/id:image/...") --%>
<div class="wing-banner">
    <div class="wing-title">최근 본 상품</div>
    <%
        String ctxW = request.getContextPath() + "/campus";
        int wingCount = 0;
        Cookie[] cookiesWing = request.getCookies();
        if (cookiesWing != null) {
            for (Cookie ck : cookiesWing) {
                if (!"recentItems".equals(ck.getName())) continue;
                String raw = java.net.URLDecoder.decode(ck.getValue(), "UTF-8");
                for (String item : raw.split("/")) {
                    if (wingCount >= 3) break;
                    String[] parts = item.split(":", -1);
                    if (parts.length < 2 || !parts[0].matches("\\d+")) continue;
                    String rId = parts[0];
                    String rImg = parts[1].replaceAll("[^A-Za-z0-9._-]", "");
    %>
        <a class="recent-item" href="<%=ctxW%>/product/detail.jsp?id=<%=rId%>">
            <% if (!rImg.isEmpty()) { %>
                <img src="<%=ctxW%>/assets/upload/<%=rImg%>" alt="">
            <% } else { %>
                <span class="recent-noimg">#<%=rId%></span>
            <% } %>
        </a>
    <%
                    wingCount++;
                }
                break;
            }
        }
        if (wingCount == 0) {
    %>
        <p class="wing-empty">아직 본 상품이<br>없어요</p>
    <% } %>
    <a href="#" class="wing-more-btn" onclick="window.scrollTo({top:0,behavior:'smooth'});return false;">TOP</a>
</div>
