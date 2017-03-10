SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/10/2012
-- Description:	Imports files from the specified path, moving them to local path, and then importing them into the specified table.
-- =============================================
CREATE PROCEDURE [dbo].[ImportChartImagesFromFTPS]
AS
BEGIN
	SET NOCOUNT ON;

	--i) Declare and initialize key variables...
	DECLARE @CountSource int;
	DECLARE @CountDestination int;
	DECLARE @DestinationPath nvarchar(2048);
	DECLARE @DestinationRootPath nvarchar(2048);
	DECLARE @DestinationTable nvarchar(256);
	DECLARE @Extension nvarchar(3);
	DECLARE @Extension2 nvarchar(3);
	DECLARE @Extension3 nvarchar(3);
	DECLARE @Extension4 nvarchar(3);
	DECLARE @SourcePath nvarchar(2048);

	DECLARE @FileData varbinary(max);
	DECLARE @FileName nvarchar(2048);
	DECLARE @ID int;
	DECLARE @MaxID int;
	DECLARE @MinID int;

	DECLARE @Params nvarchar(max);
	DECLARE @Sql nvarchar(max);

	SET @DestinationRootPath = '\\CHSPRODDB05\ChartNet\McLaren\';
	SET @DestinationPath = @DestinationRootPath + '\' + 
									CONVERT(nvarchar(8), GETDATE(), 112) + '_' + 
									CASE WHEN LEN(CONVERT(nvarchar(2), DATEPART(hour, GETDATE()))) = 1 THEN '0' ELSE '' END + CONVERT(nvarchar(2), DATEPART(hour, GETDATE())) +
									CASE WHEN LEN(CONVERT(nvarchar(2), DATEPART(minute, GETDATE()))) = 1 THEN '0' ELSE '' END + CONVERT(nvarchar(2), DATEPART(minute, GETDATE())) +
									CASE WHEN LEN(CONVERT(nvarchar(2), DATEPART(second, GETDATE()))) = 1 THEN '0' ELSE '' END + CONVERT(nvarchar(2), DATEPART(second, GETDATE()));
	SET @DestinationTable = 'dbo.ChartImageFileImport';
	SET @Extension = 'pdf';
	SET @Extension2 = 'tif';
	SET @Extension3 = 'png';
	SET @Extension4 = 'jpg';
	SET @SourcePath = '\\CHSProdDB05\ChartNet\Incoming\McLaren\';
	--SET @SourcePath = '\\chs-ftp\FTP-Data\ftpMcLaren\ToCentauri\Charts\';

	IF OBJECT_ID('tempdb..#DestinationFiles') IS NOT NULL	
		DROP TABLE #DestinationFiles;

	CREATE TABLE #DestinationFiles
	(
		[FileName] nvarchar(2048) NULL,
		[ID] int IDENTITY(1, 1) NOT NULL,
		[Name] nvarchar(256) NULL,
		[Path] nvarchar(2048) NULL
	);

	IF OBJECT_ID('tempdb..#SourceFiles') IS NOT NULL	
		DROP TABLE #SourceFiles;

	CREATE TABLE #SourceFiles
	(
		[FileName] nvarchar(2048) NULL,
		[ID] int IDENTITY(1, 1) NOT NULL,
		[Name] nvarchar(256) NULL,
		[Path] nvarchar(2048) NULL
	);

	DECLARE @CmdOutput TABLE
	(
		[CmdOutput] nvarchar(max) NULL
	);

	--ii) Construct temporary tally table...
	IF OBJECT_ID('tempdb..#Tally') IS NOT NULL
		DROP TABLE #Tally;

	WITH TallyPartA AS
	(
		SELECT	1 AS N
		UNION ALL
		SELECT	1 AS N
		UNION ALL
		SELECT	1 AS N
	),
	TallyPartB AS 
	(
		
		SELECT	1 AS N 
		FROM	TallyPartA AS A1, TallyPartA AS A2, TallyPartA AS A3
	),
	TallySource AS
	(
		SELECT	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
		FROM	TallyPartB AS B1, TallyPartB AS B2, TallyPartB AS B3
	)
	SELECT	* 
	INTO	#Tally
	FROM	TallySource
	WHERE	N <= 4096;

	CREATE UNIQUE CLUSTERED INDEX IX_#Tally ON #Tally (N);

	--1) Identify and move new files on the FTP site...
	PRINT 'Source:			' + @SourcePath;
	PRINT 'Destination:	' + @DestinationPath;
	PRINT 'Extension:		' + @Extension + ', ' + @Extension2 + ', ' + @Extension3 + ', ' + @Extension4;
	PRINT REPLICATE(CHAR(13) + CHAR(10), 2);

	SET @Sql = 'master..xp_cmdshell ''dir /b /s ' + @SourcePath + '\*.' + @Extension + '''';
	PRINT @sql;
	
	INSERT INTO #SourceFiles
			([FileName])
	EXEC	(@sql);
	
	SET @Sql = 'master..xp_cmdshell ''dir /b /s ' + @SourcePath + '\*.' + @Extension2 + '''';
	PRINT @sql;

	INSERT INTO #SourceFiles
			([FileName])
	EXEC	(@sql);
	
	SET @Sql = 'master..xp_cmdshell ''dir /b /s ' + @SourcePath + '\*.' + @Extension3 + '''';
	PRINT @sql;

	INSERT INTO #SourceFiles
			([FileName])
	EXEC	(@sql);
	
	SET @Sql = 'master..xp_cmdshell ''dir /b /s ' + @SourcePath + '\*.' + @Extension4 + '''';
	PRINT @sql;

	INSERT INTO #SourceFiles
			([FileName])
	EXEC	(@sql);

	WITH SourceFilesParse AS
	(
		SELECT	ID,
				MAX(T.N) AS PathEnd
		FROM	#SourceFiles AS SF
				INNER JOIN #Tally AS T 
						ON T.N BETWEEN 1 AND LEN(SF.[FileName])
		WHERE	(SUBSTRING(SF.[FileName], T.N, 1) = '\')
		GROUP BY ID
	)
	UPDATE	SF
	SET		Name = RIGHT(SF.[FileName], LEN(SF.[FileName]) - SFP.PathEnd),
			[Path] = LEFT(SF.[FileName], SFP.PathEnd)
	FROM	SourceFilesParse AS SFP
			INNER JOIN #SourceFiles AS SF
					ON SFP.ID = SF.ID;

	IF NOT EXISTS(SELECT TOP 1 1 FROM #SourceFiles WHERE Name IS NOT NULL)
		SELECT * FROM #SourceFiles WHERE FileName IS NOT NULL;

	DELETE FROM #SourceFiles WHERE [FileName] IS NULL OR [Name] IS NULL;

	SET @CountSource = (SELECT COUNT(*) FROM #SourceFiles);

	IF @CountSource > 0
		BEGIN;
			SET @Sql = 'master..xp_cmdshell ''dir /b /ad ' + @DestinationPath + '''';

			INSERT INTO @CmdOutput
			EXEC	(@sql);
		
			IF EXISTS (SELECT TOP 1 1 FROM @CmdOutput WHERE CmdOutput IN ('File Not Found', 'The system cannot find the path specified.'))
				BEGIN;
					SET @Sql = 'master..xp_cmdshell ''mkdir ' + @DestinationPath + '''';
				
					INSERT INTO @CmdOutput
					EXEC (@sql);
					
					PRINT 'Destination path created.';
				END;
			ELSE
				PRINT 'Destination path verified.';
				
			DELETE FROM @CmdOutput;
			PRINT REPLICATE(CHAR(13) + CHAR(10), 1);

			SELECT @ID = MIN(ID), @MaxID = MAX(ID), @MinID = MIN(ID) FROM #SourceFiles;

			WHILE @ID BETWEEN @MinID AND @MaxID
				BEGIN;
					SELECT @FileName = REPLACE([FileName], '''', '''''') FROM #SourceFiles WHERE ID = @ID;
					
					IF @FileName IS NOT NULL
						BEGIN;
							SET @Sql = 'master..xp_cmdshell ''move /y "' + @FileName + '" "' + @DestinationPath + '\"''';
							PRINT @Sql;
							
							INSERT INTO @CmdOutput
							EXEC (@Sql);
							PRINT '"' + @FileName + '" moved to destination.';
							
						END;
				
					SET @ID = @ID + 1;
				END;

			DELETE FROM @CmdOutput;
		END;

		--SELECT * FROM #SourceFiles
		
	--2) Import files from destination location in local database...
		IF OBJECT_ID(@DestinationTable) IS NULL
			BEGIN;
				SET @Sql =	'CREATE TABLE ' + @DestinationTable + CHAR(13) + CHAR(10) +
							'(' + CHAR(13) + CHAR(10) +
							'	CreatedDate datetime NOT NULL DEFAULT (GETDATE()), ' + CHAR(13) + CHAR(10) +
							'	FileData varbinary(max) NULL, ' + CHAR(13) + CHAR(10) +
							'	FileID int IDENTITY(1, 1) NOT NULL, ' + CHAR(13) + CHAR(10) +
							'	FileName nvarchar(2048) NOT NULL, ' + CHAR(13) + CHAR(10) +
							'	[Name] nvarchar(256) NOT NULL, ' + CHAR(13) + CHAR(10) +
							'	[NotifyDate] datetime NULL, ' + CHAR(13) + CHAR(10) +
							'	OriginalPath nvarchar(2048) NOT NULL, ' + CHAR(13) + CHAR(10) +
							'	[Path] nvarchar(2048) NOT NULL, ' + CHAR(13) + CHAR(10) +
							'	[Size] bigint NULL, ' + CHAR(13) + CHAR(10) +
							'	[Xref] nvarchar(64) NULL, ' + CHAR(13) + CHAR(10) +
							'	CONSTRAINT [PK_' + REPLACE(@DestinationTable, '.', '_') + '] PRIMARY KEY CLUSTERED (FileID ASC)' + CHAR(13) + CHAR(10) +
							'	WITH (DATA_COMPRESSION = PAGE) ' + CHAR(13) + CHAR(10) +
							');' + CHAR(13) + CHAR(10) +
							'CREATE UNIQUE NONCLUSTERED INDEX IX_' + REPLACE(@DestinationTable, '.', '_') + ' ON ' + @DestinationTable + ' (FileName ASC);' + CHAR(13) + CHAR(10);
							
				EXEC (@Sql);
			END;
			

	SET @Sql = 'master..xp_cmdshell ''dir /b /s ' + @DestinationRootPath + '\*.' + @Extension + '''';

	INSERT INTO #DestinationFiles
			([FileName])
	EXEC	(@sql);

	SET @Sql = 'master..xp_cmdshell ''dir /b /s ' + @DestinationRootPath + '\*.' + @Extension2 + '''';

	INSERT INTO #DestinationFiles
			([FileName])
	EXEC	(@sql);

	SET @Sql = 'master..xp_cmdshell ''dir /b /s ' + @DestinationRootPath + '\*.' + @Extension3 + '''';

	INSERT INTO #DestinationFiles
			([FileName])
	EXEC	(@sql);
	
	SET @Sql = 'master..xp_cmdshell ''dir /b /s ' + @DestinationRootPath + '\*.' + @Extension4 + '''';

	INSERT INTO #DestinationFiles
			([FileName])
	EXEC	(@sql);

	WITH DestinationFilesParse AS
	(
		SELECT	ID,
				MAX(T.N) AS PathEnd
		FROM	#DestinationFiles AS DF
				INNER JOIN #Tally AS T 
						ON T.N BETWEEN 1 AND LEN(DF.[FileName])
		WHERE	(SUBSTRING(DF.[FileName], T.N, 1) = '\')
		GROUP BY ID
	)
	UPDATE	DF
	SET		Name = RIGHT(DF.[FileName], LEN(DF.[FileName]) - DFP.PathEnd),
			[Path] = LEFT(DF.[FileName], DFP.PathEnd)
	FROM	DestinationFilesParse AS DFP
			INNER JOIN #DestinationFiles AS DF
					ON DFP.ID = DF.ID;

	DELETE FROM #DestinationFiles WHERE [FileName] IS NULL OR [Name] IS NULL;

	SET @Sql =	'DELETE FROM #DestinationFiles WHERE [FileName] IN (SELECT [FileName] FROM ' + @DestinationTable + ');';				
	EXEC (@Sql);

	SET @CountDestination = (SELECT COUNT(*) FROM #DestinationFiles);

	IF @CountDestination > 0
		BEGIN;
			IF OBJECT_ID('tempdb..#DestinationFileData') IS NOT NULL
				DROP TABLE #DestinationFileData;
		
			CREATE TABLE #DestinationFileData
			(
				FileData varbinary(max) NOT NULL,
				[ID] int NOT NULL
			);
			
			SELECT @ID = MIN(ID), @MaxID = MAX(ID), @MinID = MIN(ID) FROM #DestinationFiles;
			
			WHILE @ID BETWEEN @MinID AND @MaxID
				BEGIN;
					SELECT @FileName = REPLACE([FileName], '''', '''''') FROM #DestinationFiles WHERE ID = @ID;
					
					IF @FileName IS NOT NULL
						BEGIN;
							SET @Params = '@FileData varbinary(max) OUTPUT';
							SET @Sql = 'SELECT @FileData = BulkColumn FROM OPENROWSET(BULK N''' + @FileName + ''', SINGLE_BLOB) AS FileData;'
							
							EXEC sys.sp_executesql @Sql, @Params, @FileData = @FileData OUTPUT;
											
							IF @FileData IS NOT NULL
								BEGIN;
									INSERT INTO #DestinationFileData
											(FileData, ID)
									VALUES  (@FileData, @ID);
									
									PRINT '"' + @FileName + '" imported.';
								END;
						END;
						
					SET @FileData = NULL;
					SET @ID = @ID + 1;
				END;
				
			PRINT REPLICATE(CHAR(13) + CHAR(10), 1);
				
			SET @Sql =	'INSERT INTO ' + @DestinationTable + CHAR(13) + CHAR(10) +
						'		(CreatedDate, FileData, [FileName], Name, OriginalPath, [Path], Size)' + CHAR(13) + CHAR(10) +
						'SELECT	GETDATE(), DFD.FileData, DF.[FileName], DF.[Name], ISNULL(SF.[Path], ''' + @SourcePath + '''), DF.[Path], DATALENGTH(DFD.FileData)' + CHAR(13) + CHAR(10) +
						'FROM	#DestinationFiles AS DF' + CHAR(13) + CHAR(10) +
						'		INNER JOIN #DestinationFileData AS DFD' + CHAR(13) + CHAR(10) +
						'				ON DF.ID = DFD.ID' + CHAR(13) + CHAR(10) +
						'		LEFT OUTER JOIN #SourceFiles AS SF' + CHAR(13) + CHAR(10) +
						'				ON DF.[Name] = SF.[Name]' + CHAR(13) + CHAR(10) +
						'ORDER BY DF.[FileName] ASC;';
						
			EXEC (@Sql);
			
			PRINT 'File info copied to "' + @DestinationTable + '".';
		END;

	SELECT @CountSource AS [Source File Count], @CountDestination AS [Destination File Count];
	EXEC ('SELECT CreatedDate, [FileName], Name, OriginalPath, [Path], Size FROM ' + @DestinationTable + ' WHERE (CreatedDate IN (SELECT MAX(CreatedDate) FROM ' + @DestinationTable + '));');
END



GO
