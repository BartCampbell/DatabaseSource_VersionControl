SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	psch_getDays4Pratitioners 40,2016,3,3,104,1
CREATE PROCEDURE [dbo].[psch_getDays4Pratitioners] 
	@practitioner int,
	@Year int,
	@Month int,
	@Day int,
	@member bigint,
	@onlyDays bit
AS
BEGIN
	set datefirst 1

	DECLARE @dt AS Date = GetDate()
	if (@Year<>0)
		SET @dt = CAST(CAST(@Year AS VARCHAR)+'-'+CAST(@Month AS VARCHAR)+'-'+CAST(@Day AS VARCHAR) AS Date)
		
	IF @onlyDays=0
	BEGIN
		DECLARE @member_lat AS FLOAT
		DECLARE @member_lng AS FLOAT

		DECLARE @pract_lat AS FLOAT
		DECLARE @pract_lng AS FLOAT
		SELECT @member_lat=IsNull(M.Latitude,Z.Latitude),@member_lng=IsNull(M.Longitude,Z.Longitude) FROM tblMember M WITH (NOLOCK) INNER JOIN tblZipCode Z WITH (NOLOCK) ON Z.ZipCode_PK = M.ZipCode_PK WHERE M.Member_PK = @member
		SELECT @pract_lat=Latitude,@pract_lng=Longitude from tblUser WHERE User_PK = @practitioner
		

		--List of working days
		SELECT @dt PDay,datepart(weekday,@dt) Day_PK

		--Working hour for each working day
		SELECT Day_PK,FromHour,FromMin,ToHour,ToMin FROM tblUserWorkingHour WHERE User_PK=@practitioner AND datepart(weekday,@dt)=Day_PK

		--Paractitioner Existing Schedule List
		SELECT M.Address,Z.ZipCode,Z.City,Z.State
			,dbo.distance(@member_lat,@member_lng,IsNull(M.Latitude,Z.Latitude),IsNull(M.Longitude,Z.Longitude)) DistanceFromAppointment
			,dbo.distance(@pract_lat,@pract_lng,IsNull(M.Latitude,Z.Latitude),IsNull(M.Longitude,Z.Longitude)) DistanceFromPractitioner
			,POS.Sch_Start,POS.Sch_End,CAST(POS.Sch_Start AS Date) PDay
		FROM tblMemberSchedule POS WITH (NOLOCK) 
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = POS.Member_PK
			INNER JOIN tblZipCode Z WITH (NOLOCK) ON Z.ZipCode_PK = M.ZipCode_PK
		WHERE POS.Sch_User_PK = @practitioner AND CAST(POS.Sch_Start AS DATE)=@dt
		Order By POS.Sch_Start
	END
	ELSE
	BEGIN
		DECLARE @dtStart AS Date = GetDate()
		DECLARE @dtEnd AS Date = DateAdd(day,30,GetDate())
		Create Table #tmpDate (PDay Date)
		CREATE INDEX idxDay ON #tmpDate (PDay)
		SET @dt = @dtStart
		WHILE (@dt<@dtEnd)
		BEGIN
			INSERT INTO #tmpDate VALUES(@dt)
			SET @dt = DateAdd(day,1,@dt)
		END

		--List of working days
		SELECT PDay,Day_PK,Count(MS.Member_PK) Schs FROM #tmpDate T 
			INNER JOIN tblUserWorkingHour UWH WITH (NOLOCK) ON datepart(weekday,PDay)=Day_PK AND User_PK=@practitioner 
			LEFT JOIN tblMemberSchedule MS ON MS.Sch_User_PK = @practitioner AND CAST(Sch_Start AS DATE)=PDay
		GROUP BY PDay,Day_PK
		ORDER BY PDay
	END
END
GO
