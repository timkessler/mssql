use <database_name>
go


WITH v_NonIndexedFKColumns AS (
   SELECT 
      Object_Name(a.parent_object_id) AS Table_Name
      ,b.NAME AS Column_Name
   FROM 
      sys.foreign_key_columns a
      ,sys.all_columns b
      ,sys.objects c
   WHERE 
      a.parent_column_id = b.column_id
      AND a.parent_object_id = b.object_id
      AND b.object_id = c.object_id
      AND c.is_ms_shipped = 0
   EXCEPT
   SELECT 
      Object_name(a.Object_id)
      ,b.NAME
   FROM 
      sys.index_columns a
      ,sys.all_columns b
      ,sys.objects c
   WHERE 
      a.object_id = b.object_id
      AND a.key_ordinal = 1
      AND a.column_id = b.column_id
      AND a.object_id = c.object_id
      AND c.is_ms_shipped = 0
   )
select * from (
SELECT 
   v.Table_Name AS NonIndexedCol_Table_Name
   ,v.Column_Name AS NonIndexedCol_Column_Name             
   ,fk.NAME AS Constraint_Name   
   ,SCHEMA_NAME(fk.schema_id) AS Ref_Schema_Name       
   ,object_name(fkc.referenced_object_id) AS Ref_Table_Name      
   ,c2.NAME AS Ref_Column_Name         
FROM 
   v_NonIndexedFKColumns v
   ,sys.all_columns c
   ,sys.all_columns c2
   ,sys.foreign_key_columns fkc
   ,sys.foreign_keys fk
WHERE 
   v.Table_Name = Object_Name(fkc.parent_object_id)
   AND v.Column_Name = c.NAME
   AND fkc.parent_column_id = c.column_id
   AND fkc.parent_object_id = c.object_id
   AND fkc.referenced_column_id = c2.column_id
   AND fkc.referenced_object_id = c2.object_id
   AND fk.object_id = fkc.constraint_object_id
) t
where 
NonIndexedCol_Table_Name in ( 'PayrollTransaction' )
or Ref_Table_Name in ( 'PayrollTransaction')
ORDER BY 1,2


