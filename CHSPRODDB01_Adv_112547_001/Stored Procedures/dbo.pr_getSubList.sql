SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Jun-25-2014
-- Description:	To get Finance Report Summary for Dashboad
-- =============================================
/* Sample Executions
pr_getSubList 0,1,2,2,'1/1/2010','1/1/2016',1
*/
CREATE PROCEDURE [dbo].[pr_getSubList]
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@LoginUser int,
	@User int,
	@UserType int,
	@DateType int,
	@startDate varchar(12),
	@endDate varchar(12),
	@DrillType int
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)
	IF @Projects='0'
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@LoginUser)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1 AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@LoginUser AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
	END
	ELSE
		EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroup+'=0 OR ProjectGroup_PK='+@ProjectGroup+')');
	-- PROJECT SELECTION

	DECLARE @SQL VARCHAR(MAX)
	IF (@UserType=1)	--Scheduler
	BEGIN
		IF @DrillType=1
		BEGIN
			SET @SQL = '
				SELECT tPO.Address+IsNULL(''<br>''+Z.City+'', ''+Z.ZipCode+'' ''+Z.State,'''') Address,COUNT(DISTINCT S.Provider_PK) Providers,COUNT(DISTINCT S.Suspect_PK) Charts,
				MIN(PO.LastUpdated_Date) Scheduled_On, U.Lastname+'', ''+U.Firstname ST,MIN(PO.Sch_Start) Sch_Start,MAX(PO.Sch_End) Sch_End
				FROM tblSuspect S WITH (NOLOCK)
						INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
						INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
						INNER JOIN tblProviderOfficeSchedule PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK AND S.Project_PK = PO.Project_PK
						INNER JOIN tblProviderOffice tPO WITH (NOLOCK) ON P.ProviderOffice_PK = tPO.ProviderOffice_PK
						INNER JOIN tblUser U WITH (NOLOCK) ON U.User_PK = PO.LastUpdated_User_PK
						LEFT JOIN tblZipcode Z WITH (NOLOCK) ON Z.ZipCode_PK = tPO.ZipCode_PK
				WHERE 1=1 '

			IF @User<>0
				SET @SQL = @SQL + ' AND PO.LastUpdated_User_PK=' + CAST(@User AS VARChar);
			IF @DateType = 1
				SET @SQL = @SQL + ' AND DATEPART(wk, PO.LastUpdated_Date) = DATEPART(wk, GETDATE()-7) AND Year(PO.LastUpdated_Date) = Year(GETDATE()-7)'
			ELSE IF @DateType = 2
				SET @SQL = @SQL + ' AND DATEPART(wk, PO.LastUpdated_Date) = DATEPART(wk, GETDATE()) AND Year(PO.LastUpdated_Date) = Year(GETDATE())'
			ELSE IF @DateType = 3
				SET @SQL = @SQL + ' AND Month(PO.LastUpdated_Date) = Month(GETDATE()) AND Year(PO.LastUpdated_Date) = Year(GETDATE())'
			ELSE IF @DateType = 4
				SET @SQL = @SQL + ' AND Month(PO.LastUpdated_Date) = Month(DateAdd(month,-1,getdate())) AND Year(PO.LastUpdated_Date) = Year(DateAdd(month,-1,getdate()))'
			ELSE IF @DateType = 5
				SET @SQL = @SQL + ' AND PO.LastUpdated_Date>= '''+ @startDate +''' AND PO.LastUpdated_Date < DATEADD(Day,1,CAST('''+ @endDate +''' as Date))'
				
			SET @SQL = @SQL + ' GROUP BY tPO.Address,Z.City,Z.ZipCode,Z.State,U.Lastname,U.Firstname'
		END
		ELSE
		BEGIN
			SET @SQL = '
				SELECT tPO.Address+IsNULL(''<br>''+Z.City+'', ''+Z.ZipCode+'' ''+Z.State,'''') Address,COUNT(DISTINCT S.Provider_PK) Providers,COUNT(DISTINCT S.Suspect_PK) Charts,
				MAX(PO.LastUpdated_Date) Contacted_On
				FROM tblSuspect S WITH (NOLOCK)
						INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
						INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
						INNER JOIN tblContactNotesOffice PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.Office_PK AND S.Project_PK = PO.Project_PK
						INNER JOIN tblProviderOffice tPO WITH (NOLOCK) ON P.ProviderOffice_PK = tPO.ProviderOffice_PK
						LEFT JOIN tblZipcode Z WITH (NOLOCK) ON Z.ZipCode_PK = tPO.ZipCode_PK
				WHERE 1=1 '

			IF @User<>0
				SET @SQL = @SQL + ' AND PO.LastUpdated_User_PK=' + CAST(@User AS VARChar);
			IF @DateType = 1
				SET @SQL = @SQL + ' AND DATEPART(wk, PO.LastUpdated_Date) = DATEPART(wk, GETDATE()-7) AND Year(PO.LastUpdated_Date) = Year(GETDATE()-7)'
			ELSE IF @DateType = 2
				SET @SQL = @SQL + ' AND DATEPART(wk, PO.LastUpdated_Date) = DATEPART(wk, GETDATE()) AND Year(PO.LastUpdated_Date) = Year(GETDATE())'
			ELSE IF @DateType = 3
				SET @SQL = @SQL + ' AND Month(PO.LastUpdated_Date) = Month(GETDATE()) AND Year(PO.LastUpdated_Date) = Year(GETDATE())'
			ELSE IF @DateType = 4
				SET @SQL = @SQL + ' AND Month(PO.LastUpdated_Date) = Month(DateAdd(month,-1,getdate())) AND Year(PO.LastUpdated_Date) = Year(DateAdd(month,-1,getdate()))'
			ELSE IF @DateType = 5
				SET @SQL = @SQL + ' AND PO.LastUpdated_Date>= '''+ @startDate +''' AND PO.LastUpdated_Date < DATEADD(Day,1,CAST('''+ @endDate +''' as Date))'
				
			SET @SQL = @SQL + ' GROUP BY tPO.Address,Z.City,Z.ZipCode,Z.State'		
		END
	END
	
	ELSE IF (@UserType=2)	--Scan Tech
	BEGIN
		IF @DrillType=1
		BEGIN 
			SET @SQL = '
				SELECT S.Suspect_PK, M.Lastname+ISNULL('', ''+M.Firstname,'''') Member, PM.Lastname+ISNULL('', ''+PM.Firstname,'''') Provider,  S.Scanned_Date DT
					FROM tblSuspect S 
						INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
						INNER JOIN tblMember M ON M.Member_PK = S.Member_PK
						INNER JOIN tblProvider P ON P.Provider_PK = S.Provider_PK
						INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
				WHERE IsScanned=1 '
			
			SET @SQL = @SQL + ' AND S.Scanned_User_PK=' + CAST(@User AS VARChar);		
			IF @DateType = 1
				SET @SQL = @SQL + ' AND DATEPART(wk, S.Scanned_Date) = DATEPART(wk, GETDATE()-7) AND Year(S.Scanned_Date) = Year(GETDATE()-7)'
			ELSE IF @DateType = 2
				SET @SQL = @SQL + ' AND DATEPART(wk, S.Scanned_Date) = DATEPART(wk, GETDATE()) AND Year(S.Scanned_Date) = Year(GETDATE())'
			ELSE IF @DateType = 3
				SET @SQL = @SQL + ' AND Month(S.Scanned_Date) = Month(GETDATE()) AND Year(S.Scanned_Date) = Year(GETDATE())'
			ELSE IF @DateType = 4
				SET @SQL = @SQL + ' AND Month(S.Scanned_Date) = Month(DateAdd(month,-1,getdate())) AND Year(S.Scanned_Date) = Year(DateAdd(month,-1,getdate()))'
			ELSE IF @DateType = 5
				SET @SQL = @SQL + ' AND S.Scanned_Date>= '''+ @startDate +''' AND S.Scanned_Date < DATEADD(Day,1,CAST('''+ @endDate +''' as Date))'
			SET @SQL = @SQL + ' ORDER BY Provider,Member'
		END
		ELSE
		BEGIN
			SET @SQL = '
				SELECT S.Suspect_PK, M.Lastname+ISNULL('', ''+M.Firstname,'''') Member, PM.Lastname+ISNULL('', ''+PM.Firstname,'''') Provider,  S.CNA_Date DT
					FROM tblSuspect S 
						INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
						INNER JOIN tblMember M ON M.Member_PK = S.Member_PK
						INNER JOIN tblProvider P ON P.Provider_PK = S.Provider_PK
						INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
				WHERE IsCNA=1 ';

			SET @SQL = @SQL + ' AND S.CNA_User_PK=' + CAST(@User AS VARChar);						
			IF @DateType = 1
				SET @SQL = @SQL + ' AND DATEPART(wk, S.CNA_Date) = DATEPART(wk, GETDATE()-7) AND DATEPART(yy, S.CNA_Date) = DATEPART(yy, GETDATE()-7)'
			ELSE IF @DateType = 2
				SET @SQL = @SQL + ' AND DATEPART(wk, S.CNA_Date) = DATEPART(wk, GETDATE()) AND DATEPART(yy, S.CNA_Date) = DATEPART(yy, GETDATE())'
			ELSE IF @DateType = 3
				SET @SQL = @SQL + ' AND Month(S.CNA_Date) = Month(GETDATE()) AND Year(S.CNA_Date) = Year(GETDATE())'
			ELSE IF @DateType = 4
				SET @SQL = @SQL + ' AND Month(S.CNA_Date) = Month(DateAdd(month,-1,getdate())) AND Year(S.CNA_Date) = Year(DateAdd(month,-1,getdate()))'
			ELSE IF @DateType = 5
				SET @SQL = @SQL + ' AND S.CNA_Date>= '''+ @startDate +''' AND S.CNA_Date < DATEADD(Day,1,CAST('''+ @endDate +''' as Date))'
			SET @SQL = @SQL + ' ORDER BY Provider,Member'
		END
	END	
	
	ELSE IF (@UserType=3)		--Coder	-- Reviewer
	BEGIN
			SET @SQL = '
				SELECT S.Suspect_PK, M.Lastname+ISNULL('', ''+M.Firstname,'''') Member, PM.Lastname+ISNULL('', ''+PM.Firstname,'''') Provider,  SLC.dtInserted DT
					FROM tblSuspect S 
						INNER JOIN tblSuspectLevelCoded SLC ON SLC.Suspect_PK = S.Suspect_PK
						INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
						INNER JOIN tblMember M ON M.Member_PK = S.Member_PK
						INNER JOIN tblProvider P ON P.Provider_PK = S.Provider_PK
						INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			WHERE IsCoded=1 ';
		
		IF @User<>0
			SET @SQL = @SQL + ' AND SLC.User_PK=' + CAST(@User AS VARChar);			
		IF @DateType = 1
			SET @SQL = @SQL + ' AND DATEPART(wk, SLC.dtInserted) = DATEPART(wk, GETDATE()-7) AND DATEPART(yy, SLC.dtInserted) = DATEPART(yy, GETDATE()-7)'
		ELSE IF @DateType = 2
			SET @SQL = @SQL + ' AND DATEPART(wk, SLC.dtInserted) = DATEPART(wk, GETDATE()) AND DATEPART(yy, SLC.dtInserted) = DATEPART(yy, GETDATE())'
		ELSE IF @DateType = 3
			SET @SQL = @SQL + ' AND Month(SLC.dtInserted) = Month(GETDATE()) AND Year(SLC.dtInserted) = Year(GETDATE())'
		ELSE IF @DateType = 4
			SET @SQL = @SQL + ' AND Month(SLC.dtInserted) = Month(DateAdd(month,-1,getdate())) AND Year(SLC.dtInserted) = Year(DateAdd(month,-1,getdate()))'
		ELSE IF @DateType = 5
			SET @SQL = @SQL + ' AND SLC.dtInserted>= '''+ @startDate +''' AND SLC.dtInserted < DATEADD(Day,1,CAST('''+ @endDate +''' as Date))'
	END		
	
	EXEC (@SQL);
END
GO
