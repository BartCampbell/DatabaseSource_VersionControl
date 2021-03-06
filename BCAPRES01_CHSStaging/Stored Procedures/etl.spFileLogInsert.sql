SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Create an entry into FileLog
Use:

DECLARE @FileLogID INT
EXEC CHSStaging.etl.spFileLogInsert
	--100000,'\\192.168.50.214\DataIntake\112556\Oxford\Monthly','SFHP_OHP_ccv_mask_2016.06.txt', NULL, NULL, @FileLogID OUTPUT
	100229,'\\fs01.imihealth.com\FileStore\McLaren\CGF','MCLAREN_LAB_MKTP_2017_3.txt', NULL, NULL, NULL, @FileLogID OUTPUT
SELECT @FileLogID
SELECT * FROM etl.FileLog WHERE FileLogID = @FileLogID


Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-11-23	Michael Vlk			- Create
2017-01-18	Michael Vlk			- Enable logging of files without a FileConfig entry
								- Manual exclusion file list. May be table driven or made more refined later
2017-01-20	Michael Vlk			- Add logic to parse DateFile from @FileNameIntake where defined
2017-01-26	Michael Vlk			- Add @FileLogSessionID
2017-02-02	Michael Vlk			- Allow Manual exclusion file list logic to handle dynamic file names.
2017-03-27	Michael Vlk			- Add DateFileStr pattern %<YYYY-MM-DD>%
2017-03-31	Michael Vlk			- Add DateFileStr pattern %<YYYYMM>%
2017-04-05	Michael Vlk			- Add DateFileStr pattern %<YYYY_MM>%
2017-04-13	Michael Vlk			- Add Input Parm @FileSize
2017-04-26	Michael Vlk			- Add FTPLogID capture / return
****************************************************************************************************************************************************/
CREATE PROCEDURE [etl].[spFileLogInsert] (
	@FileConfigID INT 
	,@FilePathIntake VARCHAR(100)
	,@FileNameIntake VARCHAR(100)
	,@FileSize BIGINT
	,@RowCntExp INT
	,@RowCntFile INT
	,@FileLogSessionID INT
	,@FileLogID INT OUTPUT
	,@FTPLogID INT OUTPUT
	)
AS
BEGIN

	IF
		@FileNameIntake NOT LIKE ('BCPFileFormat%')
			AND @FileNameIntake NOT LIKE ('BCPFileStage%')
	BEGIN
		DECLARE 
			@CentauriClientID INT,
			@DateFileStr VARCHAR(255),
			@DateFile DATETIME

		-- Pull FTPLogID
		IF @FileNameIntake LIKE '#CHS%#%'
			BEGIN
				SET @FTPLogID = CAST(SUBSTRING(@FileNameIntake,5,CHARINDEX('#',@FileNameIntake,5) - 5) AS INT)
				-- SET @FileNameIntake = SUBSTRING(@FileNameIntake,CHARINDEX('#',@FileNameIntake,5) + 1, 100)
			END

		-- Get @CentauriClientID

		IF @FileConfigID IS NOT NULL
			SELECT @CentauriClientID = CentauriClientID FROM etl.FileConfig FC WHERE FileConfigID = @FileConfigID

		IF @CentauriClientID IS NULL
			SELECT @CentauriClientID = MAX(CentauriClientID) FROM etl.FileConfig FC WHERE fc.FilePathIntakeVolume + fc.FilePathIntakePath = LEFT(@FilePathIntake,(LEN(fc.FilePathIntakeVolume + fc.FilePathIntakePath)))

		-- Get @DateFile

		SELECT 
			@DateFileStr = CASE 
				WHEN fc.FileNamePattern LIKE '%<YYYYMMDD>%' 
					THEN SUBSTRING(@FileNameIntake, PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', @FileNameIntake),8)		
				WHEN fc.FileNamePattern LIKE '%<MMDDYYYY>%' 
					THEN SUBSTRING(@FileNameIntake, PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', @FileNameIntake) + 4, 4)
						+ SUBSTRING(@FileNameIntake, PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', @FileNameIntake), 4)
				WHEN fc.FileNamePattern LIKE '%[_]<YYMMDD>%' 
					THEN SUBSTRING(@FileNameIntake, PATINDEX('%[_][0-9][0-9][0-9][0-9][0-9][0-9][_]%', @FileNameIntake) + 1,6)
				WHEN fc.FileNamePattern LIKE '%<YYMMDD>%' 
					THEN SUBSTRING(@FileNameIntake, PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9]%', @FileNameIntake),6)
				WHEN fc.FileNamePattern LIKE '%<YYYY-MM-DD>%' 
					THEN SUBSTRING(@FileNameIntake, PATINDEX('%[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]%', @FileNameIntake),10)
				WHEN fc.FileNamePattern LIKE '%<YYYYMM>%' 
					THEN SUBSTRING(@FileNameIntake, PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9]%', @FileNameIntake),6) + '01'
				WHEN fc.FileNamePattern LIKE '%<YYYY[_]MM>%' 
					THEN 
						CASE WHEN PATINDEX('%[0-9][0-9][0-9][0-9][_][0-9][0-9]%', @FileNameIntake) > 0 
							THEN SUBSTRING(@FileNameIntake, PATINDEX('%[0-9][0-9][0-9][0-9][_][0-9]%', @FileNameIntake),4) 
								+ SUBSTRING(@FileNameIntake, PATINDEX('%[0-9][0-9][0-9][0-9][_][0-9]%', @FileNameIntake) + 5, 2)
								+ '01'
						ELSE SUBSTRING(@FileNameIntake, PATINDEX('%[0-9][0-9][0-9][0-9][_][0-9]%', @FileNameIntake),4) 
								+ '0' + SUBSTRING(@FileNameIntake, PATINDEX('%[0-9][0-9][0-9][0-9][_][0-9]%', @FileNameIntake) + 5, 1)
								+ '01'
						END 
				ELSE fc.FileNamePattern
				END
		FROM 
			CHSStaging.etl.FileConfig fc
		WHERE
			fc.FileConfigID = @FileConfigID

		SELECT @DateFile = CASE WHEN ISDATE(@DateFileStr) = 1 THEN CAST(@DateFileStr AS DATE) ELSE NULL END

		-- Insert

		INSERT INTO etl.FileLog (
			FileLogSessionID
			,FileConfigID
			,CentauriClientID
			,FTPLogID
			,FilePathIntake
			,FileNameIntake
			,FileSize
			,RowCntExp
			,RowCntFile
			,DateFile
			)
		VALUES (
			@FileLogSessionID
			,@FileConfigID
			,@CentauriClientID
			,@FTPLogID
			,@FilePathIntake
			,@FileNameIntake
			,@FileSize
			,@RowCntExp
			,@RowCntFile
			,@DateFile
			)

		SELECT @FileLogID = MAX(FileLogID) -- SELECT *
		FROM etl.FileLog
		WHERE 1=1
			AND ISNULL(FileConfigID,-1) = ISNULL(@FileConfigID,-1)
			AND FilePathIntake = @FilePathIntake
			AND FileNameIntake = @FileNameIntake
	END

END
GO
