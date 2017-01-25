SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/3/2013
-- Description:	Refreshes the database object list for the current configuration.
-- =============================================
CREATE PROCEDURE [DbUtility].[RefreshSplitDbObjects]
(
	@DmSplitConfigID smallint,
	@ResortAll bit = 1
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @HasChanges bit;
	SET @HasChanges = 0;

	BEGIN TRY;
	
		BEGIN TRANSACTION TRefreshDbObjects;

		IF OBJECT_ID('tempdb..#DbUtility_SplitDbObjects') IS NOT NULL
			DROP TABLE #DbUtility_SplitDbObjects;
			
		SELECT * INTO #DbUtility_SplitDbObjects FROM DbUtility.SplitDbObjects;
		CREATE UNIQUE CLUSTERED INDEX IX_#DbUtility_SplitDbObjects ON #DbUtility_SplitDbObjects (ObjectName, ObjectSchema, DmSplitConfigID);
			
		IF OBJECT_ID('tempdb..#DbObjects') IS NOT NULL
			DROP TABLE #DbObjects;

		SELECT * INTO #DbObjects FROM DbUtility.GetDbObjectTypes(DEFAULT, DEFAULT) WHERE ObjectTypeID IS NOT NULL;

		CREATE UNIQUE CLUSTERED INDEX IX_#DbObjects ON #DbObjects (ObjectName, ObjectSchema);

		INSERT INTO #DbUtility_SplitDbObjects 
				(AllowDestination,
				AllowSource,
				AllowSynonym,
				DmSplitConfigID,
				IsActive,
				ObjectName,
				ObjectSchema,
				ObjectTypeID)
		SELECT	0 AS AllowDestination,
				1 AS AllowSource,
				0 AS AllowSynonym,
				@DmSplitConfigID AS DmSplitConfigID,
				1 AS IsActive,
				t.ObjectName,
				t.ObjectSchema,
				t.ObjectTypeID
		FROM	#DbObjects AS t
				LEFT OUTER JOIN #DbUtility_SplitDbObjects AS SDO
						ON t.ObjectName = SDO.ObjectName AND
							t.ObjectSchema = SDO.ObjectSchema AND
							SDO.DmSplitConfigID = @DmSplitConfigID
		WHERE	(SDO.ObjectName IS NULL)
		ORDER BY ObjectTypeID, ObjectSchema, ObjectName;
		
		IF @@ROWCOUNT > 0 
			SET @HasChanges = 1;

		UPDATE	SDO
		SET		IsActive = 0
		FROM	#DbUtility_SplitDbObjects AS SDO
				LEFT OUTER JOIN #DbObjects AS t
						ON SDO.ObjectName = t.ObjectName AND
							SDO.ObjectSchema = t.ObjectSchema 
		WHERE	(SDO.DmSplitConfigID = @DmSplitConfigID) AND
				(t.ObjectName IS NULL);
		
		IF @@ROWCOUNT > 0 
			SET @HasChanges = 1;
			
		UPDATE	SDO
		SET		IsActive = 1
		FROM	#DbUtility_SplitDbObjects AS SDO
				INNER JOIN #DbObjects AS t
						ON SDO.ObjectName = t.ObjectName AND
							SDO.ObjectSchema = t.ObjectSchema 
		WHERE	(SDO.DmSplitConfigID = @DmSplitConfigID) AND
				(SDO.IsActive = 0);
				
		IF @@ROWCOUNT > 0 
			SET @HasChanges = 1;
			
		IF @HasChanges = 1 
			BEGIN;
				IF @ResortAll = 1
					TRUNCATE TABLE DbUtility.SplitDbObjects;
				ELSE
					DELETE FROM DbUtility.SplitDbObjects WHERE DmSplitConfigID = @DmSplitConfigID;	
					
				--Correct any object types that are mismatched (sys.objects)
				UPDATE	SDO
				SET		ObjectTypeID = SDOT.ObjectTypeID
				FROM	#DbUtility_SplitDbObjects AS SDO
						INNER JOIN sys.objects AS o
								ON SDO.ObjectName = o.name AND
									SDO.ObjectSchema = SCHEMA_NAME(o.schema_id)
						INNER JOIN DbUtility.SplitDbObjectTypes AS SDOT
								ON SDOT.SysObjectType COLLATE DATABASE_DEFAULT = o.[type] COLLATE DATABASE_DEFAULT
				WHERE	SDO.ObjectTypeID <> SDOT.ObjectTypeID
					
				--Correct any object types that are mismatched (sys.types)
				UPDATE	SDO
				SET		ObjectTypeID = SDOT.ObjectTypeID
				FROM	#DbUtility_SplitDbObjects AS SDO
						INNER JOIN sys.types AS t
								ON SDO.ObjectName = t.name AND
									SDO.ObjectSchema = SCHEMA_NAME(t.schema_id) AND
									t.is_user_defined = 1 AND
									t.is_assembly_type = 0
						INNER JOIN DbUtility.SplitDbObjectTypes AS SDOT
								ON (SDOT.SysObjectType = '?' AND t.is_table_type = 0) OR
									(SDOT.SysObjectType = '?T' AND t.is_table_type = 1)
				WHERE	SDO.ObjectTypeID <> SDOT.ObjectTypeID
					
				INSERT INTO DbUtility.SplitDbObjects
						(AllowDestination,
						AllowSource,
						AllowSynonym,
						DmSplitConfigID,
						IsActive,
						ObjectName,
						ObjectSchema,
						ObjectTypeID)
				SELECT	AllowDestination,
						AllowSource,
						AllowSynonym,
						DmSplitConfigID,
						IsActive,
						ObjectName,
						ObjectSchema,
						ObjectTypeID
				FROM	#DbUtility_SplitDbObjects	
				WHERE	(@ResortAll = 1) OR (DmSplitConfigID = @DmSplitConfigID)
				ORDER BY DmSplitConfigID, ObjectTypeID, ObjectSchema, ObjectName;
				        		
			END;

		COMMIT TRANSACTION TRefreshDbObjects;
	END TRY
	BEGIN CATCH;
		DECLARE @ErrorLine int;
		DECLARE @ErrorMessage nvarchar(MAX);
		DECLARE @ErrorNumber int;
		DECLARE @ErrorSeverity int;
		DECLARE @ErrorState int;
		
		SET @ErrorLine = ERROR_LINE();
		SET @ErrorMessage = 'Error %d, Line %d: ' + ERROR_MESSAGE();
		SET @ErrorNumber = ERROR_NUMBER();
		SET @ErrorSeverity = ERROR_SEVERITY();
		SET @ErrorState = ERROR_STATE();

		WHILE @@TRANCOUNT > 0
			ROLLBACK;

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorNumber, @ErrorLine);
	END CATCH;
END
GO
GRANT EXECUTE ON  [DbUtility].[RefreshSplitDbObjects] TO [Processor]
GO
