SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/8/2012
-- Description:	Transforms claim data from dbo.Claim/dbo.ClaimItem into the Claim.ClaimItems table and Claim.ClaimCodes. (v2)
--				(UPDATED: 10/13/2015 to incorporate some of Leon Dowling's concepts in production.)
--            Leon Update - 1/15/2017
-- =============================================
--/*
CREATE PROCEDURE [Import].[TransformEncounterClaims]
(
	@DataSetID int,
	@HedisMeasureID varchar(10) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
--*/	
--select * from batch.datasets

	--declare @DataSetID int = 1;
	--declare @HedisMeasureID varchar(10) = NULL;


	DECLARE @tRes TABLE (RowCnt INT);
	DECLARE @iMaxDiagCode INT;
	DECLARE @iMaxSurgProc INT;
	DECLARE @i INT ;

	DECLARE @DebugOutput bit = 0;

	DECLARE @CmdParam nvarchar(max);
	DECLARE @CmdSql nvarchar(max);

	BEGIN TRY;
		
		-- SET @iMaxDiagCode and @iMaxSurgProc
		BEGIN
			SET @i = 50

			WHILE @i > 0
				AND @iMaxDiagCode IS NULL
			BEGIN
				IF EXISTS (SELECT * 
							FROM INFORMATION_SCHEMA.COlumns 
							WHERE TABLE_NAME = 'Claim'
								AND TABLE_SCHEMA = 'dbo'
								AND COLUMN_NAME = 'DiagnosisCode' + CONVERT(VARCHAR(2),@i))
				BEGIN
					DELETE FROM @tRes
					SET @CmdSQl = 'SELECT COUNT(*) FROM Claim WHERE ISNULL(DiagnosisCode' + CONVERT(VARCHAR(2),@i) + ','''') <> '''''

					INSERT INTO @tRes
							(RowCnt)
					EXEC (@CmdSQL)

					IF EXISTS (SELECT 1 FROM @tRes WHERE RowCnt > 0)
						SET @iMaxDiagCode = @i
				END
		
				SET @i = @i -1

			END

			SET @i = 50

			WHILE @i > 0
				AND @iMaxSurgProc IS NULL
			BEGIN
				IF EXISTS (SELECT * 
							FROM INFORMATION_SCHEMA.COlumns 
							WHERE TABLE_NAME = 'Claim'
								AND TABLE_SCHEMA = 'dbo'
								AND COLUMN_NAME = 'SurgicalProcedure' + CONVERT(VARCHAR(2),@i))
				BEGIN
					DELETE FROM @tRes
					SET @CmdSQl = 'SELECT COUNT(*) FROM Claim WHERE ISNULL(SurgicalProcedure' + CONVERT(VARCHAR(2),@i) + ','''') <> '''''

					INSERT INTO @tRes
							(RowCnt)
					EXEC (@CmdSQL)

					IF EXISTS (SELECT 1 FROM @tRes WHERE RowCnt > 0)
						SET @iMaxSurgProc = @i
				END
		
				SET @i = @i -1

			END

			-- Add count of 1 to each
			SELECT @iMaxDiagCode = @iMaxDiagCode  + 1
			SELECT @iMaxSurgProc = @iMaxSurgProc + 1
    
		END

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
		DECLARE @CodeTypeI tinyint;
		DECLARE @CodeTypeQ tinyint;
		DECLARE @CodeTypeSuppCode tinyint;
		
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
		SELECT @CodeTypeI = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'I';
		SELECT @CodeTypeQ = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'Q';
		SELECT @CodeTypeSuppCode = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '!';

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
			DataType nvarchar(128) NOT NULL,
			[ID] smallint IDENTITY(1, 1) NOT NULL,
			IsPrimary bit NOT NULL DEFAULT (0),
			SourceColumn nvarchar(128) NOT NULL,
			SourceSchema nvarchar(128) NOT NULL,
			SourceTable nvarchar(128) NOT NULL,
			ColumnSpecificSQL VARCHAR(500)
		);
		
		WITH SourceColumns(CodeTypeID, Condition, IsPrimary, SortOrder, SourceColumn, SourceSchema, SourceTable,ColumnSpecificSQL) AS
		(
			--CPT
			SELECT	@CodeType1 AS CodeTypeID, 
					NULL AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'CPTProcedureCode' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'ClaimLineItem' AS SourceTable,
					NULL AS ColumnSpecificSQL 
			UNION
			--CPT2
			SELECT	@CodeType2 AS CodeTypeID, 
					NULL AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'CPT_II' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'ClaimLineItem' AS SourceTable,
					NULL AS ColumnSpecificSQL 
			UNION
			--CPT2, Part 2 (Potential CPT2 in the CPT field)
			SELECT	@CodeType2 AS CodeTypeID, 
					'CPTProcedureCode LIKE ''[0-9][0-9][0-9][0-9][a-z]%''' AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'CPTProcedureCode' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'ClaimLineItem' AS SourceTable,
					NULL AS ColumnSpecificSQL 
			UNION
			--CPT Modifiers
			SELECT	@CodeType0 AS CodeTypeID, 
					NULL AS Condition,
					0 AS IsPrimary, 
					N AS SortOrder,
					'CPTProcedureCodeModifier' + CONVERT(nvarchar(16), N) AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'ClaimLineItem' AS SourceTable,
					NULL AS ColumnSpecificSQL 
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
					'ClaimLineItem' AS SourceTable,
					'CASE WHEN cli.RevenueCode IS NULL THEN SPACE(0) '
						+ ' ELSE UPPER(CASE WHEN LEN(LTRIM(RTRIM(RevenueCode))) = 3 THEN CONVERT(VARCHAR(1),0) + LTRIM(RTRIM(RevenueCode)) '
						+ ' WHEN LEN(LTRIM(RTRIM(RevenueCode))) = 4 THEN NULLIF(LTRIM(RTRIM(RevenueCode)), SPACE(0)) END)'
						+ ' END ' AS ColumnSpecificSQL  
					--ELSE import.CleanUB(cli.RevenueCode) END' AS ColumnSpecificSQL 
			UNION
			--UB Type of Bill
			SELECT	@CodeTypeB AS CodeTypeID, 
					NULL AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'BillType' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable,
					'CASE WHEN BillType IS NULL THEN SPACE(0) '
						+ ' ELSE UPPER(CASE WHEN LEN(LTRIM(RTRIM(BillType))) = 3 THEN CONVERT(VARCHAR(1),0) + LTRIM(RTRIM(BillType)) '
						+ ' WHEN LEN(LTRIM(RTRIM(BillType))) = 4 THEN NULLIF(LTRIM(RTRIM(BillType)), SPACE(0)) END)'
						+ ' END ' AS ColumnSpecificSQL  
					--'CASE WHEN c.BillType IS NULL THEN '''' ELSE import.CleanUB(c.BillType) END' AS ColumnSpecificSQL 
			UNION
			--ICD-9 Diagnosis Codes
			SELECT	@CodeTypeD AS CodeTypeID, 
					'[ICDCodeType] = 9' AS Condition,
					CASE WHEN N = 1 THEN 1 ELSE 0 END AS IsPrimary, 
					N AS SortOrder,
					'DiagnosisCode' + CONVERT(nvarchar(16), N) AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable,
					NULL AS ColumnSpecificSQL 
			FROM	dbo.Tally
			WHERE	N BETWEEN 1 AND @iMaxDiagCode
			UNION
			--ICD-9 Procedure Codes
			SELECT	@CodeTypeP AS CodeTypeID, 
					'[ICDCodeType] = 9' AS Condition,
					CASE WHEN N = 1 THEN 1 ELSE 0 END AS IsPrimary, 
					N AS SortOrder,
					'SurgicalProcedure' + CONVERT(nvarchar(16), N) AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable,
					NULL AS ColumnSpecificSQL 
			FROM	dbo.Tally
			WHERE	N BETWEEN 1 AND @iMaxSurgProc
			UNION
			--ICD-10 Diagnosis Codes
			SELECT	@CodeTypeI AS CodeTypeID, 
					'[ICDCodeType] = 10' AS Condition,
					CASE WHEN N = 1 THEN 1 ELSE 0 END AS IsPrimary, 
					N AS SortOrder,
					'DiagnosisCode' + CONVERT(nvarchar(16), N) AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable,
					NULL AS ColumnSpecificSQL 
			FROM	dbo.Tally
			WHERE	N BETWEEN 1 AND @iMaxDiagCode
			UNION
			--ICD-10 Procedure Codes
			SELECT	@CodeTypeQ AS CodeTypeID, 
					'[ICDCodeType] = 10' AS Condition,
					CASE WHEN N = 1 THEN 1 ELSE 0 END AS IsPrimary, 
					N AS SortOrder,
					'SurgicalProcedure' + CONVERT(nvarchar(16), N) AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable,
					NULL AS ColumnSpecificSQL 
			FROM	dbo.Tally
			WHERE	N BETWEEN 1 AND @iMaxSurgProc
			UNION
			--CMS DRG
			SELECT	@CodeTypeC AS CodeTypeID, 
					'[DiagnosisRelatedGroupType] = ''C''' AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'DiagnosisRelatedGroup' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable,
					NULL AS ColumnSpecificSQL 
			UNION
			--MS DRG
			SELECT	@CodeTypeM AS CodeTypeID, 
					'[DiagnosisRelatedGroupType] = ''M''' AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'DiagnosisRelatedGroup' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable,
					NULL AS ColumnSpecificSQL 
			UNION
			--HCPCS
			SELECT	@CodeTypeH AS CodeTypeID, 
					NULL AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'HCPCSProcedureCode' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'ClaimLineItem' AS SourceTable,
					NULL AS ColumnSpecificSQL 
			UNION
			--HCPCS, Part 2 (Potential HCPCS in the CPT field)
			SELECT	@CodeTypeH AS CodeTypeID, 
					'CPTProcedureCode LIKE ''[a-z][0-9][0-9][0-9][0-9]%''' AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'CPTProcedureCode' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'ClaimLineItem' AS SourceTable,
					NULL AS ColumnSpecificSQL 
			UNION
			--Place of Service Code
			SELECT	@CodeTypeS AS CodeTypeID, 
					NULL AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'PlaceOfService' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable,
					NULL AS ColumnSpecificSQL 
			UNION
			--Discharge Status Code
			SELECT	@CodeTypeX AS CodeTypeID, 
					NULL AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'DischargeStatus' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable,
					NULL AS ColumnSpecificSQL 
			UNION
			--APR DRG
			SELECT	@CodeTypeA AS CodeTypeID, 
					'[DiagnosisRelatedGroupType] = ''A''' AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'DiagnosisRelatedGroup' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable,
					NULL AS ColumnSpecificSQL 
			UNION
			--Supplemental Data Code
			SELECT	@CodeTypeSuppCode AS CodeTypeID, 
					'[SupplementalDataFlag] = ''Y''' AS Condition,
					0 AS IsPrimary, 
					1 AS SortOrder,
					'SupplementalDataCode' AS SourceColumn, 
					'dbo' AS SourceSchema, 
					'Claim' AS SourceTable,
					NULL AS ColumnSpecificSQL 
		)
		INSERT INTO @CodeSource
				(CodeTypeID, Condition, DataType, IsPrimary, SourceColumn, SourceSchema, SourceTable,ColumnSpecificSQL)
		SELECT	SC.CodeTypeID, 
				SC.Condition, 
				--Borrowed from [Cloud].[GetSqlForBatchInXml]
				C.DATA_TYPE + 
						COALESCE('(' + CAST(NULLIF(C.CHARACTER_MAXIMUM_LENGTH, -1) AS nvarchar(32)) + ')', 
									'(' + CAST(NULLIF(C.NUMERIC_PRECISION, -1) AS nvarchar(32)) + ', ' + CAST(NULLIF(NULLIF(C.NUMERIC_SCALE, 0), -1) AS nvarchar(32)) + ')',
									CASE WHEN C.CHARACTER_MAXIMUM_LENGTH = -1 AND C.DATA_TYPE IN ('nvarchar','varchar') THEN '(max)' END, 
									''),
				SC.IsPrimary, 
				SC.SourceColumn, 
				SC.SourceSchema, 
				SC.SourceTable,
				ColumnSpecificSQL = CASE WHEN sc.ColumnSpecificSQL IS NULL 
										THEN 'NULLIF(LTRIM(RTRIM('
											+ CASE
												WHEN SourceSchema = 'dbo' AND SourceTable = 'Claim' THEN '[C].'
												WHEN SourceSchema = 'dbo' AND SourceTable = 'ClaimLineItem' THEN '[CLI].'
												ELSE '' 
												END
											+ sc.SourceColumn
											+ ')),'''')'
										ELSE
											sc.ColumnSpecificSQL
										END
		FROM	SourceColumns AS SC
				INNER JOIN INFORMATION_SCHEMA.COLUMNS AS C
						ON SC.SourceColumn = C.COLUMN_NAME AND
							SC.SourceSchema = C.TABLE_SCHEMA AND
							SC.SourceTable = C.TABLE_NAME
		ORDER BY CodeTypeID, SortOrder;
		
		DECLARE @AddColumnList nvarchar(MAX);
		DECLARE @ColumnList nvarchar(MAX);
		DECLARE @ColumnSQL NVARCHAR(MAX);
		--iii) Build a temp table for claims from Staging...
		SET @AddColumnList = NULL;
		SET @ColumnList = NULL;

		SELECT	@AddColumnList = ISNULL(@AddColumnList + ', ', '') + QUOTENAME(SourceColumn) + ' ' + DataType + ' NULL',
				@ColumnList = ISNULL(@ColumnList + ', ', '') + QUOTENAME(SourceColumn),
				@ColumnSQL = ISNULL(@ColumnSQL + ', ','') + QUOTENAME(SourceColumn)
							+ ' = ' + ColumnSpecificSQL
		FROM	@CodeSource
		WHERE	SourceSchema = 'dbo' AND
				SourceTable = 'Claim'
		GROUP BY SourceColumn, DataType, ColumnSpecificSQL
		ORDER BY SourceColumn;

		IF OBJECT_ID('tmp_dbo_claim') IS NOT NULL
			DROP TABLE tmp_dbo_claim;

		CREATE TABLE tmp_dbo_claim
		(
			ID bigint NOT NULL IDENTITY(1, 1),
			ClaimID int NOT NULL,
			PayerClaimID varchar(30) NULL,
			ClaimType char(1) NULL,
			ServicingProviderID int NULL,
			ihds_prov_id_servicing int NULL,
			ihds_member_id int NULL,
			MemberID int NULL,
			DataSource varchar(50) NULL,
			SupplementalDataFlag char(1) NULL,
			DiagnosisRelatedGroupType varchar(1) NULL,
			ICDCodeType tinyint NULL,
			ClaimStatus varchar(2) NULL
		) ON tmpClaim;

		SET @CmdSql = 'ALTER TABLE tmp_dbo_claim ADD ' + @AddColumnList + ';';
		EXEC sys.sp_executesql @CmdSql;

		SET @CmdSql = 'INSERT INTO tmp_dbo_claim' +
								'([ClaimID], ' +
								'[PayerClaimID], ' +
								'[ClaimType], ' +
								'[ServicingProviderID], ' +
								'[ihds_prov_id_servicing], ' +
								'[ihds_member_id], ' +
								'[MemberID], ' +
								'[DataSource], ' +
								'[SupplementalDataFlag], ' +
								'[DiagnosisRelatedGroupType], ' +
								'[ICDCodeType], ' +
								'[ClaimStatus], ' +
								@ColumnList + ')' + CHAR(13) + CHAR(10) + 
						'SELECT	[ClaimID], ' +
								'[PayerClaimID], ' +
								'[ClaimType], ' +
								'[ServicingProviderID], ' +
								'[ihds_prov_id_servicing], ' +
								'[ihds_member_id], ' +
								'[MemberID], ' +
								'[DataSource], ' +
								'[SupplementalDataFlag], ' +
								'[DiagnosisRelatedGroupType], ' +
								'[ICDCodeType], ' +
								'[ClaimStatus], ' +
								REPLACE(@ColumnSQL,'''','''''') + CHAR(13) + CHAR(10) + 
						'FROM	[dbo].[Claim] C' + CHAR(13) + CHAR(10);

		IF (@HedisMeasureID IS NOT NULL)
			SET @CmdSql = @CmdSql + 'WHERE	([HedisMeasureID] = ''' + @HedisMeasureID + ''')';

		IF @DebugOutput = 1
			BEGIN;
				PRINT '#Claim: ' + CHAR(13) + CHAR(10) + @CmdSql;
				PRINT REPLICATE('-', 60) + CHAR(13) + CHAR(10); 
			END;

		EXEC sys.sp_executesql @CmdSql;

		CREATE UNIQUE CLUSTERED INDEX PK_tmp_dbo_claim on tmp_dbo_claim (ID) ON tmpClaimNDX;
		CREATE NONCLUSTERED INDEX IX_tmp_dbo_claim on tmp_dbo_claim (ClaimID) INCLUDE (PayerClaimID, ClaimType, DischargeStatus, PlaceOfService, BillType) ON tmpClaimNDX;

		--iv) Build a temp table for claim lines from Staging...
		SET @AddColumnList = NULL;
		SET @ColumnList = NULL;
		SET @ColumnSQL = NULL;

		SELECT	@AddColumnList = ISNULL(@AddColumnList + ', ', '') + QUOTENAME(SourceColumn) + ' ' + DataType + ' NULL',
				@ColumnList = ISNULL(@ColumnList + ', ', '') + QUOTENAME(SourceColumn),
				@ColumnSQL = ISNULL(@ColumnSQL + ', ','') + QUOTENAME(SourceColumn)
							+ ' = ' + ColumnSpecificSQL
		FROM	@CodeSource
		WHERE	SourceSchema = 'dbo' AND
				SourceTable = 'ClaimLineItem'
		GROUP BY SourceColumn, DataType, ColumnSpecificSQL
		ORDER BY SourceColumn;

		IF OBJECT_ID('tmp_dbo_claimLineItem') IS NOT NULL
			DROP TABLE tmp_dbo_claimLineItem;

		CREATE TABLE tmp_dbo_claimLineItem
		(
			ID bigint NOT NULL IDENTITY(1, 1),
			ClaimID int NOT NULL,
			ClaimLineItemID int NOT NULL,
			DateServiceBegin smalldatetime NULL,
			DateServiceEnd smalldatetime NULL,
			ClaimStatus varchar(2) NULL,
			Units numeric(10, 2) NULL,
			CoveredDays numeric (10, 2) NULL,
			DataSource varchar(50) NULL,
			PlaceOfServiceCode char(2) NULL
		) ON tmpClaimLineItem;

		SET @CmdSql = 'ALTER TABLE tmp_dbo_claimLineItem ADD ' + @AddColumnList + ';';
		EXEC sys.sp_executesql @CmdSql;

		SET @CmdSql =	'INSERT INTO tmp_dbo_claimLineItem' + CHAR(13) + CHAR(10) +
								'([ClaimID], ' +
								'[ClaimLineItemID], ' +
								'[DateServiceBegin], ' +
								'[DateServiceEnd], ' +
								'[ClaimStatus], ' +
								'[Units], ' +
								'[CoveredDays], ' +
								'[DataSource], ' +
								'[PlaceOfServiceCode],' + 
								@ColumnList + ')' + CHAR(13) + CHAR(10) +
						'SELECT	[ClaimID], ' +
								'[ClaimLineItemID], ' +
								'[DateServiceBegin], ' +
								'[DateServiceEnd], ' +
								'[ClaimStatus], ' +
								'[Units], ' +
								'[CoveredDays], ' +
								'[DataSource], ' +
								'[PlaceOfServiceCode],' + 
								REPLACE(@ColumnSQL,'''','''''') + CHAR(13) + CHAR(10) +  
						'FROM	[dbo].[ClaimLineItem] CLI' + CHAR(13) + CHAR(10);

		IF (@HedisMeasureID IS NOT NULL)
			SET @CmdSql = @CmdSql + 'WHERE	([HedisMeasureID] = ''' + @HedisMeasureID + ''')';

		IF @DebugOutput = 1
			BEGIN;
				PRINT '#ClaimLineItem: ' + CHAR(13) + CHAR(10) + @CmdSql;
				PRINT REPLICATE('-', 60) + CHAR(13) + CHAR(10); 
			END;
	
		EXEC sys.sp_executesql @CmdSql;

		CREATE UNIQUE CLUSTERED INDEX PK_tmp_dbo_claimLineItem on tmp_dbo_claimLineItem (ID) ON tmpClaimLineItemNDX;
		CREATE NONCLUSTERED INDEX IX_tmp_dbo_claimLineItem on tmp_dbo_claimLineItem (ClaimID, DateServiceBegin, DateServiceEnd) INCLUDE (ClaimLineItemID, CPTProcedureCode, CPT_II, CPTProcedureCodeModifier1, CPTProcedureCodeModifier2, CPTProcedureCodeModifier3, HCPCSProcedureCode, ClaimStatus, PlaceOfServiceCode, Units) ON tmpClaimLineItemNDX;
		
		SET @CmdSql = NULL;

		--v) Build a temp table for the Members table in the engine...
		IF OBJECT_ID('tempdb..#Member_Members') IS NOT NULL
			DROP TABLE #Member_Members;

		SELECT	DSMemberID,
				IhdsMemberID,
				MemberID
		INTO	#Member_Members
		FROM	Member.Members
		WHERE	(DataSetID = @DataSetID);

		CREATE UNIQUE CLUSTERED INDEX IX_#Member_Members ON #Member_Members (IhdsMemberID, MemberID);

		--vi) Build a temp table for the Providers table in the engine...
		IF OBJECT_ID('tempdb..#Provider_Providers') IS NOT NULL
			DROP TABLE #Provider_Providers;

		SELECT	DSProviderID,
				IhdsProviderID,
				ProviderID
		INTO	#Provider_Providers
		from	Provider.Providers
		WHERE	(DataSetID = @DataSetID);

		CREATE UNIQUE CLUSTERED INDEX IX_#Provider_Providers ON #Provider_Providers (IhdsProviderID, ProviderID);

		--1a) Disable active nonclustered indexes on Claim Lines and Claim Codes
		EXEC dbo.ChangeIndexState  @DisplayMessages = 0,
									@IsEnabled = 0, 
									@TableName = N'ClaimLines',
									@TableSchema = N'Claim';

		EXEC dbo.ChangeIndexState  @DisplayMessages = 0,
									@IsEnabled = 0, 
									@TableName = N'ClaimCodes',
									@TableSchema = N'Claim';
		
		--1b) Purge Claim Code records for the specified DataSet, if any
		DELETE FROM Claim.ClaimCodes WHERE (ClaimTypeID = @ClaimTypeE) AND (DataSetID = @DataSetID);
		
		IF NOT EXISTS (SELECT TOP 1 1 FROM Claim.ClaimCodes)
			TRUNCATE TABLE Claim.ClaimCodes;
		
		
		--1c) Purge Claim Line records for the specified DataSet, if any
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
				IsSupplemental,
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
				--Changed for HEDIS 2017 per NCQA's Guideline 46 and clarified by certification via PCS
				CASE --I BLAME GEORGE!
					 WHEN /*Rev --> */ ISNULL(CLI.RevenueCode,'') <> '' OR
						  /*TOB --> */ ISNULL(C.BillType, '') <> '' OR
						  /*DRG --> */ ISNULL(C.DiagnosisRelatedGroup, '') <> ''
					 THEN @ClaimSrcTypeInst 
					 WHEN /*CPT --> */ (NULLIF(LTRIM(RTRIM(CASE WHEN LEN(CLI.CPTProcedureCode) <= 5 AND ISNUMERIC(CLI.CPTProcedureCode) = 1 THEN CLI.CPTProcedureCode END)), '') IS NOT NULL) OR 
						  /*HCPCS --> */ (NULLIF(LTRIM(RTRIM(CLI.HCPCSProcedureCode)), '') IS NOT NULL) OR
						  /*POS --> */(NULLIF(LTRIM(RTRIM(ISNULL(C.PlaceOfService, CASE WHEN ISNUMERIC(CLI.PlaceOfServiceCode) = 1 AND LEN(CLI.PlaceOfServiceCode) = 2 THEN CLI.PlaceOfServiceCode END))), '') IS NOT NULL)
					 THEN @ClaimSrcTypeProf
					 ELSE @ClaimSrcTypeDflt 
					 END,
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
							(ISNULL(CLI.CoveredDays, -1) <= 0) OR
							((CASE WHEN (ISNULL(CLI.ClaimStatus, C.ClaimStatus) IN ('1')) OR (ISNUMERIC(CLI.ClaimStatus) = 0 AND ISNULL(CLI.ClaimStatus, '') <> ''  AND CLI.ClaimStatus <> 'D') THEN 1 ELSE 0 END) = 0) --Borrowed from IsPaid field below
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
				CASE WHEN C.SupplementalDataFlag = 'Y' THEN 1 ELSE 0 END AS IsSupplemental,
				NULL AS LabValue,
				NULL AS LOINC, 
				NULL AS NDC,
				NULLIF(LTRIM(RTRIM(ISNULL(C.PlaceOfService, CASE WHEN ISNUMERIC(CLI.PlaceOfServiceCode) = 1 AND LEN(CLI.PlaceOfServiceCode) = 2 THEN CLI.PlaceOfServiceCode END))), '') AS POS,
				CASE WHEN ISNULL(CLI.Units, 1) > 2147483647 THEN 2147483647 WHEN ISNULL(CLI.Units, 1) < -2147483648 THEN -2147483648 ELSE ISNULL(CLI.Units, 1) END AS Qty,
				UPPER(CASE WHEN LEN(LTRIM(RTRIM(CLI.RevenueCode))) = 3 THEN '0' + LTRIM(RTRIM(CLI.RevenueCode)) WHEN LEN(LTRIM(RTRIM(CLI.RevenueCode))) = 4 THEN NULLIF(LTRIM(RTRIM(CLI.RevenueCode)), '') END) AS Rev,
				--Import.CleanUB(CLI.RevenueCode) AS Rev,
				CLI.DateServiceBegin AS ServDate,
				UPPER(CASE WHEN LEN(LTRIM(RTRIM(C.BillType))) = 3 THEN '0' + LTRIM(RTRIM(C.BillType)) WHEN LEN(LTRIM(RTRIM(C.BillType))) = 4 THEN NULLIF(LTRIM(RTRIM(C.BillType)), '') END) AS TOB
				--Import.CleanUB(C.BillType) AS TOB
		FROM	tmp_dbo_claim AS C
				INNER JOIN tmp_dbo_claimLineItem AS CLI
						ON C.ClaimID = CLI.ClaimID AND
							CLI.DateServiceBegin IS NOT NULL AND
							(CLI.DateServiceEnd IS NULL OR (CLI.DateServiceEnd IS NOT NULL AND CLI.DateServiceBegin <= CLI.DateServiceEnd))
				INNER JOIN #Provider_Providers AS P
						ON ISNULL(NULLIF(C.ServicingProviderID, ''), @ProviderID) = P.ProviderID AND
							ISNULL(NULLIF(C.ihds_prov_id_servicing, ''), @IhdsProviderID) = P.IhdsProviderID
				INNER JOIN #Member_Members AS M
						ON C.ihds_member_id = M.IhdsMemberID AND
							C.MemberID = M.MemberID
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
		ORDER BY CLI.ClaimID, CLI.ClaimLineItemID;
		
		--2b) Populate Encounter Claim Codes
		DECLARE @MaxID smallint;
		DECLARE @MinID smallint;
		SELECT @MaxID = MAX(ID), @MinID = MIN(ID) FROM @CodeSource;

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
										CASE WHEN CodeTypeID IN (@CodeTypeD, @CodeTypeI) THEN 'Import.CleanDiag(' ELSE '' END + 
										CASE
											WHEN SourceSchema = 'dbo' AND SourceTable = 'Claim' THEN '[C].'
											WHEN SourceSchema = 'dbo' AND SourceTable = 'ClaimLineItem' THEN '[CLI].'
											ELSE '' END +
								QUOTENAME(SourceColumn) + 
										CASE WHEN CodeTypeID IN (@CodeTypeB, @CodeTypeD, @CodeTypeI, @CodeTypeR) THEN ')' ELSE '' END + 
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
						'	FROM	tmp_dbo_claim AS C ' + @lf +
						'			INNER JOIN tmp_dbo_claimLineItem AS CLI ' + @lf +
						'					ON C.ClaimID = CLI.ClaimID ' + @lf +
						'			INNER JOIN #DSClaimLines AS CL ' + @lf +
						'					ON CLI.ClaimLineItemID = CL.ClaimLineItemID ' + @lf +
						'			INNER JOIN dbo.Tally AS T ' + @lf +
						'					ON T.N BETWEEN ' + CONVERT(nvarchar(16), @MinID) + ' AND ' + CONVERT(nvarchar(16), @MaxID) + ' ' + @lf +
						')' + @lf +
						'SELECT * FROM DSClaimCodeSource WHERE CodeTypeID IS NOT NULL AND Code IS NOT NULL ORDER BY DSClaimLineID, CodeTypeID, IsPrimary, Code; ';
		IF @DebugOutput = 1
			BEGIN;
				PRINT 'PARAMETERS: ' + CHAR(13) + CHAR(10) + @CmdParam;
				PRINT REPLICATE('-', 60) + CHAR(13) + CHAR(10);

				PRINT 'SQL: ' + CHAR(13) + CHAR(10) + @CmdSql;
				PRINT REPLICATE('-', 60);

				PRINT 'Code SQL: ' + CHAR(13) + CHAR(10) + @CaseCodeSql
				PRINT REPLICATE('-', 60) + CHAR(13) + CHAR(10);

				PRINT 'CodeType SQL: ' + CHAR(13) + CHAR(10) + @CaseCodeTypeSql
				PRINT REPLICATE('-', 60) + CHAR(13) + CHAR(10);

				PRINT 'IsPrimary SQL: ' + CHAR(13) + CHAR(10) + @CaseIsPrimarySql

				SELECT * FROM @CodeSource;
			END;

		INSERT INTO Claim.ClaimCodes
				(ClaimTypeID,
				Code,
				CodeTypeID,
				DataSetID,
				DSClaimLineID,
				DSMemberID,
				IsPrimary)
		EXEC sys.sp_executesql @CmdSql, @CmdParam, @ClaimTypeE = @ClaimTypeE, @DataSetID = @DataSetID;

		--3) Re-enable nonclustered indexes on Claim Lines and Claim Codes
		EXEC dbo.ChangeIndexState  @DisplayMessages = 0,
									@IsEnabled = 1, 
									@TableName = N'ClaimLines',
									@TableSchema = N'Claim';

		EXEC dbo.ChangeIndexState  @DisplayMessages = 0,
									@IsEnabled = 1, 
									@TableName = N'ClaimCodes',
									@TableSchema = N'Claim';

		IF @DebugOutput = 0
		BEGIN
			IF OBJECT_id('tmp_dbo_claim') IS NOT NULL 
				DROP TABLE tmp_dbo_claim
			IF OBJECT_ID('tmp_dbo_claimlineitem') is not null 
				drop table tmp_dbo_claimlineitem
			IF OBJECT_ID('tempdb..#Member_Members') IS NOT NULL
				DROP TABLE #Member_Members;
			IF OBJECT_ID('tempdb..#Provider_Providers') IS NOT NULL
				DROP TABLE #Provider_Providers;
		END



--/*
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

--*/

GO
GRANT EXECUTE ON  [Import].[TransformEncounterClaims] TO [Processor]
GO
