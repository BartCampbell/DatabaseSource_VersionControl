SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vwQuantityInformation]
AS
     SELECT
          q.InterchangeId,
          q.PositionInInterchange,
          q.TransactionSetId,
          q.ParentLoopId,
          q.LoopId,
          qx1.Definition AS QuantityType,
          q.[02] AS Quantity
     FROM Interchange AS i
          INNER JOIN FunctionalGroup AS fg ON i.id = fg.InterchangeId
          INNER JOIN TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                             AND ts.InterchangeId = i.Id
          INNER JOIN LOOP AS l ON l.TransactionSetId = ts.Id
                                  AND l.InterchangeId = i.Id
          INNER JOIN LastRevQTY AS q ON i.id = q.InterchangeId
                                        AND ts.id = q.TransactionSetId
                                        AND l.id = q.parentloopid
          LEFT JOIN X12CodeList AS qx1 ON q.[01] = qx1.Code
                                          AND qx1.ElementId = 673;

GO
