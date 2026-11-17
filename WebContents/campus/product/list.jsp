<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, my.model.ProductDTO, my.dao.ProductDAO, my.dao.WishlistDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    request.setCharacterEncoding("UTF-8");
    String userID = (String) session.getAttribute("userID");

    String category = request.getParameter("category");
    String status   = request.getParameter("status");
    String sort     = request.getParameter("sort");
    String keyword  = request.getParameter("keyword");
    if (category == null || category.isEmpty()) category = "all";
    if (status == null || status.isEmpty()) status = "all";
    if (sort == null || sort.isEmpty()) sort = "new";

    Map<String, String> catNames = new LinkedHashMap<>();
    catNames.put("all", "전체 상품");
    catNames.put("digital", "디지털기기");
    catNames.put("book", "도서・교재");
    catNames.put("living", "생활용품");
    catNames.put("etc", "기타");
    if (!catNames.containsKey(category)) category = "all";

    List<ProductDTO> list = new ArrayList<>();
    Set<Integer> myWishSet = new HashSet<>();
    try {
        list = new ProductDAO().getProducts(category, status, keyword, sort);
        if (userID != null) myWishSet = new WishlistDAO().getWishlistProductIdSet(userID);
    } catch (Exception e) { e.printStackTrace(); }

    request.setAttribute("list", list);
    request.setAttribute("myWishSet", myWishSet);
    request.setAttribute("category", category);
    request.setAttribute("status", status);
    request.setAttribute("sort", sort);
    request.setAttribute("catTitle", (keyword != null && !keyword.isEmpty()) ? null : catNames.get(category));
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${empty catTitle ? '검색 결과' : catTitle} - 캠퍼스마켓</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/campus/assets/style.css">
</head>
<body>
<jsp:include page="/campus/common/header.jsp"><jsp:param name="menu" value="${category}" /></jsp:include>
<c:set var="ctx" value="${pageContext.request.contextPath}/campus" />
<c:url var="baseUrl" value="/campus/product/list.jsp">
    <c:param name="category" value="${category}" />
    <c:if test="${not empty param.keyword}"><c:param name="keyword" value="${param.keyword}" /></c:if>
</c:url>

<main>
    <section class="main-section">
        <div class="list-head">
            <h2 class="section-title-main">
                <c:choose>
                    <c:when test="${not empty param.keyword}">'<c:out value="${param.keyword}" />' 검색 결과</c:when>
                    <c:otherwise>${catTitle}</c:otherwise>
                </c:choose>
                <span class="count">${list.size()}개</span>
            </h2>
        </div>

        <!-- 필터 바 -->
        <div class="filter-bar">
            <div class="chip-group">
                <a href="${baseUrl}&sort=${sort}&status=all" class="chip ${status == 'all' ? 'on' : ''}">전체</a>
                <a href="${baseUrl}&sort=${sort}&status=SALE" class="chip ${status == 'SALE' ? 'on' : ''}">판매중</a>
                <a href="${baseUrl}&sort=${sort}&status=RESERVED" class="chip ${status == 'RESERVED' ? 'on' : ''}">예약중</a>
                <a href="${baseUrl}&sort=${sort}&status=DONE" class="chip ${status == 'DONE' ? 'on' : ''}">거래완료</a>
            </div>
            <div class="sort-group">
                <a href="${baseUrl}&status=${status}&sort=new" class="${sort == 'new' ? 'on' : ''}">최신순</a>
                <a href="${baseUrl}&status=${status}&sort=popular" class="${sort == 'popular' ? 'on' : ''}">인기순</a>
                <a href="${baseUrl}&status=${status}&sort=lowPrice" class="${sort == 'lowPrice' ? 'on' : ''}">낮은가격순</a>
                <a href="${baseUrl}&status=${status}&sort=highPrice" class="${sort == 'highPrice' ? 'on' : ''}">높은가격순</a>
            </div>
        </div>

        <c:choose>
            <c:when test="${empty list}">
                <div class="empty-box">
                    <p>조건에 맞는 상품이 없어요 🥲</p>
                    <a href="${ctx}/product/register.jsp" class="btn-primary">첫 상품 등록하기</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="product-grid">
                    <c:forEach var="p" items="${list}">
                        <c:set var="cardItem" value="${p}" scope="request" />
                        <jsp:include page="/campus/common/productCard.jsp" />
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </section>
</main>

<jsp:include page="/campus/common/wing.jsp" />
<jsp:include page="/campus/common/footer.jsp" />
</body>
</html>
