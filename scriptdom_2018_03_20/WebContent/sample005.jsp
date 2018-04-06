<%@ page language="java" contentType="text/html; charset=UTF-8"  pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="javax.xml.parsers.*, org.w3c.dom.*, org.xml.sax.*, javax.xml.xpath.*, java.io.*" %>
<%
	//JSP code
	request.setCharacterEncoding("UTF-8");
	String contextRoot = request.getContextPath();
	StringBuilder sb = new StringBuilder();
	
	String mid = request.getParameter("mid");

	String filePath = request.getServletContext().getRealPath("/");
	System.out.println(filePath);
	
	File inputFile = new File(filePath + "//" + "members.xml");
	DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
	DocumentBuilder dBuilder;
	dBuilder = dbFactory.newDocumentBuilder();
	Document doc = dBuilder.parse(inputFile);

	sb.append("Root element: ");
	sb.append(doc.getDocumentElement().getNodeName());
	sb.append("<br>");
	
	XPath xPath = XPathFactory.newInstance().newXPath();
	String expression = String.format("/members/member");
	
	if (mid != null) {
		expression += String.format("[@mid='%s']", mid);
	}
	
	NodeList nodeList = (NodeList) xPath.compile(expression).evaluate(doc, XPathConstants.NODESET);

	for (int i = 0; i < nodeList.getLength(); i++) {
		Node nNode = nodeList.item(i);

		if (nNode.getNodeType() == Node.ELEMENT_NODE) {
			Element eElement = (Element) nNode;
			sb.append(String.format("name : %s<br>", eElement.getElementsByTagName("name").item(0).getTextContent()));
			sb.append(String.format("phone : %s<br>",eElement.getElementsByTagName("phone").item(0).getTextContent()));
			sb.append("-----------<br>");
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
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">

<style>

div#input:hover, div#output:hover {
	box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
}

</style>

<!-- Google Map API -->
<script src="https://maps.googleapis.com/maps/api/js"></script>

<!-- jQuery library -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>

<!-- Latest compiled JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>


<script>
$(document).ready(function(){

	   // jQuery methods go here...

});
</script>
</head>
<body>

<div class="container">
	<h1>XML Parser</h1>
	<p><%=sb.toString()%></p>
</div>

</body>
</html>