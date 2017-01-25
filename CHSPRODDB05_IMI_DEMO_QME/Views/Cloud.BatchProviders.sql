SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Cloud].[BatchProviders] AS
SELECT DISTINCT 
		B.BatchID, B.DataRunID, B.DataSetID, BI.DSProviderID
FROM	Batch.BatchProviders AS BI 
		INNER JOIN Batch.[Batches] AS B 
				ON BI.BatchID = B.BatchID	


GO
