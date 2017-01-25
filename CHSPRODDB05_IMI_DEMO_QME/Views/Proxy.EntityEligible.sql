SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Proxy].[EntityEligible] AS
SELECT  [BatchID],
		[BitProductLines],
        [DataRunID],
        [DataSetID],
        [EnrollGroupID],
        [EntityBaseID],
        LastSegBeginDate,
        LastSegEndDate
FROM    Internal.[EntityEligible]
WHERE	(SpId = @@SPID)

GO
