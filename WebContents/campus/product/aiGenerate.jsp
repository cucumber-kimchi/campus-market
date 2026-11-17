<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.io.*, java.net.*, java.nio.charset.StandardCharsets, java.util.regex.*" %>
<%!
    /*
     * AI 판매글 생성 API
     * - 환경변수 ANTHROPIC_API_KEY 가 있으면 Claude API 호출
     * - 없거나 실패하면 규칙 기반 템플릿으로 생성 (발표/시연 시에도 동작하도록)
     * 응답: {"status":"ok","source":"ai|template","title":"...","description":"..."}
     */
    static final String MODEL = "claude-haiku-5-5";

    static String jsonEscape(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder();
        for (char ch : s.toCharArray()) {
            switch (ch) {
                case '"':  sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n");  break;
                case '\r': break;
                case '\t': sb.append("\\t");  break;
                default:
                    if (ch < 0x20) sb.append(String.format("\\u%04x", (int) ch));
                    else sb.append(ch);
            }
        }
        return sb.toString();
    }

    /** Claude 응답 JSON에서 첫 번째 "text" 값만 꺼내기 (라이브러리 없이) */
    static String extractText(String json) {
        Matcher m = Pattern.compile("\"text\"\\s*:\\s*\"").matcher(json);
        if (!m.find()) return null;
        StringBuilder sb = new StringBuilder();
        for (int i = m.end(); i < json.length(); i++) {
            char ch = json.charAt(i);
            if (ch == '"') break;
            if (ch == '\\' && i + 1 < json.length()) {
                char n = json.charAt(++i);
                switch (n) {
                    case 'n': sb.append('\n'); break;
                    case 't': sb.append('\t'); break;
                    case 'r': break;
                    case 'u': sb.append((char) Integer.parseInt(json.substring(i + 1, i + 5), 16)); i += 4; break;
                    default:  sb.append(n);
                }
            } else sb.append(ch);
        }
        return sb.toString();
    }

    static String callClaude(String apiKey, String prompt) throws IOException {
        URL url = new URL("https://api.anthropic.com/v1/messages");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(30000);
        conn.setDoOutput(true);
        conn.setRequestProperty("content-type", "application/json");
        conn.setRequestProperty("x-api-key", apiKey);
        conn.setRequestProperty("anthropic-version", "2023-06-01");

        String body = "{\"model\":\"" + MODEL + "\",\"max_tokens\":800,"
                    + "\"messages\":[{\"role\":\"user\",\"content\":\"" + jsonEscape(prompt) + "\"}]}";
        try (OutputStream os = conn.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }
        if (conn.getResponseCode() != 200) throw new IOException("HTTP " + conn.getResponseCode());

        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) sb.append(line);
        }
        return extractText(sb.toString());
    }

    static String nvl(String s) { return s == null ? "" : s.trim(); }
%>
<%
    request.setCharacterEncoding("UTF-8");

    if (session.getAttribute("userID") == null) {
        out.print("{\"status\":\"login_required\",\"message\":\"로그인이 필요합니다.\"}");
        return;
    }

    String name = nvl(request.getParameter("name"));
    String price = nvl(request.getParameter("price"));
    String condition = nvl(request.getParameter("condition"));
    String category = nvl(request.getParameter("category"));
    String features = nvl(request.getParameter("features"));

    if (name.isEmpty() || price.isEmpty() || condition.isEmpty()) {
        out.print("{\"status\":\"error\",\"message\":\"상품명, 가격, 상품 상태를 입력해주세요.\"}");
        return;
    }
    String priceText;
    try { priceText = String.format("%,d", Long.parseLong(price)); } catch (Exception e) { priceText = price; }

    String title = null, description = null, source = "template";

    // 1) Claude API 시도
    String apiKey = System.getenv("ANTHROPIC_API_KEY");
    if (apiKey != null && !apiKey.isEmpty()) {
        String prompt =
            "너는 대학생 중고거래 사이트 '캠퍼스마켓'의 판매글 작성 도우미야.\n"
          + "아래 정보로 같은 학교 학생에게 올릴 판매 게시글을 써줘.\n\n"
          + "- 상품명: " + name + "\n"
          + "- 카테고리: " + category + "\n"
          + "- 가격: " + priceText + "원\n"
          + "- 상품 상태: " + condition + "\n"
          + "- 주요 특징: " + (features.isEmpty() ? "(없음)" : features) + "\n\n"
          + "규칙:\n"
          + "1. 제목은 40자 이내, 상품명과 핵심 장점이 드러나게.\n"
          + "2. 설명은 친근한 존댓말로 5~8줄. 상품 소개, 상태, 구성품/특징, 거래 방법(교내 직거래 권장) 순서.\n"
          + "3. 입력에 없는 사실(구매처, 보증기간 등)은 지어내지 마.\n"
          + "4. 이모지는 최대 2개.\n"
          + "5. 반드시 아래 형식으로만 답해. 다른 말은 쓰지 마.\n"
          + "[제목]\n(제목)\n[설명]\n(설명)";
        try {
            String text = callClaude(apiKey, prompt);
            if (text != null && text.contains("[설명]")) {
                String[] parts = text.split("\\[설명\\]", 2);
                title = parts[0].replace("[제목]", "").trim();
                description = parts[1].trim();
                source = "ai";
            }
        } catch (Exception e) {
            e.printStackTrace();   // 실패 시 템플릿으로 대체
        }
    }

    // 2) 템플릿 대체 생성
    if (title == null || title.isEmpty()) {
        String point = "";
        if (!features.isEmpty()) {
            point = features.split("[,\\n.]")[0].trim();
            if (point.length() > 15) point = point.substring(0, 15);
        }
        title = "[" + condition + "] " + name + (point.isEmpty() ? " 판매합니다" : " · " + point);

        StringBuilder d = new StringBuilder();
        d.append("안녕하세요! ").append(name).append(" 판매합니다.\n\n");
        d.append("■ 가격: ").append(priceText).append("원\n");
        d.append("■ 상태: ").append(condition).append("\n");
        if (!category.isEmpty()) d.append("■ 카테고리: ").append(category).append("\n");
        if (!features.isEmpty()) {
            d.append("\n■ 특징\n");
            for (String f : features.split("[,\\n]")) {
                if (!f.trim().isEmpty()) d.append(" - ").append(f.trim()).append("\n");
            }
        }
        d.append("\n교내에서 직거래 가능하고, 궁금한 점은 채팅 주세요 :)");
        description = d.toString();
    }

    out.print("{\"status\":\"ok\",\"source\":\"" + source + "\",\"title\":\"" + jsonEscape(title)
              + "\",\"description\":\"" + jsonEscape(description) + "\"}");
%>
