SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****************************************************************************************************************************************************
Description:	Helper proc to call spBcpFileImport. Gets params for call given the FileLogID 
Depenedents:	etl.spBcpFileImport

Usage

EXEC CHSStaging.etl.spBcpFileImportDynamicMaster
	@FileLogID = 1000864 -- INT
	,@FileProcessID = 3001 -- INT
	,@Debug = 1 -- INT = 1

SELECT TOP 1000 * FROM CHSStaging.etl.BCPFileStage_1001

Change Log:
----------------------------------------------------------------------------------------------------------------------------------------------------- 
2016-11-23	Michael Vlk			- Create
2016-12-24	Michael Vlk			- Add pre-validation of first row
2017-01-16	Michael Vlk			- Log pre-validation of first row
2017-01-27	Michael Vlk			- re-apply + 1 logic to SET @BcpParmColCountFile
								- Add RAISEERROR on validation error
2017-02-02	Michael Vlk			- Allow stage table to be dynamic based on ProcessID
2017-03-24	Michael Vlk			- Change Fixed width validation to use DATALENGTH instead of LEN to account for trailing spaces properly
2017-03-29	Michael Vlk			- Update File Validation to handle when is BcpParmIsTabDelimited
****************************************************************************************************************************************************/
CREATE PROC [etl].[spBcpFileImportDynamicMaster]
	@FileLogID INT
	,@FileProcessID INT
	,@Debug INT = 0
AS
	
	DECLARE
		@vcCmd NVARCHAR(MAX)
		,@FileConfigID INT
		,@FilePathIntake VARCHAR(1000)
		,@FileNameIntake VARCHAR(1000)
		,@BcpParmColCount INT
		,@BcpParmFieldTerminator VARCHAR(10)
		,@BcpParmRowTerminator VARCHAR(10)
		,@BcpParmIsTabDelimited INT
		,@BcpParmIsFixedWidth INT
		,@BcpParmRemoveTextQuotes INT
		,@HasHeader INT
		,@FileFmtValRowSample VARCHAR(MAX)
		,@FileFmtValRowFile VARCHAR(MAX)
		,@FileFmtValRowPass INT = NULL
		,@BcpParmColCountFile INT
		,@RowWidthSample INT
		,@RowWidthFile INT
		,@RowCount INT
		,@FileLogDetailTxt VARCHAR(MAX)

	--

	SELECT
		@FileConfigID = fc.FileConfigID
		,@FilePathIntake = fl.FilePathIntake + CASE WHEN RIGHT(fc.FilePathIntakePath,1) <> '\' THEN '\' ELSE '' END
		,@FileNameIntake = fl.FileNameIntake
		,@BcpParmColCount = fc.BcpParmColCount
		,@BcpParmFieldTerminator = CASE
									WHEN fc.BcpParmFieldTerminator IS NOT NULL THEN fc.BcpParmFieldTerminator
									WHEN fc.BcpParmIsTabDelimited = 1 THEN CHAR(9)
									ELSE '!!!ERROR!!!'
									END
		,@BcpParmRowTerminator = fc.BcpParmRowTerminator
		,@BcpParmIsFixedWidth = fc.BcpParmIsFixedWidth
		,@BcpParmIsTabDelimited = fc.BcpParmIsTabDelimited
		,@BcpParmRemoveTextQuotes = fc.BcpParmRemoveTextQuotes
		,@HasHeader = fc.HasHeader
		,@FileFmtValRowSample = fcv.FileFmtValRowSample
	FROM
		CHSStaging.etl.FileLog fl
	INNER JOIN 
		CHSStaging.etl.FileConfig fc
		ON fl.FileConfigID = fc.FileConfigID
	LEFT OUTER JOIN 
		CHSStaging.etl.FileConfigFileFmtValRowSample fcv
		ON fl.FileConfigID = fcv.FileConfigID
	WHERE 1=1
		AND fl.FileLogID = @FileLogID

	--

	IF @Debug >= 1 
		BEGIN
			PRINT CHAR(13) + 'spBcpFileImportDynamicMaster:'
			SELECT @FileLogID,@FileProcessID,@FileConfigID,@FilePathIntake,@FileNameIntake,@BcpParmColCount,@BcpParmFieldTerminator,@BcpParmRowTerminator,@BcpParmIsTabDelimited,@BcpParmRemoveTextQuotes,@HasHeader,@Debug
			SELECT @FileFmtValRowSample
		END


	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImportDynamicMaster: Validation of File Format'

	IF @Debug <= 1 
	BEGIN
		EXEC CHSStaging.etl.spBcpFileImportDynamic
			@FileLogID = @FileLogID
			,@FileProcessID = @FileProcessID
			,@vcPath = @FilePathIntake
			,@vcTxtFile = @FileNameIntake
			,@iColCnt = 1
			,@vcFieldTerminator = NULL
			,@vcRowTerminator = '\n'
			,@bTabDelimited = 0
			,@bBcpParmIsFixedWidth = 1
			,@bRemoveTextQuotes = 0
			,@iMinRow = NULL
			,@iMaxRow = 1			
			,@Debug = @Debug
			;

		SELECT @vcCmd = 'SELECT @FileFmtValRowFile = Col1 FROM CHSStaging.etl.BCPFileStage_' + CAST(@FileProcessID AS VARCHAR) + ' WHERE RowFileID = 1'

		IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImportDynamicMaster: SELECT @FileFmtValRowFile: ' + CHAR(13) + @vcCmd
		IF @Debug <= 1 EXEC sp_executesql @vcCmd, N'@FileFmtValRowFile VARCHAR(MAX) OUT', @FileFmtValRowFile OUT
		
		

		IF @FileFmtValRowSample IS NULL AND @FileFmtValRowFile IS NOT NULL
			BEGIN
				PRINT CHAR(13) + 'spBcpFileImportDynamicMaster: @FileFmtValRowSample IS NULL, UPDATE FROM @FileFmtValRowFile'
				SET @FileFmtValRowSample = @FileFmtValRowFile
				INSERT INTO CHSStaging.etl.FileConfigFileFmtValRowSample VALUES (@FileConfigID, @FileFmtValRowSample,GETDATE(), GETDATE() )
			END

		IF @FileFmtValRowPass IS NULL AND @HasHeader = 1
			BEGIN
				IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImportDynamicMaster: Validation of File Format: @HasHeader'

				SET @FileFmtValRowPass = CASE WHEN @FileFmtValRowSample = @FileFmtValRowFile 
												THEN 1 
											ELSE 0 
											END

				IF @Debug >= 1 
					BEGIN
						PRINT CHAR(13) + 'spBcpFileImportDynamicMaster:'
						PRINT 'FileFmtValRowSample: ' + @FileFmtValRowSample
						PRINT 'FileFmtVal:          ' + @FileFmtValRowFile
						PRINT 'FileFmtValRowPass:   ' + CAST(@FileFmtValRowPass AS VARCHAR)
					END
			END -- @HasHeader

		IF @FileFmtValRowPass IS NULL AND @BcpParmIsFixedWidth = 1
			BEGIN
				IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImportDynamicMaster: Validation of File Format: @BcpParmIsFixedWidth'

				SET @RowWidthSample = DATALENGTH(@FileFmtValRowSample)
				SET @RowWidthFile = DATALENGTH(@FileFmtValRowFile)

				SET @FileFmtValRowPass = CASE WHEN @RowWidthSample = @RowWidthFile
												THEN 1 
											ELSE 0 
											END
				IF @Debug >= 1 
					BEGIN
						PRINT CHAR(13) + 'spBcpFileImportDynamicMaster:'
						PRINT 'RowWidthSample:     ' + CAST(@RowWidthSample AS VARCHAR)
						PRINT 'RowWidthFile:       ' + CAST(@RowWidthFile AS VARCHAR)
						PRINT 'FileFmtValRowPass:  ' + CAST(@FileFmtValRowPass AS VARCHAR)
					END

			END -- @BcpParmIsFixedWidth
			
		IF @FileFmtValRowPass IS NULL AND @BcpParmFieldTerminator IS NOT NULL
			BEGIN
				IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImportDynamicMaster: Validation of File Format: @BcpParmFieldTerminator'

				SET @BcpParmColCountFile = (DATALENGTH(@FileFmtValRowFile) - DATALENGTH(REPLACE(@FileFmtValRowFile, @BcpParmFieldTerminator, ''))) + 1
				SET @FileFmtValRowPass = CASE WHEN @BcpParmColCountFile = @BcpParmColCount
												THEN 1 
											ELSE 0 
											END

				IF @Debug >= 1 
					BEGIN
						PRINT CHAR(13) + 'spBcpFileImportDynamicMaster:'
						PRINT 'BcpParmColCount:     ' + CAST(@BcpParmColCount AS VARCHAR)
						PRINT 'BcpParmColCountFile: ' + CAST(@BcpParmColCountFile AS VARCHAR)
						PRINT 'FileFmtValRowPass:   ' + CAST(@FileFmtValRowPass AS VARCHAR)
					END
			END -- @BcpParmFieldTerminator

		IF ISNULL(@FileFmtValRowPass,0) = 0
			BEGIN
				SET @FileLogDetailTxt = 
					'ERROR: spBcpFileImportDynamicMaster: Validation of File Format: FAILURE'
					+ CHAR(13) + CHAR(9) + '@FileFmtValRowSample:	' + ISNULL(@FileFmtValRowSample,'Error')
					+ CHAR(13) + CHAR(9) + '@FileFmtValRowFile:		' + ISNULL(@FileFmtValRowFile,'Error')
					+ CHAR(13) + CHAR(9) + '@RowWidthSample:		' + CAST(ISNULL(@RowWidthSample,-1) AS VARCHAR)
					+ CHAR(13) + CHAR(9) + '@RowWidthFile:			' + CAST(ISNULL(@RowWidthFile,-1) AS VARCHAR)
					+ CHAR(13) + CHAR(9) + '@BcpParmColCount:		' + CAST(ISNULL(@BcpParmColCount,-1) AS VARCHAR)
					+ CHAR(13) + CHAR(9) + '@BcpParmColCountFile:	' + CAST(ISNULL(@BcpParmColCountFile,-1) AS VARCHAR)

				PRINT CHAR(13) + @FileLogDetailTxt

				INSERT INTO CHSStaging.etl.FileLogDetail
						( FileLogID,
						  FileLogDetailDate,
						  FileLogDetailTxt
						)
				VALUES
						( @FileLogID, -- FileLogID - int
						  GETDATE(), -- FileLogDetailDate - datetime
						  @FileLogDetailTxt  -- FileLogDetailTxt - varchar(max)
						)

				RAISERROR(@FileLogDetailTxt,11,1)
				RETURN

			END -- ISNULL(@FileFmtValRowPass,0) = 0

	END

	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	IF @FileFmtValRowPass = 1
	BEGIN
		IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImportDynamicMaster: Load file: EXEC CHSStaging.etl.spBcpFileImport'
	
		IF @Debug <= 1 
		BEGIN
			EXEC CHSStaging.etl.spBcpFileImportDynamic
				@FileLogID = @FileLogID
				,@FileProcessID = @FileProcessID
				,@vcPath = @FilePathIntake
				,@vcTxtFile = @FileNameIntake
				,@iColCnt = @BcpParmColCount
				,@vcFieldTerminator = @BcpParmFieldTerminator
				,@vcRowTerminator = @BcpParmRowTerminator
				,@bTabDelimited = @BcpParmIsTabDelimited
				,@bBcpParmIsFixedWidth = @BcpParmIsFixedWidth
				,@bRemoveTextQuotes = @BcpParmRemoveTextQuotes
				,@iMinRow = NULL			
				,@iMaxRow = NULL			
				,@Debug = @Debug
				;
			
			SELECT @vcCmd = 'SELECT @RowCount = COUNT(*) FROM CHSStaging.etl.BCPFileStage_' + CAST(@FileProcessID AS VARCHAR)

			IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFileImportDynamicMaster: SELECT @RowCount: ' + CHAR(13) + @vcCmd
			IF @Debug <= 1 EXEC sp_executesql @vcCmd, N'@RowCount INT OUT', @RowCount OUT

			UPDATE CHSStaging.etl.FileLog SET RowCntImport = @RowCount WHERE FileLogID = @FileLogID
		END
	END




GO
