<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="my.model.ProductDTO" %>
<%@ page import="my.dao.ProductDAO" %>
<%@ page import="my.dao.WishlistDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // 1. 로그인 사용자
    String userID = (String) session.getAttribute("userID");

    // 2. DAO로 메인 데이터 준비
    ProductDAO productDAO = new ProductDAO();
    WishlistDAO wishlistDAO = new WishlistDAO();

    List<ProductDTO> popularList = new ArrayList<>();
    List<ProductDTO> newList = new ArrayList<>();
    Set<Integer> myWishSet = new HashSet<>();

    try {
        popularList = productDAO.getPopularProducts(8);   // 인기 상품 8개
        newList = productDAO.getNewProducts(8);           // 최신 등록 8개
        if (userID != null) myWishSet = wishlistDAO.getWishlistProductIdSet(userID);
    } catch (Exception e) {
        e.printStackTrace();
    }

    // 3. EL / include 페이지에서 쓰도록 request에 올림
    request.setAttribute("popularList", popularList);
    request.setAttribute("newList", newList);
    request.setAttribute("myWishSet", myWishSet);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>캠퍼스마켓 - 우리 학교 중고거래</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/campus/assets/style.css">
</head>
<body>
<jsp:include page="/campus/common/header.jsp"><jsp:param name="menu" value="home" /></jsp:include>
<c:set var="ctx" value="${pageContext.request.contextPath}/campus" />

<!-- ===== 메인 배너 슬라이더 ===== -->
<section class="banner-slider-wrapper">
    <div class="banner-track">
        <a href="${ctx}/product/register.jsp" class="visual-banner slide banner-1">
            <div class="banner-text">
                <span class="banner-tag">AI 판매글 작성</span>
                <h2>몇 가지만 입력하면<br>판매글은 AI가 써드려요</h2>
                <p>상품명 · 가격 · 상태 · 특징만 입력하고 바로 등록하세요</p>
            </div>
            <div class="banner-emoji">🤖</div>
        </a>
        <a href="${ctx}/product/list.jsp?category=book" class="visual-banner slide banner-2">
            <div class="banner-text">
                <span class="banner-tag">새 학기 특집</span>
                <h2>선배가 쓰던 전공책,<br>반값에 득템하세요</h2>
                <p>도서・교재 카테고리 바로가기</p>
            </div>
            <div class="banner-emoji">📚</div>
        </a>
        <a href="${ctx}/event/event.jsp" class="visual-banner slide banner-3">
            <div class="banner-text">
                <span class="banner-tag">EVENT</span>
                <h2>첫 거래 완료하면<br>학식 쿠폰 증정!</h2>
                <p>이벤트 자세히 보기</p>
            </div>
            <div class="banner-emoji">🎁</div>
        </a>
    </div>
    <button class="slider-btn prev-btn" type="button">❮</button>
    <button class="slider-btn next-btn" type="button">❯</button>
    <div class="slider-dots">
        <span class="dot active" data-index="0"></span>
        <span class="dot" data-index="1"></span>
        <span class="dot" data-index="2"></span>
    </div>
</section>

<main>
    <!-- ===== 카테고리 바로가기 ===== -->
    <section class="main-section">
        <div class="category-quick">
            <a href="${ctx}/product/list.jsp?category=digital" class="quick-item"><span class="quick-icon">💻</span>디지털기기</a>
            <a href="${ctx}/product/list.jsp?category=book" class="quick-item"><span class="quick-icon">📚</span>도서・교재</a>
            <a href="${ctx}/product/list.jsp?category=living" class="quick-item"><span class="quick-icon">🛋️</span>생활용품</a>
            <a href="${ctx}/product/list.jsp?category=etc" class="quick-item"><span class="quick-icon">🎒</span>기타</a>
            <a href="${ctx}/product/list.jsp?category=all&status=SALE" class="quick-item"><span class="quick-icon">🟢</span>판매중만</a>
            <a href="${ctx}/product/register.jsp" class="quick-item quick-sell"><span class="quick-icon">✍️</span>판매하기</a>
        </div>
    </section>

    <!-- ===== 인기 상품 ===== -->
    <section class="main-section">
        <div class="section-header-wrap">
            <h2 class="section-title-main">🔥 지금 인기 있는 상품</h2>
            <a href="${ctx}/product/list.jsp?category=all&sort=popular" class="more-btn">더보기 +</a>
        </div>
        <c:choose>
            <c:when test="${empty popularList}">
                <p class="empty-msg">등록된 상품이 없습니다.</p>
            </c:when>
            <c:otherwise>
                <div class="product-grid">
                    <c:forEach var="p" items="${popularList}" varStatus="st">
                        <c:set var="cardItem" value="${p}" scope="request" />
                        <c:set var="cardRank" value="${st.count}" scope="request" />
                        <jsp:include page="/campus/common/productCard.jsp" />
                    </c:forEach>
                    <c:remove var="cardRank" scope="request" />
                </div>
            </c:otherwise>
        </c:choose>
    </section>

    <!-- ===== AI 등록 안내 ===== -->
    <section class="main-section">
        <a href="${ctx}/product/register.jsp" class="ai-cta">
            <div>
                <strong>판매글 쓰기 귀찮으셨죠? 🤖</strong>
                <p>상품명, 가격, 상태, 특징만 입력하면 AI가 제목과 상세 설명을 자동으로 만들어 드려요.</p>
            </div>
            <span class="ai-cta-btn">AI로 판매글 쓰기 →</span>
        </a>
    </section>

    <!-- ===== 최신 등록 상품 ===== -->
    <section class="main-section">
        <div class="section-header-wrap">
            <h2 class="section-title-main">✨ 방금 올라온 상품</h2>
            <a href="${ctx}/product/list.jsp?category=all&sort=new" class="more-btn">더보기 +</a>
        </div>
        <c:choose>
            <c:when test="${empty newList}">
                <p class="empty-msg">등록된 상품이 없습니다.</p>
            </c:when>
            <c:otherwise>
                <div class="product-grid">
                    <c:forEach var="p" items="${newList}">
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
