<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.File, my.model.ProductDTO, my.dao.ProductDAO" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%
    // ※ cos.jar 필요 (WEB-INF/lib 에 추가)
    String ctx = request.getContextPath() + "/campus";
    String userID = (String) session.getAttribute("userID");
    if (userID == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='" + ctx + "/user/login.jsp';</script>");
        return;
    }

    String savePath = application.getRealPath("/campus/assets/upload");
    File dir = new File(savePath);
    if (!dir.exists()) dir.mkdirs();

    try {
        MultipartRequest multi = new MultipartRequest(request, savePath, 10 * 1024 * 1024, "UTF-8",
                                                      new DefaultFileRenamePolicy());

        String title = multi.getParameter("title");
        String category = multi.getParameter("category");
        String condition = multi.getParameter("itemCondition");
        String description = multi.getParameter("description");
        int price = Integer.parseInt(multi.getParameter("price"));
        String image = multi.getFilesystemName("image");

        // 이미지 확장자 검사
        if (image != null && !image.toLowerCase().matches(".*\\.(jpg|jpeg|png|gif|webp)$")) {
            new File(savePath, image).delete();
            out.println("<script>alert('이미지 파일(jpg, png, gif, webp)만 올릴 수 있어요.'); history.back();</script>");
            return;
        }
        if (title == null || title.trim().isEmpty() || category == null || condition == null || price < 0) {
            out.println("<script>alert('필수 항목을 모두 입력해주세요.'); history.back();</script>");
            return;
        }

        ProductDTO p = new ProductDTO();
        p.setSellerId(userID);
        p.setTitle(title.trim());
        p.setCategory(category);
        p.setItemCondition(condition);
        p.setDescription(description);
        p.setPrice(price);
        p.setImage(image);

        int newId = new ProductDAO().insertProduct(p);
        out.println("<script>alert('상품이 등록되었습니다!'); location.href='" + ctx
                    + "/product/detail.jsp?id=" + newId + "';</script>");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('등록 중 오류가 발생했어요.'); history.back();</script>");
    }
%>
