SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwClaimNotes]
AS
     SELECT
          n.InterchangeId,
          n.PositionInInterchange,
          n.TransactionSetId,
          n.ParentLoopId,
          n.LoopId,
          nx1.Definition AS NoteType,
          CONVERT(VARCHAR(80),n.[02]) AS Note
     FROM Interchange AS i
          INNER JOIN FunctionalGroup AS fg ON i.id = fg.InterchangeId
          INNER JOIN TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                             AND ts.InterchangeId = i.Id
          INNER JOIN LOOP AS l ON l.TransactionSetId = ts.Id
                                  AND l.InterchangeId = i.Id
          INNER JOIN LastRevNTE AS n ON i.id = n.InterchangeId
                                        AND ts.id = n.TransactionSetId
                                        AND l.id = n.parentloopid
          LEFT JOIN X12CodeList AS nx1 ON n.[01] = nx1.Code
                                          AND nx1.ElementId = 363;


GO
