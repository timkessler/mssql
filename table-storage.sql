
SELECT 
	(SUM(case when t.NAME LIKE '%mytablename%' then a.used_pages else 0 end) * 8)/1024/1024 GB_by_table,
	(SUM(a.used_pages ) * 8)/1024/1024 GB_total,
	((SUM(case when t.NAME LIKE '%mytablename%' then a.used_pages * 1.0 else 0 end) * 8)/1024/1024) / ((SUM(a.used_pages * 1.0) * 8)/1024/1024) * 100.0 perc_storage
FROM 
    sys.tables t
INNER JOIN 
    sys.schemas s ON s.schema_id = t.schema_id
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
WHERE 
     t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
