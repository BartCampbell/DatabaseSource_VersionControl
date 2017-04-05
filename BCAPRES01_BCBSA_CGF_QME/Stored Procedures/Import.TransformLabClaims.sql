SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/24/2011
-- Description:	Transforms claim data from dbo.LabResult into the Claim.ClaimItems table and Claim.ClaimCodes.
-- =============================================
CREATE PROCEDURE [Import].[TransformLabClaims]
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
		
		DECLARE @CodeType1 tinyint;
		DECLARE @CodeType2 tinyint;
		DECLARE @CodeType0 tinyint;
		DECLARE @CodeTypeR tinyint;
		DECLARE @CodeTypeB tinyint;
		DECLARE @CodeTypeD tinyint;
		DECLARE @CodeTypeP tinyint;
		DECLARE @CodeTypeC tinyint;
		DECLARE @CodeTypeM tinyint;
		DECLARE @CodeTypeH tinyint;
		DECLARE @CodeTypeS tinyint;
		DECLARE @CodeTypeX tinyint;
		DECLARE @CodeTypeN tinyint;
		DECLARE @CodeTypeL tinyint;
		DECLARE @CodeTypeT tinyint;
		DECLARE @CodeTypeV tinyint;

		SELECT @CodeType1 = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '1';
		SELECT @CodeType2 = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '2';
		SELECT @CodeType0 = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '0';
		SELECT @CodeTypeR = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'R';
		SELECT @CodeTypeB = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'B';
		SELECT @CodeTypeD = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'D';
		SELECT @CodeTypeP = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'P';
		SELECT @CodeTypeC = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'C';
		SELECT @CodeTypeM = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'M';
		SELECT @CodeTypeH = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'H';
		SELECT @CodeTypeS = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'S';
		SELECT @CodeTypeX = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'X';
		SELECT @CodeTypeN = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'N';
		SELECT @CodeTypeL = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'L';
		SELECT @CodeTypeT = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'T';
		SELECT @CodeTypeV = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'V';

		DECLARE @CodeTypeSuppCode tinyint;
		SELECT @CodeTypeSuppCode = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '!';
		
		---------------------------------------------------------------------------------------------
		
		--Disable indexes
		EXEC dbo.ChangeIndexState  @DisplayMessages = 0,
									@IsEnabled = 0, 
									@TableName = N'ClaimLines',
									@TableSchema = N'Claim';

		EXEC dbo.ChangeIndexState  @DisplayMessages = 0,
									@IsEnabled = 0, 
									@TableName = N'ClaimCodes',
									@TableSchema = N'Claim';

		
		--Purge Lab Claim Code records for the specified DataSet, if any
		DELETE FROM Claim.ClaimCodes WHERE (ClaimTypeID = @ClaimTypeL) AND (DataSetID = @DataSetID);
		
		IF NOT EXISTS (SELECT TOP 1 1 FROM Claim.ClaimCodes)
			TRUNCATE TABLE Claim.ClaimCodes;
		
		
		--Purge Lab Claim Line records for the specified DataSet, if any
		DELETE FROM Claim.ClaimLines WHERE (ClaimTypeID = @ClaimTypeL) AND (DataSetID = @DataSetID);
		
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
		IF OBJECT_ID('tempdb..#Provider_Providers') IS NOT NULL
			DROP TABLE #Provider_Providers;

		SELECT	DSProviderID,
				IhdsProviderID,
				ProviderID
		INTO	#Provider_Providers
		from	Provider.Providers
		WHERE	(DataSetID = @DataSetID);

		CREATE UNIQUE CLUSTERED INDEX IX_#Provider_Providers ON #Provider_Providers (IhdsProviderID, ProviderID);

		IF OBJECT_ID('tempdb..#DSClaimLines') IS NOT NULL
			DROP TABLE #DSClaimLines;

		CREATE TABLE #DSClaimLines
		(
			ClaimLineItemID int NOT NULL, 
			DSClaimLineID bigint NOT NULL, 
			DSMemberID bigint NOT NULL
		);

		--Populate Lab Claim Lines
		INSERT INTO Claim.ClaimLines
				(BeginDate,
				CPT,
				CPT2,
				CPTMod1,
				CPTMod2,
				CPTMod3,
				CVX, 
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
				Rev,
				ServDate,
				SNOMED,
				TOB)
		OUTPUT	INSERTED.ClaimLineItemID, INSERTED.DSClaimLineID, INSERTED.DSMemberID INTO #DSClaimLines (ClaimLineItemID, DSClaimLineID, DSMemberID)
		SELECT	ISNULL(LR.DateServiceBegin, LR.DateOfService) AS BeginDate,
				NULLIF(LTRIM(RTRIM(LR.HCPCSProcedureCode)), '') AS CPT,
				NULL AS CPT2,
				NULL AS CPTMod1,
				NULL AS CPTMod2,
				NULL AS CPTMod3,
				NULL AS CVX,
				LR.LabResultID AS ClaimID,
				LR.LabResultID AS ClaimLineItemID,
				NULL AS ClaimNum,
				@ClaimTypeL AS ClaimTypeID,
				@DataSetID AS DataSetID,
				BDSS.DataSourceID,
				M.DSMemberID,
				P.DSProviderID,
				NULL AS [Days],
				NULL AS DischargeStatus,
				ISNULL(LR.DateServiceEnd, LR.DateOfService) AS EndDate,
				NULLIF(LTRIM(RTRIM(LR.HCPCSProcedureCode)), '') AS HCPCS,
				1 AS IsPaid, --Changed to paid on 11/5/2015 for NCS
				CASE WHEN LR.PNIndicator IN ('P','Y') THEN 1 ELSE 0 END AS IsPositive,
				CASE WHEN LR.SupplementalDataFlag = 'Y' THEN 1 ELSE 0 END AS IsSupplemental,
				CASE WHEN ISNUMERIC(LR.LabValue) = 1 THEN CAST(LR.LabValue AS decimal(18,6)) END AS LabValue,
				NULLIF(LTRIM(RTRIM(LR.LOINCCode)), '') AS LOINC,
				NULL AS NDC,
				NULL AS POS,
				1 AS Qty,
				NULL AS Rev,
				LR.DateOfService  AS ServDate,
				NULLIF(LTRIM(RTRIM(LR.SNOMEDCode)), '') AS SNOMED,
				NULL AS TOB
		FROM	dbo.LabResult AS LR
				INNER JOIN #Member_Members AS M
						ON LR.MemberID = M.MemberID AND
							LR.ihds_member_id = M.IhdsMemberID AND
							LR.DateOfService IS NOT NULL AND
							(
								(LR.HCPCSProcedureCode IS NOT NULL AND LR.HCPCSProcedureCode <> '') OR
								(LR.LOINCCode IS NOT NULL AND LR.LOINCCode <> '') OR
								(LR.SupplementalDataFlag = 'Y' AND LR.SupplementalDataCode IS NOT NULL AND LR.SupplementalDataCode <> '')
							)
				LEFT OUTER JOIN #Provider_Providers AS P
						ON LR.CustomerOrderingProviderID = P.ProviderID AND
							LR.ihds_prov_id_ordering = P.IhdsProviderID
				INNER JOIN Batch.DataSetSources AS BDSS
						ON LR.DataSource = BDSS.DataSource AND
							(
								(LR.SupplementalDataFlag = 'Y'  AND BDSS.IsSupplemental = 1) OR
								(LR.SupplementalDataFlag <> 'Y' AND BDSS.IsSupplemental = 0) OR
								(LR.SupplementalDataFlag IS NULL AND BDSS.IsSupplemental = 1)                              
							) AND                
							BDSS.DataSetID = @DataSetID AND
							BDSS.SourceSchema = 'dbo' AND
							BDSS.SourceTable = 'LabResult'                          
		WHERE	((@HedisMeasureID IS NULL) OR (LR.HedisMeasureID = @HedisMeasureID))
		ORDER BY M.DSMemberID, LR.DateOfService
		OPTION(OPTIMIZE FOR (@HedisMeasureID = NULL)) ;
		

		CREATE UNIQUE CLUSTERED INDEX IX_#DSClaimLines ON #DSClaimLines (ClaimLineItemID);
				
		--Populate Lab Claim Codes
		INSERT INTO Claim.ClaimCodes --CPT
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary)
		SELECT	@ClaimTypeL AS ClaimTypeID,
				LTRIM(RTRIM(LR.HCPCSProcedureCode)) AS Code,
				@CodeType1 AS CodeType,
				@DataSetID AS DataSetID,
				CL.DSClaimLineID,
				CL.DSMemberID,
				0 AS IsPrimary
		FROM	dbo.LabResult AS LR
				INNER JOIN #Member_Members AS M
						ON LR.MemberID = M.MemberID AND
									LR.ihds_member_id = M.IhdsMemberID AND
									LR.DateOfService IS NOT NULL AND
									LR.HCPCSProcedureCode IS NOT NULL AND LR.HCPCSProcedureCode <> ''
				INNER JOIN #DSClaimLines AS CL
						ON LR.LabResultID = CL.ClaimLineItemID AND
							CL.DSMemberID = M.DSMemberID 
		ORDER BY CL.DSClaimLineID;
			
		INSERT INTO Claim.ClaimCodes --LOINC
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary)
		SELECT	@ClaimTypeL AS ClaimTypeID,
				LTRIM(RTRIM(LR.LOINCCode)) AS Code,
				@CodeTypeL AS CodeType,
				@DataSetID AS DataSetID,
				CL.DSClaimLineID,
				CL.DSMemberID,
				0 AS IsPrimary
		FROM	dbo.LabResult AS LR
				INNER JOIN #Member_Members AS M
						ON LR.MemberID = M.MemberID AND
									LR.ihds_member_id = M.IhdsMemberID AND
									LR.DateOfService IS NOT NULL AND
									LR.LOINCCode IS NOT NULL AND LR.LOINCCode <> ''
				INNER JOIN #DSClaimLines AS CL
						ON LR.LabResultID = CL.ClaimLineItemID AND
							CL.DSMemberID = M.DSMemberID			
		ORDER BY CL.DSClaimLineID;

		INSERT INTO Claim.ClaimCodes --SNOMED
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary)
		SELECT	@ClaimTypeL AS ClaimTypeID,
				LTRIM(RTRIM(LR.SNOMEDCode)) AS Code,
				@CodeTypeT AS CodeType,
				@DataSetID AS DataSetID,
				CL.DSClaimLineID,
				CL.DSMemberID,
				0 AS IsPrimary
		FROM	dbo.LabResult AS LR
				INNER JOIN #Member_Members AS M
						ON LR.MemberID = M.MemberID AND
									LR.ihds_member_id = M.IhdsMemberID AND
									LR.DateOfService IS NOT NULL AND
									LR.SNOMEDCode IS NOT NULL AND LR.SNOMEDCode <> ''
				INNER JOIN #DSClaimLines AS CL
						ON LR.LabResultID = CL.ClaimLineItemID AND
							CL.DSMemberID = M.DSMemberID			
		ORDER BY CL.DSClaimLineID;

		INSERT INTO Claim.ClaimCodes --SupplementalDataCode
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary)
		SELECT	@ClaimTypeL AS ClaimTypeID,
				LTRIM(RTRIM(LR.SupplementalDataCode)) AS Code,
				@CodeTypeSuppCode AS CodeType,
				@DataSetID AS DataSetID,
				CL.DSClaimLineID,
				CL.DSMemberID,
				0 AS IsPrimary
		FROM	dbo.LabResult AS LR
				INNER JOIN #Member_Members AS M
						ON LR.MemberID = M.MemberID AND
									LR.ihds_member_id = M.IhdsMemberID AND
									LR.DateOfService IS NOT NULL AND
									LR.SupplementalDataCode IS NOT NULL AND LR.SupplementalDataCode <> ''
				INNER JOIN #DSClaimLines AS CL
						ON LR.LabResultID = CL.ClaimLineItemID AND
							CL.DSMemberID = M.DSMemberID 
		WHERE	LR.SupplementalDataFlag = 'Y'
		ORDER BY CL.DSClaimLineID;

		--Re-enable indexes
		EXEC dbo.ChangeIndexState  @DisplayMessages = 0,
									@IsEnabled = 1, 
									@TableName = N'ClaimLines',
									@TableSchema = N'Claim';

		EXEC dbo.ChangeIndexState  @DisplayMessages = 0,
									@IsEnabled = 1, 
									@TableName = N'ClaimCodes',
									@TableSchema = N'Claim';

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
GRANT EXECUTE ON  [Import].[TransformLabClaims] TO [Processor]
GO
