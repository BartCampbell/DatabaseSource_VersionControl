SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwProfessionalService]
AS
     SELECT
          s.InterchangeId,
          s.PositionInInterchange,
          s.TransactionSetId,
          s.ParentLoopId,
          s.LoopId,
          CONVERT(VARCHAR(MAX),s.[01]) AS ProductOrService,
          sx1.Definition AS ProductOrServiceType,
          dbo.ufn_parsefind(s.[01], ':', 2) AS ProductOrServiceCode,
          dbo.ufn_parsefind(s.[01], ':', 3) AS Modifier1,
          dbo.ufn_parsefind(s.[01], ':', 4) AS Modifier2,
          dbo.ufn_parsefind(s.[01], ':', 5) AS Modifier3,
          dbo.ufn_parsefind(s.[01], ':', 6) AS Modifier4,
          dbo.ufn_parsefind(s.[01], ':', 7) AS ProductOrServiceDescription,
          s.[02] AS ChargeAmt,
          sx3.Definition AS ServiceUnit,
          s.[04] AS ServiceUnitCount,
          pos.POSName AS PlaceOfService,
          CONVERT(VARCHAR(35),s.[07]) AS DXCodeOrder,
          sx9.Definition AS EmergencyRelated,
          sx11.Definition AS EPSDTIndicator,
          sx12.Definition AS FamilyPlanningIndicator,
          sx15.Definition AS CoPayStatus
     FROM Interchange AS i
          INNER JOIN FunctionalGroup AS fg ON i.id = fg.InterchangeId
          INNER JOIN TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                             AND ts.InterchangeId = i.Id
          INNER JOIN LOOP AS l ON l.TransactionSetId = ts.Id
                                  AND l.InterchangeId = i.Id
          INNER JOIN LastRevSV1 AS s ON i.id = s.InterchangeId
                                        AND ts.id = s.TransactionSetId
                                        AND l.id = s.parentloopid
          LEFT JOIN X12CodeList AS sx1 ON LEFT(s.[01], CHARINDEX(':', s.[01])-1) = sx1.Code
                                          AND sx1.ElementId = 235
          LEFT JOIN X12CodeList AS sx3 ON s.[03] = sx3.Code
                                          AND sx3.ElementId = 355
          LEFT JOIN dbo.vwPlaceOfService AS pos ON s.[05] = pos.POSCode
          LEFT JOIN X12CodeList AS sx9 ON s.[09] = sx9.Code
                                          AND sx9.ElementId = 1073
          LEFT JOIN X12CodeList AS sx11 ON s.[11] = sx11.Code
                                           AND sx11.ElementId = 1073
          LEFT JOIN X12CodeList AS sx12 ON s.[12] = sx12.Code
                                           AND sx12.ElementId = 1073
          LEFT JOIN X12CodeList AS sx15 ON s.[15] = sx15.Code
                                           AND sx15.ElementId = 1327;


GO
