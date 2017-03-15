SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [dbo].[vwRemainingPatientLiability]
AS
SELECT
     i.Id AS InterchangeID,
	ts.Id AS TransactionSetID,
     ax1.Definition AS AmountCode,
     a.[02] AS Amount
FROM  Interchange AS i
      INNER JOIN FunctionalGroup AS fg ON i.id = fg.InterchangeId
      INNER JOIN TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                         AND ts.InterchangeId = i.Id
      INNER JOIN LastRevAMT AS a ON a.InterchangeId = i.Id AND a.TransactionSetId = ts.Id
      LEFT JOIN X12CodeList AS ax1 ON a.[01] = ax1.Code
                                      AND ax1.ElementId = 522


GO
