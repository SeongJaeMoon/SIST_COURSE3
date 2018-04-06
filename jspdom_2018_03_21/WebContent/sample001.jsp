<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="javax.xml.parsers.*, org.w3c.dom.*, org.xml.sax.*, javax.xml.xpath.*, java.net.URL" %>	
<%
		//JSP code
		request.setCharacterEncoding("UTF-8");
		String contextRoot = request.getContextPath();
		StringBuilder sb = new StringBuilder();
		
		/* 
		원격 XML 데이터 읽기 (Java 프로그램)
		- 기상청 RSS
		http://www.kma.go.kr/weather/lifenindustry/sevice_rss.jsp
		- 기상청 육상 중기예보
		http://www.kma.go.kr/weather/forecast/mid-term-rss3.jsp?stnId=109
		
		stnId=108 (전국)
		stnId=109 (서울, 경기)
		stnId=105 (강원)
		stnId=131 (충청북도)
		stnId=133 (충청남도)
		stnId=146 (전라북도)
		stnId=156 (전라남도)
		stnId=143 (경상북도)
		stnId=159 (경상남도)
		stnId=184 (제주특별자치도)
			
		- 기상청 동네예보 웹서비스
		서울특별시 강남구 개포1동
		wideCode 시도 - 11 : 서울
		cityCode 시군구 - 680 : 강남구
		http://www.kma.go.kr/wid/queryDFSRSS.jsp?zone=1168000000

		wideCode
		[{"code":"11","value":"서울특별시"},{"code":"26","value":"부산광역시"},{"code":"27","value":"대구광역시"},{"code":"28","value":"인천광역시"},{"code":"29","value":"광주광역시"},{"code":"30","value":"대전광역시"},{"code":"31","value":"울산광역시"},{"code":"41","value":"경기도"},{"code":"42","value":"강원도"},{"code":"43","value":"충청북도"},{"code":"44","value":"충청남도"},{"code":"45","value":"전라북도"},{"code":"46","value":"전라남도"},{"code":"47","value":"경상북도"},{"code":"48","value":"경상남도"},{"code":"50","value":"제주특별자치도"}]
		
		cityCode
		[{"code":"11110","value":"종로구"},{"code":"11140","value":"중구"},{"code":"11170","value":"용산구"},{"code":"11200","value":"성동구"},{"code":"11215","value":"광진구"},{"code":"11230","value":"동대문구"},{"code":"11260","value":"중랑구"},{"code":"11290","value":"성북구"},{"code":"11305","value":"강북구"},{"code":"11320","value":"도봉구"},{"code":"11350","value":"노원구"},{"code":"11380","value":"은평구"},{"code":"11410","value":"서대문구"},{"code":"11440","value":""},{"code":"11470","value":"양천구"},{"code":"11500","value":"강서구"},{"code":"11530","value":"구로구"},{"code":"11545","value":"금천구"},{"code":"11560","value":"영등포구"},{"code":"11590","value":"동작구"},{"code":"11620","value":"관악구"},{"code":"11650","value":"서초구"},{"code":"11680","value":"강남구"},{"code":"11710","value":"송파구"},{"code":"11740","value":"강동구"}]
		*/
		 
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		DocumentBuilder builder = factory.newDocumentBuilder();
		Document xmlObj = null;
		
		String stnId = request.getParameter("stnId");
		if (stnId == null) {
			stnId = "108"; //전국
		}
		String str = String.format("http://www.kma.go.kr/weather/forecast/mid-term-rss3.jsp?stnId=%s", stnId);
		URL url = new URL(str);
		InputSource is = new InputSource(url.openStream());
		xmlObj = builder.parse(is);
		
		// ROOT 엘리먼트 접근
		Element root = xmlObj.getDocumentElement();
		System.out.println(root.getNodeName());
		
		// XPath에 의한 XML 엘리먼트 탐색
		XPath xPath = XPathFactory.newInstance().newXPath();
		String title = xPath.compile("rss/channel/item/title").evaluate(xmlObj);
		String wf = xPath.compile("rss/channel/item/description/header/wf").evaluate(xmlObj);
		
		sb.append(String.format("<h2>%s</h2>",title));
		sb.append(String.format("<p>%s</p>",wf));

		NodeList locationNodeList = (NodeList) xPath.compile("rss/channel/item/description/body/location")
				.evaluate(xmlObj, XPathConstants.NODESET);

		for (int i = 1; i <= locationNodeList.getLength(); ++i) {
			String city = xPath.compile(String.format("rss/channel/item/description/body/location[%s]/city", i))
					.evaluate(xmlObj);
			sb.append(String.format("<h3>%s</h3>", city));
			sb.append("<table class=\"table\"><thead><tr><th>날짜</th><th>날씨</th><th>최저기온</th><th>최고기온</th><th>신뢰도</th></tr></thead><tbody>");

			NodeList dataNodeList = (NodeList) xPath
					.compile(String.format("rss/channel/item/description/body/location[%s]/data", i))
					.evaluate(xmlObj, XPathConstants.NODESET);
			for (int j = 1; j <= dataNodeList.getLength(); ++j) {
				String tmEf = xPath
						.compile(
								String.format("rss/channel/item/description/body/location[%s]/data[%s]/tmEf", i, j))
						.evaluate(xmlObj);
				String datawf = xPath
						.compile(String.format("rss/channel/item/description/body/location[%s]/data[%s]/wf", i, j))
						.evaluate(xmlObj);
				String tmn = xPath
						.compile(String.format("rss/channel/item/description/body/location[%s]/data[%s]/tmn", i, j))
						.evaluate(xmlObj);
				String tmx = xPath
						.compile(String.format("rss/channel/item/description/body/location[%s]/data[%s]/tmx", i, j))
						.evaluate(xmlObj);
				String reliability = xPath
						.compile(String.format(
								"rss/channel/item/description/body/location[%s]/data[%s]/reliability", i, j))
						.evaluate(xmlObj);

				String wimg = contextRoot + "/resources/pictures";
				switch (datawf) {
				case "구름조금":
					wimg += "/W_NB02.png";
					break;
				case "구름많음":
					wimg += "/W_NB03.png";
					break;
				case "구름많고 비":
					wimg += "/W_NB20.png";
					break;
				case "눈":
					wimg += "/W_DB08.png";
					break;
				case "비":
					wimg += "/W_DB05.png";
					break;
				case "흐림":
					wimg += "/W_DB04.png";
					break;
				case "눈비":
					wimg += "/W_DB06.png";
					break;
				case "흐리고 비":
					wimg += "/W_NB08.png";
					break;
				}
				sb.append(String.format(
						"<tr><td>%s</td><td><img src=\"%s\"> %s</td><td> %s ℃</td><td> %s ℃</td><td>%s</td></tr>",
						tmEf, wimg, datawf, tmn, tmx, reliability));
			}
			sb.append("</tbody></table>");
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

		  var stnId = "<%=stnId%>";
		  $("input[value="+stnId+"]").attr("checked", "checked");

	});
</script>
</head>
<body>

	<div class="container">
		<div class="panel page-header" style="text-align: center;">
			<h1 style="font-size: xx-large;">
				<img
					src="<%=contextRoot%>/resources/img/sist_logo.png"
					alt="sist_logo.png"> 기상청 육상 중기 예보 <small>v1.0</small> <span
					style="font-size: small; color: #777777;"></span>
			</h1>
		</div>

		<div class="panel panel-default" id="input">
			<div class="panel-heading">기상 정보 지역 선택</div>
			<div class="panel-body">

				<form role="form" method="post">
					<input type="radio" name="stnId" value="108" checked="checked">
					전국 <input type="radio" name="stnId" value="109"> 서울,경기 <input
						type="radio" name="stnId" value="105"> 강원 <input
						type="radio" name="stnId" value="131"> 충청북도 <input
						type="radio" name="stnId" value="133"> 충청남도 <input
						type="radio" name="stnId" value="146"> 전라북도 <input
						type="radio" name="stnId" value="156"> 전라남도 <input
						type="radio" name="stnId" value="143"> 경상북도 <input
						type="radio" name="stnId" value="159"> 경상남도 <input
						type="radio" name="stnId" value="184"> 제주특별자치도

					<button type="submit" class="btn btn-default btn-sm">Submit</button>
				</form>
				
			</div>
		</div>

		<div class="panel panel-default" id="output">
			<div class="panel-heading">기상 정보 출력</div>
			<div class="panel-body">
			
			<%=sb.toString()%>
			
			</div>
		</div>


	</div>

</body>
</html>