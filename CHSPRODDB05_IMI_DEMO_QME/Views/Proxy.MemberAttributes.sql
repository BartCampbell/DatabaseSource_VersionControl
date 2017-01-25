SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Proxy].[MemberAttributes] AS
SELECT  [BatchID],
        [DataRunID],
        [DataSetID],
        [DSMbrAttribID],
        [DSMemberID],
        MbrAttribID
FROM    Internal.[MemberAttributes]
WHERE   (SpId = @@SPID) ;


GO
