SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Cloud].[BatchMembers] AS
SELECT DISTINCT
		B.BatchID, B.DataRunID, B.DataSetID, BI.DSMemberID
FROM	Batch.BatchMembers AS BI
		INNER JOIN Batch.Batches AS B
				ON BI.BatchID = B.BatchID


GO
