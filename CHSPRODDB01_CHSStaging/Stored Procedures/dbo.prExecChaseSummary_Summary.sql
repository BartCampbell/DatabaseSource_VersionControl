SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[prExecChaseSummary_Summary] 
	@ClientName varchar(25),
	@Location varchar(25),
	@ReportDate date
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

IF(@ReportDate IS NULL OR @ReportDate = '01/01/1900')
 set @ReportDate =  dateadd(day,datediff(day,1,GETDATE()),0) --added for subscription 


if OBJECT_ID('CHSStaging.dbo.ProductivityAgentMaster') is not null
DROP Table CHSStaging.dbo.ProductivityAgentMaster;
CREATE TABLE CHSStaging.dbo.ProductivityAgentMaster(
	ClientID int,
	UserID int,
	UserName varchar(100),
	Location varchar(50),
	--ProjectGroup varchar(50),
	LastUpdatedDate date,
	ContactedOfficeCnt int default 0,
	ContactedChaseCnt int default 0,
	ScheduledOfficeCnt int default 0,
	ScheduledChaseCnt int default 0,
	LoadDate datetime);

if @ClientName = 'Viva'
begin
	if @Location = 'ALL'
	begin

	if object_id('tempdb..#temp_VivaAllSched') is not null
	drop table #temp_VivaAllSched
	select	User_PK,
			LastName+', '+FirstName as UserName,
			IsActive,
			t1.Location_PK,
			IsAdmin,
			IsScheduler,
			IsReviewer,
			IsQA,
			t2.Location
	into #temp_VivaAllSched
	from Adv_112546_001.dbo.tblUser t1
	join Adv_112546_001.dbo.tblLocation t2
	on t1.Location_PK = t2.Location_PK
	where t1.Location_PK in ('1','2','3','7')
	and IsClient = 0



	---- Contacts Section ----
	if object_id('tempdb..#temp_VivaAllContacts') is not null
		drop table #temp_VivaAllContacts
	select	t1.User_PK,
			t1.UserName,
			t1.Location,
			--t1.ProjectGroup,
			t1.LastUpdatedDate as LastUpdateDate,
			sum(t1.Sched_OffContacted) as OfficesContacted,
			sum(t1.Sched_Charts) as Contact_Chases
	into #temp_VivaAllContacts
	from(
	select	t1.User_PK,
			t1.UserName,
			t1.Location,
			--t1.Project_PK as Sched_ProjectPK,
			t1.OfficesContacted as Sched_OffContacted,
			t1.Charts as Sched_Charts,
			--t1.ProjectGroup,
			t1.LastUpdatedDate
	from(
		select  t1.User_PK,
				t1.UserName,
				t1.Location,
				--t4.ProjectGroup,
				t2.LastUpdatedDate,
				count(t2.Office_PK) as OfficesContacted,
				isnull(sum(t4.UniqueChases),0) as Charts
		from #temp_VivaAllSched t1
		left outer join(
						select	LastUpdated_User_PK,
								--Project_PK,
								Office_PK,
								convert(date,LastUpdated_Date) as LastUpdatedDate
						from Adv_112546_001.dbo.tblContactNotesOffice
						where convert(date,LastUpdated_Date) = @ReportDate-- and @enddate
						group by LastUpdated_User_PK, --Project_PK
								Office_PK,
								convert(date,LastUpdated_Date)
						)t2
		on t1.User_PK = t2.LastUpdated_User_PK
		left outer join(
						select	--t3.ProjectGroup,
								t2.ProviderOffice_PK,
								count(distinct t1.Suspect_PK) as UniqueChases
						from Adv_112546_001.dbo.tblSuspect t1
						join Adv_112546_001.dbo.tblProvider t2
						on t1.Provider_PK = t2.Provider_PK
						join Adv_112546_001.dbo.tblProject t3
						on t1.Project_PK = t3.Project_PK
						group by /*t3.ProjectGroup,*/ t2.ProviderOffice_PK
						)t4
		--on t2.Project_PK = t4.Project_PK
		on t2.Office_PK = t4.ProviderOffice_PK
		group by t1.User_PK, t1.UserName, t1.Location, t2.LastUpdatedDate
		)t1
	)t1
	group by t1.User_PK, t1.UserName, t1.Location, t1.LastUpdatedDate
	order by t1.location, t1.UserName


	---- Scheduler Sections ----


	if object_id('tempdb..#temp_VivaAllScheduled') is not null
		drop table #temp_VivaAllScheduled
	select	t1.*,
			t2.LastUpdateDate,
			--t2.ProjectGroup,
			t2.OfficeCount,
			t2.ChartCount
	into #temp_VivaAllScheduled
	from #temp_VivaAllSched t1
	left outer join(
					select	t1.LastUpdated_User_PK,
							t1.LastUpdateDate,
							--t2.ProjectGroup,
							count(distinct t1.ProviderOffice_PK) as OfficeCount,
							sum(t2.UniqueChases) as ChartCount
					from(
						select	distinct t1.LastUpdated_User_PK,
								convert(date,t1.LastUpdated_Date) as LastUpdateDate,
								t1.ProviderOffice_PK
						from Adv_112546_001.dbo.tblProviderOfficeSchedule t1
						where convert(date,LastUpdated_Date) = @ReportDate-- and @EndDate
						--and t1.LastUpdated_User_PK = '85'
						)t1
					left outer join(
									select	--t3.ProjectGroup,
											t2.ProviderOffice_PK,
											count(distinct t1.Suspect_PK) as UniqueChases
									from Adv_112546_001.dbo.tblSuspect t1
									join Adv_112546_001.dbo.tblProvider t2
									on t1.Provider_PK = t2.Provider_PK
									join Adv_112546_001.dbo.tblProject t3
									on t1.Project_PK = t3.Project_PK
									group by --t3.ProjectGroup, 
									t2.ProviderOffice_PK
									)t2
					on t1.ProviderOffice_PK = t2.ProviderOffice_PK
					group by t1.LastUpdated_User_PK, t1.LastUpdateDate--, t2.ProjectGroup
					)t2
	on t1.User_PK = t2.LastUpdated_User_PK


	---- Main Data Pull ----
	insert into CHSStaging.dbo.ProductivityAgentMaster(
		ClientID,
		UserID,
		UserName,
		Location,
		--ProjectGroup,
		LastUpdatedDate,
		ContactedOfficeCnt,
		ContactedChaseCnt,
		ScheduledOfficeCnt,
		ScheduledChaseCnt,
		LoadDate)

	select	'112546' as ClientID,
			t1.User_PK,
			t1.UserName,
			t1.Location,
			--t1.ProjectGroup,
			t1.LastUpdateDate,
			t1.OfficesContacted,
			t1.Contact_Chases,
			isnull(t2.OfficeCount,0) as OfficesScheduled,
			isnull(t2.ChartCount,0) as ScheduleChases,
			getdate()
			--t3.IsActive
	from #temp_VivaAllContacts t1
	left outer join #temp_VivaAllScheduled t2
	on t1.user_PK = t2.User_PK
	and t1.Location = t2.Location
	--and isnull(t1.ProjectGroup,'') = isnull(t2.ProjectGroup,'')
	and t1.LastUpdateDate = t2.LastUpdateDate
	join #temp_VivaAllSched t3
	on t1.User_PK = t3.User_PK
	where t1.OfficesContacted > 0 --Remove those Users with no activity
	--and t1.Location = @Location
	order by t1.Location

	--select *
	--from CHSStaging.dbo.ProductivityAgentMaster
	end

else if @Location <> 'ALL'
	begin

	if object_id('tempdb..#temp_VivaSched') is not null
	drop table #temp_VivaSched
	select	User_PK,
			LastName+', '+FirstName as UserName,
			IsActive,
			t1.Location_PK,
			IsAdmin,
			IsScheduler,
			IsReviewer,
			IsQA,
			t2.Location
	into #temp_VivaSched
	from Adv_112546_001.dbo.tblUser t1
	join Adv_112546_001.dbo.tblLocation t2
	on t1.Location_PK = t2.Location_PK
	where t1.Location_PK in ('1','2','3','7')
	and IsClient = 0



	---- Contacts Section ----
	if object_id('tempdb..#temp_VivaContacts') is not null
		drop table #temp_VivaContacts
	select	t1.User_PK,
			t1.UserName,
			t1.Location,
			--t1.ProjectGroup,
			t1.LastUpdatedDate as LastUpdateDate,
			sum(t1.Sched_OffContacted) as OfficesContacted,
			sum(t1.Sched_Charts) as Contact_Chases
	into #temp_VivaContacts
	from(
	select	t1.User_PK,
			t1.UserName,
			t1.Location,
			--t1.Project_PK as Sched_ProjectPK,
			t1.OfficesContacted as Sched_OffContacted,
			t1.Charts as Sched_Charts,
			--t1.ProjectGroup,
			t1.LastUpdatedDate
	from(
		select  t1.User_PK,
				t1.UserName,
				t1.Location,
				--t4.ProjectGroup,
				t2.LastUpdatedDate,
				count(t2.Office_PK) as OfficesContacted,
				isnull(sum(t4.UniqueChases),0) as Charts
		from #temp_VivaSched t1
		left outer join(
						select	LastUpdated_User_PK,
								--Project_PK,
								Office_PK,
								convert(date,LastUpdated_Date) as LastUpdatedDate
						from Adv_112546_001.dbo.tblContactNotesOffice
						where convert(date,LastUpdated_Date) = @ReportDate-- and @enddate
						group by LastUpdated_User_PK, --Project_PK
								Office_PK,
								convert(date,LastUpdated_Date)
						)t2
		on t1.User_PK = t2.LastUpdated_User_PK
		left outer join(
						select	--t3.ProjectGroup,
								t2.ProviderOffice_PK,
								count(distinct t1.Suspect_PK) as UniqueChases
						from Adv_112546_001.dbo.tblSuspect t1
						join Adv_112546_001.dbo.tblProvider t2
						on t1.Provider_PK = t2.Provider_PK
						join Adv_112546_001.dbo.tblProject t3
						on t1.Project_PK = t3.Project_PK
						group by  t2.ProviderOffice_PK
						)t4
		--on t2.Project_PK = t4.Project_PK
		on t2.Office_PK = t4.ProviderOffice_PK
		group by t1.User_PK, t1.UserName, t1.Location,  t2.LastUpdatedDate
		)t1
	)t1
	group by t1.User_PK, t1.UserName, t1.Location,  t1.LastUpdatedDate
	order by t1.location, t1.UserName


	---- Scheduler Sections ----


	if object_id('tempdb..#temp_VivaScheduled') is not null
		drop table #temp_VivaScheduled
	select	t1.*,
			t2.LastUpdateDate,
			--t2.ProjectGroup,
			t2.OfficeCount,
			t2.ChartCount
	into #temp_VivaScheduled
	from #temp_VivaSched t1
	left outer join(
					select	t1.LastUpdated_User_PK,
							t1.LastUpdateDate,
							--t2.ProjectGroup,
							count(distinct t1.ProviderOffice_PK) as OfficeCount,
							sum(t2.UniqueChases) as ChartCount
					from(
						select	distinct t1.LastUpdated_User_PK,
								convert(date,t1.LastUpdated_Date) as LastUpdateDate,
								t1.ProviderOffice_PK
						from Adv_112546_001.dbo.tblProviderOfficeSchedule t1
						where convert(date,LastUpdated_Date) = @ReportDate-- and @EndDate
						--and t1.LastUpdated_User_PK = '85'
						)t1
					left outer join(
									select	--t3.ProjectGroup,
											t2.ProviderOffice_PK,
											count(distinct t1.Suspect_PK) as UniqueChases
									from Adv_112546_001.dbo.tblSuspect t1
									join Adv_112546_001.dbo.tblProvider t2
									on t1.Provider_PK = t2.Provider_PK
									join Adv_112546_001.dbo.tblProject t3
									on t1.Project_PK = t3.Project_PK
									group by --t3.ProjectGroup, 
									t2.ProviderOffice_PK
									)t2
					on t1.ProviderOffice_PK = t2.ProviderOffice_PK
					group by t1.LastUpdated_User_PK, t1.LastUpdateDate--, t2.ProjectGroup
					)t2
	on t1.User_PK = t2.LastUpdated_User_PK


	---- Main Data Pull ----
	insert into CHSStaging.dbo.ProductivityAgentMaster(
		ClientID,
		UserID,
		UserName,
		Location,
		--ProjectGroup,
		LastUpdatedDate,
		ContactedOfficeCnt,
		ContactedChaseCnt,
		ScheduledOfficeCnt,
		ScheduledChaseCnt,
		LoadDate)

	select	'112546' as ClientID,
			t1.User_PK,
			t1.UserName,
			t1.Location,
			--t1.ProjectGroup,
			t1.LastUpdateDate,
			t1.OfficesContacted,
			t1.Contact_Chases,
			isnull(t2.OfficeCount,0) as OfficesScheduled,
			isnull(t2.ChartCount,0) as ScheduleChases,
			getdate()
			--t3.IsActive
	from #temp_VivaContacts t1
	left outer join #temp_VivaScheduled t2
	on t1.user_PK = t2.User_PK
	and t1.Location = t2.Location
	--and isnull(t1.ProjectGroup,'') = isnull(t2.ProjectGroup,'')
	and t1.LastUpdateDate = t2.LastUpdateDate
	join #temp_VivaSched t3
	on t1.User_PK = t3.User_PK
	where t1.OfficesContacted > 0 --Remove those Users with no activity
	and t1.Location = @Location
	order by t1.Location

	--select *
	--from CHSStaging.dbo.ProductivityAgentMaster

	end

end

else if @ClientName = 'WellCare'
begin
	if @Location <> 'ALL'
	begin

	if object_id('tempdb..#temp_WCSched') is not null
	drop table #temp_WCSched
	select	User_PK,
			LastName+', '+FirstName as UserName,
			IsActive,
			t1.Location_PK,
			IsAdmin,
			IsScheduler,
			IsReviewer,
			IsQA,
			t2.Location
	into #temp_WCSched
	from Adv_112547_001.dbo.tblUser t1
	join Adv_112547_001.dbo.tblLocation t2
	on t1.Location_PK = t2.Location_PK
	where t1.Location_PK in ('1','2','3','7')
	and IsClient = 0



	---- Contacts Section ----
	if object_id('tempdb..#temp_WCContacts') is not null
		drop table #temp_WCContacts
	select	t1.User_PK,
			t1.UserName,
			t1.Location,
			--t1.ProjectGroup,
			t1.LastUpdatedDate as LastUpdateDate,
			sum(t1.Sched_OffContacted) as OfficesContacted,
			sum(t1.Sched_Charts) as Contact_Chases
	into #temp_WCContacts
	from(
	select	t1.User_PK,
			t1.UserName,
			t1.Location,
			--t1.Project_PK as Sched_ProjectPK,
			t1.OfficesContacted as Sched_OffContacted,
			t1.Charts as Sched_Charts,
			--t1.ProjectGroup,
			t1.LastUpdatedDate
	from(
		select  t1.User_PK,
				t1.UserName,
				t1.Location,
				--t4.ProjectGroup,
				t2.LastUpdatedDate,
				count(t2.Office_PK) as OfficesContacted,
				isnull(sum(t4.UniqueChases),0) as Charts
		from #temp_WCSched t1
		left outer join(
						select	LastUpdated_User_PK,
								--Project_PK,
								Office_PK,
								convert(date,LastUpdated_Date) as LastUpdatedDate
						from Adv_112547_001.dbo.tblContactNotesOffice
						where convert(date,LastUpdated_Date) = @ReportDate-- and @enddate
						group by LastUpdated_User_PK, --Project_PK
								Office_PK,
								convert(date,LastUpdated_Date)
						)t2
		on t1.User_PK = t2.LastUpdated_User_PK
		left outer join(
						select	--t3.ProjectGroup,
								t2.ProviderOffice_PK,
								count(distinct t1.Suspect_PK) as UniqueChases
						from Adv_112547_001.dbo.tblSuspect t1
						join Adv_112547_001.dbo.tblProvider t2
						on t1.Provider_PK = t2.Provider_PK
						join Adv_112547_001.dbo.tblProject t3
						on t1.Project_PK = t3.Project_PK
						group by  t2.ProviderOffice_PK
						)t4
		--on t2.Project_PK = t4.Project_PK
		on t2.Office_PK = t4.ProviderOffice_PK
		group by t1.User_PK, t1.UserName, t1.Location,  t2.LastUpdatedDate
		)t1
	)t1
	group by t1.User_PK, t1.UserName, t1.Location,  t1.LastUpdatedDate
	order by t1.location, t1.UserName

	---- Scheduler Sections ----


	if object_id('tempdb..#temp_WCScheduled') is not null
		drop table #temp_WCScheduled
	select	t1.*,
			t2.LastUpdateDate,
			--t2.ProjectGroup,
			t2.OfficeCount,
			t2.ChartCount
	into #temp_WCScheduled
	from #temp_WCSched t1
	left outer join(
					select	t1.LastUpdated_User_PK,
							t1.LastUpdateDate,
							--t2.ProjectGroup,
							count(distinct t1.ProviderOffice_PK) as OfficeCount,
							sum(t2.UniqueChases) as ChartCount
					from(
						select	distinct t1.LastUpdated_User_PK,
								convert(date,t1.LastUpdated_Date) as LastUpdateDate,
								t1.ProviderOffice_PK
						from Adv_112547_001.dbo.tblProviderOfficeSchedule t1
						where convert(date,LastUpdated_Date) = @ReportDate-- and @EndDate
						--and t1.LastUpdated_User_PK = '85'
						)t1
					left outer join(
									select	--t3.ProjectGroup,
											t2.ProviderOffice_PK,
											count(distinct t1.Suspect_PK) as UniqueChases
									from Adv_112547_001.dbo.tblSuspect t1
									join Adv_112547_001.dbo.tblProvider t2
									on t1.Provider_PK = t2.Provider_PK
									join Adv_112547_001.dbo.tblProject t3
									on t1.Project_PK = t3.Project_PK
									group by --t3.ProjectGroup, 
									t2.ProviderOffice_PK
									)t2
					on t1.ProviderOffice_PK = t2.ProviderOffice_PK
					group by t1.LastUpdated_User_PK, t1.LastUpdateDate--, t2.ProjectGroup
					)t2
	on t1.User_PK = t2.LastUpdated_User_PK


	---- Main Data Pull ----
	insert into CHSStaging.dbo.ProductivityAgentMaster(
		ClientID,
		UserID,
		UserName,
		Location,
		--ProjectGroup,
		LastUpdatedDate,
		ContactedOfficeCnt,
		ContactedChaseCnt,
		ScheduledOfficeCnt,
		ScheduledChaseCnt,
		LoadDate)

	select	'112547' as ClientID,
			t1.User_PK,
			t1.UserName,
			t1.Location,
			--t1.ProjectGroup,
			t1.LastUpdateDate,
			t1.OfficesContacted,
			t1.Contact_Chases,
			isnull(t2.OfficeCount,0) as OfficesScheduled,
			isnull(t2.ChartCount,0) as ScheduleChases,
			getdate()
			--t3.IsActive
	from #temp_WCContacts t1
	left outer join #temp_WCScheduled t2
	on t1.user_PK = t2.User_PK
	and t1.Location = t2.Location
	--and isnull(t1.ProjectGroup,'') = isnull(t2.ProjectGroup,'')
	and t1.LastUpdateDate = t2.LastUpdateDate
	join #temp_WCSched t3
	on t1.User_PK = t3.User_PK
	where t1.OfficesContacted > 0 --Remove those Users with no activity
	and t1.Location = @Location
	order by t1.Location

	--select *
	--from CHSStaging.dbo.ProductivityAgentMaster
	end
else if @Location = 'ALL'
	begin

	if object_id('tempdb..#temp_WCALLSched') is not null
	drop table #temp_WCALLSched
	select	User_PK,
			LastName+', '+FirstName as UserName,
			IsActive,
			t1.Location_PK,
			IsAdmin,
			IsScheduler,
			IsReviewer,
			IsQA,
			t2.Location
	into #temp_WCALLSched
	from Adv_112547_001.dbo.tblUser t1
	join Adv_112547_001.dbo.tblLocation t2
	on t1.Location_PK = t2.Location_PK
	where t1.Location_PK in ('1','2','3','7')
	and IsClient = 0



	---- Contacts Section ----
	if object_id('tempdb..#temp_WCALLContacts') is not null
		drop table #temp_WCALLContacts
	select	t1.User_PK,
			t1.UserName,
			t1.Location,
			--t1.ProjectGroup,
			t1.LastUpdatedDate as LastUpdateDate,
			sum(t1.Sched_OffContacted) as OfficesContacted,
			sum(t1.Sched_Charts) as Contact_Chases
	into #temp_WCALLContacts
	from(
	select	t1.User_PK,
			t1.UserName,
			t1.Location,
			--t1.Project_PK as Sched_ProjectPK,
			t1.OfficesContacted as Sched_OffContacted,
			t1.Charts as Sched_Charts,
			--t1.ProjectGroup,
			t1.LastUpdatedDate
	from(
		select  t1.User_PK,
				t1.UserName,
				t1.Location,
				--t4.ProjectGroup,
				t2.LastUpdatedDate,
				count(t2.Office_PK) as OfficesContacted,
				isnull(sum(t4.UniqueChases),0) as Charts
		from #temp_WCALLSched t1
		left outer join(
						select	LastUpdated_User_PK,
								--Project_PK,
								Office_PK,
								convert(date,LastUpdated_Date) as LastUpdatedDate
						from Adv_112547_001.dbo.tblContactNotesOffice
						where convert(date,LastUpdated_Date) = @ReportDate-- and @enddate
						group by LastUpdated_User_PK, --Project_PK
								Office_PK,
								convert(date,LastUpdated_Date)
						)t2
		on t1.User_PK = t2.LastUpdated_User_PK
		left outer join(
						select	--t3.ProjectGroup,
								t2.ProviderOffice_PK,
								count(distinct t1.Suspect_PK) as UniqueChases
						from Adv_112547_001.dbo.tblSuspect t1
						join Adv_112547_001.dbo.tblProvider t2
						on t1.Provider_PK = t2.Provider_PK
						join Adv_112547_001.dbo.tblProject t3
						on t1.Project_PK = t3.Project_PK
						group by  t2.ProviderOffice_PK
						)t4
		--on t2.Project_PK = t4.Project_PK
		on t2.Office_PK = t4.ProviderOffice_PK
		group by t1.User_PK, t1.UserName, t1.Location,  t2.LastUpdatedDate
		)t1
	)t1
	group by t1.User_PK, t1.UserName, t1.Location,  t1.LastUpdatedDate
	order by t1.location, t1.UserName

	---- Scheduler Sections ----


	if object_id('tempdb..#temp_WCALLScheduled') is not null
		drop table #temp_WCALLScheduled
	select	t1.*,
			t2.LastUpdateDate,
			--t2.ProjectGroup,
			t2.OfficeCount,
			t2.ChartCount
	into #temp_WCALLScheduled
	from #temp_WCALLSched t1
	left outer join(
					select	t1.LastUpdated_User_PK,
							t1.LastUpdateDate,
							--t2.ProjectGroup,
							count(distinct t1.ProviderOffice_PK) as OfficeCount,
							sum(t2.UniqueChases) as ChartCount
					from(
						select	distinct t1.LastUpdated_User_PK,
								convert(date,t1.LastUpdated_Date) as LastUpdateDate,
								t1.ProviderOffice_PK
						from Adv_112547_001.dbo.tblProviderOfficeSchedule t1
						where convert(date,LastUpdated_Date) = @ReportDate-- and @EndDate
						--and t1.LastUpdated_User_PK = '85'
						)t1
					left outer join(
									select	--t3.ProjectGroup,
											t2.ProviderOffice_PK,
											count(distinct t1.Suspect_PK) as UniqueChases
									from Adv_112547_001.dbo.tblSuspect t1
									join Adv_112547_001.dbo.tblProvider t2
									on t1.Provider_PK = t2.Provider_PK
									join Adv_112547_001.dbo.tblProject t3
									on t1.Project_PK = t3.Project_PK
									group by --t3.ProjectGroup, 
									t2.ProviderOffice_PK
									)t2
					on t1.ProviderOffice_PK = t2.ProviderOffice_PK
					group by t1.LastUpdated_User_PK, t1.LastUpdateDate--, t2.ProjectGroup
					)t2
	on t1.User_PK = t2.LastUpdated_User_PK


	---- Main Data Pull ----
	insert into CHSStaging.dbo.ProductivityAgentMaster(
		ClientID,
		UserID,
		UserName,
		Location,
		--ProjectGroup,
		LastUpdatedDate,
		ContactedOfficeCnt,
		ContactedChaseCnt,
		ScheduledOfficeCnt,
		ScheduledChaseCnt,
		LoadDate)

	select	'112547' as ClientID,
			t1.User_PK,
			t1.UserName,
			t1.Location,
			--t1.ProjectGroup,
			Convert (datetime, t1.LastUpdateDate, 120),
			t1.OfficesContacted,
			t1.Contact_Chases,
			isnull(t2.OfficeCount,0) as OfficesScheduled,
			isnull(t2.ChartCount,0) as ScheduleChases,
			getdate()
			--t3.IsActive
	from #temp_WCALLContacts t1
	left outer join #temp_WCALLScheduled t2
	on t1.user_PK = t2.User_PK
	and t1.Location = t2.Location
	--and isnull(t1.ProjectGroup,'') = isnull(t2.ProjectGroup,'')
	and t1.LastUpdateDate = t2.LastUpdateDate
	join #temp_WCALLSched t3
	on t1.User_PK = t3.User_PK
	where t1.OfficesContacted > 0 --Remove those Users with no activity
	--and t1.Location = @Location
	order by t1.Location

	--select *
	--from CHSStaging.dbo.ProductivityAgentMaster
	--end

end

END




--if OBJECT_ID('CHSStaging.dbo.ChaseDetail') is not null
--DROP Table CHSStaging.dbo.ChaseDetail;
--select	ClientID,
--		UserID,
--		UserName,
--		Location,
--		ProjectGroup,
--		LastUpdatedDate,
--		ContactedOfficeCnt,
--		ContactedChaseCnt,
--		ScheduledOfficeCnt,
--		ScheduledChaseCnt,
--		LoadDate
--		into ChaseDetail
--from dbo.ProductivityAgentMaster;



--if OBJECT_ID('CHSStaging.dbo.ChaseSummary') is not null
--DROP Table CHSStaging.dbo.ChaseSummary;
--select	Location,
--		count(distinct UserID) as UserCnt,
--		sum(ContactedOfficeCnt) as SumConOfficeCnt,
--		sum(ContactedOfficeCnt)/count(distinct UserID) as AvgConOffice,
--		sum(ContactedChaseCnt) as SumConChaseCnt,
--		sum(ScheduledOfficeCnt) as SumSchOfficeCnt,
--		sum(ScheduledOfficeCnt)/count(distinct UserID) as AvgSchOffice,
--		sum(ScheduledChaseCnt) as SumSchChaseCnt,
--		sum(ScheduledChaseCnt)/count(distinct UserID) as AvgSchChase
--		--into ChaseSummary
--from dbo.ProductivityAgentMaster
--group by Location;


--End


select	Location,
		count(distinct UserID) as UserCnt,
		sum(ContactedOfficeCnt) as SumConOfficeCnt,
		sum(ContactedOfficeCnt)/count(distinct UserID) as AvgConOffice,
		sum(ContactedChaseCnt) as SumConChaseCnt,
		sum(ScheduledOfficeCnt) as SumSchOfficeCnt,
		sum(ScheduledOfficeCnt)/count(distinct UserID) as AvgSchOffice,
		sum(ScheduledChaseCnt) as SumSchChaseCnt,
		sum(ScheduledChaseCnt)/count(distinct UserID) as AvgSchChase
		--into ChaseSummary
from dbo.ProductivityAgentMaster
group by Location






END



GO
