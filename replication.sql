SELECT 
  msp.publication AS PublicationName,
  msa.publisher_db AS DatabaseName,
  msa.article AS ArticleName,
  msa.source_owner AS SchemaName,
  msa.source_object AS TableName, *
FROM distribution.dbo.MSarticles msa
JOIN distribution.dbo.MSpublications msp ON msa.publication_id = msp.publication_id
ORDER BY 
  msp.publication, 
  msa.article;


USE distribution;
go

SELECT DISTINCT  
srv.srvname publication_server  
, a.publisher_db 
, p.publication publication_name 
, a.article 
, a.destination_object 
, ss.srvname subscription_server 
, s.subscriber_db 
, da.name AS distribution_agent_job_name 
FROM MSArticles a  
JOIN MSpublications p ON a.publication_id = p.publication_id 
JOIN MSsubscriptions s ON p.publication_id = s.publication_id 
JOIN master..sysservers ss ON s.subscriber_id = ss.srvid 
JOIN master..sysservers srv ON srv.srvid = p.publisher_id 
JOIN MSdistribution_agents da ON da.publisher_id = p.publisher_id  
     AND da.subscriber_id = s.subscriber_id 
ORDER BY 1,2,3  ;

USE distribution;
go
select * from MSpublications;
select * from MSrepl_commands;
select * from MSrepl_errors order by time desc;
select * from MSdistribution_agents;
select * from MSdistribution_history order by start_time desc;
select * from MSsnapshot_history order by start_time asc;
select cast(time as date) error_date, count(*) from MSrepl_errors group by cast(time as date) order by cast(time as date) desc;
select top 5 * from MSrepl_transactions order by entry_time desc;

