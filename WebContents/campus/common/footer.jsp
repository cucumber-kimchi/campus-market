<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}/campus" />

<button id="scrollToTopBtn" class="scroll-to-top-btn" title="맨 위로">↑</button>

<footer class="site-footer">
    <div class="footer-inner">
        <section class="footer-top-benefit">
            <h3 class="footer-title">🎓 캠퍼스마켓 안전거래 수칙</h3>
            <ul class="benefit-list">
                <li>거래는 가급적 <b>교내 공개 장소</b>(학생회관, 도서관 앞 등)에서 직거래하세요.</li>
                <li>물건을 직접 확인하기 전에는 <b>선입금을 하지 마세요.</b></li>
                <li>학교 인증 회원끼리만 거래할 수 있어 외부인 사기를 줄였습니다.</li>
                <li>거래가 끝나면 상품 상태를 <b>거래완료</b>로 바꿔주세요.</li>
            </ul>
        </section>

        <section class="footer-link-grid">
            <div class="footer-col">
                <h4>서비스</h4>
                <ul>
                    <li><a href="${ctx}/index.jsp">홈</a></li>
                    <li><a href="${ctx}/product/register.jsp">판매하기</a></li>
                    <li><a href="${ctx}/event/event.jsp">이벤트</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h4>카테고리</h4>
                <ul>
                    <li><a href="${ctx}/product/list.jsp?category=digital">디지털기기</a></li>
                    <li><a href="${ctx}/product/list.jsp?category=book">도서・교재</a></li>
                    <li><a href="${ctx}/product/list.jsp?category=living">생활용품</a></li>
                    <li><a href="${ctx}/product/list.jsp?category=etc">기타</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h4>내 활동</h4>
                <ul>
                    <li><a href="${ctx}/user/mypage.jsp">마이페이지</a></li>
                    <li><a href="${ctx}/user/mypage.jsp?tab=wish">찜한 상품</a></li>
                    <li><a href="${ctx}/user/mypage.jsp?tab=done">거래내역</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h4>고객센터</h4>
                <ul>
                    <li>평일 09:00 ~ 18:00</li>
                    <li>문의 campusmarket@school.ac.kr</li>
                </ul>
            </div>
        </section>
        <p class="copyright">© 2026 Campus Market. 웹프로그래밍 텀프로젝트</p>
    </div>
</footer>

<script>const CTX = '${ctx}'; const IS_LOGIN = ${not empty sessionScope.userID};</script>
<script src="${ctx}/assets/script.js"></script>
