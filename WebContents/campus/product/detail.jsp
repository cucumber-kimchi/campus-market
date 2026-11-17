<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.net.*, my.model.ProductDTO, my.dao.ProductDAO, my.dao.WishlistDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    String userID = (String) session.getAttribute("userID");
    int id = 0;
    try { id = Integer.parseInt(request.getParameter("id")); } catch (Exception ignore) {}

    ProductDAO dao = new ProductDAO();
    ProductDTO product = null;
    List<ProductDTO> related = new ArrayList<>();
    Set<Integer> myWishSet = new HashSet<>();
    try {
        dao.increaseViewCount(id);
        product = dao.getProduct(id);
        if (product != null) related = dao.getRelatedProducts(product.getCategory(), id, 4);
        if (userID != null) myWishSet = new WishlistDAO().getWishlistProductIdSet(userID);
    } catch (Exception e) { e.printStackTrace(); }

    if (product == null) {
        out.println("<script>alert('존재하지 않거나 삭제된 상품입니다.'); history.back();</script>");
        return;
    }

    // 최근 본 상품 쿠키 저장 (최대 10개, "id:image/id:image")
    String img = product.getImage() == null ? "" : product.getImage();
    String newEntry = id + ":" + img;
    StringBuilder sb = new StringBuilder(newEntry);
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie ck : cookies) {
            if (!"recentItems".equals(ck.getName())) continue;
            int cnt = 1;
            for (String item : URLDecoder.decode(ck.getValue(), "UTF-8").split("/")) {
                if (item.isEmpty() || item.startsWith(id + ":") || cnt >= 10) continue;
                sb.append("/").append(item);
                cnt++;
            }
        }
    }
    Cookie recent = new Cookie("recentItems", URLEncoder.encode(sb.toString(), "UTF-8"));
    recent.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
    recent.setMaxAge(60 * 60 * 24 * 7);
    response.addCookie(recent);

    request.setAttribute("product", product);
    request.setAttribute("related", related);
    request.setAttribute("myWishSet", myWishSet);
    request.setAttribute("isOwner", userID != null && userID.equals(product.getSellerId()));
    request.setAttribute("wished", myWishSet.contains(id));
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><c:out value="${product.title}" /> - 캠퍼스마켓</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/campus/assets/style.css">
</head>
<body>
<jsp:include page="/campus/common/header.jsp"><jsp:param name="menu" value="${product.category}" /></jsp:include>
<c:set var="ctx" value="${pageContext.request.contextPath}/campus" />

<main>
    <nav class="breadcrumb">
        <a href="${ctx}/index.jsp">홈</a> ›
        <a href="${ctx}/product/list.jsp?category=${product.category}">${product.categoryLabel}</a> ›
        <span><c:out value="${product.title}" /></span>
    </nav>

    <section class="detail-wrap">
        <div class="detail-image">
            <c:choose>
                <c:when test="${not empty product.image}">
                    <img src="${ctx}/assets/upload/${product.image}" alt="<c:out value='${product.title}'/>">
                </c:when>
                <c:otherwise>
                    <div class="product-main-img no-image cat-${product.category}"><span>${product.categoryLabel}</span></div>
                </c:otherwise>
            </c:choose>
            <c:if test="${product.status == 'DONE'}"><div class="done-overlay big">거래완료</div></c:if>
        </div>

        <div class="detail-info">
            <div class="detail-badges">
                <span class="status-badge inline status-${product.status}">${product.statusLabel}</span>
                <span class="tag">${product.categoryLabel}</span>
                <span class="tag">${product.itemCondition}</span>
            </div>
            <h2 class="detail-title"><c:out value="${product.title}" /></h2>
            <p class="detail-price"><fmt:formatNumber value="${product.price}" pattern="#,###" />원</p>

            <ul class="detail-meta">
                <li><span>판매자</span><b><c:out value="${product.sellerName}" /></b></li>
                <li><span>등록</span>${product.timeAgo}</li>
                <li><span>조회</span>${product.viewCount}회</li>
                <li><span>찜</span><b id="wishCount">${product.wishCount}</b>명</li>
            </ul>

            <c:choose>
                <c:when test="${isOwner}">
                    <!-- 판매자 본인: 거래 상태 변경 -->
                    <form class="status-form" action="${ctx}/product/statusProcess.jsp" method="post">
                        <input type="hidden" name="id" value="${product.id}">
                        <input type="hidden" name="redirect" value="detail">
                        <p class="form-label">거래 상태 변경</p>
                        <div class="status-switch">
                            <button name="status" value="SALE" class="${product.status == 'SALE' ? 'on' : ''}">판매중</button>
                            <button name="status" value="RESERVED" class="${product.status == 'RESERVED' ? 'on' : ''}">예약중</button>
                            <button name="status" value="DONE" class="${product.status == 'DONE' ? 'on' : ''}">거래완료</button>
                        </div>
                    </form>
                    <form action="${ctx}/product/deleteProcess.jsp" method="post"
                          onsubmit="return confirm('정말 삭제할까요? 되돌릴 수 없습니다.');">
                        <input type="hidden" name="id" value="${product.id}">
                        <button class="btn-outline full">상품 삭제</button>
                    </form>
                </c:when>
                <c:otherwise>
                    <div class="detail-actions">
                        <button type="button" class="heart-btn big ${wished ? 'active' : ''}"
                                onclick="toggleHeart(this, ${product.id})">♥</button>
                        <c:choose>
                            <c:when test="${product.status == 'DONE'}">
                                <button class="btn-primary full" disabled>거래가 완료된 상품이에요</button>
                            </c:when>
                            <c:otherwise>
                                <button type="button" class="btn-primary full need-login"
                                        onclick="if(IS_LOGIN) alert('판매자에게 채팅 요청을 보냈어요! (채팅 기능은 추후 연결)')">
                                    💬 판매자와 채팅하기
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </section>

    <section class="detail-desc">
        <h3>상품 설명</h3>
        <div class="desc-body"><c:out value="${product.description}" /></div>
        <div class="safe-tip">🛡️ 교내 공개된 장소에서 물건을 직접 확인한 뒤 거래하세요. 선입금 요구는 사기일 수 있어요.</div>
    </section>

    <c:if test="${not empty related}">
        <section class="main-section">
            <div class="section-header-wrap">
                <h2 class="section-title-main">이 카테고리의 다른 상품</h2>
                <a href="${ctx}/product/list.jsp?category=${product.category}" class="more-btn">더보기 +</a>
            </div>
            <div class="product-grid">
                <c:forEach var="p" items="${related}">
                    <c:set var="cardItem" value="${p}" scope="request" />
                    <jsp:include page="/campus/common/productCard.jsp" />
                </c:forEach>
            </div>
        </section>
    </c:if>
</main>

<jsp:include page="/campus/common/wing.jsp" />
<jsp:include page="/campus/common/footer.jsp" />
</body>
</html>
