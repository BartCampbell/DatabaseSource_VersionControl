SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Proxy].[EnrollmentKey] AS
SELECT  [BatchID],
        [DataRunID],
        [DataSetID],
        [EnrollGroupID],
        [PayerID],
        PopulationID,
		[Priority],
        [ProductClassID],
        [ProductTypeID]
FROM    Internal.[EnrollmentKey]
WHERE	(SpId = @@SPID);
GO
