SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/19/2011
-- Description:	Initializes entities with a top-ranked criteria based the entity-based year-end seed date.  
--				(Date Comparer: 0B38E8E0-A019-4537-AC9B-50422B5EBDEB)
-- =============================================
CREATE PROCEDURE [Batch].[InitializeEntityByEntitySeedDate]
(
	@BatchID int,
	@CountRecords bigint = 0 OUTPUT,
	@Iteration tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @BeginInitSeedDate datetime;
	DECLARE @CalculateXml bit;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
				@CalculateXml = DR.CalculateXml,
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
			
		DECLARE @DateCompTypeE tinyint; --Entity
		--DECLARE @DateCompTypeN tinyint; --Enrollment
		--DECLARE @DateCompTypeS tinyint; --Seed Date
		--DECLARE @DateCompTypeV tinyint; --Event

		SELECT @DateCompTypeE = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'E';
		--SELECT @DateCompTypeN = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'N';
		--SELECT @DateCompTypeS = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'S';
		--SELECT @DateCompTypeV = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'V';

		----------------------------------------------------------------------------------------------

		DECLARE @DateComparerID int;
		SELECT	@DateComparerID = DateComparerID 
		FROM	Measure.DateComparers 
		WHERE	(DateComparerGuid = '0B38E8E0-A019-4537-AC9B-50422B5EBDEB') AND
				(DateCompTypeID = @DateCompTypeE);

		SELECT DISTINCT
				ME.EntityID 
		INTO	#ValidEntities
		FROM	Measure.Entities AS ME
				INNER JOIN Proxy.EntityKey AS PEK
								ON ME.EntityID = PEK.EntityID
		WHERE	ME.MeasureSetID = @MeasureSetID AND
				ME.Iteration = @Iteration AND
				ME.IsEnabled = 1;
				
		CREATE UNIQUE CLUSTERED INDEX IX_#ValidEntities ON #ValidEntities (EntityID);
		
		SELECT	MEC.Allow, 
				@BatchID AS BatchID,
				TE.BeginDate,
				TE.BeginOrigDate,
				@DataRunID AS DataRunID,
				@DataSetID AS DataSetID,
				TE.DataSourceID,
				MEC.DateComparerID,
				MEC.DateComparerInfo,
				NULL AS DateComparerLink,
				TE.[Days],
				TE.DSMemberID,
				TE.DSProviderID,
				TE.EndDate,
				TE.EndOrigDate,
				CAST(NULL AS bigint) AS EntityBaseID,
				DATEADD(dd, MEC.BeginDays, DATEADD(mm, MEC.BeginMonths, @BeginInitSeedDate)) AS EntityBeginDate,
				MEC.EntityCritID, 
				DATEADD(dd, MEC.EndDays, DATEADD(mm, MEC.EndMonths, @EndInitSeedDate)) AS EntityEndDate,
				MEC.EntityID,
				CASE WHEN @CalculateXml = 1 THEN (SELECT ISNULL(TE.EntityInfo, NULL) FOR XML PATH('components'), TYPE) END AS EntityInfo,
				NULL AS EntityLinkInfo, 
				MEC.IsForIndex,
				TE.IsSupplemental,
				MEC.OptionNbr, 
				1 AS Qty,
				ISNULL(MEC.QtyMax, 32767) AS QtyMax, 
				ISNULL(MEC.QtyMin, 1) AS QtyMin,
				MEC.RankOrder,
				TE.DSEntityID AS SourceID,
				NULL AS SourceLinkID
		FROM	Measure.EntityCriteria  AS MEC
				INNER JOIN Proxy.Entities AS TE
						ON MEC.DateComparerInfo = TE.EntityID AND
							MEC.DateComparerID = @DateComparerID  AND
							MEC.IsEnabled = 1 AND
							MEC.EntityID IN (SELECT EntityID FROM #ValidEntities) 
				INNER JOIN Proxy.Members AS M
						ON TE.DSMemberID = M.DSMemberID AND
						
							--1st Rank-specific Criteria---------------------------------------------------------------
							(MEC.Allow = 1) AND --1st Rank must always be "allowed", ignores anything that is "not allowed".
							(MEC.RankOrder = 1) AND
				
							--Apply After-Date-of-Birth Criteria---------------------------------------------------
							((MEC.AfterDOBDays IS NULL) OR 
							(MEC.AfterDOBMonths IS NULL) OR
							((MEC.AfterDOBDays IS NOT NULL) AND (MEC.AfterDOBMonths IS NOT NULL) AND (TE.BeginDate >= DATEADD(dd, MEC.AfterDOBDays, DATEADD(mm, MEC.AfterDOBMonths, M.DOB))))) AND
				
							--Apply Supplemental Data Criteria-----------------------------------------------------------------
							((MEC.AllowSupplemental = 1) OR
							((MEC.AllowSupplemental = 0) AND (TE.IsSupplemental = 0))) AND

							--Apply Transfer Criteria-----------------------------------------------------------------
							--((MEC.AllowXfers = 1) OR
							--((MEC.AllowXfers = 0) AND (TE.IsXfer = 0))) AND
							--((TE.XferID IS NULL) OR (TE.XferID = TE.EventBaseID)) AND
							
							--Apply Date Criteria*--------------------------------------------------------------------
							(
								(
									(
										(MEC.AllowBeginDate = 1) AND 
										(TE.BeginDate BETWEEN DATEADD(dd, MEC.BeginDays, DATEADD(mm, MEC.BeginMonths, @BeginInitSeedDate)) AND DATEADD(dd, MEC.EndDays, DATEADD(mm, MEC.EndMonths, @EndInitSeedDate)))
									) OR
									(
										(MEC.AllowEndDate = 1) AND 
										(TE.EndDate BETWEEN DATEADD(dd, MEC.BeginDays, DATEADD(mm, MEC.BeginMonths, @BeginInitSeedDate)) AND DATEADD(dd, MEC.EndDays, DATEADD(mm, MEC.EndMonths, @EndInitSeedDate)))
									) OR
									(
										(MEC.AllowServDate = 1) AND 
										(
											(
												(TE.EndDate IS NULL) AND 
												(TE.BeginDate BETWEEN DATEADD(dd, MEC.BeginDays, DATEADD(mm, MEC.BeginMonths, @BeginInitSeedDate)) AND DATEADD(dd, MEC.EndDays, DATEADD(mm, MEC.EndMonths, @EndInitSeedDate)))
											) OR
											(
												(TE.EndDate IS NOT NULL) AND 
												(TE.EndDate BETWEEN DATEADD(dd, MEC.BeginDays, DATEADD(mm, MEC.BeginMonths, @BeginInitSeedDate)) AND DATEADD(dd, MEC.EndDays, DATEADD(mm, MEC.EndMonths, @EndInitSeedDate)))
											)
										) 
									) 
								) 	
							) AND
							
							--Apply Length/Number of Days Criteria----------------------------------------------------
							((MEC.DaysMax IS NULL) OR
							((MEC.DaysMax IS NOT NULL) AND (MEC.DaysMax >= DATEDIFF(dd, TE.BeginDate, TE.EndDate) + 1))) AND
							((MEC.DaysMin IS NULL) OR
							((MEC.DaysMin IS NOT NULL) AND (MEC.DaysMin <= DATEDIFF(dd, TE.BeginDate, TE.EndDate) + 1))) AND
							
							--Apply Enrollment Segment Criteria-------------------------------------------------------
							((DATEADD(dd, MEC.BeginEnrollSegDays, DATEADD(mm, MEC.BeginEnrollSegMonths, @SeedDate)) IS NULL) OR 
							(DATEADD(dd, MEC.BeginEnrollSegDays, DATEADD(mm, MEC.BeginEnrollSegMonths, @SeedDate)) <= TE.LastSegBeginDate)) AND
							((DATEADD(dd, MEC.EndEnrollSegDays, DATEADD(mm, MEC.EndEnrollSegMonths, @SeedDate)) IS NULL) OR 
							(DATEADD(dd, MEC.EndEnrollSegDays, DATEADD(mm, MEC.EndEnrollSegMonths, @SeedDate)) >= TE.LastSegBeginDate))
		ORDER BY Allow DESC, EntityCritID, M.DSMemberID, ISNULL(EndDate, BeginDate)
		
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
GRANT EXECUTE ON  [Batch].[InitializeEntityByEntitySeedDate] TO [Processor]
GO
