-- Average memory usage

SELECT cpu_number, host_id, total_mem
FROM host_info
INNER JOIN host_usage 
    ON host_info.id = host_usage.host_id
GROUP BY cpu_number, host_id, total_mem
ORDER BY total_mem DESC;

CREATE FUNCTION round_to_5(ts timestamp) RETURNS timestamp AS
$$
BEGIN
    RETURN date_trunc('hour', ts) + date_part('minute', ts)::int / 5 * interval '5 minute';
END;
$$
LANGUAGE PLPGSQL;

-- Average used memory per host per 5min interval
CREATE OR REPLACE VIEW avg_host_usage AS
    SELECT host_id,
        hostname,
        round_to_5(timestamp) AS rounded_timestamp,
        avg(((total_mem - memory_free)*100 / total_mem)) AS avg_used_mem
    FROM host_usage
        INNER JOIN host_info ON host_usage.host_id = host_info.id
    GROUP BY host_id, hostname, rounded_timestamp;

SELECT host_id, hostname, avg_used_mem
FROM avg_host_usage

-- detect host failures 
SELECT host_id,
    round_to_5(timestamp) AS rounded_timestamp, 
    COUNT(timestamp) AS failure_count
FROM host_usage
GROUP BY host_id, round_to_5(timestamp)
HAVING failure_count < 3;


