SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/18/2011
-- Description:	Identifies the earliest possible entity episode per member by "Begin Date" with the episode chosen before eligibility is applied.
--				(Entity Type: 32887384-C4CE-48C1-819D-F3655CA6F8CE)
-- =============================================
CREATE PROCEDURE [Batch].[IdentifyEntityEpisodesForEarliestByBeginDateAndEarlyIndex]
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
		IF 1 = 1--@BatchID IS NOT NULL AND	@Iteration IS NOT NULL AND EXISTS (SELECT TOP 1 1 FROM Temp.EntityBase)
			BEGIN;
			
				WITH Entities AS
				(
					SELECT DISTINCT
							ME.EntityID, ME.IsNonSuppPrioritized
					FROM	Measure.Entities AS ME
							INNER JOIN Proxy.EntityKey AS PEK
									ON ME.EntityID = PEK.EntityID
							INNER JOIN Measure.EntityTypes AS MET
									ON ME.EntityTypeID = MET.EntityTypeID AND
										ME.Iteration = @Iteration AND
										ME.MeasureSetID = @MeasureSetID AND
										MET.EntityTypeGuid = '32887384-C4CE-48C1-819D-F3655CA6F8CE'	
				)
				SELECT	COUNT(CASE WHEN Allow = 1 THEN MEC.EntityCritID END) AS CountAllowed,
						COUNT(CASE WHEN Allow = 1 AND MEC.IsForIndex = 0 THEN MEC.EntityCritID END) AS CountAllowedAfterIndex /*Updated*/,
						COUNT(CASE WHEN Allow = 1 AND MEC.IsForIndex = 1 THEN MEC.EntityCritID END) AS CountAllowedForIndex /*Updated*/,
						COUNT(MEC.EntityCritID) AS CountCriteria,
						COUNT(CASE WHEN Allow = 0 THEN MEC.EntityCritID END) AS CountDenied,
						COUNT(CASE WHEN Allow = 0 AND MEC.IsForIndex = 0 THEN MEC.EntityCritID END) AS CountDeniedAfterIndex /*Updated*/,
						COUNT(CASE WHEN Allow = 0 AND MEC.IsForIndex = 1 THEN MEC.EntityCritID END) AS CountDeniedForIndex /*Updated*/,
						MEC.EntityID,
						CONVERT(bit, MAX(CONVERT(tinyint, IsNonSuppPrioritized))) AS IsNonSuppPrioritized,
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
						CONVERT(bit, MAX(CONVERT(tinyint, IsNonSuppPrioritized))) AS IsNonSuppPrioritized,
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
				GROUP BY TEB.EntityBaseID, EO.EntityID, EO.OptionNbr, 
						EO.CountAllowedForIndex, EO.CountAllowedAfterIndex
				HAVING	(COUNT(DISTINCT CASE WHEN Allow = 0 AND TEB.IsForIndex = 1 THEN TEB.EntityCritID END) = 0) AND
						(COUNT(DISTINCT CASE WHEN Allow = 1 AND TEB.IsForIndex = 1 THEN TEB.EntityCritID END) = EO.CountAllowedForIndex);
				
				CREATE UNIQUE CLUSTERED INDEX IX_PossibleEntities_EntityBaseID ON #PossibleEntities (EntityBaseID);
			
				SELECT	TEB.DSMemberID, TEB.EntityID, 
						COALESCE(MIN(CASE WHEN PE.IsSupplemental = 0 AND PE.IsNonSuppPrioritized = 1 THEN TEB.BeginDate END), MIN(TEB.BeginDate)) AS KeyDate, 
						MIN(TEB.BeginDate) AS KeyDateNoSupplementalFilter,
						PE.SourceLinkID 
				INTO	#KeyEntities
				FROM	#PossibleEntities AS PE
						INNER JOIN Proxy.EntityBase AS TEB
								ON PE.EntityBaseID = TEB.EntityBaseID AND
									TEB.RankOrder = 1
				GROUP BY TEB.DSMemberID, TEB.EntityID, PE.SourceLinkID
							
				CREATE UNIQUE CLUSTERED INDEX IX_#KeyEntities ON #KeyEntities (DSMemberID, EntityID, SourceLinkID);

				DELETE FROM #PossibleEntities WHERE EntityBaseID NOT IN (SELECT EntityBaseID FROM Proxy.EntityEligible);
				
				SELECT	COALESCE(MIN(CASE WHEN t.IsSupplemental = 0 THEN t.EntityBaseID END), MIN(t.EntityBaseID)) AS EntityBaseID,
						CONVERT(bit, MIN(CONVERT(tinyint, t.IsSupplemental))) AS IsSupplemental
				FROM	#PossibleEntities AS t
						INNER JOIN Proxy.EntityBase AS TEB
								ON t.EntityBaseID = TEB.EntityBaseID AND
										TEB.RankOrder = 1
						INNER JOIN #KeyEntities AS KE 
								ON TEB.DSMemberID = KE.DSMemberID AND
									TEB.BeginDate = KE.KeyDate AND
									TEB.EntityID = KE.EntityID AND
									(TEB.SourceLinkID = KE.SourceLinkID OR (TEB.SourceLinkID IS NULL AND KE.SourceLinkID IS NULL))
				WHERE	(t.IsValid = 1) 
				GROUP BY KE.DSMemberID, KE.KeyDate, KE.EntityID, KE.SourceLinkID;
				
				SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			END;
		
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
GRANT EXECUTE ON  [Batch].[IdentifyEntityEpisodesForEarliestByBeginDateAndEarlyIndex] TO [Processor]
GO
