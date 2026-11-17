<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, my.model.ProductDTO, my.dao.ProductDAO, my.dao.WishlistDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    String userID = (String) session.getAttribute("userID");
    if (userID == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='"
                    + request.getContextPath() + "/campus/user/login.jsp';</script>");
        return;
    }

    // tab: selling(판매중+예약중) / done(거래완료=거래내역) / wish(찜) / all
    String tab = request.getParameter("tab");
    if (tab == null || !Arrays.asList("selling", "done", "wish", "all").contains(tab)) tab = "selling";

    ProductDAO dao = new ProductDAO();
    WishlistDAO wdao = new WishlistDAO();
    List<ProductDTO> items = new ArrayList<>();
    int saleCnt = 0, reservedCnt = 0, doneCnt = 0, wishCnt = 0;
    long doneTotal = 0;
    Set<Integer> myWishSet = new HashSet<>();

    try {
        saleCnt = dao.countBySeller(userID, "SALE");
        reservedCnt = dao.countBySeller(userID, "RESERVED");
        doneCnt = dao.countBySeller(userID, "DONE");
        myWishSet = wdao.getWishlistProductIdSet(userID);
        wishCnt = myWishSet.size();
        for (ProductDTO d : dao.getProductsBySeller(userID, "DONE")) doneTotal += d.getPrice();

        if ("wish".equals(tab)) {
            items = wdao.getWishlistProducts(userID);
        } else if ("done".equals(tab)) {
            items = dao.getProductsBySeller(userID, "DONE");
        } else if ("all".equals(tab)) {
            items = dao.getProductsBySeller(userID, null);
        } else {
            for (ProductDTO p : dao.getProductsBySeller(userID, null))
                if (!"DONE".equals(p.getStatus())) items.add(p);
        }
    } catch (Exception e) { e.printStackTrace(); }

    request.setAttribute("tab", tab);
    request.setAttribute("items", items);
    request.setAttribute("myWishSet", myWishSet);
    request.setAttribute("saleCnt", saleCnt);
    request.setAttribute("reservedCnt", reservedCnt);
    request.setAttribute("doneCnt", doneCnt);
    request.setAttribute("wishCnt", wishCnt);
    request.setAttribute("doneTotal", doneTotal);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>마이페이지 - 캠퍼스마켓</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/campus/assets/style.css">
</head>
<body>
<jsp:include page="/campus/common/header.jsp"><jsp:param name="menu" value="" /></jsp:include>
<c:set var="ctx" value="${pageContext.request.contextPath}/campus" />

<main>
    <!-- 프로필 -->
    <section class="mypage-profile">
        <div class="profile-avatar">${fn:substring(sessionScope.userName, 0, 1)}</div>
        <div class="profile-text">
            <h2><c:out value="${sessionScope.userName}" />님</h2>
            <p>🎓 <c:out value="${sessionScope.userSchool}" /> · 인증 회원</p>
        </div>
        <a href="${ctx}/product/register.jsp" class="btn-primary">+ 상품 등록</a>
    </section>

    <!-- 요약 -->
    <section class="mypage-stats">
        <a href="?tab=selling" class="stat"><b>${saleCnt}</b><span>판매중</span></a>
        <a href="?tab=selling" class="stat"><b>${reservedCnt}</b><span>예약중</span></a>
        <a href="?tab=done" class="stat"><b>${doneCnt}</b><span>거래완료</span></a>
        <a href="?tab=wish" class="stat"><b>${wishCnt}</b><span>찜한 상품</span></a>
        <div class="stat highlight"><b><fmt:formatNumber value="${doneTotal}" pattern="#,##0" />원</b><span>누적 판매금액</span></div>
    </section>

    <!-- 탭 -->
    <nav class="tab-nav">
        <a href="?tab=selling" class="${tab == 'selling' ? 'on' : ''}">판매 중인 상품</a>
        <a href="?tab=done" class="${tab == 'done' ? 'on' : ''}">거래 내역</a>
        <a href="?tab=wish" class="${tab == 'wish' ? 'on' : ''}">찜한 상품</a>
        <a href="?tab=all" class="${tab == 'all' ? 'on' : ''}">등록한 전체 상품</a>
    </nav>

    <section class="main-section">
        <c:choose>
            <c:when test="${empty items}">
                <div class="empty-box">
                    <p>
                        <c:choose>
                            <c:when test="${tab == 'wish'}">아직 찜한 상품이 없어요.</c:when>
                            <c:when test="${tab == 'done'}">완료된 거래가 없어요.</c:when>
                            <c:otherwise>등록한 상품이 없어요.</c:otherwise>
                        </c:choose>
                    </p>
                    <a href="${ctx}/index.jsp" class="btn-outline">상품 둘러보기</a>
                </div>
            </c:when>

            <%-- 찜 탭은 카드형 --%>
            <c:when test="${tab == 'wish'}">
                <div class="product-grid">
                    <c:forEach var="p" items="${items}">
                        <c:set var="cardItem" value="${p}" scope="request" />
                        <jsp:include page="/campus/common/productCard.jsp" />
                    </c:forEach>
                </div>
            </c:when>

            <%-- 내 상품 탭은 관리용 표 --%>
            <c:otherwise>
                <table class="manage-table">
                    <thead>
                        <tr><th>상품</th><th>가격</th><th>등록</th><th>조회/찜</th><th>거래 상태</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${items}">
                            <tr>
                                <td class="td-product">
                                    <a href="${ctx}/product/detail.jsp?id=${p.id}">
                                        <c:choose>
                                            <c:when test="${not empty p.image}">
                                                <img src="${ctx}/assets/upload/${p.image}" alt="">
                                            </c:when>
                                            <c:otherwise><span class="thumb-noimg cat-${p.category}">${p.categoryLabel}</span></c:otherwise>
                                        </c:choose>
                                        <span><c:out value="${p.title}" /></span>
                                    </a>
                                </td>
                                <td><fmt:formatNumber value="${p.price}" pattern="#,###" />원</td>
                                <td>${p.timeAgo}</td>
                                <td>${p.viewCount} / ${p.wishCount}</td>
                                <td>
                                    <form action="${ctx}/product/statusProcess.jsp" method="post">
                                        <input type="hidden" name="id" value="${p.id}">
                                        <input type="hidden" name="redirect" value="mypage">
                                        <input type="hidden" name="tab" value="${tab}">
                                        <select name="status" class="status-select status-${p.status}" onchange="this.form.submit()">
                                            <option value="SALE" ${p.status == 'SALE' ? 'selected' : ''}>판매중</option>
                                            <option value="RESERVED" ${p.status == 'RESERVED' ? 'selected' : ''}>예약중</option>
                                            <option value="DONE" ${p.status == 'DONE' ? 'selected' : ''}>거래완료</option>
                                        </select>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </section>
</main>

<jsp:include page="/campus/common/footer.jsp" />
</body>
</html>
