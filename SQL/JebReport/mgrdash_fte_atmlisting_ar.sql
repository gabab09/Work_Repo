SELECT
    a.automaton_id as 'atm_id',
    a.name as 'atm_name',    
    sum(a.engineer_time_to_remediate) as 'time_saved',
    a.engineer_time_to_remediate as 'time_to',
    count(distinct e.ticket_id) as 'count'
FROM
    IPslr.ticket_summary ts
        JOIN
    IPradar.tickets_resolved tr USING (ticket_id)
		LEFT JOIN
    IPautomata.execution e USING (ticket_id)
        LEFT JOIN
    IPautomata.automaton a USING (automaton_id)
        ##client_join##
WHERE
    tr.resolve_date > '##report_start##'
        AND tr.resolve_date < '##report_close##'        
        AND e.created > '##report_start##'
        AND e.created < '##report_close##'    
        AND e.purpose = 'REMEDIATION'
        AND e.status = 'COMPLETE'
        AND e.success = 1
        AND exists( select im.ipim_id
           from IPradar.ipim_ticket_mapping im
           where im.ticket_id = tr.ticket_id)
		##client_name##
GROUP BY a.automaton_id, a.name ORDER BY count DESC
