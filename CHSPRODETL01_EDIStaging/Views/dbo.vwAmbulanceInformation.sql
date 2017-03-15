SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwAmbulanceInformation]
AS
     SELECT
          c.InterchangeId,
          c.PositionInInterchange,
          c.TransactionSetId,
          c.ParentLoopId,
          c.LoopId,
          cx1.Definition AS PatientWeightUnit,
          c.[02] AS PatientWeight,
          cx4.Definition AS TransportReason,
          cx5.Definition AS TransportDistanceUnit,
          c.[06] AS TransportDistance,
          CONVERT(VARCHAR(80),c.[09]) AS RoundTripPurpose,
          CONVERT(VARCHAR(80),c.[10]) AS StretcherPurpose
     FROM dbo.Interchange AS i
          INNER JOIN dbo.FunctionalGroup AS fg ON i.id = fg.InterchangeId
          INNER JOIN dbo.TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                                 AND ts.InterchangeId = i.Id
          INNER JOIN dbo.CR1 AS c ON c.InterchangeId = i.Id
                                     AND c.TransactionSetId = ts.Id
          LEFT JOIN X12CodeList AS cx1 ON c.[01] = cx1.Code
                                          AND cx1.ElementId = 355
          LEFT JOIN X12CodeList AS cx4 ON c.[04] = cx4.Code
                                          AND cx4.ElementId = 1317
          LEFT JOIN X12CodeList AS cx5 ON c.[05] = cx5.Code
                                          AND cx5.ElementId = 355;



GO
