SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [dbo].[vwTransactionSetPurpose_BHT]
AS
SELECT
     i.Id AS InterchangeID,
	ts.Id AS TransactionSetID,
     bx1.Definition AS HierarchStructCode,
     bx2.Definition AS TransmissionPurpose,
	CONVERT(VARCHAR(80),b.[03]) AS ReferenceIdent,
	b.[04] AS TransactionDate,
	CONVERT(VARCHAR(8),b.[05]) AS TransactionTime,
	bx6.Definition AS TransactionPurpose
FROM  Interchange AS i
      INNER JOIN FunctionalGroup AS fg ON i.id = fg.InterchangeId
      INNER JOIN TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                         AND ts.InterchangeId = i.Id
      INNER JOIN LastRevBHT AS b ON b.InterchangeId = i.Id AND b.TransactionSetId = ts.Id
      LEFT JOIN X12CodeList AS bx1 ON b.[01] = bx1.Code
                                      AND bx1.ElementId = 1005
	 LEFT JOIN X12CodeList AS bx2 ON b.[02] = bx2.Code
                                      AND bx2.ElementId = 353
	 LEFT JOIN X12CodeList AS bx6 ON b.[06] = bx6.Code
                                      AND bx6.ElementId = 640



GO
