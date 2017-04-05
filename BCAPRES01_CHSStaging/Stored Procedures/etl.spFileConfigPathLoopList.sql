SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****************************************************************************************************************************************************
Description:	Given a Path and Name, Return the matching FileConfigID
Use:

EXEC CHSStaging.etl.spFileConfigPathLoopList 
	@FileProcessID = 1001
	--,@FileSetID = 100000
	,@FilePathIntake = '\\CHS-FS01\DataIntake\112556\AllScripts'

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-12-02	Michael Vlk			- Create
2017-01-04	Michael Vlk			- Select DISTINCT
2017-02-22	Michael Vlk			- Add additional input parms to limit scope of a run
****************************************************************************************************************************************************/
CREATE PROCEDURE [etl].[spFileConfigPathLoopList] (
	@FileProcessID INT
	,@FileSetID INT = 0
	,@FilePathIntake VARCHAR(2000) = ''
	)
AS
BEGIN

	SELECT DISTINCT fc.FilePathIntakeVolume + fc.FilePathIntakePath AS FilePathIntake
	FROM etl.FileConfig fc
	WHERE 1=1
		AND fc.FileProcessID = @FileProcessID
		AND (@FileSetID = 0 OR (@FileSetID > 0 AND fc.FileSetID = @FileSetID))
		AND (@FilePathIntake = '' OR (@FilePathIntake <> '' AND fc.FilePathIntakeVolume + fc.FilePathIntakePath = @FilePathIntake))
		AND fc.IsActive = 1
		AND fc.FilePathIntakeVolume IS NOT NULL 
		AND fc.FilePathIntakePath IS NOT NULL


END


GO
