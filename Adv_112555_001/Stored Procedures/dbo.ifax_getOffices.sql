SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	ifax_getOffices 0,1
CREATE PROCEDURE [dbo].[ifax_getOffices] 
	@preview tinyint,
	@page int
AS
BEGIN
	DECLARE @location_charts AS SMALLINT
	DECLARE @isFaxIn AS BIT
	DECLARE @isMailIn AS BIT
	DECLARE @isEmail AS BIT
	DECLARE @DaysSinceLastContact AS SMALLINT
	DECLARE @DaysBeforeSchReturn AS SMALLINT
	DECLARE @DaysPastSchReturn AS SMALLINT
	DECLARE @DaysSinceLastFax AS SMALLINT
	DECLARE @IssueLocations AS BIT
	DECLARE @StopEngine AS BIT
	SELECT @location_charts=location_charts,@isFaxIn=isFaxIn,@isMailIn=isMailIn,@isEmail=isEmail,@DaysSinceLastContact=DaysSinceLastContact,@DaysBeforeSchReturn=DaysBeforeSchReturn,@DaysPastSchReturn=DaysPastSchReturn,@DaysSinceLastFax=DaysSinceLastFax,@IssueLocations=IssueLocations,@StopEngine=StopEngine FROM tblConfig_iFax

	SELECT ROW_NUMBER() OVER(ORDER BY PO.Address ASC) RowNum,PO.ProviderOffice_PK,MAX(cPO.office_status) OfficeStatus		
			,PO.Address,ZC.City,ZC.County,ZC.State,PO.ZipCode_PK,ZC.Zipcode
			,SUM(cPO.providers) Providers
			,SUM(cPO.charts-cPO.extracted_count-cPO.cna_count) Charts
			,MIN(follow_up) [Follow Up],Min(dtLastContact) [Last Contact]
			,Max(Sch.SDate) Scheduled,MAX(Fax.FDate) [Last Faxed]
			,MAX(CASE WHEN Issue.ProviderOffice_PK IS NULL THEN 0 ELSE 1 END) [Issue Location]
			,MAX(schedule_type) schedule_type,IsNull(MAX(E.ProviderOffice_PK),0) Excluded
		INTO #tmp
		FROM 
			cacheProviderOffice cPO WITH (NOLOCK)
			INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK=cPO.ProviderOffice_PK 
			Outer Apply (SELECT TOP 1 Sch_Start SDate FROM tblProviderOfficeSchedule WHERE ProviderOffice_PK = PO.ProviderOffice_PK ORDER BY LastUpdated_Date DESC) Sch
			Outer Apply (SELECT TOP 1 LastUpdated_Date FDate FROM tblContactNotesOffice WHERE ContactNote_PK=6 AND Office_PK = PO.ProviderOffice_PK ORDER BY LastUpdated_Date DESC) Fax
			Outer Apply (SELECT TOP 1 ProviderOffice_PK FROM tblProviderOfficeStatus WHERE OfficeIssueStatus=1 AND ProviderOffice_PK = PO.ProviderOffice_PK) Issue
			LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK	
			LEFT JOIN tblExclude_iFax E WITH (NOLOCK) ON E.ProviderOffice_PK=cPO.ProviderOffice_PK 
	WHERE cPO.charts-cPO.extracted_count-cPO.cna_count<>0
	GROUP BY PO.ProviderOffice_PK,PO.Address,ZC.City,ZC.County,ZC.State,PO.ZipCode_PK,ZC.Zipcode
	Having (SUM(cPO.charts-cPO.extracted_count-cPO.cna_count)<=@location_charts OR @location_charts=0)
		AND (@DaysSinceLastContact=0 OR DateDiff(day,MIN(dtLastContact),GetDate())>=@DaysSinceLastContact)
		AND (@DaysBeforeSchReturn=0 OR DateDiff(day,Max(Sch.SDate),GetDate())<=@DaysBeforeSchReturn)
		AND (@DaysPastSchReturn=0 OR DateDiff(day,Max(Sch.SDate),GetDate())>=@DaysPastSchReturn)
		AND (@DaysSinceLastFax=0 OR DateDiff(day,MAX(FDate),GetDate())>=@DaysSinceLastFax)
		AND
		MAX(schedule_type)<>0 AND 
		(
			(@isFaxIn=1 AND MAX(schedule_type)=1)
			OR
			(@isMailIn=1 AND MAX(schedule_type)=3)
			OR
			(@isEmail=1 AND MAX(schedule_type)=2)
		)

		AND 	
		((@IssueLocations=0 AND MAX(CASE WHEN Issue.ProviderOffice_PK IS NULL THEN 0 ELSE 1 END)=0) OR @IssueLocations=1)
	
	IF (@preview=1)
	BEGIN
		DECLARE @PageSize INT = 25
		SELECT * FROM #tmp WHERE RowNum>(@page-1)*@PageSize AND RowNum<=(@page*@PageSize)

		SELECT '' alpha1,'' alpha2,Count(*) records FROM #tmp
	END
	ELSE
	BEGIN
		SELECT @StopEngine StopEngine
		IF (@StopEngine=1)
			return;

		SELECT * FROM #tmp WHERE Excluded=0
	END 
END
GO
