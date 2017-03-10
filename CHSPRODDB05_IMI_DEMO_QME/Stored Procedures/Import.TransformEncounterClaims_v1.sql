SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/24/2011
-- Description:	Transforms claim data from dbo.Claim/dbo.ClaimItem into the Claim.ClaimItems table and Claim.ClaimCodes.
-- =============================================
CREATE PROCEDURE [Import].[TransformEncounterClaims_v1]
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
		
		--------------------------------------------------------------------------------------------
		
		DECLARE @IhdsProviderID int;
		DECLARE @ProviderID int;
				
		SELECT	@IhdsProviderID = P.ihds_prov_id,
				@ProviderID = P.ProviderID
		FROM	Batch.DataSets AS DS
				INNER JOIN dbo.Provider AS P
						ON DS.DefaultIhdsProviderID = P.ihds_prov_id
		WHERE	(DS.DataSetID = @DataSetID);
				
		--Purge Claim Code records for the specified DataSet, if any
		DELETE FROM Claim.ClaimCodes WHERE (ClaimTypeID = @ClaimTypeE) AND (DataSetID = @DataSetID);
		
		IF NOT EXISTS (SELECT TOP 1 1 FROM Claim.ClaimCodes)
			TRUNCATE TABLE Claim.ClaimCodes;
		
		
		--Purge Claim Line records for the specified DataSet, if any
		DELETE FROM Claim.ClaimLines WHERE (ClaimTypeID = @ClaimTypeE) AND (DataSetID = @DataSetID);
		
		IF NOT EXISTS (SELECT TOP 1 1 FROM Claim.ClaimLines)
			TRUNCATE TABLE Claim.ClaimLines;
		
		
		--Populate Encounter Claim Lines
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
				DSMemberID,
				DSProviderID,
				[Days],
				DischargeStatus,
				EndDate,
				HCPCS,
				IsPaid,
				IsPositive,
				LabValue,
				LOINC,
				NDC,
				POS,
				Qty,
				Rev,
				ServDate,
				TOB)
		SELECT	CLI.DateServiceBegin AS BeginDate,
				NULLIF(LTRIM(RTRIM(CLI.CPTProcedureCode)), '') AS CPT,
				NULLIF(LTRIM(RTRIM(CLI.CPT_II)), '') AS CPT2,
				NULLIF(LTRIM(RTRIM(CLI.CPTProcedureCodeModifier1)), '') AS CPTMod1,
				NULLIF(LTRIM(RTRIM(CLI.CPTProcedureCodeModifier2)), '') AS CPTMod2,
				NULLIF(LTRIM(RTRIM(CLI.CPTProcedureCodeModifier3)), '') AS CPTMod3,
				C.ClaimID,
				CLI.ClaimLineItemID,
				C.PayerClaimID AS ClaimNum,
				@ClaimTypeE AS ClaimTypeID,
				@DataSetID AS DataSetID,
				M.DSMemberID,
				P.DSProviderID,
				CASE 
					WHEN CLI.DateServiceEnd IS NOT NULL --AND 
					--	 (
					--		ISNULL(CLI.CoveredDays, -1) <= 0 OR
					--		ISNULL(C.ClaimStatus, '') <> '1'
					--	 )
					--THEN 0 
					--WHEN DATEDIFF(dd, CLI.DateServiceBegin, CLI.DateServiceEnd) >= CLI.CoveredDays
					--THEN CLI.CoveredDays 
					--ELSE 
					THEN ISNULL(NULLIF(DATEDIFF(dd, CLI.DateServiceBegin, CLI.DateServiceEnd), 0), 1)
					END AS [Days],
				NULLIF(LTRIM(RTRIM(C.DischargeStatus)), '') AS DischargeStatus,
				CLI.DateServiceEnd AS EndDate,
				NULLIF(LTRIM(RTRIM(CLI.HCPCSProcedureCode)), '') AS HCPCS,
				CASE WHEN CLI.ClaimStatus = '1' /*AND ((CLI.DateServiceEnd IS NULL) OR (CLI.DateServiceEnd IS NOT NULL AND ISNULL(CLI.CoveredDays, 0) > 0))*/ THEN 1 ELSE 0 END AS IsPaid,
				NULL AS IsPositive,
				NULL AS LabValue,
				NULL AS LOINC,
				NULL AS NDC,
				NULLIF(LTRIM(RTRIM(C.PlaceOfService)), '') AS POS,
				ISNULL(CLI.Units, 1) AS Qty,
				CASE WHEN LEN(LTRIM(RTRIM(CLI.RevenueCode))) = 3 THEN '0' + LTRIM(RTRIM(CLI.RevenueCode)) ELSE NULLIF(LTRIM(RTRIM(CLI.RevenueCode)), '') END AS Rev,
				CLI.DateServiceBegin AS ServDate,
				NULLIF(LTRIM(RTRIM(C.BillType)), '') AS TOB
		FROM	dbo.Claim AS C
				INNER JOIN dbo.ClaimLineItem AS CLI
						ON C.ClaimID = CLI.ClaimID AND
							CLI.DateServiceBegin IS NOT NULL AND
							(CLI.DateServiceEnd IS NULL OR (CLI.DateServiceEnd IS NOT NULL AND CLI.DateServiceBegin <= CLI.DateServiceEnd))
				INNER JOIN Provider.Providers AS P
						ON ISNULL(NULLIF(C.ServicingProviderID, ''), @ProviderID) = P.ProviderID AND
							ISNULL(NULLIF(C.ihds_prov_id_servicing, ''), @IhdsProviderID) = P.IhdsProviderID AND
							P.DataSetID = @DataSetID 
				INNER JOIN Member.Members AS M
						ON C.ihds_member_id = M.IhdsMemberID AND
							C.MemberID = M.MemberID AND
							M.DataSetID = @DataSetID 
		WHERE	((@HedisMeasureID IS NULL) OR (C.HedisMeasureID = @HedisMeasureID))
		ORDER BY CLI.ClaimID, CLI.ClaimLineItemID
		OPTION(RECOMPILE);
		
		--ALTER INDEX ALL ON Claim.ClaimLines REBUILD;
				
		--Populate Encounter Claim Codes
		--CREATE NONCLUSTERED INDEX tmp_IX_fromTransformEncounterClaims ON dbo.ClaimLineItem (CPTProcedureCode ASC) INCLUDE (ClaimLineItemID, ClaimID);
		
		WITH Codes AS -- CPT
		(
			SELECT	CLI.CPTProcedureCode AS Code,
					@CodeType1 AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.ClaimLineItem AS CLI
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		--DROP INDEX tmp_IX_fromTransformEncounterClaims ON dbo.ClaimLineItem;
		--CREATE NONCLUSTERED INDEX tmp_IX_fromTransformEncounterClaims ON dbo.ClaimLineItem (CPT_II ASC) INCLUDE (ClaimLineItemID, ClaimID);
		
		WITH Codes AS -- CPT 2
		(
			SELECT	CLI.CPT_II AS Code,
					@CodeType2 AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.ClaimLineItem AS CLI
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND 
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		--DROP INDEX tmp_IX_fromTransformEncounterClaims ON dbo.ClaimLineItem;
		--CREATE NONCLUSTERED INDEX tmp_IX_fromTransformEncounterClaims ON dbo.ClaimLineItem (CPTProcedureCodeModifier1 ASC) INCLUDE (ClaimLineItemID, ClaimID);
		
		WITH Codes AS -- CPT Modifier 1
		(
			SELECT	CLI.CPTProcedureCodeModifier1 AS Code,
					@CodeType0 AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.ClaimLineItem AS CLI
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		--DROP INDEX tmp_IX_fromTransformEncounterClaims ON dbo.ClaimLineItem;
		--CREATE NONCLUSTERED INDEX tmp_IX_fromTransformEncounterClaims ON dbo.ClaimLineItem (CPTProcedureCodeModifier2 ASC) INCLUDE (ClaimLineItemID, ClaimID);
		
		WITH Codes AS -- CPT Modifier 2
		(
			SELECT	CLI.CPTProcedureCodeModifier2 AS Code,
					@CodeType0 AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.ClaimLineItem AS CLI
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		--DROP INDEX tmp_IX_fromTransformEncounterClaims ON dbo.ClaimLineItem;
		--CREATE NONCLUSTERED INDEX tmp_IX_fromTransformEncounterClaims ON dbo.ClaimLineItem (CPTProcedureCodeModifier3 ASC) INCLUDE (ClaimLineItemID, ClaimID);
		
		WITH Codes AS -- CPT Modifier 3
		(
			SELECT	CLI.CPTProcedureCodeModifier3 AS Code,
					@CodeType0 AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.ClaimLineItem AS CLI
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND	
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		--DROP INDEX tmp_IX_fromTransformEncounterClaims ON dbo.ClaimLineItem;
		--CREATE NONCLUSTERED INDEX tmp_IX_fromTransformEncounterClaims ON dbo.ClaimLineItem (RevenueCode ASC) INCLUDE (ClaimLineItemID, ClaimID);
		
		WITH Codes AS -- UB Revenue
		(
			SELECT	CLI.RevenueCode AS Code,
					@CodeTypeR AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.ClaimLineItem AS CLI
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND	
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				CASE LEN(LTRIM(RTRIM(Code))) WHEN 3 THEN '0' + LTRIM(RTRIM(Code)) ELSE LTRIM(RTRIM(Code)) END AS Code,
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		--DROP INDEX tmp_IX_fromTransformEncounterClaims ON dbo.ClaimLineItem;
		--CREATE NONCLUSTERED INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim (BillType ASC) INCLUDE (ClaimID);
		
		WITH Codes AS -- UB Type of Bill
		(
			SELECT	C.BillType AS Code,
					@CodeTypeB AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
							
		--DROP INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim;
		--CREATE NONCLUSTERED INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim(DiagnosisCode1 ASC) INCLUDE (ClaimID);
							
		WITH Codes AS -- ICD-9 Diagnosis 1
		(
			SELECT	C.DiagnosisCode1 AS Code,
					@CodeTypeD AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					1 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		--DROP INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim;
		--CREATE NONCLUSTERED INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim (DiagnosisCode2 ASC) INCLUDE (ClaimID);
							
		WITH Codes AS -- ICD-9 Diagnosis 2
		(
			SELECT	C.DiagnosisCode2 AS Code,
					@CodeTypeD AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
							
		--DROP INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim;
		--CREATE NONCLUSTERED INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim (DiagnosisCode3 ASC) INCLUDE (ClaimID);
							
		WITH Codes AS -- ICD-9 Diagnosis 3
		(
			SELECT	C.DiagnosisCode3 AS Code,
					@CodeTypeD AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID  AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		--DROP INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim;
		--CREATE NONCLUSTERED INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim (DiagnosisCode4 ASC) INCLUDE (ClaimID);

		WITH Codes AS -- ICD-9 Diagnosis 4
		(
			SELECT	C.DiagnosisCode4 AS Code,
					@CodeTypeD AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;

		--DROP INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim;
		--CREATE NONCLUSTERED INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim(DiagnosisCode5 ASC) INCLUDE (ClaimID);

		WITH Codes AS -- ICD-9 Diagnosis 5
		(
			SELECT	C.DiagnosisCode5 AS Code,
					@CodeTypeD AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		--DROP INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim;
		--CREATE NONCLUSTERED INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim (DiagnosisCode6 ASC) INCLUDE (ClaimID);

		WITH Codes AS -- ICD-9 Diagnosis 6
		(
			SELECT	C.DiagnosisCode6 AS Code,
					@CodeTypeD AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		--DROP INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim;
		--CREATE NONCLUSTERED INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim (DiagnosisCode7 ASC) INCLUDE (ClaimID);

		WITH Codes AS -- ICD-9 Diagnosis 7
		(
			SELECT	C.DiagnosisCode7 AS Code,
					@CodeTypeD AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		--DROP INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim;
		--CREATE NONCLUSTERED INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim (DiagnosisCode8 ASC) INCLUDE (ClaimID);

		WITH Codes AS -- ICD-9 Diagnosis 8
		(
			SELECT	C.DiagnosisCode8 AS Code,
					@CodeTypeD AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		--DROP INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim;
		--CREATE NONCLUSTERED INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim (DiagnosisCode9 ASC) INCLUDE (ClaimID);

		WITH Codes AS -- ICD-9 Diagnosis 9
		(
			SELECT	C.DiagnosisCode9 AS Code,
					@CodeTypeD AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		--DROP INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim;
		--CREATE NONCLUSTERED INDEX tmp_IX_fromTransformEncounterClaims ON dbo.Claim (DiagnosisCode10 ASC) INCLUDE (ClaimID);

		WITH Codes AS -- ICD-9 Diagnosis 10
		(
			SELECT	C.DiagnosisCode10 AS Code,
					@CodeTypeD AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		WITH Codes AS -- ICD-9 Procedure 1
		(
			SELECT	C.SurgicalProcedure1 AS Code,
					@CodeTypeP AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					1 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;

		WITH Codes AS -- ICD-9 Procedure 2
		(
			SELECT	C.SurgicalProcedure2 AS Code,
					@CodeTypeP AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		WITH Codes AS -- ICD-9 Procedure 3
		(
			SELECT	C.SurgicalProcedure3 AS Code,
					@CodeTypeP AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;

		WITH Codes AS -- ICD-9 Procedure 4
		(
			SELECT	C.SurgicalProcedure4 AS Code,
					@CodeTypeP AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		WITH Codes AS -- ICD-9 Procedure 5
		(
			SELECT	C.SurgicalProcedure5 AS Code,
					@CodeTypeP AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		WITH Codes AS -- ICD-9 Procedure 6
		(
			SELECT	C.SurgicalProcedure6 AS Code,
					@CodeTypeP AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		WITH Codes AS -- CMS DRG
		(
			SELECT	C.DiagnosisRelatedGroup AS Code,
					@CodeTypeC AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
			WHERE	C.DiagnosisRelatedGroupType = 'C'
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		WITH Codes AS -- MS DRG
		(
			SELECT	C.DiagnosisRelatedGroup AS Code,
					@CodeTypeM AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
			WHERE	C.DiagnosisRelatedGroupType = 'M'
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		WITH Codes AS -- HCPCS
		(
			SELECT	CLI.HCPCSProcedureCode AS Code,
					@CodeTypeH AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.ClaimLineItem AS CLI
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		WITH Codes AS -- POS
		(
			SELECT	C.PlaceOfService AS Code,
					@CodeTypeS AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;
		
		WITH Codes AS -- Discharge Status
		(
			SELECT	C.DischargeStatus AS Code,
					@CodeTypeX AS CodeTypeID,
					CL.DSClaimLineID,
					CL.DSMemberID,
					0 AS IsPrimary,
					ISNULL(CLI.Units, 1) AS Qty
			FROM	dbo.Claim AS C
					INNER JOIN dbo.ClaimLineItem AS CLI
							ON C.ClaimID = CLI.ClaimID
					INNER JOIN Claim.ClaimLines AS CL
							ON CLI.ClaimLineItemID = CL.ClaimLineItemID AND
								C.ClaimID = CL.ClaimID AND
								CL.DataSetID = @DataSetID 
		)
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID, Code, CodeTypeID, DataSetID, DSClaimLineID, DSMemberID, IsPrimary, Qty)
		SELECT	@ClaimTypeE AS ClaimTypeID,
				LTRIM(RTRIM(Code)) AS Code, 
				CodeTypeID, 
				@DataSetID AS DataSetID,
				DSClaimLineID, 
				DSMemberID,
				IsPrimary, 
				Qty
		FROM	Codes
		WHERE	(Code IS NOT NULL AND Code <> '')
		ORDER BY DSClaimLineID;

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
GRANT VIEW DEFINITION ON  [Import].[TransformEncounterClaims_v1] TO [db_executer]
GO
GRANT EXECUTE ON  [Import].[TransformEncounterClaims_v1] TO [db_executer]
GO
GRANT EXECUTE ON  [Import].[TransformEncounterClaims_v1] TO [Processor]
GO
