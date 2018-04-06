<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page
	import="javax.xml.parsers.*, org.w3c.dom.*, org.xml.sax.*, javax.xml.xpath.*, java.net.*"%>
<%
	//JSP code
	request.setCharacterEncoding("UTF-8");
	String contextRoot = request.getContextPath();
	StringBuilder sb = new StringBuilder();

	DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
	DocumentBuilder builder = factory.newDocumentBuilder();
	Document xmlObj = null;

	String key = request.getParameter("key");
	String value = request.getParameter("value");

	String totalRows = "0";
	if (key == null) {
		key = "";
		value = "";
		sb.append("<div style =\"text-align: center;\">검색어를 입력해 주세요.</div>");
	} else {
		String str = String.format(
				"http://book.interpark.com/api/search.api?key=7D000600C2E163DE162954A0168941F3F3509861765F0AFFE7CFDF915EF1F418&inputEncoding=utf-8&query=%s&queryType=%s&maxResults=100",
				URLEncoder.encode(value, "UTF-8"), key);
		URL url = new URL(str);

		InputSource is = new InputSource(url.openStream());
		xmlObj = builder.parse(is);

		// ROOT 엘리먼트 접근
		Element root = xmlObj.getDocumentElement();

		// XPath에 의한 XML 엘리먼트 탐색
		XPath xPath = XPathFactory.newInstance().newXPath();

		// 도서 검색
		NodeList itemList = (NodeList) xPath.compile("channel/item").evaluate(xmlObj, XPathConstants.NODESET);

		totalRows = xPath.compile("channel/totalResults").evaluate(xmlObj);
		
		if (totalRows.equals("0")) {
			sb.append("<div style =\"text-align: center;\">검색 결과가 없습니다.</div>");
		} else {

			for (int i = 1; i <= itemList.getLength(); ++i) {
				String coverLargeUrl = xPath.compile(String.format("channel/item[%d]/coverSmallUrl", i))
						.evaluate(xmlObj);
				String title = xPath.compile(String.format("channel/item[%d]/title", i)).evaluate(xmlObj);
				String description = (xPath.compile(String.format("channel/item[%d]/description", i))
						.evaluate(xmlObj));
				if (description.length() > 100) {
					description = description.substring(0, 100) + "...";
				}
				String publisher = xPath.compile(String.format("channel/item[%d]/publisher", i)).evaluate(xmlObj);
				String author = xPath.compile(String.format("channel/item[%d]/author", i)).evaluate(xmlObj);
				String priceStandard = xPath.compile(String.format("channel/item[%d]/priceStandard", i))
						.evaluate(xmlObj);
				String isbn = xPath.compile(String.format("channel/item[%d]/isbn", i)).evaluate(xmlObj);
				String pubDate = xPath.compile(String.format("channel/item[%d]/pubDate", i)).evaluate(xmlObj);
				String link = xPath.compile(String.format("channel/item[%d]/link", i)).evaluate(xmlObj);
	
				sb.append("<div class=\"row\" style=\"margin-top:30px; border-top:1px dashed #e5e5e5; padding-top:20px;\">");
				sb.append(String.format("<div class=\"col-sm-1\">%d</div>", i));
				sb.append(String.format("<div class=\"col-sm-2\"><img src=\"%s\" alt=\"%s\"></div>", coverLargeUrl,
						coverLargeUrl));
				sb.append("<div  class=\"col-sm-7\">");
				sb.append(String.format(
						"<ul><li><strong>title</strong> %s</li><li><strong>description</strong> %s</li><li><strong>publisher</strong> %s</li><li><strong>author</strong> %s</li><li><strong>priceStandard</strong> %s</li><li><strong>isbn</strong> %s</li><li><strong>pubDate</strong> %s</li></ul>",
						title, description, publisher, author, priceStandard, isbn, pubDate));
				sb.append("</div>");
				sb.append("<div class=\"col-sm-2\">");
				sb.append(String.format(
						"<button type=\"button\" class=\"btn btn-default btn-xs\" onclick=\"window.open('%s')\">인터파크 상세보기</button>",
						link));
				sb.append("</div>");
				sb.append("</div>");
			}
		}
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1">

<title>SIST_쌍용교육센터</title>

<!-- Latest compiled and minified CSS -->
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">

<style>
div#input:hover, div#output:hover {
	box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0
		rgba(0, 0, 0, 0.19);
}
</style>

<!-- Google Map API -->
<script src="https://maps.googleapis.com/maps/api/js"></script>

<!-- jQuery library -->
<script
	src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>

<!-- Latest compiled JavaScript -->
<script
	src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>


<script>
	$(document).ready(function() {

		var key = "<%=key%>";
        var value = "<%=value%>";
		$("select#key > option[value=" + key + "]").attr("selected", "selected");
		$("input#value").val(value);
		
	});
</script>
</head>
<body>

	<div class="container">

		<div class="panel page-header" style="text-align: center;">
			<h1 style="font-size: xx-large;">
				<img
					src="<%=contextRoot%>/resources/img/sist_logo.png"
					alt="sist_logo.png"> 인터파크 도서 검색 <small>v1.0</small> <span
					style="font-size: small; color: #777777;"></span>
			</h1>
		</div>

		<div class="panel panel-default" id="input">
			<div class="panel-heading">도서 검색</div>
			<div class="panel-body">
				<form class="form-inline" method="post">
					<select class="form-control" id="key" name="key">
						<option value="title">Title</option>
						<option value="author">Author</option>
						<option value="publisher">Publisher</option>
						<option value="isbn">ISBN</option>
					</select> <input type="text" class="form-control" id="value"
						name="value" placeholder="Search" style="width: 30%">
					<button class="btn btn-default" type="submit">
						<i class="glyphicon glyphicon-search"></i><span>Search</span>
					</button>
				</form>
			</div>
		</div>


		<div class="panel panel-default" id="output">
			<div class="panel-heading">
				도서 검색 결과 
			</div>
			<div class="panel-body book-list-box">
				<button type="button" class="btn btn-default">
					TotalRows <span class="badge"><%=totalRows%></span>
				</button>
				<span style="font-size: small; color: #777777;">결과는 최대 100건까지만 출력됩니다.</span>

				<%=sb.toString()%>

			</div>
		</div>

	</div>

</body>
</html>