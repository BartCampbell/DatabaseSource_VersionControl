SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vwMeasurements]
AS
     SELECT
          m.InterchangeId,
          m.PositionInInterchange,
          m.TransactionSetId,
          m.ParentLoopId,
          m.LoopId,
          mx1.Definition AS MeasurementType,
          mx2.Definition AS Measurement,
          m.[03] AS MeasurementValue
     FROM Interchange AS i
          INNER JOIN FunctionalGroup AS fg ON i.id = fg.InterchangeId
          INNER JOIN TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                             AND ts.InterchangeId = i.Id
          INNER JOIN LastRevMEA AS m ON i.id = m.InterchangeId
                                        AND ts.Id = m.TransactionSetId
          LEFT JOIN X12CodeList AS mx1 ON m.[01] = mx1.Code
                                          AND mx1.ElementId = 737
          LEFT JOIN X12CodeList AS mx2 ON m.[02] = mx2.Code
                                          AND mx2.ElementId = 738;

GO
