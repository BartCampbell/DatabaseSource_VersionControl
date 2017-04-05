SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****************************************************************************************************************************************************
Description:	Create the FileProcessID specifc copy of the stage table. Also return a create script for use on the destination server.			

Usage

EXEC CHSStaging.etl.spBCPFileStageTableCreate_Flat
	@FileProcessID = 10001 -- INT
	,@Debug = 1 -- INT = 1

SELECT * FROM CHSStaging.etl.BCPFileStage_1001

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2017-01-26	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROC [etl].[spBCPFileStageTableCreate_Flat]
	@FileProcessID INT
	,@Debug INT = 0


AS

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	SET NOCOUNT ON 

	DECLARE
		@BCPFileStageTableName VARCHAR(25) = 'BCPFileStage_' + CAST(@FileProcessID AS VARCHAR)
		,@vcCmd VARCHAR(MAX)

	-- Drop existing

	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'etl' AND TABLE_NAME = @BCPFileStageTableName))
	BEGIN
		SELECT @vcCmd = 'DROP TABLE etl.' + @BCPFileStageTableName

		IF @Debug >= 1
			PRINT @vcCMd
		
		IF @Debug <= 1
			EXEC (@vcCMD)
	END

	-- CREATE Blank copy of BCPFileStage_Template

	SELECT @vcCmd = 'SELECT * INTO CHSStaging.etl.' + @BCPFileStageTableName + ' FROM CHSStaging.etl.BCPFileStage_TemplateFlat WHERE 1=2'

	IF @Debug >= 1
		PRINT @vcCMd
		
	IF @Debug <= 1
		EXEC (@vcCMD)


GO
