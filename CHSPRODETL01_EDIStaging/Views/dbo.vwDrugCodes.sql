SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwDrugCodes]
AS
     SELECT
          l.InterchangeId,
          l.PositionInInterchange,
          l.TransactionSetId,
          l.ParentLoopId,
          l.LoopId,
          lx2.Definition AS DrugCodeType,
          CONVERT(VARCHAR(80),l.[03]) AS DrugCode
     FROM Interchange AS i
          INNER JOIN FunctionalGroup AS fg ON i.id = fg.InterchangeId
          INNER JOIN TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                             AND ts.InterchangeId = i.Id
          INNER JOIN LastRevLIN AS l ON i.id = l.InterchangeId
                                        AND ts.Id = l.TransactionSetId
          LEFT JOIN X12CodeList AS lx2 ON l.[02] = lx2.Code
                                          AND lx2.ElementId = 235;




GO
