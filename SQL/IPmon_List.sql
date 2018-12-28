    SELECT
        ipmon.name
    FROM
        IPadmin.host host
            JOIN
        IPadmin.ipmon ipmon ON ipmon.ipmonID = host.preferredIpmonEntryId
    WHERE
        host.preferredIpmonEntryId IS NOT NULL
    GROUP BY ipmon.name;
