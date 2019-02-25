
<cfsetting requestTimeOut = "180" showDebugOutput = "yes" enableCFoutputOnly="yes">
<cfprocessingdirective suppressWhiteSpace="yes">

<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="0" />
</head>
<body>
<cfset TimeStamp = "#hour(now())##minute(now())##second(now())#">

<cfset WellsFileText = "">
<cfset LithoFileText = "">

<cfif IsDefined("form.attrWhere")>
	<cfset form.attrWhere = Replace(form.attrWhere, "water_use_code", "w.water_use_code")>
</cfif>
<cfif IsDefined("form.comboWhere")>
	<cfset form.comboWhere = Replace(form.comboWhere, "water_use_code", "w.water_use_code")>
</cfif>

<!--- WWC5 WELLS: --->
	<cfset WellsFileName = "WWC5-WELLS-#TimeStamp#.csv">
	<cfset WellsOutputFile = "\\vmpyrite\d$\webware\Apache\Apache2\htdocs\kgsmaps\oilgas\output\#WellsFileName#">

	<!--- PREPARE OUTPUT FILE: --->
	<cfset Headers = "KGS_ID,COUNTY,TOWNSHIP,TWN_DIR,RANGE,RANGE_DIR,SECTION,SPOT,NAD27_LONGITUDE,NAD27_LATITUDE,LONG_LAT_TYPE,OWNER,WELL_USE,COMPLETION_DATE,STATUS,WELL_ID,DWR_NUMBER,DIRECTIONS,WELL_DEPTH,ELEVATION,STATIC_DEPTH,EST_YIELD,DRILLER">
	<cffile action="write" file="#WellsOutputFile#" output="#Headers#" addnewline="yes">

	<!--- GET DATA: --->
	<cfquery name="qWWC5" datasource="gis_webinfo">
		select
	    	w.input_seq_number,
	        g.name as county,
	        w.township,
	        w.township_direction,
	        w.range,
	        w.range_direction,
	        w.section,
	        w.quarter_call_3||' '||w.quarter_call_2||' '||w.quarter_call_1_largest as spot,
	        w.nad27_longitude,
	        w.nad27_latitude,
	        w.gps_longitude,
	        w.owner_name,
	        u.use_description as use,
	        to_char(w.completion_date,'mm/dd/yyyy') as comp_date,
	        s.typewell as status,
	        w.monitoring_number as otherid,
	        w.dwr_appropriation_number,
	        trim(w.location_directions) as directions,
	        w.depth_of_completed_well,
	        w.elevation_of_well,
	        w.static_water_level,
	        w.estimeted_yield,
	        w.contractor_name as w_contractor,
	        c.contractor_name as c_contractor
	    from
	    	wwc5_wells w,
	        global.counties g,
	        wwc5.well_status_type_rf7 s,
	        wwc5.welluse_type u,
	        wwc5.wwc5_contractors c
	    where
	    	w.county_code = g.code
	        and
	        w.water_use_code = u.water_use_code(+)
	        and
	        w.type_of_action_code = s.wltwel(+)
	        and
	        w.contractors_license_number = c.contractors_license(+)
			<cfif #form.type# eq "d">
				and
	        	w.nad83_longitude > #form.xmin# and w.nad83_longitude < #form.xmax# and w.nad83_latitude > #form.ymin# and w.nad83_latitude < #form.ymax#
			<cfelse>
				and
				w.nad27_latitude = (select nad27_latitude from wwc5_wells where input_seq_number = #form.seqnum#)
				and
				w.nad27_longitude = (select nad27_longitude from wwc5_wells where input_seq_number = #form.seqnum#)
			</cfif>
			<cfif IsDefined("form.comboWhere") and form.comboWhere neq "">
				and
				#PreserveSingleQuotes(form.combowhere)#
			<cfelseif IsDefined("form.attrWhere") and form.attrWhere neq "">
				and
				#PreserveSingleQuotes(form.attrWhere)#
			</cfif>
	</cfquery>

	<!--- WRITE FILE: --->
	<cfif IsDefined("qWWC5") AND #qWWC5.recordcount# gt 0>
		<cfloop query="qWWC5">
			<cfset LongLatType = "">
			<cfif #gps_longitude# eq "">
				<cfset LongLatType = "From PLSS">
			<cfelse>
				<cfset LongLatType = "GPS">
			</cfif>

			<cfset Contractor = "">
			<cfif #c_contractor# neq "">
				<cfset Contractor = c_contractor>
			<cfelseif #w_contractor# neq "">
				<cfset Contractor = w_contractor>
			</cfif>

			<cfset Data = '"#input_seq_number#","#county#","#township#","#township_direction#","#range#","#range_direction#","#section#","#spot#","#nad27_longitude#","#nad27_latitude#","#LongLatType#","#owner_name#","#use#","#comp_date#","#status#","#otherid#","#dwr_appropriation_number#","#directions#","#depth_of_completed_well#","#elevation_of_well#","#static_water_level#","#estimeted_yield#","#Contractor#"'>
			<cffile action="append" file="#WellsOutputFile#" output="#Data#" addnewline="yes">
		</cfloop>
		<cfset WellsFileText = "Download WWC5 Wells File">
	<cfelse>
		<cfset WellsFileText = "No well data for this search">
	</cfif>
<!--- End WWC5 Wells. --->


<!--- LITHOLOGY FILE: --->
	<cfset LithoFileName = "WWC5-LITHO-#TimeStamp#.csv">
	<cfset LithoOutputFile = "\\vmpyrite\d$\webware\Apache\Apache2\htdocs\kgsmaps\oilgas\output\#LithoFileName#">

	<!--- PREPARE OUTPUT FILE: --->
	<cfset Headers = "KGS_ID,NAD27_LONGITUDE,NAD27_LATITUDE,FEET,LOG">
	<cffile action="write" file="#LithoOutputFile#" output="#Headers#" addnewline="yes">

	<!--- GET DATA: --->
	<cfquery name="qLitho" datasource="gis_webinfo">
		select
	    	l.wlid as well_id,
	      	w.nad27_longitude as longitude,
	      	w.nad27_latitude as latitude,
	    	l.wlfeet as feet,
	    	trim(r.wllogt) as log
	    from
	    	wwc5.wwc5_99_reflog r,
	      	wwc5.wwc5_99_logfile l,
	      	wwc5_wells w
	    where
	    	l.wllog = r.wllog
	      	and
	      	l.wlid = w.input_seq_number
			<cfif #form.type# eq "d">
				and
	        	w.nad83_longitude > #form.xmin# and w.nad83_longitude < #form.xmax# and w.nad83_latitude > #form.ymin# and w.nad83_latitude < #form.ymax#
			<cfelse>
				and
				w.nad27_latitude = (select nad27_latitude from wwc5_wells where input_seq_number = #form.seqnum#)
				and
				w.nad27_longitude = (select nad27_longitude from wwc5_wells where input_seq_number = #form.seqnum#)
			</cfif>
			<cfif IsDefined("form.comboWhere") and form.comboWhere neq "">
				and
				#PreserveSingleQuotes(form.combowhere)#
			<cfelseif IsDefined("form.attrWhere") and form.attrWhere neq "">
				and
				#PreserveSingleQuotes(form.attrWhere)#
			</cfif>
		order by
	    	well_id, feet
	</cfquery>

	<!--- WRITE FILE: --->
	<cfif IsDefined("qLitho") AND #qLitho.recordcount# gt 0>
		<cfloop query="qLitho">
	    	<cfset Record = '"#well_id#","#longitude#","#latitude#","#feet#","#log#"'>
	        <cffile action="append" file="#LithoOutputFile#" output="#Record#" addnewline="yes">
	    </cfloop>
		<cfset LithoFileText = "Download Lithology File">
	<cfelse>
		<cfset LithoFileText = "No lithology data for this search">
	</cfif>
<!--- End Lithology File. --->


<cfoutput>
	<cfif #form.type# eq "d">
	    <cfif FindNoCase("Download", #WellsFileText#) neq 0>
			<div class="download-link"><a href="http://vmpyrite.kgs.ku.edu/KgsMaps/oilgas/output/#WellsFileName#"><span class="esri-icon-download"></span>#WellsFileText#</a></div>
		<cfelse>
			<div class="download-link">#WellsFileText#</div>
		</cfif>

		<cfif FindNoCase("Download", #LithoFileText#) neq 0>
			<div class="download-link"><a href="http://vmpyrite.kgs.ku.edu/KgsMaps/oilgas/output/#LithoFileName#"><span class="esri-icon-download"></span>#LithoFileText#</a></div>
			<div class="note" style="padding-left:23px">Note: Lithologic log data was not entered by the Kansas Geological Survey nor does the Survey check its accuracy.</div>
		<cfelse>
			<div class="download-link">#LithoFileText#</div>
		</cfif>
	<cfelse>
		<cfif FindNoCase("Download", #WellsFileText#) neq 0>
			#WellsFileName#
		<cfelse>
			"no file"
		</cfif>
	</cfif>
</cfoutput>

</body>
</html>
</cfprocessingdirective>
