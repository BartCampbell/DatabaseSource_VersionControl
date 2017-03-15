SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwDurableEquipmentCertification]
AS
     SELECT
          c.InterchangeId,
          c.PositionInInterchange,
          c.TransactionSetId,
          c.ParentLoopId,
          c.LoopId,
          cx1.Definition AS CertificationType,
          cx2.Definition AS CertificationTimePeriod,
          c.[03] AS CertificationDuration
     FROM dbo.Interchange AS i
          INNER JOIN dbo.FunctionalGroup AS fg ON i.id = fg.InterchangeId
          INNER JOIN dbo.TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                                 AND ts.InterchangeId = i.Id
          INNER JOIN dbo.CR3 AS c ON c.InterchangeId = i.Id
                                     AND c.TransactionSetId = ts.Id
          LEFT JOIN X12CodeList AS cx1 ON c.[01] = cx1.Code
                                          AND cx1.ElementId = 1322
          LEFT JOIN X12CodeList AS cx2 ON c.[02] = cx2.Code
                                          AND cx2.ElementId = 355;


GO
