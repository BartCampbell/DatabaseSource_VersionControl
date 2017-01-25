SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/19/2011
-- Description:	Applies the additional entity criteria based on End Date (only) of the originating event.  
--				(Date Comparer: DC8ED37E-ADBC-4A19-9803-EAA4CC740D6C)
-- =============================================
CREATE PROCEDURE [Batch].[ApplyEntityCriteriaByEventEndDateOnly]
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
		WHERE	(B.BatchID = @BatchID);
			
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
		WHERE	(DateComparerGuid = 'DC8ED37E-ADBC-4A19-9803-EAA4CC740D6C') AND
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
		
		SELECT	DATEADD(dd, MEC.AfterDOBDays, DATEADD(mm, MEC.AfterDOBMonths, M.DOB)) AS AfterDOBDate,
				MEC.Allow, MEC.AllowActiveScript,
				MEC.AllowBeginDate, MEC.AllowEndDate, MEC.AllowServDate, MEC.AllowSupplemental,
				MEC.AllowXfers, MEC.DateComparerID, MEC.DateComparerInfo, 
				MEC.DaysMax, MEC.DaysMin, TEB.DSMemberID, TEB.DSProviderID, TEB.EntityBaseID,
				DATEADD(dd, MEC.BeginDays, DATEADD(mm, MEC.BeginMonths, TEB.EndDate)) AS EntityBeginDate,
				MEC.EntityCritID, 
				TEB.EndDate AS EntityDate,
				DATEADD(dd, MEC.EndDays, DATEADD(mm, MEC.EndMonths, TEB.EndDate)) AS EntityEndDate,
				MEC.EntityID, MEC.IsForIndex, MEC.OptionNbr, ISNULL(MEC.QtyMax, 32767) AS QtyMax, ISNULL(MEC.QtyMin, 1) AS QtyMin,
				MEC.RankOrder, MEC.RequireDiffProvider, MEC.RequirePaid, MEC.ValueMax, MEC.ValueMin
		INTO	#Base
		FROM	Measure.EntityCriteria AS MEC
				INNER JOIN #ValidEntities AS t
						ON MEC.EntityID = t.EntityID
				INNER JOIN Proxy.EntityBase AS TEB
						ON MEC.EntityID = TEB.EntityID AND
							MEC.OptionNbr = TEB.OptionNbr AND
							(MEC.RankOrder > 1) AND
							(TEB.RankOrder = 1)
				INNER JOIN Proxy.Members AS M
						ON TEB.DSMemberID = M.DSMemberID
		WHERE	(MEC.DateComparerID = @DateComparerID) AND
				(MEC.IsEnabled = 1) AND
				(TEB.EndDate IS NOT NULL);

		CREATE CLUSTERED INDEX IX_#Base ON #Base (DSMemberID, DateComparerID, DateComparerInfo, EntityBeginDate, EntityEndDate, EntityBaseID);
		
		SELECT	t.Allow, 
				@BatchID AS BatchID, 
				TV.BeginDate,
				TV.BeginOrigDate,
				@DataRunID AS DataRunID,
				@DataSetID AS DataSetID,
				TV.DataSourceID,
				t.DateComparerID,
				t.DateComparerInfo,
				NULL AS DateComparerLink,
				TV.[Days],
				TV.DSMemberID,
				TV.DSProviderID,
				TV.EndDate,
				TV.EndOrigDate,
				t.EntityBaseID,
				t.EntityBeginDate,
				t.EntityCritID, 
				t.EntityEndDate,
				t.EntityID, 
				CASE WHEN @CalculateXml = 1 THEN (SELECT ISNULL(TV.EventInfo, NULL) FOR XML PATH('components'), TYPE) END AS EntityInfo,
				NULL AS EntityLinkInfo,
				t.IsForIndex, 
				TV.IsSupplemental,
				t.OptionNbr, 
				1 AS Qty,
				t.QtyMax, 
				t.QtyMin,
				t.RankOrder,
				TV.DSEventID AS SourceID,
				NULL AS SourceLinkID
		FROM	#Base AS t
				INNER JOIN Proxy.[Events] AS TV
						ON t.DateComparerInfo = TV.EventID AND
							t.DateComparerID = @DateComparerID AND
							t.DSMemberID = TV.DSMemberID AND
							
							--Apply After-Date-of-Birth Criteria---------------------------------------------------
							((T.AfterDOBDate IS NULL) OR
							((T.AfterDOBDate IS NOT NULL) AND (TV.BeginDate >= T.AfterDOBDate)) OR 
							((T.AfterDOBDate IS NOT NULL) AND (TV.EndDate >= T.AfterDOBDate))) AND
							
							--Apply Supplemental Data Criteria-----------------------------------------------------------------
							((t.AllowSupplemental = 1) OR
							((t.AllowSupplemental = 0) AND (TV.IsSupplemental = 0))) AND

							--Apply Transfer Criteria-----------------------------------------------------------------
							((t.AllowXfers = 1) OR
							((t.AllowXfers = 0) AND (TV.IsXfer = 0))) AND
							((TV.XferID IS NULL) OR (TV.XferID = TV.EventBaseID)) AND 
				
							--Apply Date Criteria*--------------------------------------------------------------------
							(
								(
									(
										(t.AllowBeginDate = 1) AND 
										(TV.BeginDate BETWEEN T.EntityBeginDate AND T.EntityEndDate)
									) OR
									(
										(t.AllowEndDate = 1) AND 
										(TV.EndDate BETWEEN T.EntityBeginDate AND T.EntityEndDate)
									) OR
									(
										(t.AllowServDate = 1) AND 
										(
											(
												(TV.EndDate IS NULL) AND 
												(TV.BeginDate BETWEEN T.EntityBeginDate AND T.EntityEndDate)
											) OR
											(
												(TV.EndDate IS NOT NULL) AND 
												(TV.EndDate BETWEEN T.EntityBeginDate AND T.EntityEndDate)
											)
										) 
									) 
								) OR
								
								/*Pharmacy Active Script Date Criteria*/
								(	
									(t.AllowActiveScript = 1) AND 
									(TV.EndOrigDate IS NOT NULL) AND
									(t.EntityDate > TV.BeginDate) AND
									(t.EntityDate BETWEEN TV.BeginDate AND TV.EndOrigDate)
								)
								
							) AND
							
							--Apply Length/Number of Days Criteria----------------------------------------------------
							((t.DaysMax IS NULL) OR
							((t.DaysMax IS NOT NULL) AND (t.DaysMax >= DATEDIFF(dd, TV.BeginDate, TV.EndDate) + 1))) AND
							((t.DaysMin IS NULL) OR
							((t.DaysMin IS NOT NULL) AND (t.DaysMin <= DATEDIFF(dd, TV.BeginDate, TV.EndDate) + 1))) AND
							
							--Apply Different Provider Criteria-------------------------------------------------------
							((t.RequireDiffProvider = 0) OR
							((t.RequireDiffProvider = 1) AND ((t.DSProviderID <> TV.DSProviderID) OR (t.DSProviderID IS NULL) OR (TV.DSProviderID IS NULL)))) AND

							--Apply Paid Criteria---------------------------------------------------------------------
							((t.RequirePaid = 0) OR
							((t.RequirePaid = 1) AND (TV.IsPaid = 1))) AND
							
							--Apply Value Criteria
							((t.ValueMax IS NULL) OR 
							((t.ValueMax IS NOT NULL) AND (t.ValueMax >= TV.Value))) AND
							((t.ValueMin IS NULL) OR 
							((t.ValueMin IS NOT NULL) AND (t.ValueMin <= TV.Value))) 
							
		ORDER BY t.Allow DESC, t.EntityCritID, t.DSMemberID, ISNULL(TV.EndDate, TV.BeginDate);
		
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
GRANT EXECUTE ON  [Batch].[ApplyEntityCriteriaByEventEndDateOnly] TO [Processor]
GO
