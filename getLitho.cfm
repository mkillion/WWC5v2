
<cfquery name="qLitho" datasource="gis_webinfo">
    select
        l.wlfeet as feet,
        r.wllogt as litho
    from
        wwc5.wwc5_99_logfile l,
        wwc5.wwc5_99_reflog r
    where
        l.wlid = #url.id#
        and
        l.wllog = r.wllog
    order by
        feet
</cfquery>


<cfoutput>
    <cfif qLitho.recordcount gt 0>
        <table>
        <tr><th>Depth (ft)</th><th>Lithology</th></tr>
        <cfloop query="qLitho">
            <tr><td>#feet#</td><td>#litho#</td></tr>
        </cfloop>
        <tr><td colspan="2">Note: Lithologic log data was not entered by the Kansas Geological Survey nor does the Survey check its accuracy.</td></tr>
        </table>
    <cfelse>
        No lithology data available for this well.
    </cfif>
</cfoutput>
