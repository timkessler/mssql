
DECLARE @command varchar(4000)
SELECT @command = 'select  @@SERVERNAME as server,
			''[?]'' as DatabaseName,
             u.name
            ,case when (r.principal_id is null) then ''public'' else r.name end db_role
    from [?].sys.database_principals u
        left join ([?].sys.database_role_members m join [?].sys.database_principals r on m.role_principal_id = r.principal_id) 
            on m.member_principal_id = u.principal_id
        left join [?].sys.server_principals l on u.sid = l.sid
        where u.type <> ''R'' 
		and u.name like ''%\%''
		and u.name not like ''%Service%''
--TODO figure out difference between groups and users
		and not ( -- AD Users hack
			substring(a
				u.name, 
				CHARINDEX(''\'', u.name)+1,
				DATALENGTH(u.name)-CHARINDEX(''\'', u.name)
			) COLLATE Latin1_General_CS_AS = 
			lower( 
				substring(
				u.name, 
				CHARINDEX(''\'', u.name)+1,
				DATALENGTH(u.name)-CHARINDEX(''\'', u.name)
				)
			) COLLATE Latin1_General_CS_AS
		)
		'

DECLARE @DatabasesPrincipals TABLE
(
  server varchar(50),
  database_name VARCHAR(50),
  ad_role VARCHAR(50),
  db_role VARCHAR(100)
)

INSERT  INTO @DatabasesPrincipals
EXEC sp_MSforeachdb @command

select * from @DatabasesPrincipals;

