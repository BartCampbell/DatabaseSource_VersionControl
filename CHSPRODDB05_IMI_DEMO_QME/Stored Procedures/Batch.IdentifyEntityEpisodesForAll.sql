SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/18/2011
-- Description:	Identifies valid entities based on type.  All possible episodes are valid for this particular type of entity.
--				(Entity Type: A86A519D-C00A-441E-9934-C4DC5D623DAE)
-- =============================================
CREATE PROCEDURE [Batch].[IdentifyEntityEpisodesForAll]
(
	@BatchID int,
	@CountRecords bigint = 0 OUTPUT,
	@Iteration tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @BeginInitSeedDate datetime;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
				@DataRunID = DR.DataRunID,
				@DataSetID = DS.DataSetID,
				@EndInitSeedDate = DR.EndInitSeedDate,
				@IsLogged = DR.IsLogged,
				@MeasureSetID = DR.MeasureSetID,
				@OwnerID = DS.OwnerID,
				@SeedDate = DR.SeedDate
		FROM	Batch.[Batches] AS B 
				INNER JOIN Batch.DataRuns AS DR
						ON B.DataRunID = DR.DataRunID
				INNER JOIN Batch.DataSets AS DS 
						ON B.DataSetID = DS.DataSetID 
		WHERE (B.BatchID = @BatchID);
			
		----------------------------------------------------------------------------------------------

		WITH Entities AS
		(
			SELECT DISTINCT
					ME.EntityID
			FROM	Measure.Entities AS ME
					INNER JOIN Proxy.EntityKey AS PEK
							ON ME.EntityID = PEK.EntityID
					INNER JOIN Measure.EntityTypes AS MET
							ON ME.EntityTypeID = MET.EntityTypeID AND
								ME.Iteration = @Iteration AND
								ME.MeasureSetID = @MeasureSetID AND
								MET.EntityTypeGuid = 'A86A519D-C00A-441E-9934-C4DC5D623DAE'	
		)
		SELECT	COUNT(CASE WHEN Allow = 1 THEN MEC.EntityCritID END) AS CountAllowed,
				COUNT(CASE WHEN Allow = 1 AND MEC.IsForIndex = 0 THEN MEC.EntityCritID END) AS CountAllowedAfterIndex,
				COUNT(CASE WHEN Allow = 1 AND MEC.IsForIndex = 1 THEN MEC.EntityCritID END) AS CountAllowedForIndex,	
				COUNT(MEC.EntityCritID) AS CountCriteria,
				COUNT(CASE WHEN Allow = 0 THEN MEC.EntityCritID END) AS CountDenied,
				COUNT(CASE WHEN Allow = 0 AND MEC.IsForIndex = 0 THEN MEC.EntityCritID END) AS CountDeniedAfterIndex,
				COUNT(CASE WHEN Allow = 0 AND MEC.IsForIndex = 1 THEN MEC.EntityCritID END) AS CountDeniedForIndex,
				MEC.EntityID,
				MEC.OptionNbr
		INTO	#EntityOptions
		FROM	Measure.EntityCriteria AS MEC
				INNER JOIN Entities AS t
						ON MEC.EntityID = t.EntityID 
		WHERE	MEC.IsEnabled = 1
		GROUP BY MEC.EntityID, MEC.OptionNbr
		
		CREATE UNIQUE CLUSTERED INDEX IX_EntityOptions ON #EntityOptions (EntityID, OptionNbr);
		
		SELECT DISTINCT
				TEB.EntityBaseID,
				CONVERT(bit, MAX(CONVERT(tinyint, TEB.IsSupplemental))) AS IsSupplemental,
				CAST(CASE 
						WHEN COUNT(DISTINCT CASE WHEN TEB.Allow = 0 AND TEB.IsForIndex = 0 THEN TEB.EntityCritID END) = 0 AND
								COUNT(DISTINCT CASE WHEN TEB.Allow = 1 AND TEB.IsForIndex = 0 THEN TEB.EntityCritID END) = EO.CountAllowedAfterIndex
						THEN 1
						ELSE 0 
						END AS bit) AS IsValid,
				MIN(TEB.SourceLinkID) AS SourceLinkID
		INTO	#PossibleEntities
		FROM	Proxy.EntityBase AS TEB
				INNER JOIN #EntityOptions AS EO
						ON TEB.EntityID = EO.EntityID AND
							TEB.OptionNbr = EO.OptionNbr 
		WHERE	((TEB.Qty >= TEB.QtyMin) OR (TEB.QtyMin IS NULL)) AND
				((TEB.Qty <= TEB.QtyMax) OR (TEB.QtyMax IS NULL))
		GROUP BY TEB.EntityBaseID, EO.OptionNbr, EO.EntityID,
				EO.CountAllowedForIndex, EO.CountAllowedAfterIndex
		HAVING	(COUNT(DISTINCT CASE WHEN Allow = 0 AND TEB.IsForIndex = 1 THEN TEB.EntityCritID END) = 0) AND
				(COUNT(DISTINCT CASE WHEN Allow = 1 AND TEB.IsForIndex = 1 THEN TEB.EntityCritID END) = EO.CountAllowedForIndex);
					
		CREATE UNIQUE CLUSTERED INDEX IX_#PossibleEntities ON #PossibleEntities (EntityBaseID);
							
		DELETE FROM #PossibleEntities WHERE EntityBaseID NOT IN (SELECT DISTINCT EntityBaseID FROM Proxy.EntityEligible);	
		
		SELECT DISTINCT
				COALESCE(MIN(CASE WHEN PE.IsSupplemental = 0 THEN PE.EntityBaseID END), MIN(PE.EntityBaseID)) AS EntityBaseID
		INTO	#KeyEntities
		FROM	#PossibleEntities AS PE
				INNER JOIN Proxy.EntityBase AS TEB
						ON PE.EntityBaseID = TEB.EntityBaseID AND
							TEB.RankOrder = 1 AND
							PE.IsValid = 1
				INNER JOIN Measure.Entities AS ME
						ON TEB.EntityID = ME.EntityID
		GROUP BY TEB.DSMemberID, TEB.EntityID, ISNULL(TEB.EndDate, TEB.BeginDate), PE.SourceLinkID, --Changed to "Service Date" from group by on both Begin and End Dates, 2/5/2014
				CASE WHEN ME.IsSummarized = 0 THEN TEB.EntityBaseID END
					
		CREATE UNIQUE CLUSTERED INDEX IX_#KeyEntities ON #KeyEntities (EntityBaseID);
		
		SELECT DISTINCT
				t.EntityBaseID,
				t.IsSupplemental
		FROM	#PossibleEntities AS t
				INNER JOIN #KeyEntities AS KE
						ON t.EntityBaseID = KE.EntityBaseID
		WHERE	(t.IsValid = 1);
		
		SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
		
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
GRANT VIEW DEFINITION ON  [Batch].[IdentifyEntityEpisodesForAll] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[IdentifyEntityEpisodesForAll] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[IdentifyEntityEpisodesForAll] TO [Processor]
GO
