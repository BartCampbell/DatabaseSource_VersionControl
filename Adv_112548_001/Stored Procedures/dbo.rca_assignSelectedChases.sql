SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	rca_assignSelectedChases @search_type=1, @search_value='160', @user=1, @level=1, @coders='1', @suspect='305850,305851,305853,305854,305855,305856,305857,305858,305859,305860',@only_incomplete=0,@pages=1,@less_more='g',@priority='',@Projects='0',@ProjectGroup=0,@IsBlindCoding=1,@IsHCCOnly=0,@ForceMemberAssign=0
CREATE PROCEDURE [dbo].[rca_assignSelectedChases] 
	@search_filter int,
	@search_type int,
	@search_value varchar(1000),
	@user int,
	@level int,
	@coders varchar(max),
	@suspect varchar(max),

	@only_incomplete int,
	@pages int,
	@less_more varchar(1),
	@priority varchar(5),
	@Projects varchar(1000),
	@ProjectGroup int,
	@IsBlindCoding tinyint,
	@IsHCCOnly tinyint,
	@ForceMemberAssign tinyint
AS
BEGIN
	Create table #Suspects (RN Int,Suspect_PK BigInt);
	CREATE INDEX idxSuspect_PK ON #Suspects (Suspect_PK)

	Create table #Members (Member_PK BigInt);
	CREATE INDEX idxMember_PK ON #Members (Member_PK)

	Create table #MembersS (Member_PK BigInt);
	CREATE INDEX idxMember_PKS ON #MembersS (Member_PK)

	DECLARE @SQL AS VARCHAR(MAX)
	IF (@suspect='')
	BEGIN
		-- PROJECT/Channel SELECTION
		CREATE TABLE #tmpProject (Project_PK INT)
		CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)

		CREATE TABLE #tmpChannel (Channel_PK INT)
		CREATE INDEX idxChannelPK ON #tmpChannel (Channel_PK)

		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
		BEGIN
			INSERT INTO #tmpProject(Project_PK) SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1
			INSERT INTO #tmpChannel(Channel_PK) SELECT DISTINCT Channel_PK FROM tblChannel 
		END
		ELSE
		BEGIN
			INSERT INTO #tmpProject(Project_PK) SELECT DISTINCT Project_PK FROM tblUserProject WHERE User_PK=@User
			INSERT INTO #tmpChannel(Channel_PK) SELECT DISTINCT Channel_PK FROM tblUserChannel WHERE User_PK=@User
		END		 
		-- PROJECT/Channel SELECTION

		INSERT INTO #Suspects(RN,Suspect_PK)
		SELECT ROW_NUMBER() OVER(ORDER BY S.Member_PK) RN, S.Suspect_PK
		FROM 
			tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			LEFT JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK = P.ProviderOffice_PK
			LEFT JOIN tblZipCode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK	
			LEFT JOIN tblCoderAssignment CA WITH (NOLOCK) ON CA.Suspect_PK = S.Suspect_PK AND CA.CoderLevel = @level
			LEFT JOIN tblSuspectLevelCoded SLC WITH (NOLOCK) ON SLC.CoderLevel = @level AND SLC.Suspect_PK = S.Suspect_PK
			--LEFT JOIN tblUser U ON U.User_PK = CA.User_PK
		WHERE (
			@search_filter=0 OR 
			(@search_filter=101 AND IsNull(SLC.IsCompleted,0)=0 AND S.IsScanned=1) OR
			(@search_filter=102 AND IsNull(SLC.IsCompleted,0)=0) OR
			(@search_filter=103 AND S.IsScanned=1) OR
			(@search_filter=104 AND S.IsScanned=0) OR
			(@search_filter=105 AND SLC.IsCompleted=0) OR
			SLC.CompletionStatus_PK=@search_filter
		) 
		AND
			(
			@search_type=0 OR
			--Office
			(@search_type=1 AND CAST(PO.ProviderOffice_PK AS VARCHAR)=@search_value) OR
			(@search_type=101 AND PO.Address Like '%'+@search_value+'%') OR
			(@search_type=102 AND PO.LocationID Like '%'+@search_value+'%') OR
			(@search_type=103 AND PO.ContactNumber Like '%'+@search_value+'%') OR
			(@search_type=104 AND PO.FaxNumber Like '%'+@search_value+'%') OR
			(@search_type=105 AND S.PlanLID Like '%'+@search_value+'%') OR
			--Provider
			(@search_type=2 AND CAST(PM.ProviderMaster_PK AS VARCHAR)=@search_value) OR
			(@search_type=201 AND PM.ProviderGroup Like '%'+@search_value+'%') OR
			(@search_type=202 AND PM.Provider_ID Like '%'+@search_value+'%') OR
			(@search_type=203 AND PM.NPI Like '%'+@search_value+'%') OR
			(@search_type=204 AND PM.Lastname+IsNull(', '+PM.Firstname,'') Like '%'+@search_value+'%') OR
			(@search_type=205 AND PM.PIN Like '%'+@search_value+'%') OR
			--Chase
			(@search_type=3 AND CAST(M.Member_PK AS VARCHAR)=@search_value) OR
			(@search_type=301 AND M.Member_ID Like '%'+@search_value+'%') OR
			(@search_type=302 AND M.Lastname+IsNull(', '+M.Firstname,'') Like '%'+@search_value+'%') OR
			(@search_type=303 AND M.HICNumber Like '%'+@search_value+'%') OR
			(@search_type=304 AND S.ChaseID Like '%'+@search_value+'%') OR
			--Coder
			(@search_type=4 AND CAST(CA.User_PK AS VARCHAR)=@search_value)
		)
	END
	ELSE
	BEGIN
		SET @SQL = 'INSERT INTO #Suspects SELECT ROW_NUMBER() OVER(ORDER BY S.Member_PK) RN, S.Suspect_PK FROM tblSuspect S WHERE Suspect_PK IN (' + @suspect + ');'
		EXEC (@SQL);
	END

	IF (@ForceMemberAssign=1)
	BEGIN
		INSERT INTO #Members(Member_PK)
		SELECT DISTINCT nS.Member_PK FROM #Suspects tS 
			INNER JOIN tblSuspect S ON S.Suspect_PK = tS.Suspect_PK
			INNER JOIN tblSuspect nS ON S.Member_PK = nS.Member_PK
	END

	CREATE TABLE #coder (User_PK SmallInt);
	SET @SQL = 'INSERT INTO #coder SELECT User_PK FROM tblUser WHERE User_PK IN (' + @coders + ');'			
	EXEC (@SQL);
	DECLARE @charts2Assign AS INT

	--Remove existing assingments
	IF (@ForceMemberAssign=1)
	BEGIN
		DELETE CA FROM tblCoderAssignment CA INNER JOIN tblSuspect S ON S.Suspect_PK = CA.Suspect_PK 
			INNER JOIN #Members M ON S.Member_PK = M.Member_PK
		WHERE CoderLevel = @level

		SET @charts2Assign=CEILING(CAST((SELECT COUNT(1) FROM #Members) AS Float)/CAST((SELECT COUNT(1) FROM #coder) AS Float))
	END
	ELSE 
	BEGIN
		DELETE CA FROM tblCoderAssignment CA INNER JOIN #Suspects S ON S.Suspect_PK = CA.Suspect_PK AND CoderLevel = @level

		SET @charts2Assign=CEILING(CAST((SELECT COUNT(1) FROM #Suspects) AS Float)/CAST((SELECT COUNT(1) FROM #coder) AS Float))
	END

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
GO
