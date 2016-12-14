SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Reporting Team
-- Create date: 11/15/2016
-- Description:	Stored Procedure is used to provide details on files that  
--				come in through the portal and FTP
-- =============================================
CREATE PROCEDURE [dbo].[prFileInboundReport_Summary]
	-- Add the parameters for the stored procedure here

@ClientName varchar(25),
@ProviderID varchar(25),
@BeginDate date,
@EndDate date

--declare @ClientName varchar(25);
--declare @ProviderID varchar(25);
--declare @BeginDate date;
--declare @EndDate date;

--set @ClientName = 'WellCare';
--set @ProviderID = '623CE1001';
--set @BeginDate = '11/01/2016';
--set @EndDate = '11/16/2016';

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
	SET NOCOUNT ON;

--declare @ClientName varchar(25);
--declare @ProviderID varchar(25);
--declare @BeginDate date;
--declare @EndDate date;

--set @ClientName = 'WellCare';
--set @ProviderID = '623CE1001';
--set @BeginDate = '11/01/2016';
--set @EndDate = '11/16/2016';

    -- Insert statements for procedure here
if object_id('tempdb..#temp_Client') is not null
drop table #temp_Client;
select  CentauriClientID,
		ClientName
into #temp_Client
from CHSDW.dim.Client

if object_id('tempdb..#temp_Inbound') is not null
drop table #temp_Inbound
select  t1.AuditLogID,
		t1.FTPPath,
		t1.FileName,
		Convert(Date,t1.LogDate) as LogDate,
		t1.ClientID,
		t2.ClientName as ClientName_Inbound
into #temp_Inbound
from ETLConfig.dbo.FTPInboundAuditLog t1 with(nolock)
join ETLConfig.dbo.FTPConfig t2 with(nolock)
on t1.FTPConfigID = t2.FTPConfigID


---- Create Index on Temp User Table ----
if exists (select name from sys.indexes
where name = N'idx_Inbound')
	drop index idx_Inbound on #temp_Inbound;

create nonclustered index idx_Inbound
on #temp_Inbound (AuditLogID, ClientID);



if @ClientName = 'WellCare'
	and @ProviderID <> ''
begin
exec('
	select	--t1.FileName,
			t1.LogDate,
			--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
			t1.ClientName_Inbound,
			--t2.ClientName,
		Count(*) as Total
	from #temp_Inbound t1
	join #temp_Client t2
	on t1.ClientID = t2.CentauriClientID
	where t2.ClientName = '''+@ClientName+'''
	and convert(date,t1.LogDate) between '''+@BeginDate+''' and '''+@EndDate+'''
	and t1.FTPPath like ''%'+@ProviderID+'%''
	group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName
	')


end

else if @ClientName = 'WellCare'
	and @ProviderID = ''

begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end

else if @ClientName <> 'WellCare'
begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end


if @ClientName = 'FHN'
	and @ProviderID <> ''
begin
exec('
	select	--t1.FileName,
			t1.LogDate,
			--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
			t1.ClientName_Inbound,
			--t2.ClientName,
		Count(*) as Total
	from #temp_Inbound t1
	join #temp_Client t2
	on t1.ClientID = t2.CentauriClientID
	where t2.ClientName = '''+@ClientName+'''
	and convert(date,t1.LogDate) between '''+@BeginDate+''' and '''+@EndDate+'''
	and t1.FTPPath like ''%'+@ProviderID+'%''
	group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName
	')


end

else if @ClientName = 'FHN'
	and @ProviderID = ''

begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end

else if @ClientName <> 'FHN'
begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end


if @ClientName = 'CCAI'
	and @ProviderID <> ''
begin
exec('
	select	--t1.FileName,
			t1.LogDate,
			--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
			t1.ClientName_Inbound,
			--t2.ClientName,
		Count(*) as Total
	from #temp_Inbound t1
	join #temp_Client t2
	on t1.ClientID = t2.CentauriClientID
	where t2.ClientName = '''+@ClientName+'''
	and convert(date,t1.LogDate) between '''+@BeginDate+''' and '''+@EndDate+'''
	and t1.FTPPath like ''%'+@ProviderID+'%''
	group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName
	')


end

else if @ClientName = 'CCAI'
	and @ProviderID = ''

begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end

else if @ClientName <> 'CCAI'
begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end


if @ClientName = 'Memorial Hermann'
	and @ProviderID <> ''
begin
exec('
	select	--t1.FileName,
			t1.LogDate,
			--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
			t1.ClientName_Inbound,
			--t2.ClientName,
		Count(*) as Total
	from #temp_Inbound t1
	join #temp_Client t2
	on t1.ClientID = t2.CentauriClientID
	where t2.ClientName = '''+@ClientName+'''
	and convert(date,t1.LogDate) between '''+@BeginDate+''' and '''+@EndDate+'''
	and t1.FTPPath like ''%'+@ProviderID+'%''
	group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName
	')


end

else if @ClientName = 'Memorial Hermann'
	and @ProviderID = ''

begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end

else if @ClientName <> 'Memorial Hermann'
begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end



if @ClientName = 'Viva Health'
	and @ProviderID <> ''
begin
exec('
	select	--t1.FileName,
			t1.LogDate,
			--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
			t1.ClientName_Inbound,
			--t2.ClientName,
		Count(*) as Total
	from #temp_Inbound t1
	join #temp_Client t2
	on t1.ClientID = t2.CentauriClientID
	where t2.ClientName = '''+@ClientName+'''
	and convert(date,t1.LogDate) between '''+@BeginDate+''' and '''+@EndDate+'''
	and t1.FTPPath like ''%'+@ProviderID+'%''
	group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName
	')


end

else if @ClientName = 'Viva Health'
	and @ProviderID = ''

begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end

else if @ClientName <> 'Viva Health'
begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end


if @ClientName = 'BSW'
	and @ProviderID <> ''
begin
exec('
	select	--t1.FileName,
			t1.LogDate,
			--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
			t1.ClientName_Inbound,
			--t2.ClientName,
		Count(*) as Total
	from #temp_Inbound t1
	join #temp_Client t2
	on t1.ClientID = t2.CentauriClientID
	where t2.ClientName = '''+@ClientName+'''
	and convert(date,t1.LogDate) between '''+@BeginDate+''' and '''+@EndDate+'''
	and t1.FTPPath like ''%'+@ProviderID+'%''
	group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName
	')


end

else if @ClientName = 'BSW'
	and @ProviderID = ''

begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end

else if @ClientName <> 'BSW'
begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end



if @ClientName = 'BCBS-SC'
	and @ProviderID <> ''
begin
exec('
	select	--t1.FileName,
			t1.LogDate,
			--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
			t1.ClientName_Inbound,
			--t2.ClientName,
		Count(*) as Total
	from #temp_Inbound t1
	join #temp_Client t2
	on t1.ClientID = t2.CentauriClientID
	where t2.ClientName = '''+@ClientName+'''
	and convert(date,t1.LogDate) between '''+@BeginDate+''' and '''+@EndDate+'''
	and t1.FTPPath like ''%'+@ProviderID+'%''
	group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName
	')


end

else if @ClientName = 'BCBS-SC'
	and @ProviderID = ''

begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end

else if @ClientName <> 'BCBS-SC'
begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end



if @ClientName = 'Aetna'
	and @ProviderID <> ''
begin
exec('
	select	--t1.FileName,
			t1.LogDate,
			--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
			t1.ClientName_Inbound,
			--t2.ClientName,
		Count(*) as Total
	from #temp_Inbound t1
	join #temp_Client t2
	on t1.ClientID = t2.CentauriClientID
	where t2.ClientName = '''+@ClientName+'''
	and convert(date,t1.LogDate) between '''+@BeginDate+''' and '''+@EndDate+'''
	and t1.FTPPath like ''%'+@ProviderID+'%''
	group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName
	')


end

else if @ClientName = 'Aetna'
	and @ProviderID = ''

begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end

else if @ClientName <> 'Aetna'
begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end


if @ClientName = 'HCSC'
	and @ProviderID <> ''
begin
exec('
	select	--t1.FileName,
			t1.LogDate,
			--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
			t1.ClientName_Inbound,
			--t2.ClientName,
		Count(*) as Total
	from #temp_Inbound t1
	join #temp_Client t2
	on t1.ClientID = t2.CentauriClientID
	where t2.ClientName = '''+@ClientName+'''
	and convert(date,t1.LogDate) between '''+@BeginDate+''' and '''+@EndDate+'''
	and t1.FTPPath like ''%'+@ProviderID+'%''
	group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName
	')


end

else if @ClientName = 'HCSC'
	and @ProviderID = ''

begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end

else if @ClientName <> 'HCSC'
begin

select  --t1.FileName,
		t1.LogDate,
		--count(t1.ClientName_Inbound) as ClientName_Inbound_Count,
		t1.ClientName_Inbound,
		--t2.ClientName,
		Count(*) as Total
from #temp_Inbound t1
join #temp_Client t2
on t1.ClientID = t2.CentauriClientID
where t2.ClientName = @ClientName
and convert(date,t1.LogDate) between @BeginDate and @EndDate
group by --t1.FileName,
t1.LogDate,
t1.ClientName_Inbound
Order by Total
--t2.ClientName

end


END


GO
