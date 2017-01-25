SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*************************************************************************************
Procedure:	prStagingProdIndex
Author:		Leon Dowling
Copyright:	© 2015
Date:		2014.01.01
Purpose:	
Parameters: 
Depends On:	
Calls:		
Called By:	
Returns:	None
Notes:		
Update Log:

Process:	
Test Script:

	exec prStagingProdIndex 
 
ToDo:		

*/

--/*
CREATE PROC [dbo].[prStagingProdIndex] 

@vcTargetSchema VARCHAR(100) = NULL,--'dbo',
@vcTargetTab VARCHAR(100) = NULL,--'ProviderMedicalGroup',
@bDebug BIT = 0

AS 
--*/

/*-------------------------------------------------------
DECLARE @vcTargetSchema VARCHAR(100) = NULL,--'dbo',
	@vcTargetTab VARCHAR(100) = NULL,--'brxref_membermonth',
	@bDebug BIT = 1
--*/-----------------------------------------------------



DECLARE @i INT,
	@vcCmd VARCHAR(MAX),
	@vcIDXName VARCHAR(1000)

DECLARE @IdxList TABLE 
	(IndexName VARCHAR(200),
	IndexDesc VARCHAR(1000),
	IndexKeys VARCHAR(2000))


DECLARE @IndexList TABLE
    (RowID INT IDENTITY(1, 1),
     TableSchema VARCHAR(50),
     TableName VARCHAR(50),
     IndexName VARCHAR(100),
     ClusteredFlag BIT,
     IndexFields VARCHAR(1000),
     IncludeFields VARCHAR(1000),
     IndexFileGroup VARCHAR(50)
    )


INSERT INTO @IndexList
SELECT TableSchema = 'dbo',
        TableName = 'Member',
        IndexName = 'actMember_PK',
        ClusteredFlag = 1,
        IndexFields = 'memberid',
		IncludeFields = 'IHDS_member_id',
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'dbo',
        TableName = 'Eligibility',
        IndexName = 'actEligibility_PK',
        ClusteredFlag = 1,
        IndexFields = 'MemberID, DateEffective, EligibilityID' ,
		IncludeFields = NULL,
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'dbo',
        TableName = 'MemberProvider',
        IndexName = 'actMemberProvider_PK',
        ClusteredFlag = 1,
        IndexFields = 'MemberID, ProviderId, DateEffective',
		IncludeFields = NULL,
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'dbo',
        TableName = 'Provider',
        IndexName = 'actProvider_PK',
        ClusteredFlag = 1,
        IndexFields = 'ProviderID',
		IncludeFields = NULL,
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'dbo',
        TableName = 'Provider ',
        IndexName = 'cidx_Provider2',
        ClusteredFlag = 0,
        IndexFields = 'ihds_prov_id',
		IncludeFields = 'ProviderID, ProviderFullName',
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'dbo',
        TableName = 'ProviderMedicalGroup',
        IndexName = 'actProviderMedicalGroup_PK',
        ClusteredFlag = 1,
        IndexFields = 'ProviderMedicalGroupID',
		IncludeFields = NULL,
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'dbo',
        TableName = 'Claim',
        IndexName = 'actClaim_PK',
        ClusteredFlag = 1,
        IndexFields = 'ClaimID,MemberID',
		IncludeFields = NULL,
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'dbo',
        TableName = 'ClaimLineItem',
        IndexName = 'actClaimLineItem_PK',
        ClusteredFlag = 1,
        IndexFields = 'ClaimID, ClaimLineItemID',
		IncludeFields = NULL,
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'dbo',
        TableName = 'ClaiMlineItem',
        IndexName = 'cidx_ClaimLineItem2',
        ClusteredFlag = 0,
        IndexFields = 'DateServiceBegin, ClaimLineItemID' ,
		IncludeFields = 'ClaimID, Client',
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'dbo',
        TableName = 'PharmacyClaim',
        IndexName = 'actPharmacyClaim_PK',
        ClusteredFlag = 1,
        IndexFields = 'MemberID, PharmacyClaimID',
		IncludeFields = NULL,
		IndexFileGroup = NULL
UNION
--SELECT TableSchema = 'dbo',
--        TableName = 'LabResult',
--        IndexName = 'cidx_LabResult',
--        ClusteredFlag = 1,
--        IndexFields = 'MemberID, LabResultID',
--		IncludeFields = NULL,
--		IndexFileGroup = NULL
--UNION
--SELECT TableSchema = 'dbo',
--        TableName = 'Employee',
--        IndexName = 'cidx_Employee',
--        ClusteredFlag = 1,
--        IndexFields = 'EmployeeID',
--		IncludeFields = NULL,
--		IndexFileGroup = NULL
--UNION
SELECT TableSchema = 'dbo',
        TableName = 'MemberGroup',
        IndexName = 'actMemberGroup_PK',
        ClusteredFlag = 1,
        IndexFields = 'MemberGroupID',
		IncludeFields = NULL,
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'dbo',
        TableName = 'Pharmacy',
        IndexName = 'actPharmacy_PK',
        ClusteredFlag = 1,
        IndexFields = 'PharmacyID',
		IncludeFields = NULL,
		IndexFileGroup = NULL
--UNION
--SELECT TableSchema = 'dbo',
--        TableName = 'Subscriber',
--        IndexName = 'cidx_Subscriber',
--        ClusteredFlag = 1,
--        IndexFields = 'SubscriberID',
--		IncludeFields = NULL,
--		IndexFileGroup = NULL
-- Xref Tables
UNION
SELECT TableSchema = 'dbo',
        TableName = 'BrXref_Claim',
        IndexName = 'actBrXref_Claim_pk',
        ClusteredFlag = 1,
        IndexFields = 'ClaimID',
		IncludeFields = NULL,
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'dbo',
        TableName = 'BrXref_ClaimLineItem',
        IndexName = 'actBrXref_ClaimLineItem_PK',
        ClusteredFlag = 1,
        IndexFields = 'ClaimLineItemID',
		IncludeFields = NULL,
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'dbo',
        TableName = 'BrXref_ClaimLineItem',
        IndexName = 'idx_Cov1',
        ClusteredFlag = 0,
        IndexFields = 'ClaimLineItemID',
		IncludeFields = 'EDVisit, IPAdmit, IPDays, OfficeVisit',
		IndexFileGroup = NULL


UNION
SELECT TableSchema = 'dbo',
        TableName = 'BrXref_Member',
        IndexName = 'actBrXref_Member_PK',
        ClusteredFlag = 1,
        IndexFields = 'MemberID',
		IncludeFields = NULL,
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'dbo',
        TableName = 'BrXref_MemberMonth',
        IndexName = 'actBrXref_MemberMonth_PK',
        ClusteredFlag = 1,
        IndexFields = 'MemberID, MonthDate, EligibilityID',
		IncludeFields = NULL,
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'dbo',
        TableName = 'BrXref_MemberMonth',
        IndexName = 'idx_MMF_Month',
        ClusteredFlag = 0,
        IndexFields = 'member_month_first, MonthDate',
		IncludeFields = 'MemberID',
		IndexFileGroup = NULL



UNION
SELECT TableSchema = 'dbo',
        TableName = 'IHDS_mara_normalized',
        IndexName = 'actIHDS_mara_normalized_PK',
        ClusteredFlag = 1,
        IndexFields = 'IHDS_Member_ID, MaraEndDate',
		IncludeFields = NULL,
		IndexFileGroup = NULL

UNION
SELECT TableSchema = 'dbo',
        TableName = 'IHDS_mara_normalized',
        IndexName = 'idx_MaraEndDate',
        ClusteredFlag = 0,
        IndexFields = 'MaraEndDate',
		IncludeFields = 'IHDS_Member_id',
		IndexFileGroup = NULL


UNION
SELECT TableSchema = 'dbo',
        TableName = 'ihds_mara_dtl',
        IndexName = 'actIHDS_mara_dtl_PK',
        ClusteredFlag = 1,
        IndexFields = 'IHDS_Member_ID, MaraEndDate, MaraModel',
		IncludeFields = NULL,
		IndexFileGroup = NULL


UNION
SELECT TableSchema = 'PCPProfile',
        TableName = 'PCPProfileHdr',
        IndexName = 'pk_PCPProfileHDR',
        ClusteredFlag = 1,
        IndexFields = 'ProviderId, MemberID',
		IncludeFields = NULL,
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'PCPProfile',
        TableName = 'PCPProfileDtl',
        IndexName = 'pk_PCPProfileDtl',
        ClusteredFlag = 1,
        IndexFields = 'ProviderId, MemberID, ServiceMonth',
		IncludeFields = NULL,
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'PCPProfile',
        TableName = 'CGFDtl',
        IndexName = 'fk_CGFDtl',
        ClusteredFlag = 0,
        IndexFields = 'ProviderID, MemberID, MeasureMetricDesc, ISCompliant',
		IncludeFields = NULL,
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'PCPProfile',
        TableName = 'CGFHDR',
        IndexName = 'fk_CGFHDR',
        ClusteredFlag = 0,
        IndexFields = 'ProviderID, MemberID',
		IncludeFields = NULL,
		IndexFileGroup = NULL
UNION
SELECT TableSchema = 'PCPProfile',
        TableName = 'MARA',
        IndexName = 'fk_MARA',
        ClusteredFlag = 0,
        IndexFields = 'ProviderID, MemberID',
		IncludeFields = NULL,
		IndexFileGroup = NULL


IF @bDebug = 1
	SELECT *
		FROM @IndexList

IF ISNULL(@vcTargetSchema,'') + ISNULL(@vcTargetTab,'') <> '' 
BEGIN

	DELETE a
		FROM @IndexList a
		WHERE TableSchema+ '.' + TableName <> ISNULL(@vcTargetSchema,'dbo')+'.'+@vcTargetTab
END

IF @bDebug = 1
	SELECT *
		FROM @IndexList

SELECT @i = MIN(RowID)
	FROM @IndexList

WHILE @i IS NOT NULL 
BEGIN

	DELETE FROM @IdxList

	SELECT @vcCmd = 'exec sp_helpindex ''' + TableSchema + '.' + TableName + '''',
			@vcIDXName = IndexName
		FROM @IndexList
		WHERE RowID = @i

	IF @bDebug = 1
		PRINT @vcCmd

	INSERT INTO @IdxList
	EXEC (@vcCmd)

	IF @bDebug = 1
		SELECT * FROM @IdxList WHERE IndexName = @vcIDXName

	IF NOT EXISTS (SELECT * FROM @IdxList WHERE IndexName = @vcIDXName)
	BEGIN
		SELECT @vcCmd = 'CREATE ' + CASE WHEN ClusteredFlag = 1 THEN 'CLUSTERED' ELSE '' END + ' INDEX ' + IndexName + CHAR(13)
						+ ' ON ' + TableSchema + '.' + TableName + CHAR(13)
						+ '(' + IndexFields + ')' + CHAR(13)
						+ CASE WHEN ClusteredFlag = 1 OR IncludeFields IS NULL THEN '' ELSE ' INCLUDE (' + IncludeFields + ')' + CHAR(13) END
						+ CASE WHEN IndexFileGroup IS NULL THEN '' ELSE ' ON (' + IndexFileGroup + ')'+ CHAR(13) END
			FROM @IndexList 
			WHERE RowID = @i
	
		IF @bDebug = 1
			PRINT @vcCmd

		EXEC (@vcCmd)

	END

	SELECT @i = MIN(RowID)
		FROM @IndexList
		WHERE RowID > @i


END

/*
-- temp build of pcpProfile indexes
--DECLARE @bDebug BIT = 1, @vcCmd VARCHAR(2000), @i INT
BEGIN
	
	DECLARE @tCmdList TABLE (RowID INT IDENTITY(1,1), SQLCmd VARCHAR(2000))
	INSERT INTO @tCmdList SELECT 'ALTER TABLE [PCPProfile].[PCPProfileHdr] ADD CONSTRAINT [pk_PCPProfileHDR] PRIMARY KEY CLUSTERED  ([ProviderID], [MemberID])'
	INSERT INTO @tCmdList SELECT 'CREATE STATISTICS [sp_pk_PCPProfileHdr] ON [PCPProfile].[PCPProfileHdr] ([ProviderID], [MemberID])'
	INSERT INTO @tCmdList SELECT 'ALTER TABLE [PCPProfile].[PCPProfileDtl] ADD CONSTRAINT [pk_PCPProfileDtl] PRIMARY KEY CLUSTERED  ([ProviderID], [MemberID], [ServiceMonth])'
	INSERT INTO @tCmdList SELECT 'CREATE STATISTICS [sp_pk_PCPProfileDtl] ON [PCPProfile].[PCPProfileDtl] ([ProviderID], [MemberID], [ServiceMonth])'

	INSERT INTO @tCmdList SELECT 'CREATE NONCLUSTERED INDEX [fk] ON [PCPProfile].[CGFDtl] ([ProviderID], [MemberID], [MeasureMetricDesc], [ISCompliant])'
	INSERT INTO @tCmdList SELECT 'CREATE STATISTICS [spfk] ON [PCPProfile].[CGFDtl] ([ProviderID], [MemberID], [MeasureMetricDesc], [ISCompliant])'

	INSERT INTO @tCmdList SELECT 'CREATE NONCLUSTERED INDEX [fk] ON [PCPProfile].[CGFHdr] ([ProviderID], [MemberID])'
	INSERT INTO @tCmdList SELECT 'CREATE STATISTICS [spfk] ON [PCPProfile].[CGFHdr] ([ProviderID], [MemberID])'

	INSERT INTO @tCmdList SELECT 'CREATE NONCLUSTERED INDEX [fk] ON [PCPProfile].[MARA] ([ProviderID], [MemberID])'
	INSERT INTO @tCmdList SELECT 'CREATE STATISTICS [spfk] ON [PCPProfile].[MARA] ([ProviderID], [MemberID])'

	SELECT @i = MIN(RowId)
		FROM @tCmdLIst
	WHILE @i IS NOT NULL 
	BEGIN
    
		SELECT @vcCmd = SQLCmd
			FROM @tCmdList
			WHERE rowid = @i

		IF @bDebug = 1
			PRINT @vcCmd

		EXEC (@vcCMd)

		SELECT @i = MIN(RowID)
			FROM @tCmdList
			WHERE RowID > @i

	END


END

*/
GO
