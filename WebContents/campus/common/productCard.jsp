<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%--
  상품 카드 공통 조각
  호출 전에 request 영역에 cardItem(ProductDTO), (선택) cardRank, myWishSet 을 올려두고 include
  ※ ${set.contains(x)} 는 EL 3.0(Tomcat 8 이상)에서 동작
--%>
<c:set var="ctx" value="${pageContext.request.contextPath}/campus" />
<c:set var="p" value="${requestScope.cardItem}" />
<c:set var="rank" value="${requestScope.cardRank}" />
<c:set var="wished" value="${not empty requestScope.myWishSet and requestScope.myWishSet.contains(p.id)}" />

<div class="product-card ${p.status == 'DONE' ? 'is-done' : ''}">
    <div class="product-image-container">
        <c:if test="${not empty rank and rank le 3}">
            <div class="rank-badge rank-${rank}">${rank}위</div>
        </c:if>
        <span class="status-badge status-${p.status}">${p.statusLabel}</span>

        <button type="button" class="heart-btn ${wished ? 'active' : ''}" onclick="toggleHeart(this, ${p.id})">♥</button>

        <a href="${ctx}/product/detail.jsp?id=${p.id}" class="img-link">
            <c:choose>
                <c:when test="${not empty p.image}">
                    <div class="product-main-img" style="background-image:url('${ctx}/assets/upload/${p.image}');"></div>
                </c:when>
                <c:otherwise>
                    <div class="product-main-img no-image cat-${p.category}"><span>${p.categoryLabel}</span></div>
                </c:otherwise>
            </c:choose>
            <c:if test="${p.status == 'DONE'}"><div class="done-overlay">거래완료</div></c:if>
        </a>
    </div>

    <a href="${ctx}/product/detail.jsp?id=${p.id}" class="product-footer-info">
        <span class="product-category">${p.categoryLabel} · ${p.itemCondition}</span>
        <p class="product-title"><c:out value="${p.title}" /></p>
        <p class="price-final"><fmt:formatNumber value="${p.price}" pattern="#,###" />원</p>
        <div class="product-meta">
            <span>${p.timeAgo}</span>
            <span>👁 ${p.viewCount} · ♡ ${p.wishCount}</span>
        </div>
    </a>
</div>
