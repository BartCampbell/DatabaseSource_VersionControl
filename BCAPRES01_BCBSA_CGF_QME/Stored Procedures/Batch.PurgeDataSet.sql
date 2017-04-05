SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/7/2014
-- Description:	Purges all tables with data related to the specified data set.
-- =============================================
CREATE PROCEDURE [Batch].[PurgeDataSet]
(
	@ConfirmationCode smallint = NULL,
	@DataSetID int,
	@TableSchema nvarchar(128) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;			

		DECLARE @Confirmed bit;
		DECLARE @ID smallint, @MaxID smallint, @MinID smallint;

		DECLARE @CountRecords int;
		DECLARE @SqlCmd nvarchar(max);
		DECLARE @TableObject nvarchar(512);

		DECLARE @Results TABLE ( Value int NOT NULL );

		DECLARE @ConfCodeTableName nvarchar(128);
		SET @ConfCodeTableName = '##PurgeDataSetConfirmationCode_' + DB_NAME() + '_SPID' + CONVERT(nvarchar(128), @@SPID);

		IF OBJECT_ID('tempdb..' + @ConfCodeTableName) IS NOT NULL AND @ConfirmationCode IS NOT NULL
			BEGIN;
				SET @SqlCmd = 'SELECT TOP 1 RandomCode FROM ' + @ConfCodeTableName + ';'

				INSERT INTO @Results
				EXEC (@SqlCmd);

				DECLARE @Code int;
				SELECT TOP 1 @Code = Value FROM @Results;

				IF @Code = @ConfirmationCode
					BEGIN;
						PRINT 'Code Confirmed.  Purging started...';
						SET @Confirmed = 1;

						SET @SqlCmd = 'DROP TABLE ' + @ConfCodeTableName;
						EXEC (@SqlCmd);
					END
				ELSE IF @ConfirmationCode IS NOT NULL
					PRINT 'The supplied confirmation code is invalid.';
			END;

		IF OBJECT_ID('tempdb..#PurgeTableList') IS NOT NULL
			DROP TABLE #PurgeTableList;

		SELECT	CONVERT(int, 0) AS CountRecords,
				MAX(CASE WHEN C.COLUMN_NAME = 'BatchID' THEN 1 ELSE 0 END) AS HasBatchID,
				MAX(CASE WHEN C.COLUMN_NAME = 'DataRunID' THEN 1 ELSE 0 END) AS HasDataRunID,
				MAX(CASE WHEN C.COLUMN_NAME = 'DataSetID' THEN 1 ELSE 0 END) AS HasDataSetID,
				IDENTITY(smallint, 1, 1) AS ID,
				QUOTENAME(C.TABLE_SCHEMA) + '.' + QUOTENAME(C.TABLE_NAME) AS TableObject
		INTO	#PurgeTableList
		FROM	INFORMATION_SCHEMA.COLUMNS AS C
				INNER JOIN INFORMATION_SCHEMA.TABLES AS T
						ON T.TABLE_CATALOG = C.TABLE_CATALOG AND
							T.TABLE_NAME = C.TABLE_NAME AND
							T.TABLE_SCHEMA = C.TABLE_SCHEMA
		WHERE	(
					(C.TABLE_SCHEMA NOT IN ('Batch', 'Cloud', 'Internal')) OR
					(
						(C.TABLE_SCHEMA = 'Cloud') AND
						(C.TABLE_NAME = 'BatchFileObjects')
					)
				) AND
				((@TableSchema IS NULL) OR (C.TABLE_SCHEMA = @TableSchema)) AND
				(C.TABLE_NAME NOT IN ('Attributes', 'Codes', 'EnrollmentGroups', 'EnrollmentPopulations', 'ProcessEntries', 'ProcessErrors')) AND
				(C.TABLE_CATALOG = DB_NAME()) AND
				(C.COLUMN_NAME IN ('BatchID', 'DataRunID', 'DataSetID')) AND
				(T.TABLE_TYPE = 'BASE TABLE')
		GROUP BY C.TABLE_SCHEMA,
				C.TABLE_NAME
		HAVING	(MAX(CASE WHEN C.COLUMN_NAME = 'DataSetID' THEN 1 ELSE 0 END) = 1)
		ORDER BY TableObject;

		SELECT @ID = MIN(ID), @MaxID = MAX(ID), @MinID = MIN(ID) FROM #PurgeTableList;

		WHILE (@ID BETWEEN @MinID AND @MaxID)
			BEGIN;
				SELECT @CountRecords = NULL, @TableObject = TableObject FROM #PurgeTableList WHERE ID = @ID;
				DELETE FROM @Results;

				IF @Confirmed = 1
					BEGIN;
						SET @SqlCmd = 'DELETE FROM ' + @TableObject + ' WHERE (DataSetID = ' + CONVERT(nvarchar(max), @DataSetID) + ')';
						EXEC (@SqlCmd);

						SET @CountRecords = @@ROWCOUNT;
					END;
				ELSE
					BEGIN;
						SET @SqlCmd = 'SELECT COUNT(*) AS CountRecords FROM ' + @TableObject + ' WHERE (DataSetID = ' + CONVERT(nvarchar(max), @DataSetID) + ')';
				
						INSERT INTO @Results
						EXEC (@SqlCmd);

						SELECT @CountRecords = MAX(Value) FROM @Results;
					END;

					UPDATE #PurgeTableList SET CountRecords = @CountRecords WHERE ID = @ID;

					SET @ID = @ID + 1;
			END;

		IF (ISNULL(@Confirmed, 0) = 0)
			BEGIN;
				IF OBJECT_ID('tempdb..' + @ConfCodeTableName) IS NOT NULL
					BEGIN;
						SET @SqlCmd = 'DROP TABLE ' + @ConfCodeTableName;
						EXEC (@SqlCmd);
					END;
		
				DECLARE @RandomCode nvarchar(3);
				SET @RandomCode = CONVERT(nvarchar(3), Random.GetNumber(100, 999, RAND(CHECKSUM(NEWID()))));

				SET @SqlCmd = 'SELECT ' + @RandomCode + ' AS RandomCode INTO ' + @ConfCodeTableName;
				EXEC (@SqlCmd);
			END
		ELSE
			BEGIN;
				PRINT 'Purge completed.';

				UPDATE Batch.DataSets SET IsPurged = 1, PurgedDate = GETDATE() WHERE DataSetID = @DataSetID;
				UPDATE Batch.DataRuns SET IsPurged = 1, PurgedDate = GETDATE() WHERE DataSetID = @DataSetID;
			END;

		IF (@RandomCode IS NOT NULL)
			BEGIN;
				DECLARE @Msg nvarchar(max);
				SET @Msg = 'To confirm the purge, please pass in the @ConfirmationCode parameter with a value of: ' + @RandomCode;

				SELECT @Msg AS [Confirmation Instructions];
				PRINT @Msg;
			END;
		ELSE
			SELECT 'Purge completed.' AS [Status];

		SELECT TableObject AS [Table Name], CountRecords AS [Records] FROM #PurgeTableList ORDER BY TableObject;
		
		RETURN 0;
	END TRY
	BEGIN CATCH;
		DECLARE @ErrApp nvarchar(128);
		DECLARE @ErrLine int;
		DECLARE @ErrLogID int;
		DECLARE @ErrMessage nvarchar(MAX);
		DECLARE @ErrNumber int;
		DECLARE @ErrSeverity int;
		DECLARE @ErrSource nvarchar(512);
		DECLARE @ErrState int;
		
		DECLARE @ErrResult int;
		
		SELECT	@ErrApp = DB_NAME(),
				@ErrLine = ERROR_LINE(),
				@ErrMessage = ERROR_MESSAGE(),
				@ErrNumber = ERROR_NUMBER(),
				@ErrSeverity = ERROR_SEVERITY(),
				@ErrSource = ERROR_PROCEDURE(),
				@ErrState = ERROR_STATE();
				
		EXEC @ErrResult = [Log].RecordError	@Application = @ErrApp,
											@LineNumber = @ErrLine,
											@Message = @ErrMessage,
											@ErrorNumber = @ErrNumber,
											@ErrorType = 'Q',
											@ErrLogID = @ErrLogID OUTPUT,
											@PerformRollback = 0,
											@Severity = @ErrSeverity,
											@Source = @ErrSource,
											@State = @ErrState;
		
		IF @ErrResult <> 0
			BEGIN
				PRINT '*** Error Log Failure:  Unable to record the specified entry. ***'
				SET @ErrNumber = @ErrLine * -1;
			END
			
		RETURN @ErrNumber;
	END CATCH;
END









GO
GRANT EXECUTE ON  [Batch].[PurgeDataSet] TO [Processor]
GO
