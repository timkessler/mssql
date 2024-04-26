SELECT  SERVERPROPERTY('MachineName') AS ComputerName,
        ISNULL(SERVERPROPERTY('InstanceName'), 'MSSQLSERVER') AS InstanceName,
        SERVERPROPERTY('ServerName') AS SqlInstance,
        t.session_id AS Spid,
        r.command AS StatementCommand,
        SUBSTRING(   est.[text], (r.statement_start_offset / 2) + 1,
            ((CASE r.statement_end_offset
                WHEN-1 THEN DATALENGTH(est.[text]) ELSE r.statement_end_offset
                END - r.statement_start_offset
            ) / 2 ) + 1 ) AS QueryText,
        QUOTENAME(DB_NAME(r.database_id)) + N'.' + QUOTENAME(OBJECT_SCHEMA_NAME(est.objectid, est.dbid)) + N'.'
        + QUOTENAME(OBJECT_NAME(est.objectid, est.dbid)) AS ProcedureName,
        r.start_time AS StartTime,
        tdb.UserObjectAllocated * 8 AS CurrentUserAllocatedKB,
        (t.user_objects_alloc_page_count + tdb.UserObjectAllocated) * 8 AS TotalUserAllocatedKB,
        tdb.UserObjectDeallocated * 8 AS UserDeallocatedKB,
        (t.user_objects_dealloc_page_count + tdb.UserObjectDeallocated) * 8 AS TotalUserDeallocatedKB,
        tdb.InternalObjectAllocated * 8 AS InternalAllocatedKB,
        (t.internal_objects_alloc_page_count + tdb.InternalObjectAllocated) * 8 AS TotalInternalAllocatedKB,
        tdb.InternalObjectDeallocated * 8 AS InternalDeallocatedKB,
        (t.internal_objects_dealloc_page_count + tdb.InternalObjectDeallocated) * 8 AS TotalInternalDeallocatedKB,
        r.reads AS RequestedReads,
        r.writes AS RequestedWrites,
        r.logical_reads AS RequestedLogicalReads,
        r.cpu_time AS RequestedCPUTime,
        s.is_user_process AS IsUserProcess,
        s.[status] AS [Status],
        DB_NAME(r.database_id) AS [Database],
        s.login_name AS LoginName,
        s.original_login_name AS OriginalLoginName,
        s.nt_domain AS NTDomain,
        s.nt_user_name AS NTUserName,
        s.[host_name] AS HostName,
        s.[program_name] AS ProgramName,
        s.login_time AS LoginTime,
        s.last_request_start_time AS LastRequestedStartTime,
        s.last_request_end_time AS LastRequestedEndTime
FROM    sys.dm_db_session_space_usage AS t
INNER JOIN sys.dm_exec_sessions AS s
    ON s.session_id = t.session_id
LEFT JOIN sys.dm_exec_requests AS r
    ON r.session_id = s.session_id
LEFT JOIN (
    SELECT _tsu.session_id,
        _tsu.request_id,
        SUM(_tsu.user_objects_alloc_page_count)       AS UserObjectAllocated,
        SUM(_tsu.user_objects_dealloc_page_count)     AS UserObjectDeallocated,
        SUM(_tsu.internal_objects_alloc_page_count)   AS InternalObjectAllocated,
        SUM(_tsu.internal_objects_dealloc_page_count) AS InternalObjectDeallocated
    FROM tempdb.sys.dm_db_task_space_usage AS _tsu
    GROUP BY _tsu.session_id, _tsu.request_id
) AS tdb ON  tdb.session_id = r.session_id AND  tdb.request_id = r.request_id
OUTER APPLY sys.dm_exec_sql_text(r.[sql_handle]) AS est
WHERE   t.session_id != @@SPID
AND   (tdb.UserObjectAllocated - tdb.UserObjectDeallocated + tdb.InternalObjectAllocated - tdb.InternalObjectDeallocated) != 0
