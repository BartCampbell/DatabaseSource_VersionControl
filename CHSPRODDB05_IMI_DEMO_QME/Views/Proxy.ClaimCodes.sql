SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Proxy].[ClaimCodes] AS
SELECT  [BatchID],
        [ClaimTypeID],
        [Code],
        [CodeID],
        [CodeTypeID],
        [DataRunID],
        [DataSetID],
        [DSClaimCodeID],
        [DSClaimID],
        [DSClaimLineID],
        [DSMemberID],
        [IsPrimary]
FROM    Internal.[ClaimCodes]
WHERE	(SpId = @@SPID)



GO
