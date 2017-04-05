SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****************************************************************************************************************************************************
Description:	Given a Path and Name, Return the matching FileConfigID
Use:

DECLARE @FileConfigID INT, @FileActionCd INT
EXEC CHSStaging.etl.spFileConfigGet 
	'\\CHS-FS01\DataIntake\112556\Aetna\MA','AETNA_CODES_201604.txt',@FileConfigID OUTPUT, @FileActionCd OUTPUT
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
	WHERE 1=1
		AND fc.IsActive = 1
		AND fc.FilePathIntakeVolume + fc.FilePathIntakePath = LEFT(@FilePath,(LEN(fc.FilePathIntakeVolume + fc.FilePathIntakePath)))
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
				ELSE fc.FileNamePattern
				END

END


GO
