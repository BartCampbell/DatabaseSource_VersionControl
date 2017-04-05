SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/13/2011
-- Description:	Purges all "Internal" schema tables for the specified batch.
-- =============================================
CREATE PROCEDURE [Batch].[PurgeInternalTables]
(
	@BatchID int,
	@ForcePurge bit = 0,
	@IgnoreMembers bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;			
	
		--Determine Engine Type and Settings...
		DECLARE @AllowClaimUpdates bit;
		DECLARE @AllowFinalizePurgeInternal bit;
		DECLARE @AllowFinalizePurgeLog bit;
		DECLARE @AllowTruncate bit;
		
		SELECT TOP 1
				@AllowClaimUpdates = ET.AllowClaimUpdates,
				@AllowFinalizePurgeInternal = ET.AllowFinalizePurgeInternal,
				@AllowFinalizePurgeLog = ET.AllowFinalizePurgeLog,
				@AllowTruncate = ET.AllowTruncate
		FROM	Engine.Settings AS ES
				INNER JOIN Engine.[Types] AS ET
						ON ES.EngineTypeID = ET.EngineTypeID;
		
		--Determine the number of active Batches/SPIDs on the "key" tables...
		DECLARE @CountBatches int;
		DECLARE @CountSps int;
		
		WITH Counts AS
		(
			SELECT COUNT(DISTINCT BatchID) AS CountBatches, COUNT(DISTINCT SpId) AS CountSps FROM Internal.EnrollmentKey WITH (READUNCOMMITTED)
			UNION
			SELECT COUNT(DISTINCT BatchID) AS CountBatches, COUNT(DISTINCT SpId) AS CountSps FROM Internal.EntityKey WITH (READUNCOMMITTED)
			UNION
			SELECT COUNT(DISTINCT BatchID) AS CountBatches, COUNT(DISTINCT SpId) AS CountSps FROM Internal.EventKey WITH (READUNCOMMITTED)
		)
		SELECT	@CountBatches = MAX(CountBatches),
				@CountSps = MAX(CountSps)
		FROM	Counts;
	
		DECLARE @Sql nvarchar(MAX);

		--1) Identify tables to purge...
		IF ISNULL(@AllowFinalizePurgeInternal, 1) = 1 OR ISNULL(@ForcePurge, 0) = 1
			SELECT	@Sql = ISNULL(@Sql + CHAR(13) + CHAR(10), '') +
							CASE 
								WHEN ISNULL(@AllowTruncate, 0) = 1 AND 
									 (
										(ISNULL(@ForcePurge, 0) = 1) OR
										(
											ISNULL(@CountBatches, 0) <= 1 AND
											ISNULL(@CountSps, 0) <= 1
										)
									 )
								THEN 'TRUNCATE TABLE ' + QUOTENAME(T.TABLE_SCHEMA) + '.' + QUOTENAME(T.TABLE_NAME) + ';'
								ELSE 'DELETE FROM ' + QUOTENAME(T.TABLE_SCHEMA) + '.' + QUOTENAME(T.TABLE_NAME) + ' ' + 
									 'WHERE (1 = 2)' + 
									 CASE 
										WHEN CSPID.COLUMN_NAME IS NOT NULL 
										THEN '		OR ([SpId] = @@SPID)' 
										ELSE '' 
										END + 
									 CASE 
										WHEN CBAT.COLUMN_NAME IS NOT NULL 
										THEN '		OR ([BatchID] = ' + CONVERT(nvarchar(max), @BatchID) + ')' 
										ELSE '' 
										END +
									 ';'
								END
			FROM	INFORMATION_SCHEMA.TABLES AS T
					LEFT OUTER JOIN INFORMATION_SCHEMA.COLUMNS AS CSPID
							ON T.TABLE_CATALOG = CSPID.TABLE_CATALOG AND
								T.TABLE_NAME = CSPID.TABLE_NAME AND
								T.TABLE_SCHEMA = CSPID.TABLE_SCHEMA AND
								CSPID.COLUMN_NAME = 'SpId'
					LEFT OUTER JOIN INFORMATION_SCHEMA.COLUMNS AS CBAT
							ON T.TABLE_CATALOG = CBAT.TABLE_CATALOG AND
								T.TABLE_NAME = CBAT.TABLE_NAME AND
								T.TABLE_SCHEMA = CBAT.TABLE_SCHEMA AND
								CBAT.COLUMN_NAME = 'BatchID'
			WHERE	(T.TABLE_SCHEMA = 'Internal') AND
					(T.TABLE_TYPE = 'BASE TABLE') AND
					(
						(CSPID.COLUMN_NAME IS NOT NULL) OR
						(CBAT.COLUMN_NAME IS NOT NULL)
					) AND
					(
						((@IgnoreMembers = 1) AND (T.TABLE_NAME NOT IN ('Members'))) OR
						(@IgnoreMembers = 0)
					)
			ORDER BY T.TABLE_SCHEMA, T.TABLE_NAME;

		--2) Execute the purge...
		IF @Sql IS NOT NULL
			EXEC sp_executesql @Sql;
		
		RETURN 0;
	END TRY
	BEGIN CATCH;
		DECLARE @ErrApp nvarchar(128);
		DECLARE @ErrLine int;
		DECLARE @ErrLogID int;
		DECLARE @ErrMessage nvarchar(max);
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
GRANT EXECUTE ON  [Batch].[PurgeInternalTables] TO [Processor]
GO
