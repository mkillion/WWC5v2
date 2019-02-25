
<cfquery name="qURL" datasource="gis_webinfo">
    select
        form_url
    from
        wwc5.scan_urls
    where
        well_seq_number = #url.num#
</cfquery>

<cfoutput>
<cfif qURL.recordcount gt 0>
    #qURL.form_url#
<cfelse>
    none
</cfif>
</cfoutput>
