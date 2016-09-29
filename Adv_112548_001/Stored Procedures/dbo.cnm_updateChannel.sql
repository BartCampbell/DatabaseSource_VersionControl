SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cnm_updateChannel 1,0,1
Create PROCEDURE [dbo].[cnm_updateChannel] 
	@updateType varchar(1), 
	@IDs varchar(max), 
	@Usr int,
	@Channel int
AS
BEGIN
	CREATE TABLE #tmpSuspect (Suspect_PK BIGINT)
	CREATE INDEX idxSuspectPK ON #tmpSuspect (Suspect_PK)
	DECLARE @SQL varchar(max)
	IF (@updateType='o')
	BEGIN
		SET @SQL = '
		INSERT INTO #tmpSuspect SELECT DISTINCT S.Suspect_PK
		FROM tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK	
		WHERE P.ProviderOffice_PK IN ('+@IDs+')'
	END
	ELSE IF (@updateType='p')
	BEGIN
		SET @SQL = '
		INSERT INTO #tmpSuspect SELECT DISTINCT S.Suspect_PK
		FROM tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK	
		WHERE P.Provider_PK IN ('+@IDs+')'
	END
	ELSE IF (@updateType='s')
	BEGIN
		SET @SQL = '
		INSERT INTO #tmpSuspect SELECT DISTINCT S.Suspect_PK
		FROM tblSuspect S 
		WHERE S.Suspect_PK IN ('+@IDs+')'
	END

	EXEC (@SQL);

	INSERT INTO tblChannelLog(Suspect_PK,From_Channel_PK,To_Channel_PK,User_PK,dtUpdate)
	SELECT S.Suspect_PK,Channel_PK,@Channel,@Usr,GetDate() FROM #tmpSuspect tS INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Suspect_PK = tS.Suspect_PK

	Update S SET Channel_PK = @Channel FROM #tmpSuspect tS INNER JOIN tblSuspect S ON S.Suspect_PK = tS.Suspect_PK
END
GO
