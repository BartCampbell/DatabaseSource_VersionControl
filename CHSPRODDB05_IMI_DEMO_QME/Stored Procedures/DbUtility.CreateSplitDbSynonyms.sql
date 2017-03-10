SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/22/2013
-- Description:	Creates the synonyms between to the two split databases.  Can be reused when changing database names to recreate the links.
-- =============================================
CREATE PROCEDURE [DbUtility].[CreateSplitDbSynonyms]
(
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

	DECLARE @CrLf nvarchar(2);
	DECLARE @Sql nvarchar(max);

	SET @CrLf = CHAR(13) + CHAR(10);

	IF @HasError = 0  AND NOT EXISTS (SELECT TOP 1 1 FROM DbUtility.SplitConfigs WHERE DmSplitConfigID = @DmSplitConfigID)
		BEGIN;
			SET @HasError = 1;
			SET @ErrMsg = 'The specified configuration is invalid.';
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
							(SDO.DmSplitConfigID = @DmSplitConfigID) AND
							(SDO.AllowSynonym = 1)
				)
		BEGIN;
			SET @HasError = 1;
			SET @ErrMsg = 'One or more database objects have a mismatched type.'
		END;
		
	IF @HasError = 0  AND NULLIF(@DestinationDatabaseName, '') IS NULL OR DB_ID(@DestinationDatabaseName) IS NULL
		BEGIN;
			SET @HasError = 1;
			SET @ErrMsg = 'The specified destination database name is invalid.';
		END;

	IF @HasError = 0
		BEGIN;
			DECLARE @DatabaseName nvarchar(max);
			SET @DatabaseName = DB_NAME();
			
			--1a) Prepare the database object key...
			IF OBJECT_ID('tempdb..#DbObjects') IS NOT NULL
				DROP TABLE #DbObjects;
			
			SELECT	SDO.AllowDestination,
					SDO.AllowSource,
					SDO.AllowSynonym,
					SDO.DmSplitDbObjectID,
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
					(SDO.AllowSynonym = 1) AND
					((SDO.AllowDestination = 0) OR (SDO.AllowSource = 0)) AND
					(SDO.IsActive = 1)
			ORDER BY DmSplitDbObjectID;
					
			CREATE UNIQUE CLUSTERED INDEX IX_#DbObjects ON #DbObjects (DmSplitDbObjectID);
			CREATE UNIQUE NONCLUSTERED INDEX IX_#DBObjects2 ON #DbObjects (ObjectSchema, ObjectName);
			
			DECLARE @ID int;
			
			--1b) Loop through the database object key to create synonyms for the appropriate database...
			WHILE (1 = 1)
				BEGIN;
					SELECT @ID = MIN(DmSplitDbObjectID), @Sql = NULL FROM #DbObjects WHERE ((@ID IS NULL) OR (DmSplitDbObjectID > @ID));
					
					IF @ID IS NULL
						BREAK;
					ELSE
						BEGIN;
							SELECT	@Sql = 
											CASE AllowDestination
												WHEN 0
												THEN 'USE ' + QUOTENAME(@DestinationDatabaseName) + ';' + @CrLf +
													 'CREATE SYNONYM ' + QUOTENAME(ObjectSchema) + '.' + QUOTENAME(ObjectName) + ' FOR ' + QUOTENAME(@DatabaseName) + '.' + QUOTENAME(ObjectSchema) + '.' + QUOTENAME(ObjectName) + ';' + @CrLf
												ELSE ''
												END +
											CASE AllowSource
												WHEN 0
												THEN 'USE ' + QUOTENAME(@DatabaseName) + ';' + @CrLf +
													 'CREATE SYNONYM ' +  QUOTENAME(ObjectSchema) + '.' + QUOTENAME(ObjectName) + ' FOR ' + QUOTENAME(@DestinationDatabaseName) + '.' + QUOTENAME(ObjectSchema) + '.' + QUOTENAME(ObjectName) + ';' + @CrLf
												ELSE ''
												END 
							FROM	#DbObjects
							WHERE	(DmSplitDbObjectID = @ID);
							
							IF @PrintSql = 1
								PRINT @Sql;
								
							IF @ExecuteSql = 1
								EXEC (@Sql)
							
						END;
				END;
		END;

	IF @HasError = 1
		BEGIN;
			SET @ErrMsg = 'Unable to create synonyms for the database.' + ISNULL('  ' + @ErrMsg, '');
		
			RAISERROR(@ErrMsg, 16, 1);
		END;
END

GO
GRANT VIEW DEFINITION ON  [DbUtility].[CreateSplitDbSynonyms] TO [db_executer]
GO
GRANT EXECUTE ON  [DbUtility].[CreateSplitDbSynonyms] TO [db_executer]
GO
GRANT EXECUTE ON  [DbUtility].[CreateSplitDbSynonyms] TO [Processor]
GO
