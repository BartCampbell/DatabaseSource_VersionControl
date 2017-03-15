SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwSubscriberInsuranceInformation]
AS
     SELECT
          s.InterchangeId,
          s.PositionInInterchange,
          s.TransactionSetId,
          s.ParentLoopId,
          s.LoopId,
          sx1.Definition AS PayerResponsibility,
          sx2.Definition AS PatientRelationship,
          CONVERT(VARCHAR(80),s.[03]) AS GroupPolicyNumber,
          CONVERT(VARCHAR(80),s.[04]) AS GroupPolicyName,
          sx5.Definition AS InsuranceType,
          sx9.Definition AS TypeOfClaim
     FROM Interchange AS i
          INNER JOIN FunctionalGroup AS fg ON i.id = fg.InterchangeId
          INNER JOIN TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                             AND ts.InterchangeId = i.Id
          INNER JOIN LOOP AS l ON l.TransactionSetId = ts.Id
                                  AND l.InterchangeId = i.Id
          INNER JOIN LastRevSBR AS s ON i.id = s.InterchangeId
                                        AND ts.id = s.TransactionSetId
                                        AND l.id = s.parentloopid
          LEFT JOIN X12CodeList AS sx1 ON s.[01] = sx1.Code
                                          AND sx1.ElementId = 1138
          LEFT JOIN X12CodeList AS sx2 ON s.[02] = sx2.Code
                                          AND sx2.ElementId = 1069
          LEFT JOIN X12CodeList AS sx5 ON s.[05] = sx5.Code
                                          AND sx5.ElementId = 1336
          LEFT JOIN X12CodeList AS sx9 ON s.[09] = sx9.Code
                                          AND sx9.ElementId = 1032;


GO
