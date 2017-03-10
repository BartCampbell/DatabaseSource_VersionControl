SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/12/2011
-- Description:	Initializes entities with a top-ranked criteria based the year-end seed date.  
--				(Date Comparer: 393D75A2-B6D1-48E8-9568-AE802F8732F8)
-- =============================================
CREATE PROCEDURE [Batch].[InitializeEntityByEventSeedDate]
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
			
		--DECLARE @DateCompTypeE tinyint; --Entity
		--DECLARE @DateCompTypeN tinyint; --Enrollment
		--DECLARE @DateCompTypeS tinyint; --Seed Date
		DECLARE @DateCompTypeV tinyint; --Event

		--SELECT @DateCompTypeE = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'E';
		--SELECT @DateCompTypeN = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'N';
		--SELECT @DateCompTypeS = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'S';
		SELECT @DateCompTypeV = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'V';

		----------------------------------------------------------------------------------------------

		DECLARE @DateComparerID int;
		SELECT	@DateComparerID = DateComparerID 
		FROM	Measure.DateComparers 
		WHERE	(DateComparerGuid = '393D75A2-B6D1-48E8-9568-AE802F8732F8') AND
				(DateCompTypeID = @DateCompTypeV);

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
				TV.BeginDate,
				TV.BeginOrigDate,
				@DataRunID AS DataRunID,
				@DataSetID AS DataSetID,
				TV.DataSourceID,
				MEC.DateComparerID,
				MEC.DateComparerInfo,
				NULL AS DateComparerLink,
				TV.[Days],
				TV.DSMemberID,
				TV.DSProviderID,
				TV.EndDate,
				TV.EndOrigDate,
				CAST(NULL AS bigint) AS EntityBaseID,
				DATEADD(dd, MEC.BeginDays, DATEADD(mm, MEC.BeginMonths, @BeginInitSeedDate)) AS EntityBeginDate,
				MEC.EntityCritID, 
				DATEADD(dd, MEC.EndDays, DATEADD(mm, MEC.EndMonths, @EndInitSeedDate)) AS EntityEndDate,
				MEC.EntityID,
				CASE WHEN @CalculateXml = 1 THEN (SELECT ISNULL(TV.EventInfo, NULL) FOR XML PATH('components'), TYPE) END AS EntityInfo,
				NULL AS EntityLinkInfo,
				MEC.IsForIndex,
				TV.IsSupplemental, 
				MEC.OptionNbr, 
				1 AS Qty,
				ISNULL(MEC.QtyMax, 32767) AS QtyMax, 
				ISNULL(MEC.QtyMin, 1) AS QtyMin,
				MEC.RankOrder,
				TV.DSEventID AS SourceID,
				NULL AS SourceLinkID
		FROM	Measure.EntityCriteria  AS MEC
				INNER JOIN Proxy.[Events] AS TV
						ON MEC.DateComparerInfo = TV.EventID AND
							MEC.DateComparerID = @DateComparerID AND
							MEC.IsEnabled = 1 AND
							MEC.EntityID IN (SELECT EntityID FROM #ValidEntities) 
				INNER JOIN Proxy.Members AS M
						ON TV.DSMemberID = M.DSMemberID AND
						
							--1st Rank-specific Criteria---------------------------------------------------------------
							(MEC.Allow = 1) AND --1st Rank must always be "allowed", ignores anything that is "not allowed".
							(MEC.RankOrder = 1) AND
				
							--Apply After-Date-of-Birth Criteria---------------------------------------------------
							((MEC.AfterDOBDays IS NULL) OR 
							(MEC.AfterDOBMonths IS NULL) OR
							((MEC.AfterDOBDays IS NOT NULL) AND (MEC.AfterDOBMonths IS NOT NULL) AND (TV.BeginDate >= DATEADD(dd, MEC.AfterDOBDays, DATEADD(mm, MEC.AfterDOBMonths, M.DOB)))) OR
							--Added 12/7/2012 due to 2013 CDC Deck; Commented out 12/14/2012 again due to 2013 IPU Deck... Same issue HEDIS 2014 & 2015
							--Added new AllowAdmitPreDOB flag to be used in CDC without need to comment/uncomment, 11/25/2014
							((MEC.AfterDOBDays IS NOT NULL) AND (MEC.AfterDOBMonths IS NOT NULL) AND (MEC.AllowAdmitPreDOB = 1) AND (TV.EndDate >= DATEADD(dd, MEC.AfterDOBDays, DATEADD(mm, MEC.AfterDOBMonths, M.DOB))))) AND 
				
							--Apply Supplemental Data Criteria-----------------------------------------------------------------
							((MEC.AllowSupplemental = 1) OR
							((MEC.AllowSupplemental = 0) AND (TV.IsSupplemental = 0))) AND

							--Apply Transfer Criteria-----------------------------------------------------------------
							((MEC.AllowXfers = 1) OR
							((MEC.AllowXfers = 0) AND (TV.IsXfer = 0))) AND
							((TV.XferID IS NULL) OR (TV.XferID = TV.EventBaseID)) AND
							
							--Apply Date Criteria*--------------------------------------------------------------------
							(
								(
									(
										(MEC.AllowBeginDate = 1) AND 
										(TV.BeginDate BETWEEN DATEADD(dd, MEC.BeginDays, DATEADD(mm, MEC.BeginMonths, @BeginInitSeedDate)) AND DATEADD(dd, MEC.EndDays, DATEADD(mm, MEC.EndMonths, @EndInitSeedDate)))
									) OR
									(
										(MEC.AllowEndDate = 1) AND 
										(TV.EndDate BETWEEN DATEADD(dd, MEC.BeginDays, DATEADD(mm, MEC.BeginMonths, @BeginInitSeedDate)) AND DATEADD(dd, MEC.EndDays, DATEADD(mm, MEC.EndMonths, @EndInitSeedDate)))
									) OR
									(
										(MEC.AllowServDate = 1) AND 
										(
											(
												(TV.EndDate IS NULL) AND 
												(TV.BeginDate BETWEEN DATEADD(dd, MEC.BeginDays, DATEADD(mm, MEC.BeginMonths, @BeginInitSeedDate)) AND DATEADD(dd, MEC.EndDays, DATEADD(mm, MEC.EndMonths, @EndInitSeedDate)))
											) OR
											(
												(TV.EndDate IS NOT NULL) AND 
												(TV.EndDate BETWEEN DATEADD(dd, MEC.BeginDays, DATEADD(mm, MEC.BeginMonths, @BeginInitSeedDate)) AND DATEADD(dd, MEC.EndDays, DATEADD(mm, MEC.EndMonths, @EndInitSeedDate)))
											)
										) 
									) 
								) OR
								/*Pharmacy Active Script Date Criteria*/
								(	
									(MEC.AllowActiveScript = 1) AND 
									(TV.EndOrigDate IS NOT NULL) AND
									(@BeginInitSeedDate > TV.BeginDate) AND
									(@BeginInitSeedDate BETWEEN TV.BeginDate AND TV.EndOrigDate)
								)
							) AND							
							
							--Apply Length/Number of Days Criteria----------------------------------------------------
							((MEC.DaysMax IS NULL) OR
							((MEC.DaysMax IS NOT NULL) AND (MEC.DaysMax >= DATEDIFF(dd, TV.BeginDate, TV.EndDate) + 1))) AND
							((MEC.DaysMin IS NULL) OR
							((MEC.DaysMin IS NOT NULL) AND (MEC.DaysMin <= DATEDIFF(dd, TV.BeginDate, TV.EndDate) + 1))) AND
							
							--Apply Paid Criteria---------------------------------------------------------------------
							((MEC.RequirePaid = 0) OR
							((MEC.RequirePaid = 1) AND (TV.IsPaid = 1))) AND
							
							--Apply Value Criteria
							((MEC.ValueMax IS NULL) OR 
							((MEC.ValueMax IS NOT NULL) AND (MEC.ValueMax >= TV.Value))) AND
							((MEC.ValueMin IS NULL) OR 
							((MEC.ValueMin IS NOT NULL) AND (MEC.ValueMin <= TV.Value))) 
							
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
GRANT VIEW DEFINITION ON  [Batch].[InitializeEntityByEventSeedDate] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[InitializeEntityByEventSeedDate] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[InitializeEntityByEventSeedDate] TO [Processor]
GO
