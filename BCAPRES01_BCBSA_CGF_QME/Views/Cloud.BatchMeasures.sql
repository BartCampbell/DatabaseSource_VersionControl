SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Cloud].[BatchMeasures]
AS
SELECT DISTINCT 
		B.BatchID, B.DataRunID, B.DataSetID, BI.MeasureID
FROM	Batch.BatchMeasures AS BI 
		INNER JOIN Batch.[Batches] AS B 
				ON BI.BatchID = B.BatchID

GO
