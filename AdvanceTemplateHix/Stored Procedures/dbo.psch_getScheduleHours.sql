SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--psch_getScheduleHours 107,2016,4,15,1,0
CREATE PROCEDURE [dbo].[psch_getScheduleHours] 
	@member bigint,
	@Year int,
	@Month int,
	@Day int,
	@User int,
	@practitioner int
AS
BEGIN
	--This office Latitude and Longitude
	DECLARE @DaysInView AS INT = 40
	DECLARE @Latitude AS FLOAT
	DECLARE @Longitude AS FLOAT
	DECLARE @ZipCode AS INT
	DECLARE @gender as int
	SELECT @Latitude=IsNull(M.Latitude,Z.Latitude),@Longitude=IsNull(M.Longitude,Z.Longitude),@ZipCode = Z.ZipCode,@gender=isnull(preferred_practitioner_gender,0)
	FROM tblMember M WITH (NOLOCK) 
		INNER JOIN tblZipCode Z WITH (NOLOCK) ON Z.ZipCode_PK = M.ZipCode_PK
	WHERE M.Member_PK = @member


	set datefirst 1
	DECLARE @dt AS SmallDateTime
	DECLARE @dt_start AS SmallDateTime
	SET @dt_start = DateAdd(day,-7,CAST(CAST(@Year AS VARCHAR)+'-'+CAST(@Month AS VARCHAR)+'-1' AS SmallDateTime))
	SET @dt = @dt_start
	SELECT @dt dt,datepart(weekday,@dt) Day_PK INTO #tmpDate
	WHILE (@dt<@dt_start+@DaysInView)
	BEGIN
		SET @dt = @dt+1
		INSERT INTO #tmpDate(dt,Day_PK) VALUES(@dt,datepart(weekday,@dt))
	END

	SELECT U.User_PK,
		CAST(DatePart(year,D.dt) AS VARCHAR)+RIGHT('0'+CAST(DatePart(month,D.dt) AS VARCHAR),2)+RIGHT('0'+CAST(DatePart(day,D.dt) AS VARCHAR),2) DateHour --+H.Hour_Text
		,POS.Sch_User_PK INTO #tmp
	FROM tblUser U WITH (NOLOCK)
		INNER JOIN tblUserWorkingHour UWH WITH (NOLOCK) ON UWH.User_PK = U.User_PK AND IsHRA=1
		INNER JOIN #tmpDate D WITH (NOLOCK) ON D.Day_PK = UWH.Day_PK	
		INNER JOIN tblHour H WITH (NOLOCK) ON H.Hour_PK >= UWH.FromHour AND H.Hour_PK <= UWH.ToHour
		LEFT JOIN tblUserZipCode USC WITH (NOLOCK) ON USC.User_PK = U.User_PK AND USC.ZipCode_PK = @ZipCode
		LEFT JOIN tblMemberSchedule POS WITH (NOLOCK) ON U.User_PK = POS.Sch_User_PK
			AND DatePart(HOUR,Sch_Start)<=H.Hour_PK
			AND DatePart(HOUR,Sch_End)>=H.Hour_PK
			AND CAST(CONVERT(VARCHAR,Sch_Start,102) AS SMALLDATETIME)<=D.dt
			AND CAST(CONVERT(VARCHAR,Sch_Start,102) AS SMALLDATETIME)>=D.dt
		WHERE USC.User_PK IS NOT NULL OR IsNull(U.only_work_selected_zipcodes,0)=0
	Order By U.User_PK,DateHour,POS.Sch_User_PK

	--SELECT DateHour,Count(User_PK) Total,Count(User_PK)-Count(Sch_User_PK) Available  FROM #tmp GROUP BY DateHour Having Count(User_PK)-Count(Sch_User_PK)>0 ORDER BY DateHour
	SELECT 0 DateHour,0 Total,0 Available
		
	SELECT 
	CAST(DatePart(year,D.dt) AS VARCHAR)+RIGHT('0'+CAST(DatePart(month,D.dt) AS VARCHAR),2)+RIGHT('0'+CAST(DatePart(day,D.dt) AS VARCHAR),2) DateHour  --+H.Hour_Text
	FROM tblMemberSchedule WITH (NOLOCK) 
		INNER JOIN tblHour H WITH (NOLOCK) ON 
			DatePart(HOUR,Sch_Start)<=H.Hour_PK
			AND DatePart(HOUR,Sch_End)>=H.Hour_PK		
		INNER JOIN #tmpDate D WITH (NOLOCK) ON 
			CAST(CONVERT(VARCHAR,Sch_Start,102) AS SMALLDATETIME)<=D.dt
			AND CAST(CONVERT(VARCHAR,Sch_Start,102) AS SMALLDATETIME)>=D.dt		
	WHERE Member_PK=@member-- AND Project_PK=@project

	--ProspectiveFormStatus O is Pending
	--ProspectiveFormStatus 2 is In Complete
	--ProspectiveFormStatus 1 is Complete
	SELECT TOP 25 Lastname+', '+Firstname Practitioner,Sch_Start,Sch_End,S.Schedule_PK,IsNull(SS.ProspectiveFormStatus,0) ProspectiveFormStatus,SS.MemberStatus
	FROM tblMemberSchedule S WITH (NOLOCK) INNER JOIN tblUser U WITH (NOLOCK) ON U.User_PK = S.Sch_User_PK
		INNER JOIN tblSuspect SS ON S.Suspect_PK = SS.Suspect_PK
	WHERE S.member_PK=@member-- AND S.Project_PK=@project

	--Scheduled office for next 30 days
	SELECT CAST(DatePart(year,POS.Sch_Start) AS VARCHAR)+RIGHT('0'+CAST(DatePart(month,POS.Sch_Start) AS VARCHAR),2)+RIGHT('0'+CAST(DatePart(day,POS.Sch_Start) AS VARCHAR),2) DateHour --+RIGHT('0'+CAST(DatePart(hour,POS.Sch_Start) AS VARCHAR),2)
	,U.Lastname+IsNull(', '+U.Firstname,'') Practitioner
	,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Membername,M.Address,Z.ZipCode,Z.City,Z.State
	,dbo.distance(@Latitude,@Longitude,IsNull(M.Latitude,Z.Latitude),IsNull(M.Longitude,Z.Longitude)) distance_from_appointment
	,dbo.distance(@Latitude,@Longitude,U.Latitude,U.Longitude) distance_from_practitioner_home
	,CASE WHEN U.linked_scheduler_user_pk=@User THEN 1 ELSE 0 END practitioner_associated
	,POS.Sch_User_PK
	FROM tblMemberSchedule POS WITH (NOLOCK) 
		INNER JOIN tblUser U WITH (NOLOCK) ON U.User_PK = POS.Sch_User_PK
		INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = POS.Member_PK
		INNER JOIN tblZipCode Z WITH (NOLOCK) ON Z.ZipCode_PK = M.ZipCode_PK

	WHERE POS.Sch_Start>@dt_start AND POS.Sch_End<=@dt_start+@DaysInView AND M.Member_PK<>@member
	
	Order By U.User_PK,DateHour,POS.Sch_User_PK

	--Associated Practitioners
	SELECT U.User_PK,Lastname+', '+Firstname+' &#9733;' Practitioner
		,dbo.distance(@Latitude,@Longitude,U.Latitude,U.Longitude) DistanceFromPractitioner
	FROM tblUser U WITH (NOLOCK) 
		Outer Apply (SELECT Count(*) Cnt FROM tblUserZipCode UZC WITH (NOLOCK) WHERE UZC.User_PK = U.User_PK AND UZC.ZipCode_PK = @ZipCode) T
	WHERE (U.only_work_selected_zipcodes=0 OR Cnt>0)
		AND U.IsHRA=1
		AND (@gender=0 OR (@gender=1 AND U.is_male=1) OR (@gender=2 AND isnull(U.is_male,0)=0))
		AND U.linked_scheduler_user_pk=@user
	ORDER BY Practitioner ASC

	--Non Associated Practitioners
	SELECT U.User_PK,Lastname+', '+Firstname Practitioner
		,dbo.distance(@Latitude,@Longitude,U.Latitude,U.Longitude) DistanceFromPractitioner
	FROM tblUser U WITH (NOLOCK) 
		Outer Apply (SELECT Count(*) Cnt FROM tblUserZipCode UZC WITH (NOLOCK) WHERE UZC.User_PK = U.User_PK AND UZC.ZipCode_PK = @ZipCode) T
	WHERE (U.only_work_selected_zipcodes=0 OR Cnt>0)
		AND U.IsHRA=1
		AND (@gender=0 OR (@gender=1 AND U.is_male=1) OR (@gender=2 AND isnull(U.is_male,0)=0))
		AND U.linked_scheduler_user_pk<>@user
	ORDER BY Practitioner ASC
END
GO
