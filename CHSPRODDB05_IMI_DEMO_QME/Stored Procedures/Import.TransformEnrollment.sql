SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/24/2011
-- Description:	Transforms enrollment data from dbo.Eligibility into the Member.Enrollment table, as well as setting up the enrollment benefits.
-- =============================================
CREATE PROCEDURE [Import].[TransformEnrollment]
(
	@DataSetID int,
	@HedisMeasureID varchar(10) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
	
		DECLARE @DefaultEnrollDate datetime;
		SET @DefaultEnrollDate = '2079-06-06 00:00:00.000';
	
		--Purge Enrollment Benefit records for the specified DataSet, if any
		DELETE FROM Member.EnrollmentBenefits WHERE (DataSetID = @DataSetID);
		
		IF NOT EXISTS (SELECT TOP 1 1 FROM Member.EnrollmentBenefits)
			TRUNCATE TABLE Member.EnrollmentBenefits;
				
		
		--Purge Enrollment records for the specified DataSet, if any
		DELETE FROM Member.Enrollment WHERE (DataSetID = @DataSetID);

		IF NOT EXISTS (SELECT TOP 1 1 FROM Member.Enrollment)
			TRUNCATE TABLE Member.Enrollment;
			
		DECLARE @BitMedicare bigint;
		SELECT @BitMedicare = SUM(DISTINCT BitValue) FROM Product.ProductLines WITH(NOLOCK) WHERE Abbrev IN ('Q', 'R','S');

		--Populate Enrollment
		WITH PayerBitProductLines AS
		(
			SELECT	SUM(PPL.BitValue) AS BitProductLines, PPPL.PayerID
			FROM	Product.PayerProductLines AS PPPL WITH(NOLOCK)
					INNER JOIN Product.ProductLines AS PPL WITH(NOLOCK)
							ON PPPL.ProductLineID = PPL.ProductLineID
			GROUP BY PPPL.PayerID
		)      
		SELECT	MEG.Abbrev,
				P.BitProductLines,
				MIN(EnrollGroupID) AS EnrollGroupID,
				P.PayerID 
		INTO	#Groups
		FROM	Member.EnrollmentGroups AS MEG
				INNER JOIN PayerBitProductLines AS P
						ON MEG.PayerID = P.PayerID 
				INNER JOIN Member.EnrollmentPopulations AS MEP
						ON MEG.PopulationID = MEP.PopulationID
				INNER JOIN Batch.DataSets AS BDS
						ON MEP.OwnerID = BDS.OwnerID AND
							BDS.DataSetID = @DataSetID 
		GROUP BY MEG.Abbrev, P.PayerID, P.BitProductLines;

		CREATE UNIQUE CLUSTERED INDEX IX_#Groups ON #Groups (Abbrev);

		INSERT INTO Member.Enrollment
				(BeginDate, BitProductLines, DataSetID, DataSourceID, DSMemberID, EndDate, EligibilityID, EnrollGroupID, IsEmployee)
		SELECT
				ISNULL(E.DateEffective, @DefaultEnrollDate) AS BeginDate,
				MAX(CASE WHEN E.CoverageHospiceFlag = 'Y' THEN G.BitProductLines ^ @BitMedicare & G.BitProductLines ELSE G.BitProductLines END) AS BitProductLines, --Added 12/18/2013 for HEDIS 2014 and new hospice requirement (General Guideline 7)
				@DataSetID,
				MIN(BDSS.DataSourceID) AS DataSourceID,
				M.DSMemberID,
				ISNULL(E.DateTerminated, @DefaultEnrollDate) AS EndDate,
				MAX(E.EligibilityID) AS EligibilityID,
				G.EnrollGroupID,
				CASE MAX(E.HealthPlanEmployeeFlag) WHEN 'Y' THEN 1 ELSE 0 END
		FROM	dbo.Eligibility AS E
				INNER JOIN #Groups AS G		
						ON E.ProductType = G.Abbrev
				INNER JOIN Member.Members AS M
						ON E.MemberID = M.MemberID AND
							M.DataSetID = @DataSetID
				INNER JOIN Batch.DataSetSources AS BDSS
						ON E.DataSource = BDSS.DataSource AND
							BDSS.IsSupplemental = 0 AND               
							BDSS.DataSetID = @DataSetID AND
							BDSS.SourceSchema = 'dbo' AND
							BDSS.SourceTable = 'Eligibility'                          
		WHERE	((@HedisMeasureID IS NULL) OR
				(E.HedisMeasureID = @HedisMeasureID))
		GROUP BY E.DateEffective,
				M.DSMemberID,
				E.DateTerminated,
				G.EnrollGroupID
		ORDER BY M.DSMemberID, 
				E.DateEffective,
				E.DateTerminated
		OPTION(RECOMPILE);
				
		
		--Create Enrollment Benefit key
		SELECT	'Med' AS Benefit, 
				CONVERT(smallint, NULL) AS BenefitID,
				CONVERT(bigint, NULL) AS BitValue,
				ME.EnrollItemID
		INTO	#Benefits
		FROM	Member.Enrollment AS ME
				INNER JOIN Member.Members AS M
						ON ME.DSMemberID = M.DSMemberID AND
							M.DataSetID = @DataSetID 
				INNER JOIN dbo.Eligibility AS E
						ON ME.EligibilityID = E.EligibilityID
		UNION
		SELECT	'Drug' AS Benefit, 
				CONVERT(smallint, NULL) AS BenefitID,
				CONVERT(bigint, NULL) AS BitValue,
				ME.EnrollItemID
		FROM	Member.Enrollment AS ME
				INNER JOIN Member.Members AS M
						ON ME.DSMemberID = M.DSMemberID AND
							M.DataSetID = @DataSetID 		
				INNER JOIN dbo.Eligibility AS E
						ON ME.EligibilityID = E.EligibilityID AND
							E.CoveragePharmacyFlag = 'Y'
		UNION
		SELECT	'Dental' AS Benefit, 
				CONVERT(smallint, NULL) AS BenefitID,
				CONVERT(bigint, NULL) AS BitValue,
				ME.EnrollItemID
		FROM	Member.Enrollment AS ME
				INNER JOIN Member.Members AS M
						ON ME.DSMemberID = M.DSMemberID AND
							M.DataSetID = @DataSetID 
				INNER JOIN dbo.Eligibility AS E
						ON ME.EligibilityID = E.EligibilityID AND
							E.CoverageDentalFlag = 'Y'
		UNION
		SELECT	'MHInpatient' AS Benefit, 
				CONVERT(smallint, NULL) AS BenefitID,
				CONVERT(bigint, NULL) AS BitValue,
				ME.EnrollItemID
		FROM	Member.Enrollment AS ME
				INNER JOIN Member.Members AS M
						ON ME.DSMemberID = M.DSMemberID AND
							M.DataSetID = @DataSetID 
				INNER JOIN dbo.Eligibility AS E
						ON ME.EligibilityID = E.EligibilityID AND
							E.CoverageMHInpatientFlag = 'Y'
		UNION
		SELECT	'MHDayNight' AS Benefit, 
				CONVERT(smallint, NULL) AS BenefitID,
				CONVERT(bigint, NULL) AS BitValue,
				ME.EnrollItemID
		FROM	Member.Enrollment AS ME
				INNER JOIN Member.Members AS M
						ON ME.DSMemberID = M.DSMemberID AND
							M.DataSetID = @DataSetID 
				INNER JOIN dbo.Eligibility AS E
						ON ME.EligibilityID = E.EligibilityID AND
							E.CoverageMHDayNightFlag = 'Y'
		UNION
		SELECT	'MHOutpatient' AS Benefit, 
				CONVERT(smallint, NULL) AS BenefitID,
				CONVERT(bigint, NULL) AS BitValue,
				ME.EnrollItemID
		FROM	Member.Enrollment AS ME
				INNER JOIN Member.Members AS M
						ON ME.DSMemberID = M.DSMemberID AND
							M.DataSetID = @DataSetID 
				INNER JOIN dbo.Eligibility AS E
						ON ME.EligibilityID = E.EligibilityID AND
							E.CoverageMHAmbulatoryFlag = 'Y'
				UNION
		SELECT	'CDInpatient' AS Benefit, 
				CONVERT(smallint, NULL) AS BenefitID,
				CONVERT(bigint, NULL) AS BitValue,
				ME.EnrollItemID
		FROM	Member.Enrollment AS ME
				INNER JOIN Member.Members AS M
						ON ME.DSMemberID = M.DSMemberID AND
							M.DataSetID = @DataSetID 
				INNER JOIN dbo.Eligibility AS E
						ON ME.EligibilityID = E.EligibilityID AND
							E.CoverageCDInpatientFlag = 'Y'
		UNION
		SELECT	'CDDayNight' AS Benefit, 
				CONVERT(smallint, NULL) AS BenefitID,
				CONVERT(bigint, NULL) AS BitValue,
				ME.EnrollItemID
		FROM	Member.Enrollment AS ME
				INNER JOIN Member.Members AS M
						ON ME.DSMemberID = M.DSMemberID AND
							M.DataSetID = @DataSetID 
				INNER JOIN dbo.Eligibility AS E
						ON ME.EligibilityID = E.EligibilityID AND
							E.CoverageCDDayNightFlag = 'Y'
		UNION
		SELECT	'CDOutpatient' AS Benefit, 
				CONVERT(smallint, NULL) AS BenefitID,
				CONVERT(bigint, NULL) AS BitValue,
				ME.EnrollItemID
		FROM	Member.Enrollment AS ME
				INNER JOIN Member.Members AS M
						ON ME.DSMemberID = M.DSMemberID AND
							M.DataSetID = @DataSetID 
				INNER JOIN dbo.Eligibility AS E
						ON ME.EligibilityID = E.EligibilityID AND
							E.CoverageCDAmbulatoryFlag = 'Y'
		UNION
		SELECT	'Hosp' AS Benefit, 
				CONVERT(smallint, NULL) AS BenefitID,
				CONVERT(bigint, NULL) AS BitValue,
				ME.EnrollItemID
		FROM	Member.Enrollment AS ME
				INNER JOIN Member.Members AS M
						ON ME.DSMemberID = M.DSMemberID AND
							M.DataSetID = @DataSetID 
				INNER JOIN dbo.Eligibility AS E
						ON ME.EligibilityID = E.EligibilityID AND
							E.CoverageHospiceFlag = 'Y'

		CREATE UNIQUE CLUSTERED INDEX IX_#Benefits ON #Benefits (EnrollItemID, Benefit);
		CREATE INDEX IX_#Benefits_Benefit ON #Benefits (Benefit);
		
		UPDATE	t
		SET		BenefitID = PB.BenefitID,
				BitValue = PB.BitValue
		FROM	#Benefits AS t
				INNER JOIN Product.Benefits AS PB
						ON t.Benefit = PB.Abbrev
						
		DROP INDEX IX_#Benefits_Benefit ON #Benefits;
		
		--Populate Enrollment Benefits
		INSERT INTO Member.EnrollmentBenefits
				(BenefitID, DataSetID, EnrollItemID)
		SELECT	B.BenefitID, @DataSetID, t.EnrollItemID 
		FROM	#Benefits AS t
				INNER JOIN Product.Benefits AS B
						ON T.Benefit = B.Abbrev;
						

		--Update Enrollment BitBenefits
		SELECT	SUM(DISTINCT BitValue) AS BitBenefits, 
				EnrollItemID 
		INTO	#BenefitsBitWise
		FROM	#Benefits 
		GROUP BY EnrollItemID;
		
		CREATE UNIQUE INDEX IX_#BenefitsBitWise ON #BenefitsBitWise (EnrollItemID);

		UPDATE	MN
		SET		BitBenefits = t.BitBenefits
		FROM	Member.Enrollment AS MN
				INNER JOIN #BenefitsBitWise AS t
						ON MN.EnrollItemID = t.EnrollItemID;

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
GRANT EXECUTE ON  [Import].[TransformEnrollment] TO [Processor]
GO
