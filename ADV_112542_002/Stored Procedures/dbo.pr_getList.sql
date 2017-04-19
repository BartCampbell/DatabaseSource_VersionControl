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
pr_getList '0','0',1,0,5,5,'11/1/2016','11/30/2016',0
*/
CREATE PROCEDURE [dbo].[pr_getList]
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@LoginUser int,
	@User int,
	@UserType int,
	@DateType int,
	@startDate varchar(12),
	@endDate varchar(12),
	@location int
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
		SET @SQL = '	
			SELECT DISTINCT PO.LastUpdated_User_PK User_PK,0 Project_PK,P.ProviderOffice_PK,1 Sch, 0 Cnt,COUNT(DISTINCT S.Suspect_PK) SchCharts, 0 CntCharts INTO #tmp
			FROM tblSuspect S WITH (NOLOCK)
					INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
					INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
					INNER JOIN tblProviderOfficeSchedule PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK 
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

		SET @SQL = @SQL + '	GROUP BY PO.LastUpdated_User_PK,P.ProviderOffice_PK;

			CREATE INDEX idxTmp ON #tmp (User_PK,Project_PK,ProviderOffice_PK);
			INSERT INTO #tmp
			SELECT DISTINCT PO.LastUpdated_User_PK User_PK,0 Project_PK,P.ProviderOffice_PK,0 Sch, 1 Cnt,0 SchCharts, COUNT(DISTINCT S.Suspect_PK) CntCharts
			FROM tblSuspect S WITH (NOLOCK)
					INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
					INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
					INNER JOIN tblContactNotesOffice PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.Office_PK
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

		SET @SQL = @SQL + '	GROUP BY PO.LastUpdated_User_PK,P.ProviderOffice_PK


		SELECT User_PK,0 Project_PK,ProviderOffice_PK,MAX(Sch) Sch, MAX(Cnt) Cnt,MAX(SchCharts) SchCharts,MAX(CntCharts) CntCharts INTO #Sch
		FROM #tmp GROUP BY User_PK,ProviderOffice_PK;

		CREATE INDEX idxSch ON #Sch (User_PK);
		
		SELECT ROW_NUMBER() OVER(ORDER BY U.Lastname+ISNULL('', ''+U.Firstname,'''')) AS RowNumber, U.User_PK, U.Lastname+ISNULL('', ''+U.Firstname,'''') Fullname,U.Username
				,SUM(Cnt) Contacted,SUM(Sch) Scheduled, SUM(CntCharts) CntCharts, SUM(SchCharts) SchCharts
			FROM #Sch S INNER JOIN tblUser U ON U.User_PK = S.User_PK'
		IF @location <> 0
			SET @SQL = @SQL + ' WHERE U.Location_PK=' + CAST(@location AS VARCHAR)
		SET @SQL = @SQL + '
			GROUP BY U.User_PK, U.Lastname, U.Firstname ,U.Username
			ORDER BY U.Lastname,U.Firstname';
	END
	
	ELSE IF (@UserType=2)	--Scan Tech
	BEGIN
		SET @SQL = '
			SELECT Scanned_User_PK User_PK,COUNT(DISTINCT S.Suspect_PK) Scanned, 0 CNA, 0 Invoices INTO #tmp FROM tblSuspect S 
					INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			WHERE IsScanned=1 '

		IF @User<>0
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

		SET @SQL = @SQL + '
			GROUP BY Scanned_User_PK;

			CREATE INDEX idxtmp ON #tmp (User_PK);
			INSERT INTO #tmp
			SELECT CNA_User_PK User_PK,0 Scanned, COUNT(DISTINCT S.Suspect_PK) CNA, 0 Invoices FROM tblSuspect S 
					INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			WHERE IsCNA=1 ';
					
		IF @User<>0
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
						
		SET @SQL = @SQL + '
			GROUP BY CNA_User_PK

			INSERT INTO #tmp
			SELECT S.User_PK,0 Scanned, 0 CNA, COUNT(DISTINCT S.ProviderOfficeInvoice_PK) Invoices FROM tblExtractionQueueAttachLog S 
					
			WHERE S.IsInvoice=1 ';
					
		IF @User<>0
			SET @SQL = @SQL + ' AND S.User_PK=' + CAST(@User AS VARChar);			
		IF @DateType = 1
			SET @SQL = @SQL + ' AND DATEPART(wk, S.dtInsert) = DATEPART(wk, GETDATE()-7) AND DATEPART(yy, S.dtInsert) = DATEPART(yy, GETDATE()-7)'
		ELSE IF @DateType = 2
			SET @SQL = @SQL + ' AND DATEPART(wk, S.dtInsert) = DATEPART(wk, GETDATE()) AND DATEPART(yy, S.dtInsert) = DATEPART(yy, GETDATE())'
		ELSE IF @DateType = 3
			SET @SQL = @SQL + ' AND Month(S.dtInsert) = Month(GETDATE()) AND Year(S.dtInsert) = Year(GETDATE())'
		ELSE IF @DateType = 4
			SET @SQL = @SQL + ' AND Month(S.dtInsert) = Month(DateAdd(month,-1,getdate())) AND Year(S.dtInsert) = Year(DateAdd(month,-1,getdate()))'
		ELSE IF @DateType = 5
			SET @SQL = @SQL + ' AND S.dtInsert>= '''+ @startDate +''' AND S.dtInsert < DATEADD(Day,1,CAST('''+ @endDate +''' as Date))'
						
		SET @SQL = @SQL + '
			GROUP BY S.User_PK

		SELECT ROW_NUMBER() OVER(ORDER BY U.Lastname+ISNULL('', ''+U.Firstname,'''')) AS RowNumber, U.User_PK, U.Lastname+ISNULL('', ''+U.Firstname,'''') Fullname,U.Username
			,MAX(Scanned) Scanned, MAX(CNA) CNA, MAX(Invoices) Invoices
		FROM #tmp T INNER JOIN tblUser U ON U.User_PK = T.User_PK'
		IF @location <> 0
			SET @SQL = @SQL + ' WHERE U.Location_PK=' + CAST(@location AS VARCHAR)
		SET @SQL = @SQL + ' GROUP BY U.User_PK, U.Lastname, U.Firstname ,U.Username '
		
	END	
	ELSE IF (@UserType=3)		--Coder	-- Reviewer
	BEGIN
		SET @SQL = '	

			SELECT S.User_PK User_PK,COUNT(DISTINCT S.Suspect_PK) Completed,COUNT(DISTINCT SD.ScannedData_PK) CompletedPages, 0 InComplete,NULL InCompletedPages, 0 Assigned INTO #tmp FROM tblSuspectLevelCoded S WITH (NOLOCK)
					INNER JOIN tblSuspect SC WITH (NOLOCK) ON SC.Suspect_PK = S.Suspect_PK
					INNER JOIN #tmpProject Pr ON SC.Project_PK = Pr.Project_PK
					LEFT JOIN tblScannedData SD WITH (NOLOCK) ON S.Suspect_PK = SD.Suspect_PK AND (SD.Is_Deleted IS NULL OR SD.Is_Deleted=0)
			WHERE S.IsCompleted=1 AND SC.LinkedSuspect_PK IS NULL ';
--SELECT * FROM tblSuspectLevelCoded	
		IF @User<>0
			SET @SQL = @SQL + ' AND S.User_PK=' + CAST(@User AS VARChar);			
		IF @DateType = 1
			SET @SQL = @SQL + ' AND DATEPART(wk, S.dtInserted) = DATEPART(wk, GETDATE()-7) AND DATEPART(yy, S.dtInserted) = DATEPART(yy, GETDATE()-7)'
		ELSE IF @DateType = 2
			SET @SQL = @SQL + ' AND DATEPART(wk, S.dtInserted) = DATEPART(wk, GETDATE()) AND DATEPART(yy, S.dtInserted) = DATEPART(yy, GETDATE())'
		ELSE IF @DateType = 3
			SET @SQL = @SQL + ' AND Month(S.dtInserted) = Month(GETDATE()) AND Year(S.dtInserted) = Year(GETDATE())'
		ELSE IF @DateType = 4
			SET @SQL = @SQL + ' AND Month(S.dtInserted) = Month(DateAdd(month,-1,getdate())) AND Year(S.dtInserted) = Year(DateAdd(month,-1,getdate()))'
		ELSE IF @DateType = 5
			SET @SQL = @SQL + ' AND S.dtInserted>= '''+ @startDate +''' AND S.dtInserted < DATEADD(Day,1,CAST('''+ @endDate +''' as Date))'
						
		SET @SQL = @SQL + '
			GROUP BY S.User_PK;

			CREATE INDEX idxtmp ON #tmp (User_PK);
			INSERT INTO #tmp
			SELECT S.User_PK User_PK,0 Completed,NULL CompletedPages, COUNT(DISTINCT S.Suspect_PK) InComplete,COUNT(DISTINCT SD.ScannedData_PK) InCompletedPages, 0 Assigned FROM tblSuspectLevelCoded S
					INNER JOIN tblSuspect SC ON SC.Suspect_PK = S.Suspect_PK
					INNER JOIN #tmpProject Pr ON SC.Project_PK = Pr.Project_PK
					LEFT JOIN tblScannedData SD WITH (NOLOCK) ON S.Suspect_PK = SD.Suspect_PK AND (SD.Is_Deleted IS NULL OR SD.Is_Deleted=0)
			WHERE S.IsCompleted=0  AND SC.LinkedSuspect_PK IS NULL ';
--SELECT * FROM tblSuspectLevelCoded	
		IF @User<>0
			SET @SQL = @SQL + ' AND S.User_PK=' + CAST(@User AS VARChar);			
		IF @DateType = 1
			SET @SQL = @SQL + ' AND DATEPART(wk, S.dtInserted) = DATEPART(wk, GETDATE()-7) AND DATEPART(yy, S.dtInserted) = DATEPART(yy, GETDATE()-7)'
		ELSE IF @DateType = 2
			SET @SQL = @SQL + ' AND DATEPART(wk, S.dtInserted) = DATEPART(wk, GETDATE()) AND DATEPART(yy, S.dtInserted) = DATEPART(yy, GETDATE())'
		ELSE IF @DateType = 3
			SET @SQL = @SQL + ' AND Month(S.dtInserted) = Month(GETDATE()) AND Year(S.dtInserted) = Year(GETDATE())'
		ELSE IF @DateType = 4
			SET @SQL = @SQL + ' AND Month(S.dtInserted) = Month(DateAdd(month,-1,getdate())) AND Year(S.dtInserted) = Year(DateAdd(month,-1,getdate()))'
		ELSE IF @DateType = 5
			SET @SQL = @SQL + ' AND S.dtInserted>= '''+ @startDate +''' AND S.dtInserted < DATEADD(Day,1,CAST('''+ @endDate +''' as Date))'
						
		SET @SQL = @SQL + '
			GROUP BY S.User_PK;

			INSERT INTO #tmp
			SELECT User_PK,0  Completed, NULL CompletedPages, 0 InComplete,NULL InCompletedPages, COUNT(DISTINCT S.Suspect_PK) Assigned FROM tblSuspect S 
				INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
				INNER JOIN tblCoderAssignment PA ON PA.Suspect_PK = S.Suspect_PK
			WHERE 1=1' --S.IsScanned=1 
		IF @User<>0
			SET @SQL = @SQL + ' AND PA.LastUpdated_User_PK=' + CAST(@User AS VARChar);
		IF @DateType = 1
			SET @SQL = @SQL + ' AND DATEPART(wk, PA.LastUpdated_Date) = DATEPART(wk, GETDATE()-7) AND Year(PA.LastUpdated_Date) = Year(GETDATE()-7)'
		ELSE IF @DateType = 2
			SET @SQL = @SQL + ' AND DATEPART(wk, PA.LastUpdated_Date) = DATEPART(wk, GETDATE()) AND Year(PA.LastUpdated_Date) = Year(GETDATE())'
		ELSE IF @DateType = 3
			SET @SQL = @SQL + ' AND Month(PA.LastUpdated_Date) = Month(GETDATE()) AND Year(PA.LastUpdated_Date) = Year(GETDATE())'
		ELSE IF @DateType = 4
			SET @SQL = @SQL + ' AND Month(PA.LastUpdated_Date) = Month(DateAdd(month,-1,getdate())) AND Year(PA.LastUpdated_Date) = Year(DateAdd(month,-1,getdate()))'
		ELSE IF @DateType = 5
			SET @SQL = @SQL + ' AND PA.LastUpdated_Date>= '''+ @startDate +''' AND PA.LastUpdated_Date < DATEADD(Day,1,CAST('''+ @endDate +''' as Date))'

		SET @SQL = @SQL + '					
			GROUP BY User_PK
		
		SELECT ROW_NUMBER() OVER(ORDER BY U.Lastname+ISNULL('', ''+U.Firstname,'''')) AS RowNumber, IsNull(U.User_PK,0) User_PK, U.Lastname+ISNULL('', ''+U.Firstname,'''') Fullname,IsNull(U.Username,''Unknown'') Username
			,SUM(Assigned) Assigned, SUM(Completed) Completed, SUM(CompletedPages) CompletedPages, SUM(InComplete) Incomplete, SUM(InCompletedPages) IncompletePages
		FROM #tmp T LEFT JOIN tblUser U ON U.User_PK = T.User_PK'
		IF @location <> 0
			SET @SQL = @SQL + ' WHERE U.Location_PK=' + CAST(@location AS VARCHAR)
		SET @SQL = @SQL + ' GROUP BY U.User_PK, U.Lastname, U.Firstname ,U.Username
		'		
		--		SELECT SUM(Completed) X FROM #tmp T
	END		
	ELSE IF (@UserType=4)		--PDF Inventory
	BEGIN
		SELECT COUNT(*) Files,'PDFs Assigned To Scan Techs' [Description],0 User_PK FROM tblExtractionQueue WHERE AssignedUser_PK IS NOT NULL UNION
		SELECT COUNT(*),'Pending PDFs still to be attached by Scan Techs.' + IsNull(' Oldest pending date '+CAST(Min(UploadDate) AS VARCHAR),'') X,0 FROM tblExtractionQueue WHERE AssignedUser_PK IS NULL UNION
		SELECT COUNT(*),'Total PDFs received',0 FROM tblExtractionQueue  ORDER BY [Description]		
	END
	ELSE IF (@UserType=5)		--Coder	Summary
	BEGIN
		SET @SQL = '	

			SELECT S.User_PK User_PK,COUNT(DISTINCT S.Suspect_PK) Completed, 0 InComplete, 0 Assigned INTO #tmp FROM tblSuspectLevelCoded S
					INNER JOIN tblSuspect SC ON SC.Suspect_PK = S.Suspect_PK
					INNER JOIN #tmpProject Pr ON SC.Project_PK = Pr.Project_PK
			WHERE S.IsCompleted=1  AND SC.LinkedSuspect_PK IS NULL';
--SELECT * FROM tblSuspectLevelCoded	
		IF @User<>0
			SET @SQL = @SQL + ' AND S.User_PK=' + CAST(@User AS VARChar);			
		IF @DateType = 1
			SET @SQL = @SQL + ' AND DATEPART(wk, S.dtInserted) = DATEPART(wk, GETDATE()-7) AND DATEPART(yy, S.dtInserted) = DATEPART(yy, GETDATE()-7)'
		ELSE IF @DateType = 2
			SET @SQL = @SQL + ' AND DATEPART(wk, S.dtInserted) = DATEPART(wk, GETDATE()) AND DATEPART(yy, S.dtInserted) = DATEPART(yy, GETDATE())'
		ELSE IF @DateType = 3
			SET @SQL = @SQL + ' AND Month(S.dtInserted) = Month(GETDATE()) AND Year(S.dtInserted) = Year(GETDATE())'
		ELSE IF @DateType = 4
			SET @SQL = @SQL + ' AND Month(S.dtInserted) = Month(DateAdd(month,-1,getdate())) AND Year(S.dtInserted) = Year(DateAdd(month,-1,getdate()))'
		ELSE IF @DateType = 5
			SET @SQL = @SQL + ' AND S.dtInserted>= '''+ @startDate +''' AND S.dtInserted < DATEADD(Day,1,CAST('''+ @endDate +''' as Date))'
						
		SET @SQL = @SQL + '
			GROUP BY S.User_PK;

			CREATE INDEX idxtmp ON #tmp (User_PK);

			INSERT INTO #tmp
			SELECT S.User_PK User_PK,0 Completed, COUNT(DISTINCT S.Suspect_PK) InComplete, 0 Assigned FROM tblSuspectLevelCoded S
					INNER JOIN tblSuspect SC ON SC.Suspect_PK = S.Suspect_PK
					INNER JOIN #tmpProject Pr ON SC.Project_PK = Pr.Project_PK
			WHERE S.IsCompleted=0  AND SC.LinkedSuspect_PK IS NULL';
--SELECT * FROM tblSuspectLevelCoded	
		IF @User<>0
			SET @SQL = @SQL + ' AND S.User_PK=' + CAST(@User AS VARChar);			
		IF @DateType = 1
			SET @SQL = @SQL + ' AND DATEPART(wk, S.dtInserted) = DATEPART(wk, GETDATE()-7) AND DATEPART(yy, S.dtInserted) = DATEPART(yy, GETDATE()-7)'
		ELSE IF @DateType = 2
			SET @SQL = @SQL + ' AND DATEPART(wk, S.dtInserted) = DATEPART(wk, GETDATE()) AND DATEPART(yy, S.dtInserted) = DATEPART(yy, GETDATE())'
		ELSE IF @DateType = 3
			SET @SQL = @SQL + ' AND Month(S.dtInserted) = Month(GETDATE()) AND Year(S.dtInserted) = Year(GETDATE())'
		ELSE IF @DateType = 4
			SET @SQL = @SQL + ' AND Month(S.dtInserted) = Month(DateAdd(month,-1,getdate())) AND Year(S.dtInserted) = Year(DateAdd(month,-1,getdate()))'
		ELSE IF @DateType = 5
			SET @SQL = @SQL + ' AND S.dtInserted>= '''+ @startDate +''' AND S.dtInserted < DATEADD(Day,1,CAST('''+ @endDate +''' as Date))'
						
		SET @SQL = @SQL + '
			GROUP BY S.User_PK;

			INSERT INTO #tmp
			SELECT User_PK,0 Completed, 0 InComplete, COUNT(DISTINCT S.Suspect_PK) Assigned FROM tblSuspect S 
				INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
				INNER JOIN tblCoderAssignment PA ON PA.Suspect_PK = S.Suspect_PK
			WHERE 1=1 ' -- S.IsScanned=1 
		IF @User<>0
			SET @SQL = @SQL + ' AND PA.LastUpdated_User_PK=' + CAST(@User AS VARChar);
		IF @DateType = 1
			SET @SQL = @SQL + ' AND DATEPART(wk, PA.LastUpdated_Date) = DATEPART(wk, GETDATE()-7) AND Year(PA.LastUpdated_Date) = Year(GETDATE()-7)'
		ELSE IF @DateType = 2
			SET @SQL = @SQL + ' AND DATEPART(wk, PA.LastUpdated_Date) = DATEPART(wk, GETDATE()) AND Year(PA.LastUpdated_Date) = Year(GETDATE())'
		ELSE IF @DateType = 3
			SET @SQL = @SQL + ' AND Month(PA.LastUpdated_Date) = Month(GETDATE()) AND Year(PA.LastUpdated_Date) = Year(GETDATE())'
		ELSE IF @DateType = 4
			SET @SQL = @SQL + ' AND Month(PA.LastUpdated_Date) = Month(DateAdd(month,-1,getdate())) AND Year(PA.LastUpdated_Date) = Year(DateAdd(month,-1,getdate()))'
		ELSE IF @DateType = 5
			SET @SQL = @SQL + ' AND PA.LastUpdated_Date>= '''+ @startDate +''' AND PA.LastUpdated_Date < DATEADD(Day,1,CAST('''+ @endDate +''' as Date))'

		SET @SQL = @SQL + '					
			GROUP BY User_PK
		
		SELECT ROW_NUMBER() OVER(ORDER BY L.Location) AS RowNumber, IsNull(L.Location,''Unknown'') Location
			,SUM(Assigned) Assigned, SUM(Completed) Completed, SUM(InComplete) Incomplete, 0 User_PK
		FROM #tmp T LEFT JOIN tblUser U ON U.User_PK = T.User_PK
			LEFT JOIN tblLocation L ON L.Location_PK = U.Location_PK 
		'
		IF @location <> 0
			SET @SQL = @SQL + ' WHERE U.Location_PK=' + CAST(@location AS VARCHAR)
		SET @SQL = @SQL + ' GROUP BY L.Location_PK,L.Location
		'		
	END		
	
	EXEC (@SQL);
END 
GO
