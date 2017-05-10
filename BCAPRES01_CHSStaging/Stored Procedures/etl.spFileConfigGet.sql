SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****************************************************************************************************************************************************
Description:	Given a Path and Name, Return the matching FileConfigID
Use:

DECLARE @FileConfigID INT, @FileActionCd INT
EXEC CHSStaging.etl.spFileConfigGet 
	'\\fs01.imihealth.com\FileStore\StFrancis\Anthem\Temp','CODE_SETS_03132017.txt',@FileConfigID OUTPUT, @FileActionCd OUTPUT
SELECT @FileConfigID, @FileActionCd

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-11-23	Michael Vlk			- Create
2016-12-02	Michael Vlk			- Update so @FilePath can include subfolders
2016-12-05	Michael Vlk			- Allow <YYYYMMDD> Like date patterens in FileNamePattern
2017-01-18	Michael Vlk			- Return FileActionCd
2017-01-20	Michael Vlk			- Add additional Date pattern
2017-03-27	Michael Vlk			- Add DateFileStr pattern %<YYYY-MM-DD>%
2017-03-31	Michael Vlk			- Add DateFileStr pattern %<YYYYMM>%
2017-04-31	Michael Vlk			- Add DateFileStr pattern %<YYYY_MM>%
2017-04-12	Michael Vlk			- Use etl.FileSet as primary source for FilePathIntakeVolume / FilePathIntakePath
****************************************************************************************************************************************************/
CREATE PROCEDURE [etl].[spFileConfigGet] (
	@FilePath VARCHAR(100)
	,@FileName VARCHAR(100)
	,@FileConfigID INT OUTPUT
	,@FileActionCd INT OUTPUT
	)
AS
BEGIN

	SELECT @FileConfigID = fc.FileConfigID, @FileActionCd = fc.FileActionCd
	FROM etl.FileConfig fc
	LEFT OUTER JOIN etl.FileSet fs ON fc.FileSetID = fs.FileSetID
	WHERE 1=1
		AND fc.IsActive = 1
		AND (	fs.FilePathIntakeVolume + fs.FilePathIntakePath = LEFT(@FilePath,(LEN(fs.FilePathIntakeVolume + fs.FilePathIntakePath)))
				OR fc.FilePathIntakeVolume + fc.FilePathIntakePath = LEFT(@FilePath,(LEN(fc.FilePathIntakeVolume + fc.FilePathIntakePath)))
				)
		AND @FileName LIKE 
			CASE 
				WHEN fc.FileNamePattern LIKE '%<YYYYMMDD>%' 
					THEN REPLACE(fc.FileNamePattern,'<YYYYMMDD>','[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')		
				WHEN fc.FileNamePattern LIKE '%<MMDDYYYY>%' 
					THEN REPLACE(fc.FileNamePattern,'<MMDDYYYY>','[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
				WHEN fc.FileNamePattern LIKE '%<YYMMDD>%' 
					THEN REPLACE(fc.FileNamePattern,'<YYMMDD>','[0-9][0-9][0-9][0-9][0-9][0-9]')
				WHEN fc.FileNamePattern LIKE '%<YYYY-MM-DD>%' 
					THEN REPLACE(fc.FileNamePattern, '<YYYY-MM-DD>','[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')
				WHEN fc.FileNamePattern LIKE '%<YYYYMM>%' 
					THEN REPLACE(fc.FileNamePattern,'<YYYYMM>','[0-9][0-9][0-9][0-9][0-9][0-9]')
				WHEN fc.FileNamePattern LIKE '%<YYYY_MM>%' 
					THEN REPLACE(fc.FileNamePattern,'<YYYY_MM>','[0-9][0-9][0-9][0-9]_[0-9]')
				ELSE fc.FileNamePattern
				END

END


GO
