SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[prExecSummary_ExtractSummary] 
 @CurrentDate date,
 @4weekDate date,
 @Week1Start date,
 @Week1End date,
 @Week2Start date,
 @Week2End date,
 @Week3Start date,
 @Week3End date,
 @Week4Start date,
 @Week4End date
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--declare @ClientName varchar(25);
--declare @Location varchar(25);
--declare @ReportDate date;

--set @ClientName = 'WellCare';
--set @Location = 'Scottsdale';
--set @ReportDate = '07/22/2016';

set ANSI_Warnings OFF;

set @CurrentDate = convert(date,getdate()-1);
set @4weekDate = DATEADD(week,-4,@CurrentDate);

set @Week1Start = @4weekDate;
set @Week1End = DateAdd(day,+6,@Week1Start);
set @Week2Start = DateAdd(day,+1,@Week1End);
set @Week2End = DateAdd(day,+6,@Week2Start);
set @Week3Start = DateAdd(day,+1,@Week2End);
set @Week3End = DateAdd(day,+6,@Week3Start);
set @Week4Start = DateAdd(day,+1,@Week3End);
set @Week4End = DateAdd(day,+6,@Week4Start);

drop table CHSStaging.dbo.ExecutiveDashboard_ExtractSummary;
CREATE TABLE CHSStaging.dbo.ExecutiveDashboard_ExtractSummary(
	RecID int unique identity(1,1),
	ClientID int not null,
	ProjectID int not null,
	ProjectName varchar(25) not null,
	Week1ExtractActualCnt int default 0,
	Week1ExtractGoalCnt int default 0,
	Week2ExtractActualCnt int default 0,
	Week2ExtractGoalCnt int default 0,
	Week3ExtractActualCnt int default 0,
	Week3ExtractGoalCnt int default 0,
	Week4ExtractActualCnt int default 0,
	Week4ExtractGoalCnt int default 0);

insert into CHSStaging.dbo.ExecutiveDashboard_ExtractSummary(
	ProjectName,
	ProjectID,
	ClientID)
select  t2.Project_Name,
		t2.Project_PK,
		'112547' as ClientID
from dbo.tblSuspect t1
join dbo.tblProject t2
on t1.Project_PK = t2.Project_PK
group by t2.Project_Name, t2.Project_PK

----Week 1 Data ----
update t1 
set Week1ExtractActualCnt = t2.RecCnt
from CHSStaging.dbo.ExecutiveDashboard_ExtractSummary t1
join(
	select  project_PK,
			count(Suspect_PK) as RecCnt
	from Adv_112547_001.dbo.tblSuspect
	where IsScanned = 1
	and convert(date,Scanned_Date) between @Week1Start and @Week1End
	group by project_pk
	)t2
on t1.ProjectID = t2.Project_PK



----Week 2 Data ----
update t1 
set Week2ExtractActualCnt = t2.RecCnt
from CHSStaging.dbo.ExecutiveDashboard_ExtractSummary t1
join(
	select  project_PK,
			count(Suspect_PK) as RecCnt
	from Adv_112547_001.dbo.tblSuspect
	where IsScanned = 1
	and convert(date,Scanned_Date) between @Week2Start and @Week2End
	group by project_pk
	)t2
on t1.ProjectID = t2.Project_PK

----Week 3 Data ----
update t1 
set Week3ExtractActualCnt = t2.RecCnt
from CHSStaging.dbo.ExecutiveDashboard_ExtractSummary t1
join(
	select  project_PK,
			count(Suspect_PK) as RecCnt
	from Adv_112547_001.dbo.tblSuspect
	where IsScanned = 1
	and convert(date,Scanned_Date) between @Week3Start and @Week3End
	group by project_pk
	)t2
on t1.ProjectID = t2.Project_PK

----Week 4 Data ----
update t1 
set Week4ExtractActualCnt = t2.RecCnt
from CHSStaging.dbo.ExecutiveDashboard_ExtractSummary t1
join(
	select  project_PK,
			count(Suspect_PK) as RecCnt
	from Adv_112547_001.dbo.tblSuspect
	where IsScanned = 1
	and convert(date,Scanned_Date) between @Week4Start and @Week4End
	group by project_pk
	)t2
on t1.ProjectID = t2.Project_PK




select *
from CHSStaging.dbo.ExecutiveDashboard_ExtractSummary


END 

GO
