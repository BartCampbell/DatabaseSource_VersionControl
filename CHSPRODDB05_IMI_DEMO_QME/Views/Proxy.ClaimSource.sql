SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Proxy].[ClaimSource] AS
SELECT	BatchID,
        BeginDate,
        BitClaimAttribs,
        BitClaimSrcTypes,
        BitSpecialties,
        ClaimBeginDate,
        ClaimCompareDate,
        ClaimEndDate,
        ClaimTypeID,
        Code,
        CodeID,
        CodeTypeID,
        CompareDate,
        DataRunID,
        DataSetID,
		DataSourceID,
        [Days],
		DaysPaid,
        DOB,
        DSClaimCodeID,
        DSClaimID,
        DSClaimLineID,
        DSMemberID,
        DSProviderID,
        EndDate,
        Gender,
        IsEnrolled,
        IsLab,
        IsOnly,
        IsPaid,
        IsPositive,
        IsPrimary,
		IsSupplemental,
        LabValue,
        Qty,
        QtyDispensed,
        ServDate
FROM	Internal.ClaimSource
WHERE	(SpId = @@SPID)
GO
