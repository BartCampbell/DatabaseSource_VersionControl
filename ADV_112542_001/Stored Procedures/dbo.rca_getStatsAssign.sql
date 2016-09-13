SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- exec rca_getStatsAssign @level=1,@only_incomplete=0,@pages=1,@less_more='g',@priority='',@project=0,@group=0,@charts2Assign=5,@coders='47,40,53,55,39'
-- exec rca_getStatsAssign @level=1,@only_incomplete=0,@pages=1,@less_more='',@priority='',@project=0,@group=0,@charts2Assign=100,@coders=''
CREATE PROCEDURE [dbo].[rca_getStatsAssign]
	@level int,
	@only_incomplete int,
	@pages int,
	@less_more varchar(1),
	@priority varchar(5),
	@Projects varchar(1000),
	@ProjectGroup int,
	@charts2Assign int,
	@coders varchar(1000),
	@IsBlindCoding tinyint
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)
	IF @Projects='0'
	BEGIN
		INSERT INTO #tmpProject(Project_PK)
		SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1 AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
	END
	ELSE
		EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroup+'=0 OR ProjectGroup_PK='+@ProjectGroup+')');
	-- PROJECT SELECTION

	Create table #Suspects (RN Int,Suspect_PK BigInt);
	if (@only_incomplete=1)
	BEGIN
		INSERT INTO #Suspects(RN,Suspect_PK)
		SELECT ROW_NUMBER() OVER(ORDER BY Suspect_PK) RN, Suspect_PK FROM tblSuspectLevelCoded  WHERE CoderLevel=@level AND IsCompleted=0
	END
	ELSE
	BEGIN
		INSERT INTO #Suspects(RN,Suspect_PK)
		SELECT ROW_NUMBER() OVER(ORDER BY S.Member_PK) RN, S.Suspect_PK from tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject P WITH (NOLOCK) ON P.Project_PK = S.Project_PK 
			INNER JOIN tblScannedData SD WITH (NOLOCK) ON SD.Suspect_PK = S.Suspect_PK
			LEFT JOIN tblCoderAssignment CA WITH (NOLOCK) ON CA.Suspect_PK = S.Suspect_PK AND CA.CoderLevel = @level
			LEFT JOIN tblSuspectLevelCoded SLC WITH (NOLOCK) ON SLC.Suspect_PK = S.Suspect_PK AND SLC.CoderLevel = @level-1 AND SLC.IsCompleted=1
		WHERE IsScanned=1 AND IsCoded=0 AND IsNull(SD.is_deleted,0)=0 AND CA.Suspect_PK IS NULL
			AND (@priority='' OR S.ChartPriority=@priority)
			AND (@IsBlindCoding=1 OR @level=1 OR SLC.Suspect_PK IS NOT NULL)
		GROUP BY S.Suspect_PK,S.Member_PK
		HAVING 
			@less_more='' 
			OR (@less_more='l' AND count(*)<=@pages)
			OR (@less_more='g' AND count(*)>=@pages)
		ORDER BY S.Member_PK
	END	

	if (@coders='')
		SELECT COUNT(1) X FROM #Suspects
	else
		BEGIN
			DELETE FROM #Suspects WHERE RN>@charts2Assign

			DELETE FROM CA FROM tblCoderAssignment CA INNER JOIN #Suspects S ON S.Suspect_PK = CA.Suspect_PK AND CA.CoderLevel = @level OR (@IsBlindCoding=0 AND CA.CoderLevel < @level)

			CREATE TABLE #coder (User_PK SmallInt);
			DECLARE @SQL AS VARCHAR(MAX) = 'INSERT INTO #coder SELECT User_PK FROM tblUser WHERE User_PK IN (' + @coders + ');'
			
			EXEC (@SQL);
			SELECT @charts2Assign=@charts2Assign/COUNT(1) FROM #coder
			
			DECLARE @User_PK AS VARCHAR(10)
			DECLARE db_cursor CURSOR FOR SELECT User_PK FROM #coder

			OPEN db_cursor   
			FETCH NEXT FROM db_cursor INTO @User_PK

			WHILE @@FETCH_STATUS = 0   
			BEGIN  
					SET @SQL = 'INSERT INTO tblCoderAssignment(Suspect_PK,User_PK,CoderLevel,LastUpdated_User_PK,LastUpdated_Date) '
					SET @SQL = @SQL + 'SELECT TOP '+ CAST(@charts2Assign AS VARCHAR) +' S.Suspect_PK,' + @User_PK +' User_PK,'+ CAST(@level AS VARCHAR) +' CoderLevel,0 LastUpdated_User_PK,GetDate() LastUpdated_Date FROM #Suspects S LEFT JOIN tblCoderAssignment CA ON S.Suspect_PK = CA.Suspect_PK AND CA.CoderLevel=' + CAST(@level AS VARCHAR) + ' WHERE CA.Suspect_PK IS NULL ORDER BY RN'
					EXEC(@SQL);
					PRINT @SQL;
					FETCH NEXT FROM db_cursor INTO @User_PK
			END   

			CLOSE db_cursor   
			DEALLOCATE db_cursor				

			Drop Table #Suspects
			exec rca_getStatsAssign @level,@only_incomplete,@pages,@less_more,@priority,@Projects,@ProjectGroup,0,'',@IsBlindCoding;
			exec rca_getLists @level,1,@IsBlindCoding;
		END	
END
GO
