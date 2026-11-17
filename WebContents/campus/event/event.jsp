<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>이벤트 - 캠퍼스마켓</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/campus/assets/style.css">
</head>
<body>
<jsp:include page="/campus/common/header.jsp"><jsp:param name="menu" value="event" /></jsp:include>
<c:set var="ctx" value="${pageContext.request.contextPath}/campus" />
<main>
    <section class="main-section">
        <h2 class="section-title-main">진행 중인 이벤트</h2>
        <div class="event-grid">
            <div class="event-card ev-1">
                <span class="event-period">진행중 · ~12.31</span>
                <h3>🎁 첫 거래 완료 이벤트</h3>
                <p>캠퍼스마켓에서 첫 거래를 완료하면 학식 쿠폰 1장을 드려요.</p>
                <a href="${ctx}/product/register.jsp" class="btn-light">지금 판매하기</a>
            </div>
            <div class="event-card ev-2">
                <span class="event-period">진행중 · 기말고사 기간</span>
                <h3>📚 전공책 나눔 주간</h3>
                <p>도서・교재 카테고리 상품을 0원 나눔으로 올리면 메인 상단에 노출해드려요.</p>
                <a href="${ctx}/product/list.jsp?category=book" class="btn-light">교재 보러가기</a>
            </div>
            <div class="event-card ev-3">
                <span class="event-period">상시</span>
                <h3>🤖 AI 판매글 체험</h3>
                <p>AI로 판매글을 작성해 등록하면 추첨을 통해 커피 기프티콘을 드려요.</p>
                <a href="${ctx}/product/register.jsp" class="btn-light">AI로 작성하기</a>
            </div>
            <div class="event-card ev-4 ended">
                <span class="event-period">종료</span>
                <h3>🏠 기숙사 이사철 특가</h3>
                <p>생활용품 거래 시 수수료 0원! (종료된 이벤트입니다)</p>
            </div>
        </div>
    </section>
</main>
<jsp:include page="/campus/common/footer.jsp" />
</body>
</html>
