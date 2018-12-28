SELECT
    a.automaton_id as 'atm_id',
    a.name as 'atm_name',    
    sum(a.engineer_time_to_diagnose) as 'time_saved',
    a.engineer_time_to_diagnose as 'time_to',
    count(distinct e.ticket_id) as 'count'
FROM
    IPradar.tickets tr
        LEFT JOIN
    IPautomata.execution e USING (ticket_id)
        LEFT JOIN
    IPautomata.automaton a USING (automaton_id)
        ##client_join##
WHERE
    e.created > '##report_start##'
        AND e.created < '##report_close##'            
        AND e.purpose = 'DIAGNOSIS'
        AND e.status = 'COMPLETE'
        AND e.success = 1
        AND exists( select im.ipim_id
           from IPradar.ipim_ticket_mapping im
           where im.ticket_id = tr.ticket_id)
		##client_name##
GROUP BY a.automaton_id, a.name ORDER BY count DESC