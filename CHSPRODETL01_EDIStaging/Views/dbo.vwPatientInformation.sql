SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwPatientInformation]
AS
     SELECT
          p.InterchangeId,
          p.PositionInInterchange,
          p.TransactionSetId,
          p.ParentLoopId,
          p.LoopId,
          px1.Definition AS PatientRelationship,
          CONVERT(VARCHAR(35),p.[06]) AS PatientDeathDate,
          px7.Definition AS UnitOfMeasurement,
          p.[08] AS PatientWeight,
          px9.Definition AS PatientIsPregnant
     FROM Interchange AS i
          INNER JOIN FunctionalGroup AS fg ON i.id = fg.InterchangeId
          INNER JOIN TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                             AND ts.InterchangeId = i.Id
          INNER JOIN LOOP AS l ON l.TransactionSetId = ts.Id
                                  AND l.InterchangeId = i.Id
          INNER JOIN LastRevPAT AS p ON i.id = p.InterchangeId
                                        AND ts.id = p.TransactionSetId
                                        AND l.id = p.parentloopid
          LEFT JOIN X12CodeList AS px1 ON p.[01] = px1.Code
                                          AND px1.ElementId = 1069
          LEFT JOIN X12CodeList AS px7 ON p.[07] = px7.Code
                                          AND px7.ElementId = 355
          LEFT JOIN X12CodeList AS px9 ON p.[09] = px9.Code
                                          AND px9.ElementId = 1073;


GO
