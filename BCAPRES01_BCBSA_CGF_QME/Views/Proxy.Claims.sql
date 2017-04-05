SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Proxy].[Claims] AS
SELECT  [BatchID],
        [BeginDate],
        [ClaimTypeID],
        [DataRunID],
        [DataSetID],
        [DSClaimID],
        [DSMemberID],
        [DSProviderID],
        [EndDate],
        [LOS],
        [POS],
        [ServDate]
FROM    Internal.[Claims]
WHERE	(SpId = @@SPID)

GO
