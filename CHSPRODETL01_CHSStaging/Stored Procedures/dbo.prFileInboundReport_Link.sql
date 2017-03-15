SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Reporting Team
-- Create date: 11/15/2016
-- Description:	Stored Procedure is used to provide details on files that  
--				come in through the portal and FTP
-- 12/13/2016 - Updated to reference dim.Client table
-- =============================================
CREATE PROCEDURE [dbo].[prFileInboundReport_Link]
	-- Add the parameters for the stored procedure here

@ClientName varchar(25),
--@ProviderID varchar(25),
--@BeginDate date,
--@EndDate date,
@LogDate date,
@ClientName_Inbound varchar(75)



---- POSSIBLE CLIENTS
/*
Aetna
BCBS-SC
BSW
CCAI
FHN
HCSC
Memorial Hermann
Viva Health
Wellcare
*/

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON--and convert(date,t1.LogDate) = '''+@LogDate+'''


--declare @ClientName varchar(25)--and convert(date,t1.LogDate) = '''+@LogDate+'''
--declare @ProviderID varchar(25)--and convert(date,t1.LogDate) = '''+@LogDate+'''
--declare @BeginDate date--and convert(date,t1.LogDate) = '''+@LogDate+'''
--declare @EndDate date--and convert(date,t1.LogDate) = '''+@LogDate+'''
--declare @LogDate date--and convert(date,t1.LogDate) = '''+@LogDate+'''
--declare @ClientName_Inbound varchar(75)--and convert(date,t1.LogDate) = '''+@LogDate+'''

--set @ClientName = 'WellCare'--and convert(date,t1.LogDate) = '''+@LogDate+'''
--set @ProviderID = '623CE1001'--and convert(date,t1.LogDate) = '''+@LogDate+'''
--set @BeginDate = '11/01/2016'--and convert(date,t1.LogDate) = '''+@LogDate+'''
--set @EndDate = '11/16/2016'--and convert(date,t1.LogDate) = '''+@LogDate+'''
--set @LogDate = '11/10/2016'--and convert(date,t1.LogDate) = '''+@LogDate+'''
--set @ClientName_Inbound = 'Wellcare-ProviderPortal-112547_01'--and convert(date,t1.LogDate) = '''+@LogDate+'''

    -- Insert statements for procedure here
if object_id('tempdb..#temp_Client') is not null
drop table #temp_Client--and convert(date,t1.LogDate) = '''+@LogDate+'''
select  CentauriClientID,
		ClientName
into #temp_Client
from CHSStaging.dim.Client

if object_id('tempdb..#temp_Inbound') is not null
drop table #temp_Inbound
select  t1.AuditLogID,
		t1.FTPPath,
		t1.FileName,
		t1.LogDate,
		t1.ClientID,
		t2.ClientName as ClientName_Inbound
into #temp_Inbound
from ETLConfig.dbo.FTPInboundAuditLog t1 with(nolock)
join ETLConfig.dbo.FTPConfig t2 with(nolock)
on t1.FTPConfigID = t2.FTPConfigID


---- Create Index on Temp User Table ----
if exists (select name from sys.indexes
where name = N'idx_Inbound')
	drop index idx_Inbound on #temp_Inbound--and convert(date,t1.LogDate) = '''+@LogDate+'''

create nonclustered index idx_Inbound
on #temp_Inbound (AuditLogID, ClientID)--and convert(date,t1.LogDate) = '''+@LogDate+'''


if @ClientName = 'WellCare'
	--and @ProviderID <> ''
begin
exec('
	select	t1.FileName,
			t1.LogDate,
			t1.ClientName_Inbound,
			t2.ClientName
	from #temp_Inbound t1
	join #temp_Client t2
	on t1.ClientID = t2.CentauriClientID
	where t2.ClientName = '''+@ClientName+'''
	and convert(date,t1.LogDate) = '''+@LogDate+'''
	
	and t1.ClientName_Inbound = '''+@ClientName_Inbound+'''
	')


end


else if @ClientName <> 'WellCare'
begin

select  t1.FileName,
		t1.LogDate,
		t1.ClientName_Inbound,
		t2.ClientName
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) = @LogDate
	and t1.ClientName_Inbound = @ClientName_Inbound
	--and t1.LogDate = @LogDate


end


END



GO
