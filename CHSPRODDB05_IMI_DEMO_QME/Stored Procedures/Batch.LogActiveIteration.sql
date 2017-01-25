SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/20/2011
-- Description:	Logs the data iteration-specific working tables
-- =============================================
CREATE PROCEDURE [Batch].[LogActiveIteration]
(
	@BatchID int,
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
			
		IF OBJECT_ID('Proxy.EntityBase') IS NOT NULL
			BEGIN;									
				IF @IsLogged = 1
					BEGIN;
						--Log EntityBase data...
						INSERT INTO [Log].EntityBase
								(Allow,
								BatchID,
								BeginDate,
								BeginOrigDate,
								DataRunID,
								DataSetID,
								DataSourceID,
								DateComparerID,
								DateComparerInfo,
								DateComparerLink,
								[Days],
								DSMemberID,
								DSProviderID,
								EndDate,
								EndOrigDate,
								EntityBaseID,
								EntityBeginDate,
								EntityCritID,
								EntityEndDate,
								EntityID,
								IsForIndex,
								IsSupplemental,
								Iteration,
								OptionNbr,
								OwnerID,
								Qty,
								QtyMax,
								QtyMin,
								RankOrder,
								RowID,
								SourceID,
								SourceLinkID)
						SELECT	Allow,
								@BatchID,
								BeginDate,
								BeginOrigDate,
								@DataRunID,
								@DataSetID,
								DataSourceID,
								DateComparerID,
								DateComparerInfo,
								DateComparerLink,
								[Days],
								DSMemberID,
								DSProviderID,
								EndDate,
								EndOrigDate,
								EntityBaseID,
								EntityBeginDate,
								EntityCritID,
								EntityEndDate,
								EntityID,
								IsForIndex,
								IsSupplemental,
								@Iteration,
								OptionNbr,
								@OwnerID,
								Qty,
								QtyMax,
								QtyMin,
								RankOrder,
								RowID,
								SourceID,
								SourceLinkID
						FROM	Proxy.EntityBase;
						
						--Log EntityEnrollment data...
						INSERT INTO [Log].EntityEnrollment
								(ActualBeginDate,
								ActualBeginGap,
								ActualBeginGapDays,
								ActualEndDate,
								ActualEndGap,
								ActualEndGapDays,
								ActualEnrollGroupID,
								ActualFirstRow,
								ActualGapDays,
								ActualGapMaxDays,
								ActualGaps,
								ActualHasAnchor,
								ActualHasPayer,
								ActualLastRow,
								AdminGapDays,
								AdminGaps,
								AnchorDate,
								BatchID,
								BeginDate,
								BeginDOBDate,
								BeginEnrollDate,
								BenefitID,
								BitBenefits,
								BitProductLines,
								DataRunID,
								DataSetID,
								DSMemberID,
								EndDate,
								EndDOBDate,
								EndEnrollDate,
								EnrollGroupID,
								EnrollItemID,
								EnrollSegBeginDate,
								EnrollSegEndDate,
								EntityBaseID,
								EntityEnrollID,
								EntityEnrollSetID,
								EntityEnrollSetLineID,
								EntityID,
								GapDays,
								Gaps,
								Gender,
								Iteration,
								LastSegBeginDate,
								LastSegEndDate,
								MeasEnrollID,
								OptionNbr,
								OwnerID,
								PayerDate,
								ProductClassID)
						SELECT	ActualBeginDate,
								ActualBeginGap,
								ActualBeginGapDays,
								ActualEndDate,
								ActualEndGap,
								ActualEndGapDays,
								ActualEnrollGroupID,
								ActualFirstRow,
								ActualGapDays,
								ActualGapMaxDays,
								ActualGaps,
								ActualHasAnchor,
								ActualHasPayer,
								ActualLastRow,
								AdminGapDays,
								AdminGaps,
								AnchorDate,
								@BatchID,
								BeginDate,
								BeginDOBDate,
								BeginEnrollDate,
								BenefitID,
								BitBenefits,
								BitProductLines,
								@DataRunID,
								@DataSetID,
								DSMemberID,
								EndDate,
								EndDOBDate,
								EndEnrollDate,
								EnrollGroupID,
								EnrollItemID,
								EnrollSegBeginDate,
								EnrollSegEndDate,
								EntityBaseID,
								EntityEnrollID,
								EntityEnrollSetID,
								EntityEnrollSetLineID,
								EntityID,
								GapDays,
								Gaps,
								Gender,
								@Iteration,
								LastSegBeginDate,
								LastSegEndDate,
								MeasEnrollID,
								OptionNbr,
								@OwnerID,
								PayerDate,
								ProductClassID
						FROM	Proxy.EntityEnrollment;
						
						--Log EntityEligible data...
						INSERT INTO [Log].EntityEligible
								(BatchID,
								BitProductLines,
								DataRunID,
								DataSetID,
								EnrollGroupID,
								EntityBaseID,
								Iteration,
								LastSegBeginDate,
								LastSegEndDate,
								OwnerID)
						SELECT	@BatchID,
								BitProductLines,
								@DataRunID,
								@DataSetID,
								EnrollGroupID,
								EntityBaseID,
								@Iteration,
								LastSegBeginDate,
								LastSegEndDate,
								@OwnerID
						FROM	Proxy.EntityEligible;
					END;
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
GRANT EXECUTE ON  [Batch].[LogActiveIteration] TO [Processor]
GO
