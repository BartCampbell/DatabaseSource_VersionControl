SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Given a Path and Name, Return the matching FileConfigID
Use:

EXEC CHSStaging.etl.spFileConfigPathLoopList 
	@FileProcessID = 2001
	,@FileSetID = 100004
	--,@FilePathIntake = '\\CHS-FS01\DataIntake\112556\AllScripts'

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-12-02	Michael Vlk			- Create
2017-01-04	Michael Vlk			- Select DISTINCT
2017-02-22	Michael Vlk			- Add additional input parms to limit scope of a run
2017-04-12	Michael Vlk			- Use etl.FileSet as primary source for FilePathIntakeVolume / FilePathIntakePath
****************************************************************************************************************************************************/
CREATE PROCEDURE [etl].[spFileConfigPathLoopList] (
	@FileProcessID INT
	,@FileSetID INT = 0
	,@FilePathIntake VARCHAR(2000) = ''
	)
AS
BEGIN

	SELECT
		fs.FilePathIntakeVolume + fs.FilePathIntakePath AS FilePathIntake
	FROM etl.FileSet fs
	WHERE 1=1
		AND fs.FileSetID = @FileSetID
	UNION
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
