SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/8/2012
-- Description:	Transforms claim data from dbo.Claim/dbo.ClaimItem into the Claim.ClaimItems table and Claim.ClaimCodes. (v2)
-- =============================================
CREATE PROCEDURE [Import].[TransformEncounterClaims_v2]
(
	@DataSetID int,
	@HedisMeasureID varchar(10) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;

		--i) Load preliminary variables
		DECLARE @ClaimTypeE tinyint;
		DECLARE @ClaimTypeL tinyint;
		DECLARE @ClaimTypeP tinyint;
		
		SELECT @ClaimTypeE = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'E';
		SELECT @ClaimTypeL = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'L';
		SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P';
		
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
		DECLARE @CodeTypeA tinyint;
		
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
		SELECT @CodeTypeA = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'A';
		
		--Added 12/6/2012--------------------
		DECLARE @ClaimSrcTypeDflt tinyint;
		DECLARE @ClaimSrcTypeInst tinyint;
		DECLARE @ClaimSrcTypeProf tinyint;
		
		SELECT @ClaimSrcTypeDflt = ClaimSrcTypeID FROM Claim.SourceTypes WHERE ClaimSrcTypeGuid = '17266339-5798-4b43-aac6-c25bbb8046fb';
		SELECT @ClaimSrcTypeInst = ClaimSrcTypeID FROM Claim.SourceTypes WHERE ClaimSrcTypeGuid = '755ac075-4ede-44d9-ad2d-b98fc26ede15';
		SELECT @ClaimSrcTypeProf = ClaimSrcTypeID FROM Claim.SourceTypes WHERE ClaimSrcTypeGuid = '6b38bd3f-ec89-4944-8c19-a8cbd2da20b8';
		
		--------------------------------------------------------------------------------------------
		
		DECLARE @IhdsProviderID int;
		DECLARE @ProviderID int;
				
		SELECT	@IhdsProviderID = P.ihds_prov_id,
				@ProviderID = P.ProviderID
		FROM	Batch.DataSets AS DS
				INNER JOIN dbo.Provider AS P
						ON DS.DefaultIhdsProviderID = P.ihds_prov_id
		WHERE	(DS.DataSetID = @DataSetID);
			
				
		--ii) Load the "code source" for dynamically pulling all code columns
		DECLARE @CodeSource TABLE
		(
			CodeTypeID tinyint NOT NULL,
			Condition nvarchar(1024) NULL,
			[ID] smallint IDENTITY(1, 1) NOT NULL,
			IsPrimary bit NOT NULL DEFAULT (0),
			SourceColumn nvarchar(128) NOT NULL,
			SourceSchema nvarchar(128) NOT NULL,
			SourceTable nvarchar(128) NOT NULL
		);
		
		WITH SourceColumns AS
		(
			--CPT
			SELECT	@CodeType1 AS CodeTypeID, 
					NULL AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'CPTProcedureCode' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'ClaimLineItem' AS SourceTable
			UNION
			--CPT2
			SELECT	@CodeType2 AS CodeTypeID, 
					NULL AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'CPT_II' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'ClaimLineItem' AS SourceTable
			UNION
			--CPT2, Part 2 (Potential CPT2 in the CPT field)
			SELECT	@CodeType2 AS CodeTypeID, 
					'CPTProcedureCode LIKE ''[0-9][0-9][0-9][0-9][a-z]%''' AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'CPTProcedureCode' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'ClaimLineItem' AS SourceTable
			UNION
			--CPT Modifiers
			SELECT	@CodeType0 AS CodeTypeID, 
					NULL AS Condition,
					0 AS IsPrimary, 
					N AS SortOrder,
					'CPTProcedureCodeModifier' + CONVERT(nvarchar(16), N) AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'ClaimLineItem' AS SourceTable
			FROM	dbo.Tally
			WHERE	N BETWEEN 1 AND 10
			UNION
			--UB Revenue Code
			SELECT	@CodeTypeR AS CodeTypeID, 
					NULL AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'RevenueCode' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'ClaimLineItem' AS SourceTable
			UNION
			--UB Type of Bill
			SELECT	@CodeTypeB AS CodeTypeID, 
					NULL AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'BillType' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable
			UNION
			--ICD9 Diagnosis Codes
			SELECT	@CodeTypeD AS CodeTypeID, 
					NULL AS Condition,
					CASE WHEN N = 1 THEN 1 ELSE 0 END AS IsPrimary, 
					N AS SortOrder,
					'DiagnosisCode' + CONVERT(nvarchar(16), N) AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable
			FROM	dbo.Tally
			WHERE	N BETWEEN 1 AND 50
			UNION
			--ICD9 Procedure Codes
			SELECT	@CodeTypeP AS CodeTypeID, 
					NULL AS Condition,
					CASE WHEN N = 1 THEN 1 ELSE 0 END AS IsPrimary, 
					N AS SortOrder,
					'SurgicalProcedure' + CONVERT(nvarchar(16), N) AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable
			FROM	dbo.Tally
			WHERE	N BETWEEN 1 AND 50
			UNION
			--CMS DRG
			SELECT	@CodeTypeC AS CodeTypeID, 
					'[DiagnosisRelatedGroupType] = ''C''' AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'DiagnosisRelatedGroup' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable
			UNION
			--MS DRG
			SELECT	@CodeTypeM AS CodeTypeID, 
					'[DiagnosisRelatedGroupType] = ''M''' AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'DiagnosisRelatedGroup' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable
			UNION
			--HCPCS
			SELECT	@CodeTypeH AS CodeTypeID, 
					NULL AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'HCPCSProcedureCode' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'ClaimLineItem' AS SourceTable
			UNION
			--HCPCS, Part 2 (Potential HCPCS in the CPT field)
			SELECT	@CodeTypeH AS CodeTypeID, 
					'CPTProcedureCode LIKE ''[a-z][0-9][0-9][0-9][0-9]%''' AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'CPTProcedureCode' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'ClaimLineItem' AS SourceTable
			UNION
			--Place of Service Code
			SELECT	@CodeTypeS AS CodeTypeID, 
					NULL AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'PlaceOfService' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable
			UNION
			--Discharge Status Code
			SELECT	@CodeTypeX AS CodeTypeID, 
					NULL AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'DischargeStatus' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable
			UNION
			--APR DRG
			SELECT	@CodeTypeA AS CodeTypeID, 
					'[DiagnosisRelatedGroupType] = ''A''' AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'DiagnosisRelatedGroup' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable
		)
		INSERT INTO @CodeSource
				(CodeTypeID, Condition, IsPrimary, SourceColumn, SourceSchema, SourceTable)
		SELECT	SC.CodeTypeID, SC.Condition, SC.IsPrimary, SC.SourceColumn, SC.SourceSchema, SC.SourceTable
		FROM	SourceColumns AS SC
				INNER JOIN INFORMATION_SCHEMA.COLUMNS AS C
						ON SC.SourceColumn = C.COLUMN_NAME AND
							SC.SourceSchema = C.TABLE_SCHEMA AND
							SC.SourceTable = C.TABLE_NAME
		ORDER BY CodeTypeID, SortOrder;
		
		DECLARE @MaxID smallint;
		DECLARE @MinID smallint;
		SELECT @MaxID = MAX(ID), @MinID = MIN(ID) FROM @CodeSource;
		
		
		--1a) Purge Claim Code records for the specified DataSet, if any
		DELETE FROM Claim.ClaimCodes WHERE (ClaimTypeID = @ClaimTypeE) AND (DataSetID = @DataSetID);
		
		IF NOT EXISTS (SELECT TOP 1 1 FROM Claim.ClaimCodes)
			TRUNCATE TABLE Claim.ClaimCodes;
		
		
		--1b) Purge Claim Line records for the specified DataSet, if any
		DELETE FROM Claim.ClaimLines WHERE (ClaimTypeID = @ClaimTypeE) AND (DataSetID = @DataSetID);
		
		IF NOT EXISTS (SELECT TOP 1 1 FROM Claim.ClaimLines)
			TRUNCATE TABLE Claim.ClaimLines;
		
		
		--2a) Populate Encounter Claim Lines
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
				ClaimSrcTypeID,
				ClaimTypeID,
				DataSetID,
				DataSourceID,
				DSMemberID,
				DSProviderID,
				[Days],
				[DaysPaid],
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
				NULLIF(LTRIM(RTRIM(CASE WHEN LEN(CLI.CPTProcedureCode) <= 5 AND ISNUMERIC(CLI.CPTProcedureCode) = 1 THEN CLI.CPTProcedureCode END)), '') AS CPT,
				NULLIF(LTRIM(RTRIM(CLI.CPT_II)), '') AS CPT2,
				NULLIF(LTRIM(RTRIM(CLI.CPTProcedureCodeModifier1)), '') AS CPTMod1,
				NULLIF(LTRIM(RTRIM(CLI.CPTProcedureCodeModifier2)), '') AS CPTMod2,
				NULLIF(LTRIM(RTRIM(CLI.CPTProcedureCodeModifier3)), '') AS CPTMod3,
				C.ClaimID,
				CLI.ClaimLineItemID,
				C.PayerClaimID AS ClaimNum,
				CASE C.ClaimType WHEN 'H' THEN @ClaimSrcTypeProf WHEN 'U' THEN @ClaimSrcTypeInst ELSE @ClaimSrcTypeDflt END,
				@ClaimTypeE AS ClaimTypeID,
				@DataSetID AS DataSetID,
				BDSS.DataSourceID,
				M.DSMemberID,
				P.DSProviderID,
				CASE 
					WHEN CLI.DateServiceEnd IS NOT NULL
					THEN ISNULL(NULLIF(DATEDIFF(dd, CLI.DateServiceBegin, CLI.DateServiceEnd), 0), 1)
					END AS [Days],
				CASE 
					WHEN CLI.DateServiceEnd IS NOT NULL AND 
						 (
							ISNULL(CLI.CoveredDays, -1) <= 0 OR
							ISNULL(C.ClaimStatus, '') <> '1'
						 )
					THEN 0 
					WHEN DATEDIFF(dd, CLI.DateServiceBegin, CLI.DateServiceEnd) >= CLI.CoveredDays
					THEN CLI.CoveredDays 
					ELSE ISNULL(NULLIF(DATEDIFF(dd, CLI.DateServiceBegin, CLI.DateServiceEnd), 0), 1)
					END AS [DaysPaid],
				NULLIF(LTRIM(RTRIM(C.DischargeStatus)), '') AS DischargeStatus,
				CLI.DateServiceEnd AS EndDate,
				NULLIF(LTRIM(RTRIM(CLI.HCPCSProcedureCode)), '') AS HCPCS,
				CASE WHEN (ISNULL(CLI.ClaimStatus, C.ClaimStatus) IN ('1')) OR (ISNUMERIC(CLI.ClaimStatus) = 0 AND ISNULL(CLI.ClaimStatus, '') <> ''  AND CLI.ClaimStatus <> 'D') THEN 1 ELSE 0 END AS IsPaid,
				NULL AS IsPositive,
				NULL AS LabValue,
				NULL AS LOINC, 
				NULL AS NDC,
				NULLIF(LTRIM(RTRIM(ISNULL(C.PlaceOfService, CASE WHEN ISNUMERIC(CLI.PlaceOfServiceCode) = 1 AND LEN(CLI.PlaceOfServiceCode) = 2 THEN CLI.PlaceOfServiceCode END))), '') AS POS,
				CASE WHEN ISNULL(CLI.Units, 1) > 2147483647 THEN 2147483647 WHEN ISNULL(CLI.Units, 1) < -2147483648 THEN -2147483648 ELSE ISNULL(CLI.Units, 1) END AS Qty,
				Import.CleanUB(CLI.RevenueCode) AS Rev,
				CLI.DateServiceBegin AS ServDate,
				Import.CleanUB(C.BillType) AS TOB
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
				INNER JOIN Batch.DataSetSources AS BDSS
						ON C.DataSource = BDSS.DataSource AND
							(
								(C.SupplementalDataFlag = 'Y'  AND BDSS.IsSupplemental = 1) OR
								(C.SupplementalDataFlag <> 'Y' AND BDSS.IsSupplemental = 0) OR
								(C.SupplementalDataFlag IS NULL AND BDSS.IsSupplemental = 1)                              
							) AND                
							BDSS.DataSetID = @DataSetID AND
							BDSS.SourceSchema = 'dbo' AND
							BDSS.SourceTable = 'Claim'                
		WHERE	((@HedisMeasureID IS NULL) OR (C.HedisMeasureID = @HedisMeasureID))
		ORDER BY CLI.ClaimID, CLI.ClaimLineItemID
		OPTION(OPTIMIZE FOR (@HedisMeasureID = NULL)) ;
		
		--2b) Populate Encounter Claim Codes
		DECLARE @lf nvarchar(16);
		DECLARE @tab nvarchar(16);
		
		SET @lf = CHAR(13) + CHAR(10);
		SET @tab = REPLICATE(CHAR(9), 3);
		
		DECLARE @CaseCodeSql nvarchar(max);
		DECLARE @CaseCodeTypeSql nvarchar(max);
		DECLARE @CaseIsPrimarySql nvarchar(max);
		
		SELECT	@CaseCodeSql =	ISNULL(@CaseCodeSql, @tab + 'CASE ') + @lf + @tab + 
								'	WHEN [T].[N] = ' + CONVERT(nvarchar(16), ID) + 
										ISNULL(' AND ' + 
										CASE
											WHEN SourceSchema = 'dbo' AND SourceTable = 'Claim' THEN '[C].'
											WHEN SourceSchema = 'dbo' AND SourceTable = 'ClaimLineItem' THEN '[CLI].'
											ELSE '' END + 
											Condition, '') + @lf + @tab + 
								'	THEN NULLIF(LTRIM(RTRIM(' + 
										CASE WHEN CodeTypeID IN (@CodeTypeB, @CodeTypeR) THEN 'Import.CleanUB(' ELSE '' END + 
										CASE
											WHEN SourceSchema = 'dbo' AND SourceTable = 'Claim' THEN '[C].'
											WHEN SourceSchema = 'dbo' AND SourceTable = 'ClaimLineItem' THEN '[CLI].'
											ELSE '' END +
								QUOTENAME(SourceColumn) + 
										CASE WHEN CodeTypeID IN (@CodeTypeB, @CodeTypeR) THEN ')' ELSE '' END + 
								')), '''')' +
								CASE WHEN ID = @MaxID THEN @lf + @tab + '	END' ELSE '' END,
				@CaseCodeTypeSql =	ISNULL(@CaseCodeTypeSql, @tab + 'CASE ') + @lf + @tab + 
									'	WHEN [T].[N] = ' + CONVERT(nvarchar(16), ID) + 
										ISNULL(' AND ' + 
										CASE
											WHEN SourceSchema = 'dbo' AND SourceTable = 'Claim' THEN '[C].'
											WHEN SourceSchema = 'dbo' AND SourceTable = 'ClaimLineItem' THEN '[CLI].'
											ELSE '' END + 
											Condition, '') + @lf + @tab + 
									'	THEN ' + CONVERT(nvarchar(16), CodeTypeID) +
									CASE WHEN ID = @MaxID THEN @lf + @tab + '	END' ELSE '' END,
				@CaseIsPrimarySql =	ISNULL(@CaseIsPrimarySql, @tab + 'CASE ') + @lf + @tab + 
									'	WHEN [T].[N] = ' + CONVERT(nvarchar(16), ID) + @lf + @tab + 
									'	THEN ' + CONVERT(nvarchar(16), IsPrimary) +
									CASE WHEN ID = @MaxID THEN @lf + @tab + '	END' ELSE ''END
		FROM	@CodeSource
		ORDER BY ID;
		
		DECLARE @CmdParam nvarchar(max);
		DECLARE @CmdSql nvarchar(max);
		
		SET @CmdParam = '@ClaimTypeE tinyint, @DataSetID int';
		
		SET @CmdSql =	'SELECT ClaimLineItemID, DSClaimLineID, DSMemberID INTO #DSClaimLines FROM Claim.ClaimLines WHERE DataSetID = @DataSetID; ' + @lf +
						'' + @lf +
						'CREATE UNIQUE INDEX IX_#DSClaimLines ON #DSClaimLines (ClaimLineItemID); ' + @lf +
						'' +@lf +
						'WITH DSClaimCodeSource AS ' + @lf +
						'(' + @lf +
						'	SELECT	@ClaimTypeE AS ClaimTypeID, ' + @lf +
						@CaseCodeSql + ' AS Code, ' + @lf +
						@CaseCodeTypeSql + ' AS CodeTypeID, ' + @lf +
						'			@DataSetID AS DataSetID, ' + @lf +
						'			CL.DSClaimLineID, ' + @lf +
						'			CL.DSMemberID, ' + @lf +
						@CaseIsPrimarySql + ' AS IsPrimary ' + @lf +
						'	FROM	dbo.Claim AS C ' + @lf +
						'			INNER JOIN dbo.ClaimLineItem AS CLI ' + @lf +
						'					ON C.ClaimID = CLI.ClaimID ' + @lf +
						'			INNER JOIN #DSClaimLines AS CL ' + @lf +
						'					ON CLI.ClaimLineItemID = CL.ClaimLineItemID ' + @lf +
						'			INNER JOIN dbo.Tally AS T ' + @lf +
						'					ON T.N BETWEEN ' + CONVERT(nvarchar(16), @MinID) + ' AND ' + CONVERT(nvarchar(16), @MaxID) + ' ' + @lf +
						')' + @lf +
						'SELECT * FROM DSClaimCodeSource WHERE CodeTypeID IS NOT NULL AND Code IS NOT NULL ORDER BY DSClaimLineID, CodeTypeID, IsPrimary, Code; ';
		
		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID,
				Code,
				CodeTypeID,
				DataSetID,
				DSClaimLineID,
				DSMemberID,
				IsPrimary)
		EXEC sys.sp_executesql @CmdSql, @CmdParam, @ClaimTypeE = @ClaimTypeE, @DataSetID = @DataSetID;


		RETURN 0;
	END TRY
	BEGIN CATCH;
		DECLARE @ErrApp nvarchar(128);
		DECLARE @ErrLine int;
		DECLARE @ErrLogID int;
		DECLARE @ErrMessage nvarchar(MAX);
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
GRANT VIEW DEFINITION ON  [Import].[TransformEncounterClaims_v2] TO [db_executer]
GO
GRANT EXECUTE ON  [Import].[TransformEncounterClaims_v2] TO [db_executer]
GO
GRANT EXECUTE ON  [Import].[TransformEncounterClaims_v2] TO [Processor]
GO
