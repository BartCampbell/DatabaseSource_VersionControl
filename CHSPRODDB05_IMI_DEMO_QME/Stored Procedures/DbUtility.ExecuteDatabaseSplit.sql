SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/22/2013
-- Description:	Performs the specified database split.
-- =============================================
CREATE PROCEDURE [DbUtility].[ExecuteDatabaseSplit]
(
	@Authorization varchar(36) = '',
	@BackupPath nvarchar(max),
	@DestinationDatabaseName nvarchar(128),
	@DmSplitConfigID smallint,
	@PrintSql bit = 0,
	@ExecuteSql bit = 1
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @ErrMsg varchar(max);
	DECLARE @HasError bit;
	SET @HasError = 0;

	DECLARE @DirectoryExists bit;

	DECLARE @CrLf nvarchar(2);
	DECLARE @Sql nvarchar(max);

	SET @CrLf = CHAR(13) + CHAR(10);

	DECLARE @CmdOutput TABLE
	(
		CmdOutput varchar(256) NULL,
		ID smallint IDENTITY(1, 1) NOT NULL
	);

	SET @Sql = 'master..xp_cmdshell ''dir "' + @BackupPath + '"''';

	INSERT INTO @CmdOutput
			(CmdOutput)
	EXEC (@Sql);

	DELETE FROM @CmdOutput WHERE CmdOutput IS NULL

	IF EXISTS (SELECT TOP 1 1 FROM (SELECT TOP 1 * FROM @CmdOutput ORDER BY ID DESC) AS t WHERE t.CmdOutput LIKE '%The system cannot find the file specified.%') OR
		EXISTS (SELECT TOP 1 1 FROM (SELECT TOP 1 * FROM @CmdOutput ORDER BY ID DESC) AS t WHERE t.CmdOutput LIKE '%FILE NOT FOUND%')
		SET @DirectoryExists = 0;
	ELSE
		SET @DirectoryExists = 1;

	DELETE FROM @CmdOutput;

	DECLARE @AuthCode uniqueidentifier;

	IF OBJECT_ID('tempdb..##AuthorizationCode') IS NULL
		BEGIN;
			SET @AuthCode = NEWID();
			
			SELECT @AuthCode AS AuthCode INTO ##AuthorizationCode;
			
			SET @HasError = 1;
			SET @ErrMsg = 'To confirm database split, please use the authorization code: ' + LEFT(CONVERT(varchar(36), @AuthCode), 8) + ' (Set the @Authorization parameter.)';
		END;
	ELSE
		SELECT TOP 1 @AuthCode = AuthCode FROM ##AuthorizationCode;

	IF @HasError = 0  AND NULLIF(@Authorization, '') IS NULL OR @AuthCode IS NULL OR CONVERT(varbinary(max), LEFT(CONVERT(varchar(36), @AuthCode), 8)) <> CONVERT(varbinary(max), @Authorization)
		BEGIN 
			SET @HasError = 1;
			SET @ErrMsg = 'The specified authorization code is invalid.  Please use the authorization code: ' + LEFT(CONVERT(varchar(36), @AuthCode), 8) + ' (Set the @Authorization parameter.)';
		END;
	ELSE IF @HasError = 0
		BEGIN;
			PRINT 'Authorization accepted.';
			PRINT '--------------------------------------------------------------------------------------------';
			PRINT ''
		END;


	IF @HasError = 0  AND NOT EXISTS (SELECT TOP 1 1 FROM DbUtility.SplitConfigs WHERE DmSplitConfigID = @DmSplitConfigID)
		BEGIN;
			SET @HasError = 1;
			SET @ErrMsg = 'The specified configuration is invalid.';
		END;

	IF @HasError = 0  AND @DirectoryExists = 0
		BEGIN;
			SET @HasError = 1;
			SET @ErrMsg = 'The specified backup path is invalid.';
		END;

	IF @HasError = 0  AND 
		EXISTS	(
					SELECT TOP 1 
							1
					FROM	DbUtility.SplitDbObjects AS SDO
							INNER JOIN DbUtility.GetDbObjectTypes(DEFAULT, DEFAULT) GDOT
									ON SDO.ObjectName = GDOT.ObjectName AND
										SDO.ObjectSchema = GDOT.ObjectSchema AND
										GDOT.ObjectTypeID IS NOT NULL
					WHERE	(SDO.ObjectTypeID <> GDOT.ObjectTypeID) AND
							(SDO.DmSplitConfigID = @DmSplitConfigID)
				)
		BEGIN;
			SET @HasError = 1;
			SET @ErrMsg = 'One or more database objects have a mismatched type.'
		END;
		
	IF @HasError = 0  AND NULLIF(RTRIM(@DestinationDatabaseName), '') IS  NULL
		BEGIN;
			SET @HasError = 1;
			SET @ErrMsg = 'The specified destination database name is invalid.';
		END;
		
	IF @HasError = 0  AND DB_ID(@DestinationDatabaseName) IS NOT NULL
		BEGIN;
			SET @HasError = 1;
			SET @ErrMsg = 'The specified destination database name is already in use.';
		END;

	IF @HasError = 0
		BEGIN;
			DECLARE @DatabaseName nvarchar(max);
			DECLARE @FileIdentifier nvarchar(max);

			SET @DatabaseName = DB_NAME();
			SET @FileIdentifier = CONVERT(nvarchar(max), GETDATE(), 112) + '_' + REPLACE(CONVERT(nvarchar(max), GETDATE(), 108), ':', '');
			
			--1a) Backup current database...
			SET @Sql = 'BACKUP DATABASE ' + @DatabaseName + ' TO DISK = N''' + @BackupPath + @DatabaseName + '_' + @FileIdentifier + '.bak'' WITH NOFORMAT, INIT,  NAME = N''' + @DatabaseName + '-Full Database Backup'', SKIP, COPY_ONLY, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 5;'

			IF @PrintSql = 1
				PRINT @Sql;
				
			IF @ExecuteSql = 1
				EXEC (@Sql)
			
			--1b) Identify the new names for the files in the destination database...
			DECLARE @SqlRestoreMove nvarchar(max);
			
			IF OBJECT_ID('tempdb..#DbFiles') IS NOT NULL
				DROP TABLE #DbFiles;
			
			WITH T1 AS
			(
				SELECT	1 AS N 
				UNION ALL 
				SELECT	1 AS N
			),
			T2 AS
			(
				SELECT	1 AS N 
				FROM	T1 AS n1, T1 AS n2, T1 AS n3, T1 AS n4
			),
			Tally AS --Artifically Tally Table
			(
				SELECT	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N 
				FROM	T2 AS n1, T2 AS n2, T2 AS n3, T2 AS n4
			)
			SELECT	mf.file_guid AS FileGuid, 
					mf.file_id AS FileID,
					mf.name AS [FileLogicalName], 
					mf.physical_name AS FileFullPath, 
					UPPER(LEFT(mf.physical_name, MAX(CASE WHEN SUBSTRING(mf.physical_name, t.N, 1) = '\' THEN t.N ELSE 0 END))) AS [FilePath],
					LOWER(RIGHT(mf.physical_name, LEN(physical_name) - MAX(CASE WHEN SUBSTRING(mf.physical_name, t.N, 1) = '.' THEN t.N ELSE 0 END - 1))) AS [FileExtension],
					CONVERT(nvarchar(260), NULL) AS NewFileName
			INTO	#DbFiles
			FROM	sys.master_files AS mf
					INNER JOIN Tally AS t
							ON t.N BETWEEN 1 AND LEN(mf.physical_name)
			WHERE	database_id = DB_ID()
			GROUP BY mf.file_guid, 
					mf.file_id,
					mf.name, 
					mf.physical_name
			ORDER BY FileID;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#DbFiles ON #DbFiles (FileID);
			
			UPDATE #DbFiles SET NewFileName = [FilePath]  + @DestinationDatabaseName + CONVERT(nvarchar(260), FileID) + FileExtension;
			
			CREATE UNIQUE NONCLUSTERED INDEX IX_#DbFiles_NewFileName ON #DbFiles (NewFileName);
			
			SELECT @SqlRestoreMove = ISNULL(@SqlRestoreMove + ', ', '') +
					'MOVE ''' + FileLogicalName + ''' TO ''' + NewFileName + ''''
			FROM	#DbFiles
			ORDER BY FileID;
					
			--1c) Restore the backup with a new of the destination database...		
			SET @Sql = 'RESTORE DATABASE ' + @DestinationDatabaseName + ' FROM DISK = ''' + @BackupPath + @DatabaseName + '_' + @FileIdentifier + '.bak'' WITH ' + @SqlRestoreMove + ';'
			
			IF @PrintSql = 1
				PRINT @Sql;
				
			IF @ExecuteSql = 1
				EXEC (@Sql)
			
			--2a) Prepare the database object key...
			IF OBJECT_ID('tempdb..#DbObjects') IS NOT NULL
				DROP TABLE #DbObjects;
			
			SELECT	SDO.AllowDestination,
					SDO.AllowSource,
					SDO.AllowSynonym,
					SDO.DmSplitDbObjectID,
					IDENTITY(int, 1, 1) AS ID,
					SDO.ObjectName,
					SDO.ObjectSchema,
					SDO.ObjectTypeID,
					SDOT.SysObjectType,
					SDOT.TSqlName
			INTO	#DbObjects
			FROM	DbUtility.SplitDbObjects AS SDO
					INNER JOIN DbUtility.GetDbObjectTypes(DEFAULT, DEFAULT) GDOT
							ON SDO.ObjectName = GDOT.ObjectName AND
								SDO.ObjectSchema = GDOT.ObjectSchema AND
								SDO.ObjectTypeID = GDOT.ObjectTypeID
					INNER JOIN DbUtility.SplitDbObjectTypes AS SDOT
							ON SDO.ObjectTypeID = SDOT.ObjectTypeID
			WHERE	(SDO.DmSplitConfigID = @DmSplitConfigID) AND
					(SDO.IsActive = 1)
			ORDER BY SDOT.SortOrder, SDO.ObjectSchema, SDO.ObjectName;
					
			CREATE UNIQUE CLUSTERED INDEX IX_#DbObjects ON #DbObjects (ID);
			CREATE UNIQUE NONCLUSTERED INDEX IX_#DBObjects2 ON #DbObjects (ObjectSchema, ObjectName);
			
			DECLARE @ID int;
			
			--2b) Loop through the database object key to remove objects from the appropriate database...
			WHILE (1 = 1)
				BEGIN;
					SELECT @ID = MIN(ID), @Sql = NULL FROM #DbObjects WHERE ((@ID IS NULL) OR (ID > @ID));
					
					IF @ID IS NULL
						BREAK;
					ELSE
						BEGIN;
							SELECT	@Sql = 
											CASE AllowDestination
												WHEN 0
												THEN 'USE ' + QUOTENAME(@DestinationDatabaseName) + ';' + @CrLf + 
													 'DROP ' + TSqlName + ' ' + QUOTENAME(ObjectSchema) + '.' + QUOTENAME(ObjectName) + ';' + @CrLf
												ELSE ''
												END +
											CASE AllowSource
												WHEN 0
												THEN 'USE ' + QUOTENAME(@DatabaseName) + ';' + @CrLf + 
													 'DROP ' + TSqlName + ' ' + QUOTENAME(ObjectSchema) + '.' + QUOTENAME(ObjectName) + ';' + @CrLf
												ELSE ''
												END 
							FROM	#DbObjects
							WHERE	(ID = @ID);
							
							IF @PrintSql = 1
								PRINT @Sql;
								
							IF @ExecuteSql = 1
								EXEC (@Sql)
							
						END;
				END;
				
			EXEC DbUtility.CreateSplitDbSynonyms @DestinationDatabaseName = @DestinationDatabaseName, @DmSplitConfigID = @DmSplitConfigID,
												 @PrintSql = @PrintSql, @ExecuteSql = @ExecuteSql;
			
		END;

	IF @HasError = 1
		BEGIN;
			SET @ErrMsg = 'Unable to split the database.' + ISNULL('  ' + @ErrMsg, '');
		
			RAISERROR(@ErrMsg, 16, 1);
		END;
END
GO
GRANT EXECUTE ON  [DbUtility].[ExecuteDatabaseSplit] TO [Processor]
GO
