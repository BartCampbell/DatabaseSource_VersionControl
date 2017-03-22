SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cnm_addBulkNote '1','p',1,'Testing',0,1
Create PROCEDURE [dbo].[cnm_addBulkNote] 
	@IDs varchar(max), 
	@updateType varchar(1),
	@note int,
	@addition_info varchar(500),
	@priority_supervisor int, 
	@User int
AS
BEGIN
	CREATE TABLE #tmpOffice (ProviderOffice_PK BIGINT)
	CREATE INDEX idxProviderOfficePK ON #tmpOffice (ProviderOffice_PK)
	DECLARE @SQL varchar(max)
	IF (@updateType='o')
	BEGIN
		SET @SQL = '
		INSERT INTO #tmpOffice SELECT DISTINCT ProviderOffice_PK
		FROM tblProviderOffice
		WHERE ProviderOffice_PK IN ('+@IDs+')'
	END
	ELSE IF (@updateType='p')
	BEGIN
		SET @SQL = '
		INSERT INTO #tmpOffice SELECT DISTINCT ProviderOffice_PK
		FROM tblProvider		
		WHERE Provider_PK IN ('+@IDs+')'
	END
	ELSE IF (@updateType='s')
	BEGIN
		SET @SQL = '
		INSERT INTO #tmpOffice SELECT DISTINCT P.ProviderOffice_PK
		FROM tblSuspect S 
		INNER JOIN tblProvider P ON P.Provider_PK = S.Provider_PK
		WHERE S.Suspect_PK IN ('+@IDs+')'
	END

	EXEC (@SQL);

	DECLARE @ProviderOfficePK AS BIGINT
	DECLARE db_cursor CURSOR FOR  
	SELECT ProviderOffice_PK FROM #tmpOffice 

	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @ProviderOfficePK   

	WHILE @@FETCH_STATUS = 0   
	BEGIN   
		   EXEC sch_saveOfficeContactNote @project=0, @office=@ProviderOfficePK, @note=@note, @aditionaltext=@addition_info, @User_PK=@User, @contact_num=0, @followup=-2,@priority_supervisor=@priority_supervisor;  

		   FETCH NEXT FROM db_cursor INTO @ProviderOfficePK   
	END   

	CLOSE db_cursor   
	DEALLOCATE db_cursor
END
GO
