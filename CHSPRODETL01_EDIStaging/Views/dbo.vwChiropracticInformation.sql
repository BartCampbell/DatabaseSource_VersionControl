SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwChiropracticInformation]
AS
     SELECT
          c.InterchangeId,
          c.PositionInInterchange,
          c.TransactionSetId,
          c.ParentLoopId,
          c.LoopId,
          cx8.Definition AS PatientCondition,
          CONVERT(VARCHAR(80),c.[10]) AS PatientConditionDesc,
          CONVERT(VARCHAR(80),c.[11]) AS PatientConditionDesc2
     FROM dbo.Interchange AS i
          INNER JOIN dbo.FunctionalGroup AS fg ON i.id = fg.InterchangeId
          INNER JOIN dbo.TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                                 AND ts.InterchangeId = i.Id
          INNER JOIN dbo.CR2 AS c ON c.InterchangeId = i.Id
                                     AND c.TransactionSetId = ts.Id
          LEFT JOIN X12CodeList AS cx8 ON c.[08] = cx8.Code
                                          AND cx8.ElementId = 1342;



GO
