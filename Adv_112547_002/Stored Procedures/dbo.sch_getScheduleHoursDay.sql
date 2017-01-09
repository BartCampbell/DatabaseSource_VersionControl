SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sch_getScheduleHoursDay 1,11192,32825,2015,2,6
CREATE PROCEDURE [dbo].[sch_getScheduleHoursDay] 
	@project smallint,
	@office bigint,
	@ZipCode int,
	@Year int,
	@Month int,
	@Day int
AS
BEGIN
	set datefirst 1
	DECLARE @dt AS SmallDateTime
	SET @dt = CAST(CAST(@Year AS VARCHAR)+'-'+CAST(@Month AS VARCHAR)+'-'+CAST(@Day AS VARCHAR) AS SMALLDATETIME)
	SELECT @dt dt,datepart(weekday,@dt) Day_PK INTO #tmpDate
/*	UNION
	SELECT @dt+1 dt,datepart(weekday,@dt+1) Day_PK 
	UNION
	SELECT @dt+2 dt,datepart(weekday,@dt+2) Day_PK 
	UNION
	SELECT @dt+3 dt,datepart(weekday,@dt+3) Day_PK 
	UNION
	SELECT @dt+4 dt,datepart(weekday,@dt+4) Day_PK 
	UNION
	SELECT @dt+5 dt,datepart(weekday,@dt+5) Day_PK 
	UNION
	SELECT @dt+6 dt,datepart(weekday,@dt+6) Day_PK 
	UNION
	SELECT @dt+7 dt,datepart(weekday,@dt+7) Day_PK 
	*/
	SELECT Hour_Text+Min_Text HourMin INTO #tmpHour FROM tblHour,tblMin

	SELECT U.User_PK,H.HourMin
		,POS.Sch_User_PK,Day(dt) dDay,Month(dt) dMonth,Year(dt) dYear,dt INTO #tmp
	FROM tblUser U WITH (NOLOCK)
		INNER JOIN tblUserWorkingHour UWH WITH (NOLOCK) ON UWH.User_PK = U.User_PK AND IsScanTech=1
		INNER JOIN #tmpDate D ON D.Day_PK = UWH.Day_PK	
		INNER JOIN #tmpHour H ON H.HourMin>=RIGHT('0'+CAST(UWH.FromHour AS VARCHAR),2)+RIGHT('0'+CAST(UWH.FromMin AS VARCHAR),2)
			AND H.HourMin<=RIGHT('0'+CAST(UWH.ToHour AS VARCHAR),2)+RIGHT('0'+CAST(UWH.ToMin AS VARCHAR),2)
		LEFT JOIN tblUserZipCode USC WITH (NOLOCK) ON USC.User_PK = U.User_PK AND USC.ZipCode_PK = @ZipCode
		LEFT JOIN tblProviderOfficeSchedule POS WITH (NOLOCK) ON U.User_PK = POS.Sch_User_PK AND POS.Sch_Type=0
			AND RIGHT('0'+CAST(DatePart(HOUR,Sch_Start) AS VARCHAR),2)+RIGHT('0'+CAST(DatePart(MINUTE,Sch_Start) AS VARCHAR),2)<=H.HourMin
			AND RIGHT('0'+CAST(DatePart(HOUR,Sch_End) AS VARCHAR),2)+RIGHT('0'+CAST(DatePart(MINUTE,Sch_End) AS VARCHAR),2)>=H.HourMin
			AND CAST(CONVERT(VARCHAR,Sch_Start,102) AS SMALLDATETIME)<=D.dt
			AND CAST(CONVERT(VARCHAR,Sch_Start,102) AS SMALLDATETIME)>=D.dt
			AND POS.Sch_Type=0
		WHERE USC.User_PK IS NOT NULL OR IsNull(U.only_work_selected_zipcodes,0)=0
	
--Working Hours
	SELECT HourMin,User_PK,Sch_User_PK ,dDay,dMonth,dYear FROM #tmp ORDER BY User_PK,dYear,dMonth,dDay,HourMin --WHERE Sch_User_PK IS NULL
--Working Days	
	SELECT DISTINCT User_PK,dYear,dMonth,dDay FROM #tmp WHERE Sch_User_PK IS NULL ORDER BY User_PK,dYear,dMonth,dDay
--Available Scan Techs
	SELECT U.User_PK,Lastname+', '+Firstname ScanTech
		FROM tblUser U WITH (NOLOCK) INNER JOIN #tmp T ON T.User_PK = U.User_PK
		WHERE Sch_User_PK IS NULL	
	GROUP BY U.User_PK,Lastname+', '+Firstname
	ORDER BY Lastname+', '+Firstname,MIN(dt) ASC
	
--Office Schedule Info
	SELECT POS.ProviderOfficeSchedule_PK,U.User_PK,Lastname+', '+Firstname ScanTech,Sch_Start,Sch_End,Sch_Type FROM tblProviderOfficeSchedule POS WITH (NOLOCK)
		INNER JOIN tblUser U WITH (NOLOCK) ON U.User_PK = POS.Sch_User_PK
	WHERE Project_PK=@project AND ProviderOffice_PK=@office AND Sch_Type=0
END




GO
