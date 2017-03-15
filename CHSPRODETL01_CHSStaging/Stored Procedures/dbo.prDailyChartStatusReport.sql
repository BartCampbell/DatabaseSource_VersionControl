SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Reporting Team
-- Create date: 12/15/2016
-- Description:	Stored Procedure provides the details on the WellCare DailyChartStatus files 
--				as they come in through the ETL process
-- =============================================
CREATE PROCEDURE [dbo].[prDailyChartStatusReport]
	-- Add the parameters for the stored procedure here
@ClientName varchar(25),
@BeginDate date,
@EndDate date

--declare @ClientName varchar(25);
--declare @BeginDate date;
--declare @EndDate date;

--set @ClientName = 'WellCare';
--set @BeginDate = '12/01/2016';
--set @EndDate = '12/16/2016';



AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


if object_id('tempdb..##temp_DCS') is not null
drop table ##temp_DCS
select	 t1.FileName,
		 t1.LogDate,
		 t1.ClientID,
		 t3.ClientName
into ##temp_DCS
from ETLConfig.dbo.FTPInboundAuditLog t1
join ETLConfig.dbo.FTPConfig t2
on t1.FTPConfigID = t2.FTPConfigID
join CHSStaging.dim.Client t3
on t1.ClientID = t3.CentauriClientID


if OBJECT_ID('tempdb..##temp_CHSLoad') is not null
	drop table ##temp_CHSLoad
select distinct FileName,
		ClientID,
		ProcessDate
into ##temp_CHSLoad
--select *
from CHSStaging.dbo.ChaseStatus_Archive
where Duplicate = 0



---- Create Index on Temp User Table ----
if exists (select name from sys.indexes
where name = N'idx_DCS')
	drop index idx_DCS on ##temp_DCS;

create nonclustered index idx_DCS
on ##temp_DCS (FileName, ClientName, LogDate);

select  t1.ClientID,
		case
			when t1.ClientName = 'WellCare'
				then 'WellCare'
			else t1.ClientName
		end as ClientName,
		t1.FileName,
		t1.LogDate,
		t2.ProcessDate
from ##temp_DCS t1
left outer join ##temp_CHSLoad t2
on t1.FileName = t2.FileName
and t1.ClientID = t2.ClientID
where t1.FileName like '%DailyChartStatus%'
and t1.ClientName = @ClientName
and convert(date,LogDate) between @BeginDate and @EndDate


END
GO
