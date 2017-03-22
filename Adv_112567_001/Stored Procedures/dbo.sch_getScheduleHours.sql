SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sch_getScheduleHours 0,107,12009,2016,9,30
CREATE PROCEDURE [dbo].[sch_getScheduleHours] 
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
	DECLARE @dt_start AS SmallDateTime
	SET @dt_start = CAST(CAST(@Year AS VARCHAR)+'-'+CAST(@Month AS VARCHAR)+'-'+CAST(@Day AS VARCHAR) AS SMALLDATETIME)
	SET @dt = CAST(CAST(@Year AS VARCHAR)+'-'+CAST(@Month AS VARCHAR)+'-'+CAST(@Day AS VARCHAR) AS SMALLDATETIME)
	SELECT @dt dt,datepart(weekday,@dt) Day_PK INTO #tmpDate
	WHILE (@dt<@dt_start+30)
	BEGIN
		SET @dt = @dt+1
		INSERT INTO #tmpDate(dt,Day_PK) VALUES(@dt,datepart(weekday,@dt))
	END

	SELECT U.User_PK,
		CAST(DatePart(year,D.dt) AS VARCHAR)+RIGHT('0'+CAST(DatePart(month,D.dt) AS VARCHAR),2)+RIGHT('0'+CAST(DatePart(day,D.dt) AS VARCHAR),2)+H.Hour_Text DateHour
		,POS.Sch_User_PK INTO #tmp
	FROM tblUser U WITH (NOLOCK)
		INNER JOIN tblUserWorkingHour UWH WITH (NOLOCK) ON UWH.User_PK = U.User_PK AND IsScanTech=1
		INNER JOIN #tmpDate D WITH (NOLOCK) ON D.Day_PK = UWH.Day_PK	
		INNER JOIN tblHour H WITH (NOLOCK) ON H.Hour_PK >= UWH.FromHour AND H.Hour_PK <= UWH.ToHour
		LEFT JOIN tblUserZipCode USC WITH (NOLOCK) ON USC.User_PK = U.User_PK AND USC.ZipCode_PK = @ZipCode
		LEFT JOIN tblProviderOfficeSchedule POS WITH (NOLOCK) ON U.User_PK = POS.Sch_User_PK AND POS.Sch_Type=0
			AND DatePart(HOUR,Sch_Start)<=H.Hour_PK
			AND DatePart(HOUR,Sch_End)>=H.Hour_PK
			AND CAST(CONVERT(VARCHAR,Sch_Start,102) AS SMALLDATETIME)<=D.dt
			AND CAST(CONVERT(VARCHAR,Sch_Start,102) AS SMALLDATETIME)>=D.dt
			AND POS.Sch_Type=0
		WHERE USC.User_PK IS NOT NULL OR IsNull(U.only_work_selected_zipcodes,0)=0
	Order By U.User_PK,DateHour,POS.Sch_User_PK

	SELECT DateHour,Count(User_PK) Total,Count(User_PK)-Count(Sch_User_PK) Available  FROM #tmp GROUP BY DateHour Having Count(User_PK)-Count(Sch_User_PK)>0 ORDER BY DateHour
		
	SELECT 
	CAST(DatePart(year,D.dt) AS VARCHAR)+RIGHT('0'+CAST(DatePart(month,D.dt) AS VARCHAR),2)+RIGHT('0'+CAST(DatePart(day,D.dt) AS VARCHAR),2)+H.Hour_Text DateHour
	FROM tblProviderOfficeSchedule WITH (NOLOCK) 
		INNER JOIN tblHour H WITH (NOLOCK) ON 
			DatePart(HOUR,Sch_Start)<=H.Hour_PK
			AND DatePart(HOUR,Sch_End)>=H.Hour_PK		
		INNER JOIN #tmpDate D WITH (NOLOCK) ON 
			CAST(CONVERT(VARCHAR,Sch_Start,102) AS SMALLDATETIME)<=D.dt
			AND CAST(CONVERT(VARCHAR,Sch_Start,102) AS SMALLDATETIME)>=D.dt		
	WHERE ProviderOffice_PK=@office  AND Sch_Type=0 --AND Project_PK=@project

	SELECT DISTINCT TOP 25  IsNull(Lastname+', '+Firstname,'') ScanTech,Sch_Start,Sch_End,MAX(ProviderOfficeSchedule_PK) ProviderOfficeSchedule_PK,Sch_Type
	FROM tblProviderOfficeSchedule S WITH (NOLOCK) LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK = S.Sch_User_PK
	WHERE S.ProviderOffice_PK=@office --AND S.Project_PK=@project --AND S.Sch_Type=0
	GROUP BY Lastname+', '+Firstname,Sch_Start,Sch_End,Sch_Type
	ORDER BY Sch_Start DESC

	--DELETE FROM tblProviderOfficeSchedule WHERE Sch_Type IS NULL

	SELECT DISTINCT U.User_PK,Lastname,Firstname
		FROM tblUser U WITH (NOLOCK) INNER JOIN #tmp T ON T.User_PK = U.User_PK	
END
GO
