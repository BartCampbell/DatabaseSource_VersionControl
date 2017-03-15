SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwClaimDates]
AS
     SELECT
          i.Id AS InterchangeID,
          ts.Id AS TransactionSetID,
		d.PositionInInterchange,
		d.ParentLoopId,
		d.LoopId,
          dx1.Definition AS DateType,
          dx2.Definition AS DateFormat,
          CONVERT(VARCHAR(35),d.[03]) AS Date
     FROM Interchange AS i
          INNER JOIN FunctionalGroup AS fg ON i.id = fg.InterchangeId
          INNER JOIN TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                             AND ts.InterchangeId = i.Id
          INNER JOIN LastRevDTP AS d ON d.InterchangeId = i.Id
                                        AND d.TransactionSetId = ts.Id
          LEFT JOIN X12CodeList AS dx1 ON d.[01] = dx1.Code
                                          AND dx1.ElementId = 374
          LEFT JOIN X12CodeList AS dx2 ON d.[02] = dx2.Code
                                          AND dx2.ElementId = 1250;



GO
