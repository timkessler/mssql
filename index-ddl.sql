
WITH CTE_indexes AS 
(
	SELECT
	 tables.TABLE_CATALOG,
	 tables.TABLE_SCHEMA,
	 tables.TABLE_NAME,
	 a.name index_name,
	 COL_NAME(b.object_id,b.column_id) AS Column_Name,
	 b.key_ordinal
	FROM
	 sys.indexes AS a
	INNER JOIN
	 sys.index_columns AS b
		   ON a.object_id = b.object_id AND a.index_id = b.index_id
		INNER JOIN 
		(
			select o.object_id, table_catalog, table_schema, t.TABLE_NAME from 
			(
			SELECT
			  name,
			  object_id
			FROM sys.objects 
			where type='U' and is_ms_shipped=0
			) o
			inner join 
			(select  * from information_schema.tables) t on o.name=t.TABLE_NAME
		) tables on a.object_id=tables.object_id
	WHERE
			a.is_hypothetical = 0
)
SELECT 
	 'create index ["' + t0.TABLE_SCHEMA + '"].["' + t0.TABLE_NAME + '_' + index_name + '"] on ["' + t0.TABLE_NAME + '"] ' 
     + ' ( ' + STUFF(
		(
       SELECT ',' + t1.column_name
         FROM CTE_indexes t1
        WHERE 	
			 t1.TABLE_CATALOG = t0.TABLE_CATALOG
			 and t1.TABLE_SCHEMA = t0.table_schema	
			 and t1.TABLE_NAME = t0.table_name
        ORDER BY t1.key_ordinal
          FOR XML PATH('')), 1, LEN(','), '') 
	+ ' );'
  FROM CTE_indexes t0
 GROUP BY 
	 TABLE_CATALOG,
	 TABLE_SCHEMA,
	 TABLE_NAME,
	 index_name
	order by 
	 TABLE_CATALOG,
	 TABLE_SCHEMA,
	 TABLE_NAME,
	 index_name;


