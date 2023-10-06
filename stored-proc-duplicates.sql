
select 
	t3.name, code_lines.lines_ofcode
from 
(
	select distinct t1.name -- , t2.name t2_name, SUBSTRING(t1.name,1,len(t1.name) -1) sub_1, SUBSTRING(t2.name,1,len(t2.name)-1)  sub_2 
	from 
	(
	SELECT name, 
		   type
	  FROM dbo.sysobjects
	 WHERE (type = 'P')
	 and name like '%_V%'
	) t1 join 
	(
	SELECT name, 
		   type
	  FROM dbo.sysobjects
	 WHERE (type = 'P')
	 and name like '%_V%'
	) t2 on SUBSTRING(t1.name,1,len(t1.name) -1) = SUBSTRING(t2.name,1,len(t2.name)-1) and t1.name <> t2.name
) t3 
inner join 
(
	select t.sp_name, sum(t.lines_of_code) - 1 as lines_ofcode, t.type_desc
	from
	(
		select o.name as sp_name, 
		(len(c.text) - len(replace(c.text, char(10), ''))) as lines_of_code,
		case when o.xtype = 'P' then 'Stored Procedure'
		when o.xtype in ('FN', 'IF', 'TF') then 'Function'
		end as type_desc
		from sysobjects o
		inner join syscomments c
		on c.id = o.id
		where o.xtype in ('P', 'FN', 'IF', 'TF')
		and o.category = 0
		and o.name not in ('fn_diagramobjects', 'sp_alterdiagram', 'sp_creatediagram', 'sp_dropdiagram', 'sp_helpdiagramdefinition', 'sp_helpdiagrams', 'sp_renamediagram', 'sp_upgraddiagrams', 'sysdiagrams')
	) t
	group by t.sp_name, t.type_desc
) code_lines on t3.name = code_lines.sp_name
order by name


