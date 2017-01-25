SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*************************************************************************************
Procedure:	prUpdatePrimKeyandIndex
Author:		Leon Dowling
Copyright:	© 2013
Date:		2013.01.01
Purpose:	
Parameters:	
Depends On:	
Calls:		
Called By:	
Returns:	
Notes:		
Process:	
Test Script:	exec [prUpdatePrimKeyandIndex] 1,1
ToDo:		
*************************************************************************************/
--/*
CREATE PROC [dbo].[prUpdatePrimKeyandIndex]

@bPrimKey BIT = 0,
@bIndex BIT = 0

AS
--*/

/*--------------------------------------
DECLARE @bPrimKey BIT = 1
DECLARE @bIndex BIT = 0
--------------------------------------*/

DECLARE @tPrimKey TABLE (RowID INT IDENTITY(1,1), TableName VARCHAR(100), PrimKeyName VARCHAR(100), KeyList VARCHAR(2000))
DECLARE @tIndexList TABLE (RowID INT IDENTITY(1,1), TableName VARCHAR(100), IndexName VARCHAR(100), KeyList VARCHAR(2000), IncludeList VARCHAR(2000))
DECLARE @vcCmd VARCHAR(2000)
DECLARE @i INT

DECLARE @tStats TABLE (StatName VARCHAR(200),StatKeys VARCHAR(400))
DECLARE @tIndex TABLE (IndexName VARCHAR(200), IndexDesc VARCHAR(200),IndexKeys VARCHAR(4000))

DECLARE @vcname VARCHAR(200),
	@vcTableName VARCHAR(200),
	@vcIndexName VARCHAR(200),
	@vcStatName VARCHAR(200)



IF @bPrimKey= 1
BEGIN

	INSERT INTO @tPrimKey SELECT 'AuthDetail','pk_AuthDetail','AuthDtlID'
	INSERT INTO @tPrimKey SELECT 'AuthHeader','pk_AuthHeader','AuthHeaderID'
	INSERT INTO @tPrimKey SELECT 'claim','pk_Claim', 'ClaimID'
	INSERT INTO @tPrimKey SELECT 'ClaimLineItem','pk_ClaimLineItem','ClaimLineItemID'
	INSERT INTO @tPrimKey SELECT 'Eligibility','pk_Eligiility','EligibilityID'
	INSERT INTO @tPrimKey SELECT 'Member','pk_Member','MemberID'
	INSERT INTO @tPrimKey SELECT 'MemberGroup','pk_membergroup','MemberGroupID'
	INSERT INTO @tPrimKey SELECT 'MemberProvider','pk_MemberProvider','MemberProviderID'
	INSERT INTO @tPrimKey SELECT 'Pharmacy','pk_Pharmacy','PharmacyID'
	INSERT INTO @tPrimKey SELECT 'PharmacyClaim','pk_PharmacyClaim','PharmacyClaimID'
	INSERT INTO @tPrimKey SELECT 'Provider','pk_Provider','ProviderID'
	INSERT INTO @tPrimKey SELECT 'ProviderMedicalGroup','pk_ProviderMedicalGroup','ProviderMedicalGroupID'
	INSERT INTO @tPrimKey SELECT 'Vendor','pk_Vendor','VendorID'

	SELECT @i = MIN(RowID)	
		FROM @tPrimKey

	WHILE @i IS NOT NULL 
	BEGIN

		SELECT @vcIndexName = PrimKeyName,
				@vcTableName = TableName,
				@vcStatName = 'sp_' + PrimKeyName
			FROM @tPrimKey
			WHERE RowID = @i 

		EXEC [usp_remove_auto_stats] @vcTableName
		
		DELETE FROM @tIndex 
		INSERT INTO @tIndex
		EXEC sp_helpindex @vcTableName

		IF NOT EXISTS (SELECT * 
						FROM @tIndex
						WHERE IndexName = @vcIndexName)
			AND NOT EXISTS (SELECT * FROM sys.sysconstraints WHERE OBJECT_NAME(id) = @vcTableName)
		BEGIN
			SELECT @vcCmd = 'ALTER TABLE ' + TableName + ' ADD CONSTRAINT ' + PrimKeyName + ' PRIMARY KEY ('+KeyList+')'
				FROM @tPrimKey
				WHERE RowID = @i 

			PRINT @vcCmd
			EXEC (@vcCmd)
		END

		DELETE FROM @tStats
		INSERT INTO @tStats
		EXEC sp_helpstats @vcTableName

		IF NOT EXISTS (SELECT * 
						FROM @tStats 
						WHERE StatName = @vcStatName)
		BEGIN

			SELECT @vcCmd = 'CREATE STATISTICS ' + @vcStatName + ' ON ' + TableName + ' (' +KeyList+')' 
				FROM @tPrimKey
				WHERE RowID = @i 

			PRINT @vcCmd
			EXEC (@vcCmd)

		END


		SELECT @i = MIN(RowID)	
			FROM @tPrimKey
			WHERE RowID > @i

	END

END


IF @bIndex = 1
BEGIN
	
	-- Claim
	INSERT INTO @tIndexList SELECT 'Claim','idxClaimMemberID','MemberID','DateServiceBegin'
	INSERT INTO @tIndexList SELECT 'Claim','idxClaimServicingProvID','ServicingProvID','DateServiceBegin'
	
	-- ClaimLineItem
	INSERT INTO @tIndexList SELECT 'ClaimLineItem','idxClaimLineItemClaimID','ClaimID','DateServiceBegin'
	INSERT INTO @tIndexList SELECT 'ClaimLineItem','idx_SorceSystemCov1','SourceSystem','AmountNetPayment,ClaimID,DatePaid,DateServiceBegin'

	-- ELigibility
	INSERT INTO @tIndexList SELECT 'Eligibility','idxEligibilityMemberID','MemberID','DateEffective, DateTerminated'

	-- BrXrefs
	INSERT INTO @tIndexList SELECT 'BrXref_Member','idxMember','MemberID',NULL

	INSERT INTO @tIndexList SELECT 'BrXref_ELigibility','idxEligibility','EligibilityID',Null
	INSERT INTO @tIndexList SELECT 'BrXref_MemberMonth','idxEligibility','EligibilityID','MonthDate,Member_month_first'
	INSERT INTO @tIndexList SELECT 'BrXref_MemberMonth','idxMemember','MemberID','MonthDate,Member_month_first'


	INSERT INTO @tIndexList SELECT 'BrXref_Claim','idxClaim','ClaimID',NULL

	INSERT INTO @tIndexList SELECT 'BrXref_ClaimLineItem','idxClaimLineItem','ClaimLineItemID',NULL

	SELECT @i = MIN(RowID)	
		FROM @tIndexList

	WHILE @i IS NOT NULL 
	BEGIN
		-- Check For Index
		SELECT @vcIndexName = IndexName ,
				@vcStatName = 'sp_' + IndexName,
				@vcTableName = TableName
			FROM @tIndexList
			WHERE RowID = @i 

		EXEC [usp_remove_auto_stats] @vcTableName

		DELETE FROM @tStats
		DELETE FROM @tIndex

		INSERT INTO @tStats
		EXEC sp_helpstats @vcTableName

		INSERT INTO @tIndex 
		EXEC sp_helpindex @vcTableName


		IF NOT EXISTS (SELECT * 
						FROM @tIndex
						WHERE IndexName = @vcIndexName
						)
		BEGIN
				
			SELECT @vcCmd = 'CREATE INDEX ' + IndexName + ' ON ' + TableName + ' (' +KeyList+')' + CASE WHEN IncludeLIst is NOT NULL THEN ' INCLUDE (' + IncludeList + ')' ELSE '' END
				FROM @tIndexList
				WHERE RowID = @i 

			PRINT @vcCmd
			EXEC (@vcCmd)

		END

		IF NOT EXISTS (SELECT * 
						FROM @tStats 
						WHERE StatName = @vcStatName)
		BEGIN

			SELECT @vcCmd = 'CREATE STATISTICS ' + @vcStatName + ' ON ' + TableName + ' (' +KeyList+')' 
				FROM @tIndexList
				WHERE RowID = @i 

			PRINT @vcCmd
			EXEC (@vcCmd)

		END
		

		SELECT @i = MIN(RowID)	
			FROM @tIndexList
			WHERE RowID > @i

	END

END



GO
GRANT VIEW DEFINITION ON  [dbo].[prUpdatePrimKeyandIndex] TO [db_ViewProcedures]
GO
