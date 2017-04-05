SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Proxy].[ClaimLines] AS
SELECT  [BatchID],
        [BeginDate],
        [ClaimID],
        [ClaimLineItemID],
        [ClaimNum],
        [ClaimSrcTypeID],
        [ClaimTypeID],
        [CPT],
        [CPT2],
        [CPTMod1],
        [CPTMod2],
        [CPTMod3],
		[CVX],
        [DataRunID],
        [DataSetID],
		[DataSourceID],
        [Days],
		[DaysPaid],
        [DischargeStatus],
        [DSClaimID],
        [DSClaimLineID],
        [DSMemberID],
        [DSProviderID],
        [EndDate],
        [HCPCS],
        [IsPaid],
        [IsPositive],
		[IsSupplemental],
        [LabValue],
        [LOINC],
        [NDC],
        [POS],
        [Qty],
        [QtyDispensed],
        [Rev],
        [ServDate],
		[SNOMED],
        [TOB]
FROM    Internal.[ClaimLines]
WHERE	(SpId = @@SPID);
GO
