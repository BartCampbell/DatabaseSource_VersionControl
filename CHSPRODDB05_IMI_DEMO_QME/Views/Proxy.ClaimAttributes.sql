SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Proxy].[ClaimAttributes] AS
SELECT  [BatchID],
        [ClaimAttribID],
        [DataRunID],
        [DataSetID],
        [DSClaimAttribID],
        [DSClaimLineID],
        [DSMemberID]
FROM    Internal.[ClaimAttributes]
WHERE	(SpId = @@SPID);






GO
