SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Update FileLog records for a given Session and assign files to threads
Use:

DECLARE @ThreadCnt INT

EXEC CHSStaging.etl.spFileLogThreadAssignment 
	@FileLogSessionID = 1000000
	,@ThreadCnt = @ThreadCnt OUTPUT

SELECT @ThreadCnt

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2017-04-13	Michael Vlk			- Create
2017-05-10	Michael Vlk			- Update @ThreadCnt to final thread count after assignment. 
****************************************************************************************************************************************************/
CREATE PROCEDURE [etl].[spFileLogThreadAssignment] (
	@FileLogSessionID INT
	,@ThreadCnt INT OUTPUT
	)
AS
BEGIN

	DECLARE 
		@ThreadCur INT = 1
		,@FileCur INT = 1
		,@FileLogID INT

	SELECT TOP 1 @ThreadCnt = fs.ThreadCnt
		FROM CHSStaging.etl.FileLog fl 
		INNER JOIN CHSStaging.etl.FileConfig fc ON fl.FileConfigID = fc.FileConfigID
		INNER JOIN CHSStaging.ETL.FileSet fs ON fc.FileSetID = fs.FileSetID
		WHERE 1=1
			AND fl.FileLogSessionID = @FileLogSessionID

	--PRINT @ThreadCnt
	
	SELECT TOP 1 @FileLogID = FileLogID -- SELECT TOP 1 FileLogID
		FROM CHSStaging.etl.FileLog fl 
		INNER JOIN CHSStaging.etl.FileConfig fc ON fl.FileConfigID = fc.FileConfigID
		WHERE 1=1
			AND fl.FileLogSessionID = @FileLogSessionID
			AND fc.FileActionCd = 1
			AND fl.FileThread IS NULL AND fl.FileThreadPriority IS NULL
		ORDER BY
			fc.FilePriority DESC
			,fl.FileSize DESC

	WHILE @FileLogID IS NOT NULL
	BEGIN
		-- PRINT @FileLogID
		
		UPDATE CHSStaging.etl.FileLog
			SET FileThread = @ThreadCur
				,FileThreadPriority = (@FileCur / @ThreadCnt ) + CASE WHEN @FileCur % @ThreadCnt = 0 THEN 0 ELSE 1 END
			WHERE FileLogID = @FileLogID
		
		SET @FileLogID = NULL

		SELECT TOP 1 @FileLogID = FileLogID  -- SELECT TOP 1 FileLogID
			FROM CHSStaging.etl.FileLog fl 
			INNER JOIN CHSStaging.etl.FileConfig fc ON fl.FileConfigID = fc.FileConfigID
			WHERE 1=1
				AND fl.FileLogSessionID = @FileLogSessionID
				AND fc.FileActionCd = 1
				AND fl.FileThread IS NULL AND fl.FileThreadPriority IS NULL
			ORDER BY
				fc.FilePriority DESC
				,fl.FileSize DESC

		SELECT @ThreadCur = CASE WHEN @ThreadCur = @ThreadCnt THEN 1 ELSE @ThreadCur + 1 END
		SELECT @FileCur = @FileCur + 1
	END

	--

	SELECT TOP 1 @ThreadCnt = MAX(FileThread)  -- SELECT MAX(FileThread)
			FROM CHSStaging.etl.FileLog fl
			WHERE 1=1
				AND fl.FileLogSessionID = @FileLogSessionID 
END
GO
