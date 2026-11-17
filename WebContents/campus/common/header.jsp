<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 사용법: <jsp:include page="/campus/common/header.jsp"><jsp:param name="menu" value="home"/></jsp:include> --%>
<c:set var="ctx" value="${pageContext.request.contextPath}/campus" />
<c:set var="menu" value="${param.menu}" />
<header class="main-header-v2">
    <div class="header-top-util">
        <div class="inner-container">
            <ul class="util-list">
                <c:choose>
                    <c:when test="${not empty sessionScope.userID}">
                        <li><a href="${ctx}/user/mypage.jsp" class="user-highlight">${sessionScope.userName}님</a></li>
                        <li><a href="${ctx}/user/logout.jsp">로그아웃</a></li>
                    </c:when>
                    <c:otherwise>
                        <li><a href="${ctx}/user/login.jsp">로그인</a></li>
                        <li><a href="${ctx}/user/signup.jsp">회원가입</a></li>
                    </c:otherwise>
                </c:choose>
                <li><a href="${ctx}/user/mypage.jsp?tab=done">거래내역</a></li>
                <li class="dropdown-wrapper">
                    <a href="#" style="cursor: default;">고객센터</a>
                    <div class="dropdown-menu">
                        <a href="#" class="dropdown-item">자주묻는 질문</a>
                        <a href="#" class="dropdown-item">안전거래 가이드</a>
                        <a href="#" class="dropdown-item">신고하기</a>
                    </div>
                </li>
            </ul>
        </div>
    </div>

    <div class="header-main-row">
        <div class="inner-container flex-row">
            <h1 class="brand-logo">
                <a href="${ctx}/index.jsp">
                    <span class="logo-icon">🎓</span>
                    <span class="logo-text">캠퍼스<b>마켓</b></span>
                </a>
            </h1>
            <div class="main-search-bar">
                <form action="${ctx}/product/list.jsp" method="get">
                    <input type="text" name="keyword" value="<c:out value='${param.keyword}'/>"
                           placeholder="전공책, 아이패드, 자취템… 필요한 물건을 검색해보세요" required>
                    <button type="submit">🔍</button>
                </form>
            </div>
            <div class="header-icons">
                <a href="${ctx}/product/register.jsp" class="sell-btn">+ 판매하기</a>
                <a href="${ctx}/user/mypage.jsp?tab=wish" class="icon-item" title="찜한 상품">♡</a>
                <a href="${ctx}/user/mypage.jsp" class="icon-item" title="마이페이지">👤</a>
            </div>
        </div>
    </div>

    <div class="header-gnb-nav">
        <div class="inner-container">
            <nav class="gnb-list">
                <a href="${ctx}/index.jsp" class="gnb-item ${menu == 'home' ? 'active' : ''}">홈</a>
                <a href="${ctx}/product/list.jsp?category=digital" class="gnb-item ${menu == 'digital' ? 'active' : ''}">디지털기기</a>
                <a href="${ctx}/product/list.jsp?category=book" class="gnb-item ${menu == 'book' ? 'active' : ''}">도서・교재</a>
                <a href="${ctx}/product/list.jsp?category=living" class="gnb-item ${menu == 'living' ? 'active' : ''}">생활용품</a>
                <a href="${ctx}/product/list.jsp?category=etc" class="gnb-item ${menu == 'etc' ? 'active' : ''}">기타</a>
                <a href="${ctx}/event/event.jsp" class="gnb-item highlight ${menu == 'event' ? 'active' : ''}">이벤트</a>
            </nav>
        </div>
    </div>
</header>
