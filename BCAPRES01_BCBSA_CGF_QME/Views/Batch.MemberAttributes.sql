SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Batch].[MemberAttributes] AS
SELECT	B.BatchID,
		B.DataRunID,
		MMA.DataSetID, 
		MMA.DSMbrAttribID, 
		MMA.DSMemberID, 
		MAC.Descr AS MbrAttribCtgyDescr, 
		MA.MbrAttribCtgyID,
		MMA.MbrAttribID
FROM	Member.MemberAttributes AS MMA
		INNER JOIN Member.Attributes AS MA
				ON MMA.MbrAttribID = MA.MbrAttribID
		INNER JOIN Member.AttributeCategories AS MAC
				ON MA.MbrAttribCtgyID = MAC.MbrAttribCtgyID
		INNER JOIN Batch.[Batches] AS B
				ON MMA.DataSetID = B.DataSetID
		INNER JOIN Batch.BatchMembers AS BBM
				ON BBM.BatchID = B.BatchID AND
					BBM.DSMemberID = MMA.DSMemberID
GO
