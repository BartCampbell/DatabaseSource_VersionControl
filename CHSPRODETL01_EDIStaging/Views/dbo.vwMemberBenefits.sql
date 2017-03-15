SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[vwMemberBenefits]
AS
     SELECT DISTINCT
          n.[09] AS MemberID,
          t2.SubscriberNumber,
          t2.HICNumber,
          t2.GroupPolicyNumber,
          t2.MasterPolicyNumber,
          t.MedicaidBegin,
          t.MedicaidEnd,
          t.BenefitBegin,
          t.BenefitEnd,
          t.EligibilityBegin,
          t.EligibilityEnd,
          t.MedicareBegin,
          t.MedicareEnd,
          h.InsuranceLine,
          h.PlanCvrgDescription,
          h.CoverageLevelCode,
          h.CoverageLevel,
          h.LateEnrollment,
          i.MaintenanceTypeCode,
          i.MaintenanceType,
          i.MaintenanceReason,
          i.BenefitStatus,
          i.MedicarePlan,
          i.QualifyingEvent,
          i.EmploymentStatus,
          i.StudentStatus,
          i.HandicapIndicator,
          i.DateOfDeath,
          i.Confidentiallity,
          i.BirthSequence
     FROM  dbo.NM1 AS n
           INNER JOIN
     (
         SELECT
              e.InterchangeID,
              e.TransactionSetID,
              ISNULL(l.ParentLoopId, l.Id) AS ParentLoopId,
              MAX(CASE e.DateType
                      WHEN 'Medicaid Begin'
                      THEN e.Dates
                      ELSE ''
                  END) AS MedicaidBegin,
              MAX(CASE e.DateType
                      WHEN 'Medicaid End'
                      THEN e.Dates
                      ELSE ''
                  END) AS MedicaidEnd,
              MAX(CASE e.DateType
                      WHEN 'Benefit Begin'
                      THEN e.Dates
                      ELSE ''
                  END) AS BenefitBegin,
              MAX(CASE e.DateType
                      WHEN 'Benefit End'
                      THEN e.Dates
                      ELSE ''
                  END) AS BenefitEnd,
              MAX(CASE e.DateType
                      WHEN 'Eligibility Begin'
                      THEN e.Dates
                      ELSE ''
                  END) AS EligibilityBegin,
              MAX(CASE e.DateType
                      WHEN 'Eligibility End'
                      THEN e.Dates
                      ELSE ''
                  END) AS EligibilityEnd,
              MAX(CASE e.DateType
                      WHEN 'Medicare Begin'
                      THEN e.Dates
                      ELSE ''
                  END) AS MedicareBegin,
              MAX(CASE e.DateType
                      WHEN 'Medicare End'
                      THEN e.Dates
                      ELSE ''
                  END) AS MedicareEnd
         FROM dbo.vwEligibilityDates AS e
              INNER JOIN dbo.loop AS l ON e.ParentLoopId = l.id
         GROUP BY
              e.InterchangeID,
              e.TransactionSetID,
              ISNULL(l.ParentLoopId, l.Id)
     ) AS t ON n.InterchangeId = t.InterchangeID
               AND n.TransactionSetId = t.TransactionSetID
               AND n.ParentLoopId = t.ParentLoopId
           LEFT JOIN
     (
         SELECT
              InterchangeId,
              TransactionSetId,
              ParentLoopId,
              SpecLoopId,
              MAX(CASE r.ReferenceType
                      WHEN 'Subscriber Number'
                      THEN r.ReferenceValue
                      ELSE ''
                  END) AS SubscriberNumber,
              MAX(CASE r.ReferenceType
                      WHEN 'Health Insurance Claim (HIC) Number'
                      THEN r.ReferenceValue
                      ELSE ''
                  END) AS HICNumber,
              MAX(CASE r.ReferenceType
                      WHEN 'Group or Policy Number'
                      THEN r.ReferenceValue
                      ELSE ''
                  END) AS GroupPolicyNumber,
              MAX(CASE r.ReferenceType
                      WHEN 'Master Policy Number'
                      THEN r.ReferenceValue
                      ELSE ''
                  END) AS MasterPolicyNumber
         FROM vwReferenceInformation AS r
         GROUP BY
              InterchangeId,
              TransactionSetId,
              ParentLoopId,
              SpecLoopId
     ) AS t2 ON n.InterchangeId = t2.InterchangeID
                AND n.TransactionSetId = t2.TransactionSetID
                AND n.ParentLoopId = t2.ParentLoopId
           LEFT JOIN dbo.vwHealthCoverage AS h ON h.InterchangeId = t.InterchangeID
                                                  AND h.TransactionSetId = t.TransactionSetID
                                                  AND h.ParentLoopID = t.ParentLoopId
           LEFT JOIN dbo.vwInsuredBenefit AS i ON i.InterchangeId = t.InterchangeID
                                                  AND i.TransactionSetId = t.TransactionSetID
                                                  AND i.LoopId = t.ParentLoopId
     WHERE n.[09] IS NOT NULL;
GO
