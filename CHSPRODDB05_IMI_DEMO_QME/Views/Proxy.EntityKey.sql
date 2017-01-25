SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Proxy].[EntityKey] AS
SELECT  [BatchID],
        [DataRunID],
        [DataSetID],
        [EntityID]
FROM    [Internal].[EntityKey]
WHERE	(SpId = @@SPID);
GO
