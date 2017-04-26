SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- exec rca_getStatsAssign @level=1,@only_incomplete=1,@pages=50,@less_more='l',@priority='',@projects=0,@ProjectGroup=0,@charts2Assign=10,@coders='',@IsBlindCoding=1,@IsHCCOnly=0,@ForceMemberAssign=0
CREATE PROCEDURE [dbo].[rca_getStatsAssign]
	@level int,
	@only_incomplete int,
	@pages int,
	@less_more varchar(1),
	@priority varchar(5),
	@Projects varchar(1000),
	@ProjectGroup int,
	@charts2Assign int,
	@coders varchar(max),
	@IsBlindCoding tinyint,
	@IsHCCOnly tinyint,
	@ForceMemberAssign tinyint
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
	CREATE INDEX idxSuspect_PK ON #Suspects (Suspect_PK)

	Create table #Members (Member_PK BigInt);
	CREATE INDEX idxMember_PK ON #Members (Member_PK)

	Create table #MembersS (Member_PK BigInt);
	CREATE INDEX idxMember_PKS ON #MembersS (Member_PK)
			DECLARE @SQL AS VARCHAR(MAX)
	if (@only_incomplete=1)
	BEGIN
		if (@coders='')
		BEGIN
			SELECT COUNT(DISTINCT Suspect_PK) FROM tblSuspectLevelCoded  WHERE CoderLevel=@level AND IsCompleted=0
		END
		ELSE
		BEGIN
			;WITH tbl AS (
				SELECT ROW_NUMBER() OVER(ORDER BY Suspect_PK) RN, Suspect_PK FROM tblSuspectLevelCoded  WHERE CoderLevel=@level AND IsCompleted=0
			)

			INSERT INTO #Suspects(RN,Suspect_PK)
			SELECT RN,Suspect_PK FROM tbl WHERE RN<=@charts2Assign 
		END
	END
	ELSE
	BEGIN

		SET @SQL = ' from tblSuspect S WITH (NOLOCK)'
		SET @SQL = @SQL + '			INNER JOIN #tmpProject P WITH (NOLOCK) ON P.Project_PK = S.Project_PK '
		IF @less_more<>''
			SET @SQL = @SQL + '			INNER JOIN tblScannedData SD WITH (NOLOCK) ON SD.Suspect_PK = S.Suspect_PK'
		SET @SQL = @SQL + '			LEFT JOIN tblCoderAssignment CA WITH (NOLOCK) ON CA.Suspect_PK = S.Suspect_PK AND CA.CoderLevel = '+CAST(@level AS VARCHAR)+''
		SET @SQL = @SQL + '			LEFT JOIN tblSuspectLevelCoded SLC_This WITH (NOLOCK) ON SLC_This.Suspect_PK = S.Suspect_PK AND SLC_This.CoderLevel = '+CAST(@level AS VARCHAR)+' AND SLC_This.IsCompleted=1'
		SET @SQL = @SQL + '			LEFT JOIN tblSuspectLevelCoded SLC WITH (NOLOCK) ON SLC.Suspect_PK = S.Suspect_PK AND SLC.CoderLevel = '+CAST(@level AS VARCHAR)+'-1 AND SLC.IsCompleted=1'
		IF @IsHCCOnly<>0
		BEGIN
			SET @SQL = @SQL + '			LEFT JOIN tblClaimData CD WITH (NOLOCK) ON CD.Suspect_PK = S.Suspect_PK'
			SET @SQL = @SQL + '			LEFT JOIN tblModelCode MC WITH (NOLOCK) ON MC.DiagnosisCode = CD.DiagnosisCode AND MC.V12HCC IS NOT NULL'
		END
		SET @SQL = @SQL + '		WHERE IsScanned=1' --
		IF @less_more<>''
			SET @SQL = @SQL + '			AND (SD.is_deleted IS NULL OR SD.is_deleted=0)'
		SET @SQL = @SQL + '			AND SLC_This.Suspect_PK IS NULL' --Replaced 'AND IsCoded=0' to this to Show only not coded charts by this level. 
		SET @SQL = @SQL + '			AND CA.Suspect_PK IS NULL'
		IF @priority<>''
			SET @SQL = @SQL + '			S.ChartPriority='+CAST(@priority AS VARCHAR)
		SET @SQL = @SQL + '			AND ('+CAST(@IsBlindCoding AS VARCHAR)+'=1 OR '+CAST(@level AS VARCHAR)+'=1 OR SLC.Suspect_PK IS NOT NULL)'
		IF @IsHCCOnly<>0
			SET @SQL = @SQL + '			AND MC.DiagnosisCode IS NOT NULL'
		IF @less_more<>''
		BEGIN
			SET @SQL = @SQL + '		GROUP BY S.Suspect_PK,S.Member_PK'
			SET @SQL = @SQL + '		HAVING '
			IF @less_more='l'
				SET @SQL = @SQL + '			count(DISTINCT SD.ScannedData_PK)<='+CAST(@pages AS VARCHAR)
			IF @less_more='g'
				SET @SQL = @SQL + '			count(DISTINCT SD.ScannedData_PK)>='+CAST(@pages AS VARCHAR)
		END

		if (@coders='')
		BEGIN
			SET @SQL = ';WITH tbl AS (
				SELECT S.Suspect_PK '+@SQL + ')
			SELECT COUNT(1) FROM tbl' 
		END
		ELSE
		BEGIN
			SET @SQL = ';WITH tbl AS (
				SELECT ROW_NUMBER() OVER(ORDER BY S.Member_PK) RN, S.Suspect_PK '+@SQL + ')

			INSERT INTO #Suspects(RN,Suspect_PK)
			SELECT RN,Suspect_PK FROM tbl WHERE RN<=' + cast(@charts2Assign AS VARCHAR) 
		END
		EXEC (@SQL)
	END	

	if (@coders<>'')
	BEGIN		
		IF (@ForceMemberAssign=1)
		BEGIN
			INSERT INTO #Members(Member_PK)
			SELECT DISTINCT nS.Member_PK FROM #Suspects tS 
				INNER JOIN tblSuspect S ON S.Suspect_PK = tS.Suspect_PK
				INNER JOIN tblSuspect nS ON S.Member_PK = nS.Member_PK

			DELETE CA FROM tblCoderAssignment CA INNER JOIN tblSuspect S ON S.Suspect_PK = CA.Suspect_PK 
				INNER JOIN #Members M ON S.Member_PK = M.Member_PK
			WHERE CoderLevel = @level
		END

		DELETE FROM CA FROM tblCoderAssignment CA INNER JOIN #Suspects S ON S.Suspect_PK = CA.Suspect_PK AND CA.CoderLevel = @level OR (@IsBlindCoding=0 AND CA.CoderLevel < @level)

		CREATE TABLE #coder (User_PK SmallInt);
		SET @SQL = 'INSERT INTO #coder SELECT User_PK FROM tblUser WHERE User_PK IN (' + @coders + ');'
			
		EXEC (@SQL);

		IF (@ForceMemberAssign=1)
			SET @charts2Assign=CEILING(CAST((SELECT COUNT(1) FROM #Members) AS Float)/CAST((SELECT COUNT(1) FROM #coder) AS Float))
		ELSE
			SELECT @charts2Assign=@charts2Assign/COUNT(1) FROM #coder

		DECLARE @User_PK AS VARCHAR(10)
		DECLARE db_cursor CURSOR FOR SELECT User_PK FROM #coder

		OPEN db_cursor   
		FETCH NEXT FROM db_cursor INTO @User_PK

		WHILE @@FETCH_STATUS = 0   
		BEGIN  
			IF (@ForceMemberAssign=1)
			BEGIN
				Truncate Table #MembersS
				INSERT INTO #MembersS SELECT DISTINCT TOP (@charts2Assign) M.Member_PK FROM #Members M INNER JOIN tblSuspect S ON S.Member_PK = M.Member_PK LEFT JOIN tblCoderAssignment CA ON S.Suspect_PK = CA.Suspect_PK AND CA.CoderLevel=@level WHERE CA.Suspect_PK IS NULL

				SET @SQL = 'INSERT INTO tblCoderAssignment(Suspect_PK,User_PK,CoderLevel,LastUpdated_User_PK,LastUpdated_Date) '
				SET @SQL = @SQL + 'SELECT S.Suspect_PK,' + @User_PK +' User_PK,'+ CAST(@level AS VARCHAR) +' CoderLevel,0 LastUpdated_User_PK,GetDate() LastUpdated_Date FROM #MembersS M INNER JOIN tblSuspect S ON S.Member_PK = M.Member_PK LEFT JOIN tblCoderAssignment CA ON S.Suspect_PK = CA.Suspect_PK AND CA.CoderLevel=' + CAST(@level AS VARCHAR) + ' WHERE CA.Suspect_PK IS NULL'
			END
			ELSE
			BEGIN
				SET @SQL = 'INSERT INTO tblCoderAssignment(Suspect_PK,User_PK,CoderLevel,LastUpdated_User_PK,LastUpdated_Date) '
				SET @SQL = @SQL + 'SELECT TOP '+ CAST(@charts2Assign AS VARCHAR) +' S.Suspect_PK,' + @User_PK +' User_PK,'+ CAST(@level AS VARCHAR) +' CoderLevel,0 LastUpdated_User_PK,GetDate() LastUpdated_Date FROM #Suspects S LEFT JOIN tblCoderAssignment CA ON S.Suspect_PK = CA.Suspect_PK AND CA.CoderLevel=' + CAST(@level AS VARCHAR) + ' WHERE CA.Suspect_PK IS NULL ORDER BY RN'
			END
			EXEC(@SQL);

			FETCH NEXT FROM db_cursor INTO @User_PK
		END   

		CLOSE db_cursor   
		DEALLOCATE db_cursor				

		Drop Table #Suspects
		exec rca_getStatsAssign @level,@only_incomplete,@pages,@less_more,@priority,@Projects,@ProjectGroup,0,'',@IsBlindCoding,@IsHCCOnly,0;
		exec rca_getLists @level,1,@IsBlindCoding;
	END	
END
GO
