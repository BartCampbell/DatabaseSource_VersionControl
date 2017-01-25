SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/24/2011
-- Description:	Transforms claim data from dbo.PharmacyClaim into the Claim.ClaimItems table and Claim.ClaimCodes.
-- =============================================
CREATE PROCEDURE [Import].[TransformPharmacyClaims]
(
	@DataSetID int,
	@HedisMeasureID varchar(10) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
		
		DECLARE @ClaimTypeE tinyint
		DECLARE @ClaimTypeL tinyint
		DECLARE @ClaimTypeP tinyint
		
		SELECT @ClaimTypeE = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'E'
		SELECT @ClaimTypeL = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'L'
		SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P'
		
		DECLARE @CodeType1 tinyint
		DECLARE @CodeType2 tinyint
		DECLARE @CodeType0 tinyint
		DECLARE @CodeTypeR tinyint
		DECLARE @CodeTypeB tinyint
		DECLARE @CodeTypeD tinyint
		DECLARE @CodeTypeP tinyint
		DECLARE @CodeTypeC tinyint
		DECLARE @CodeTypeM tinyint
		DECLARE @CodeTypeH tinyint
		DECLARE @CodeTypeS tinyint
		DECLARE @CodeTypeX tinyint
		DECLARE @CodeTypeN tinyint
		DECLARE @CodeTypeL tinyint
		
		SELECT @CodeType1 = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '1'
		SELECT @CodeType2 = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '2'
		SELECT @CodeType0 = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '0'
		SELECT @CodeTypeR = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'R'
		SELECT @CodeTypeB = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'B'
		SELECT @CodeTypeD = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'D'
		SELECT @CodeTypeP = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'P'
		SELECT @CodeTypeC = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'C'
		SELECT @CodeTypeM = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'M'
		SELECT @CodeTypeH = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'H'
		SELECT @CodeTypeS = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'S'
		SELECT @CodeTypeX = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'X'
		SELECT @CodeTypeN = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'N'
		SELECT @CodeTypeL = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'L'

		DECLARE @CodeTypeSuppCode tinyint;
		SELECT @CodeTypeSuppCode = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '!';
		
		--Disable indexes
		EXEC dbo.ChangeIndexState  @DisplayMessages = 0,
									@IsEnabled = 0, 
									@TableName = N'ClaimLines',
									@TableSchema = N'Claim';

		EXEC dbo.ChangeIndexState  @DisplayMessages = 0,
									@IsEnabled = 0, 
									@TableName = N'ClaimCodes',
									@TableSchema = N'Claim';

		--Purge Existing Pharmacy Claim Codes for the specified DataSet, if any
		DELETE	CC 
		FROM	Claim.ClaimCodes AS CC
				--INNER JOIN Claim.ClaimLines AS CL
				--		ON CC.DSClaimLineID = CL.DSClaimLineID
		WHERE	(CC.ClaimTypeID = @ClaimTypeP) AND
				--(CL.ClaimTypeID = @ClaimTypeP) AND
				(CC.DataSetID = @DataSetID) --AND
				--(CL.DataSetID = @DataSetID);
				
		IF NOT EXISTS (SELECT TOP 1 1 FROM Claim.ClaimCodes)
			TRUNCATE TABLE Claim.ClaimCodes;
		
		
		--Purge Existing Pharmacy Claim Codes for the specified DataSet, if any		
		DELETE FROM Claim.ClaimLines WHERE ClaimTypeID = @ClaimTypeP AND DataSetID = @DataSetID;
		
		IF NOT EXISTS (SELECT TOP 1 1 FROM Claim.ClaimLines)
			TRUNCATE TABLE Claim.ClaimLines;
		
		--Build a temp table for the Members table in the engine...
		IF OBJECT_ID('tempdb..#Member_Members') IS NOT NULL
			DROP TABLE #Member_Members;

		SELECT	DSMemberID,
				IhdsMemberID,
				MemberID
		INTO	#Member_Members
		FROM	Member.Members
		WHERE	(DataSetID = @DataSetID);

		CREATE UNIQUE CLUSTERED INDEX IX_#Member_Members ON #Member_Members (IhdsMemberID, MemberID);

		--Build a temp table for the Providers table in the engine...
		/*
		IF OBJECT_ID('tempdb..#Provider_Providers') IS NOT NULL
			DROP TABLE #Provider_Providers;

		SELECT	DSProviderID,
				IhdsProviderID,
				ProviderID
		INTO	#Provider_Providers
		from	Provider.Providers
		WHERE	(DataSetID = @DataSetID);

		CREATE UNIQUE CLUSTERED INDEX IX_#Provider_Providers ON #Provider_Providers (IhdsProviderID, ProviderID);
		*/

		IF OBJECT_ID('tempdb..#DSClaimLines') IS NOT NULL
			DROP TABLE #DSClaimLines;

		CREATE TABLE #DSClaimLines
		(
			ClaimLineItemID int NOT NULL, 
			DSClaimLineID bigint NOT NULL, 
			DSMemberID bigint NOT NULL
		);
		
		--Populate Pharmacy Claim Lines------------------------------------------------------------------------
		INSERT INTO Claim.ClaimLines
				(BeginDate,
				CPT,
				CPT2,
				CPTMod1,
				CPTMod2,
				CPTMod3,
				ClaimID,
				ClaimLineItemID,
				ClaimNum,
				ClaimTypeID,
				DataSetID,
				DataSourceID,
				DSMemberID,
				DSProviderID,
				[Days],
				DischargeStatus,
				EndDate,
				HCPCS,
				IsPaid,
				IsPositive,
				IsSupplemental,
				LabValue,
				LOINC,
				NDC,
				POS,
				Qty,
				QtyDispensed,
				Rev,
				ServDate,
				TOB)
		OUTPUT	INSERTED.ClaimLineItemID, INSERTED.DSClaimLineID, INSERTED.DSMemberID INTO #DSClaimLines (ClaimLineItemID, DSClaimLineID, DSMemberID)
		SELECT	PC.DateDispensed AS BeginDate,
				NULL AS CPT,
				NULL AS CPT2,
				NULL AS CPTMod1,
				NULL AS CPTMod2,
				NULL AS CPTMod3,
				PC.PharmacyClaimID AS ClaimID,
				PC.PharmacyClaimID AS ClaimLineItemID,
				PC.ClaimNumber AS ClaimNum,
				@ClaimTypeP AS ClaimTypeID,
				@DataSetID AS DataSetID,
				BDSS.DataSourceID, 
				M.DSMemberID,
				NULL AS DSProviderID,
				CASE 
					WHEN PC.DaysSupply IS NULL OR 
						PC.DaysSupply < 1 OR 
						PC.DaysSupply > 730 
					THEN NULL 
					ELSE PC.DaysSupply 
				END AS [Days],
				NULL AS DischargeStatus,
				CASE 
					WHEN PC.DaysSupply IS NOT NULL AND 
						PC.DaysSupply > 0 AND 
						PC.DaysSupply <= 730 AND 
						PC.DateDispensed IS NOT NULL 
					THEN DATEADD(day, PC.DaysSupply - 1, PC.DateDispensed) 
				END AS EndDate,
				NULL AS HCPCS,
				CASE WHEN PC.ClaimStatus = '1' OR (ISNUMERIC(PC.ClaimStatus) = 0 AND ISNULL(PC.ClaimStatus, '') <> '' AND PC.ClaimStatus <> 'D') THEN 1 ELSE 0 END AS IsPaid,
				NULL AS IsPositive,
				CASE WHEN PC.SupplementalDataFlag = 'Y' THEN 1 ELSE 0 END AS IsSupplemental,
				NULL AS LabValue,
				NULL AS LOINC,
				LTRIM(RTRIM(PC.NDC)) AS NDC,
				NULL AS POS,
				CASE WHEN PC.Quantity > 2147483647 THEN 2147483647 WHEN PC.Quantity < -2147483648 THEN -2147483648 ELSE PC.Quantity END AS Qty,
				PC.QuantityDispensed AS QtyDispensed,
				NULL AS Rev,
				PC.DateDispensed AS ServDate,
				NULL AS TOB
		FROM	dbo.PharmacyClaim AS PC
				INNER JOIN #Member_Members AS M
						ON PC.MemberID = M.MemberID AND
							PC.ihds_member_id = M.IhdsMemberID AND
							PC.DateDispensed IS NOT NULL AND
							(
								(
									(PC.NDC IS NOT NULL) AND
									(PC.NDC <> '')
								) OR
								(
									(PC.SupplementalDataFlag = 'Y') AND
									(PC.SupplementalDataCode IS NOT NULL) AND
									(PC.SupplementalDataCode <> '')
								)
							)
				INNER JOIN Batch.DataSetSources AS BDSS
						ON PC.DataSource = BDSS.DataSource AND
							(
								(PC.SupplementalDataFlag = 'Y'  AND BDSS.IsSupplemental = 1) OR
								(PC.SupplementalDataFlag <> 'Y' AND BDSS.IsSupplemental = 0) OR
								(PC.SupplementalDataFlag IS NULL AND BDSS.IsSupplemental = 1)                              
							) AND                
							BDSS.DataSetID = @DataSetID AND
							BDSS.SourceSchema = 'dbo' AND
							BDSS.SourceTable = 'PharmacyClaim'                          
		WHERE	((@HedisMeasureID IS NULL) OR (PC.HedisMeasureID = @HedisMeasureID))
		ORDER BY M.DSMemberID, PC.DateDispensed
		OPTION(OPTIMIZE FOR (@HedisMeasureID = NULL)) ;
	
		CREATE UNIQUE CLUSTERED INDEX IX_#DSClaimLines ON #DSClaimLines (ClaimLineItemID);

		
		--Populate Pharmacy Claim Codes
		INSERT INTO Claim.ClaimCodes --NDC
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary)
		SELECT	@ClaimTypeP,
				LTRIM(RTRIM(PC.NDC)) AS Code,
				@CodeTypeN AS CodeTypeID,
				@DataSetID AS DataSetID,
				CL.DSClaimLineID,
				CL.DSMemberID,
				0 AS IsPrimary
		FROM	dbo.PharmacyClaim AS PC
				INNER JOIN #DSClaimLines AS CL
						ON PC.PharmacyClaimID = CL.ClaimLineItemID AND
							PC.NDC IS NOT NULL AND
							PC.NDC <> ''
		ORDER BY CL.DSClaimLineID;

		INSERT INTO Claim.ClaimCodes --Supplemental Data Code
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary)
		SELECT	@ClaimTypeP,
				LTRIM(RTRIM(PC.SupplementalDataCode)) AS Code,
				@CodeTypeSuppCode AS CodeTypeID,
				@DataSetID AS DataSetID,
				CL.DSClaimLineID,
				CL.DSMemberID,
				0 AS IsPrimary
		FROM	dbo.PharmacyClaim AS PC
				INNER JOIN #DSClaimLines AS CL
						ON PC.PharmacyClaimID = CL.ClaimLineItemID AND
							PC.SupplementalDataCode IS NOT NULL AND
							PC.SupplementalDataCode <> ''
		WHERE	PC.SupplementalDataFlag = 'Y'
		ORDER BY CL.DSClaimLineID;

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
GRANT EXECUTE ON  [Import].[TransformPharmacyClaims] TO [Processor]
GO
