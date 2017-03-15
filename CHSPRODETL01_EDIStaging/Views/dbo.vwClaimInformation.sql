SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW [dbo].[vwClaimInformation]
AS
     SELECT
          i.Id AS InterchangeID,
          ts.Id AS TransactionSetID,
		c.LoopId,
		c.ParentLoopId,
          CONVERT(VARCHAR(50),c.[01]) AS ClaimID,
          c.[02] AS ClaimAmount,
          CONVERT(VARCHAR(MAX),CASE
              WHEN SUBSTRING(c.[05], CHARINDEX(':', c.[05])+1, 1) = 'B'
              THEN pos.POSName
              ELSE c.[05]
          END) AS ServiceLocation,
          CONVERT(VARCHAR(MAX),CASE RIGHT(c.[05], 1)
              WHEN '1'
              THEN 'Admit thru Discharge Claim'
              WHEN '7'
              THEN 'Replacement of Prior Claim'
              WHEN '8'
              THEN 'Void/Cancel of Prior Claim'
              ELSE c.[05]
          END) AS ClaimFrequency,
          cx6.Definition AS ProvSignatureIndicator,
          cx7.Definition AS ProvPlanParticipation,
          cx8.Definition AS BenefitsAssignmentCertIndicator,
          cx9.Definition AS ReleaseOfInformation,
          cx10.Definition AS PatientSignatureSource,
          CONVERT(VARCHAR(MAX),CASE c.[11]
              WHEN 'AA'
              THEN 'Auto Accident'
              WHEN 'EM'
              THEN 'Employment'
              WHEN 'OA'
              THEN 'Other Accident'
              ELSE c.[11]
          END) AS RelatedCauses,
          cx12.Definition AS SpecialProgram,
          cx20.Definition AS DelayReason--,
		--d.DateType,
		--d.DateFormat,
		--d.Date
     FROM Interchange AS i
          INNER JOIN FunctionalGroup AS fg ON i.id = fg.InterchangeId
          INNER JOIN TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                             AND ts.InterchangeId = i.Id
          INNER JOIN LastRevCLM AS c ON c.InterchangeId = i.Id
                                        AND c.TransactionSetId = ts.Id
          LEFT JOIN vwPlaceOfService AS pos ON LEFT(c.[05], CHARINDEX(':', c.[05])-1) = pos.POSCode
          LEFT JOIN X12CodeList AS cx6 ON c.[06] = cx6.Code
                                          AND cx6.ElementId = 1073
          LEFT JOIN X12CodeList AS cx7 ON c.[07] = cx7.Code
                                          AND cx7.ElementId = 1359
          LEFT JOIN X12CodeList AS cx8 ON c.[08] = cx8.Code
                                          AND cx8.ElementId = 1073
          LEFT JOIN X12CodeList AS cx9 ON c.[09] = cx9.Code
                                          AND cx9.ElementId = 1363
          LEFT JOIN X12CodeList AS cx10 ON c.[10] = cx10.Code
                                           AND cx10.ElementId = 1351
          LEFT JOIN X12CodeList AS cx12 ON c.[12] = cx12.Code
                                           AND cx12.ElementId = 1366
          LEFT JOIN X12CodeList AS cx20 ON c.[20] = cx20.Code
                                           AND cx20.ElementId = 1514
		--LEFT JOIN vwClaimDates d ON d.InterchangeID = c.InterchangeID
  --                                      AND d.transactionsetid = c.transactionsetid
  --                                      AND d.ParentLoopId = c.LoopId





GO
