SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/17/2011
-- Description:	Peforms the initial data gathering for calculating continuous enrollment for entities based on End Date only.
--				(Date Comparer: AD8073E4-5B49-42E4-8ABB-C7C869918B61)
-- =============================================
CREATE PROCEDURE [Batch].[InitializeEntityEnrollmentByEndDateOnly]
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

		DECLARE @DateCompTypeE tinyint; --Entity
		DECLARE @DateCompTypeN tinyint; --Enrollment
		DECLARE @DateCompTypeS tinyint; --Seed Date
		DECLARE @DateCompTypeV tinyint; --Event

		SELECT @DateCompTypeE = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'E';
		SELECT @DateCompTypeN = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'N';
		SELECT @DateCompTypeS = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'S';
		SELECT @DateCompTypeV = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'V';

		----------------------------------------------------------------------------------------------

		DECLARE @DateComparerID int;
		SELECT	@DateComparerID = DateComparerID 
		FROM	Measure.DateComparers 
		WHERE	(DateComparerGuid = 'AD8073E4-5B49-42E4-8ABB-C7C869918B61') AND
				(DateCompTypeID = @DateCompTypeN);

		SELECT	COUNT(CASE WHEN Allow = 1 THEN EntityCritID END) AS CountAllowed,
				COUNT(EntityCritID) AS CountCriteria,
				COUNT(CASE WHEN Allow = 0 THEN EntityCritID END) AS CountDenied,
				EntityID,
				OptionNbr
		INTO	#EntityOptionsForEnrollment
		FROM	Measure.EntityCriteria
		WHERE	IsEnabled = 1 AND
				EntityID IN (
								SELECT DISTINCT	
										MEN.EntityID
								FROM	Measure.EntityEnrollment AS MEN
										INNER JOIN Measure.Enrollment AS ME 
												ON MEN.MeasEnrollID = ME.MeasEnrollID AND
													ME.DateComparerID  = @DateComparerID
								WHERE	(MEN.IsEnabled = 1)
							)
		GROUP BY EntityID, OptionNbr;
		
		CREATE UNIQUE CLUSTERED INDEX IX_#EntityOptionsForEnrollment ON #EntityOptionsForEnrollment (EntityID, OptionNbr);
		
		SELECT DISTINCT
				EntityBaseID 
		INTO	#EligibleEntities
		FROM	Proxy.EntityBase AS TEB
				INNER JOIN #EntityOptionsForEnrollment AS EO
						ON TEB.EntityID = EO.EntityID AND
							TEB.OptionNbr = EO.OptionNbr 
		--WHERE	Qty BETWEEN QtyMin AND QtyMax 
		GROUP BY EntityBaseID, EO.CountAllowed
		HAVING	--(COUNT(DISTINCT CASE WHEN Allow = 0 THEN TEB.EntityCritID END) = 0) AND
				(COUNT(DISTINCT CASE WHEN Allow = 1 THEN TEB.EntityCritID END) = EO.CountAllowed);

		DROP TABLE #EntityOptionsForEnrollment;

		CREATE UNIQUE CLUSTERED INDEX IX_#EligibleEntities ON #EligibleEntities (EntityBaseID);

		SELECT DISTINCT 
				0 AS BenefitID, 
				B.BitBenefits,
				MEN.EntityID, 
				ME.*, 
				MEN.OptionNbr, 
				CASE WHEN MEN.IgnoreClass = 0 THEN PPC.ProductClassID ELSE 0 END AS ProductClassID
		INTO	#EntityEnrollmentKey
		FROM	Measure.EntityEnrollment AS MEN
				INNER JOIN Measure.Enrollment AS ME
						ON MEN.MeasEnrollID = ME.MeasEnrollID AND
							ME.DateComparerID = @DateComparerID 
				CROSS APPLY (
								SELECT  SUM(DISTINCT tPB.BitValue) AS BitBenefits
								FROM	Measure.EnrollmentBenefits AS tMEB
										INNER JOIN Product.Benefits AS tPB
												ON tPB.BenefitID = tMEB.BenefitID
								WHERE	tMEB.MeasEnrollID = MEN.MeasEnrollID
							) AS B
				CROSS JOIN Product.ProductClasses AS PPC
		WHERE 	(PPC.Abbrev IN ('HMO', 'PPO', 'FFS' /*FFS Added 1/20/2014*/)) AND
				(MEN.IsEnabled = 1);
		
		CREATE UNIQUE CLUSTERED INDEX IX_#EntityEnrollmentKey ON #EntityEnrollmentKey (EntityID, OptionNbr, MeasEnrollID, BenefitID, ProductClassID);
		
		SELECT DISTINCT
				TEB.BeginDate, EEK.BenefitID, EEK.BitBenefits, TEB.DSMemberID, TEB.EndDate, TEB.EntityBaseID, 
				EEK.AdminGaps, EEK.AdminGapDays, 
				DATEADD(dd, EEK.AnchorDays, DATEADD(mm, EEK.AnchorMonths, TEB.EndDate)) AS AnchorDate,
				DATEADD(dd, EEK.BeginDOBDays, DATEADD(mm, EEK.BeginDOBMonths, @SeedDate)) AS BeginDOBDate, --DOB criteria always on Seed Date
				DATEADD(dd, EEK.BeginDays, DATEADD(mm, EEK.BeginMonths, TEB.EndDate)) AS BeginEnrollDate,
				DATEADD(dd, EEK.EndDOBDays, DATEADD(mm, EEK.EndDOBMonths, @SeedDate)) AS EndDOBDate, --DOB criteria always on Seed Date
				DATEADD(dd, EEK.EndDays, DATEADD(mm, EEK.EndMonths, TEB.EndDate)) AS EndEnrollDate,
				EEK.EntityID, EEK.GapDays, EEK.Gaps, EEK.Gender, EEK.MeasEnrollID, EEK.OptionNbr,
				DATEADD(dd, EEK.PayerDays, DATEADD(mm, EEK.PayerMonths, TEB.EndDate)) AS PayerDate,
				EEK.ProductClassID
		INTO	#EntityBaseEnrollment
		FROM	Proxy.EntityBase AS TEB
				INNER JOIN Proxy.Members AS TM
						ON TEB.DSMemberID = TM.DSMemberID 
				INNER JOIN #EligibleEntities AS t
						ON TEB.EntityBaseID = T.EntityBaseID
				INNER JOIN #EntityEnrollmentKey AS EEK
						ON TEB.EntityID = EEK.EntityID
		WHERE	(TEB.RankOrder = 1) AND
				(TM.DOB BETWEEN DATEADD(dd, EEK.BeginDOBDays, DATEADD(mm, EEK.BeginDOBMonths, @SeedDate)) AND 
								DATEADD(dd, EEK.EndDOBDays, DATEADD(mm, EEK.EndDOBMonths, @SeedDate))) AND
				((EEK.Gender IS NULL) OR (TM.Gender = EEK.Gender));
		
		INSERT INTO Proxy.EntityEnrollment
				(AdminGapDays, AdminGaps, AnchorDate,
				BatchID, BeginDate, BeginDOBDate, BeginEnrollDate,
				BenefitID, BitBenefits, BitProductLines, DataRunID, DataSetID, DSMemberID, EndDate,
				EndDOBDate, EndEnrollDate,
				EnrollGroupID, EnrollItemID,
				EnrollSegBeginDate, EnrollSegEndDate,
				EntityBaseID, EntityID, GapDays, Gaps, Gender,
				MeasEnrollID, OptionNbr, PayerDate, [Priority], ProductClassID)
		SELECT DISTINCT
				t.AdminGapDays, 
				t.AdminGaps, 
				t.AnchorDate,
				@BatchID AS BatchID,
				t.BeginDate, 
				t.BeginDOBDate, 
				t.BeginEnrollDate,
				t.BenefitID, 
				TN.BitBenefits,
				TN.BitProductLines, 
				@DataRunID AS DataRunID,
				@DataSetID AS DataSetID,
				t.DSMemberID, 
				t.EndDate,
				t.EndDOBDate, 
				t.EndEnrollDate,
				TN.EnrollGroupID,
				TN.EnrollItemID,
				TN.BeginDate AS EnrollSegBeginDate,
				TN.EndDate AS EnrollSegEndDate,
				t.EntityBaseID, 
				t.EntityID,
				t.GapDays, 
				t.Gaps, 
				t.Gender,
				t.MeasEnrollID, 
				t.OptionNbr,
				t.PayerDate, 
				TN.[Priority],
				t.ProductClassID
		FROM	#EntityBaseEnrollment t
				INNER JOIN Proxy.Enrollment AS TN
						ON t.DSMemberID = TN.DSMemberID AND
							(
								(TN.BeginDate BETWEEN t.BeginEnrollDate AND t.EndDate) OR
								(TN.EndDate BETWEEN t.BeginEnrollDate AND t.EndEnrollDate) OR
								(t.BeginEnrollDate >= TN.BeginDate AND t.EndEnrollDate <= TN.EndDate)
							) AND
							TN.BitBenefits & t.BitBenefits = t.BitBenefits
				INNER JOIN Proxy.EnrollmentBenefits AS TNB
						ON TN.EnrollItemID = TNB.EnrollItemID AND
							t.BenefitID = TNB.BenefitID
				INNER JOIN Proxy.EnrollmentKey AS TNK
						ON TN.EnrollGroupID = TNK.EnrollGroupID AND
							(t.ProductClassID = 0 OR t.ProductClassID = TNK.ProductClassID)

		--This ORDER BY clause is absolutely CRITICAL, changing it will break continuous enrollment calculations by
		--altering the order of the two "quirky" UPDATEs in Batch.CalculateEntityEnrollment.  This ORDER BY ensures 
		--the rows are in the correct order when assigned their EntityEnrollIDs, the basis of the CLUSTERED INDEX
		--empowering the "quirky" UPDATE to iterate through the rows properly.
		ORDER BY EntityBaseID, MeasEnrollID, BenefitID, ProductClassID, 
				EnrollSegBeginDate, EnrollItemID

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
											--@PerformRollback = 0, --Not sure why this is here, 7/29/2016, MLK
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
GRANT EXECUTE ON  [Batch].[InitializeEntityEnrollmentByEndDateOnly] TO [Processor]
GO
