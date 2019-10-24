
<cfsetting requestTimeOut = "300" showDebugOutput = "yes">

<cfset FileName = "wwc5print_#hour(now())##minute(now())##second(now())#">

<cfimage
    action = "convert"
    destination = "\\vmpyrite\d$\webware\Apache\Apache2\htdocs\kgsmaps\oilgas\output\#FileName#.jpg"
    source = #form.screenshot#
    isBase64 = "yes"
    name = "TheMapImage"
    overwrite = "yes"
>

<cfscript>
    thread = CreateObject("java","java.lang.Thread");
    thread.sleep(5000);
</cfscript>

<cfset Date1 = Now()>
<cfset Year = DatePart("yyyy",Date1)>
<cfset Month = DatePart("m",Date1)>
<cfset Day = DatePart("d",Date1)>

<cfoutput>
<cfdocument format="pdf" pagetype="letter" orientation="#form.orientation#" overwrite="yes" filename="\\vmpyrite\d$\webware\Apache\Apache2\htdocs\kgsmaps\oilgas\output\#FileName#.pdf">

<html>
<body>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>

<h3>#form.title#</h3>
<div style="border:3px solid black;"><img src="http://vmpyrite.kgs.ku.edu/KgsMaps/oilgas/output/#FileName#.jpg"></div>
<div style="float:right;margin-top:10px"><h5>#Month#/#Day#/#Year#</h5></div>

</body>
</html>

</cfdocument>
</cfoutput>

<!--- Response: --->
<cfoutput>
    http://vmpyrite.kgs.ku.edu/KgsMaps/oilgas/output/#FileName#.pdf
</cfoutput>
