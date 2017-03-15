SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwInsuredBenefit]
AS
    SELECT
	    InterchangeId,
	    PositionInInterchange,
	    TransactionSetId,
	    LoopId,
	    CONVERT(VARCHAR(10),CASE i.[01] WHEN 'Y' THEN 'Subscriber' WHEN 'N' THEN 'Dependent' ELSE i.[01] END) AS MemberIndicator,
	    ix1.Definition AS Relationship,
	    CONVERT(VARCHAR(3),i.[03]) AS MaintenanceTypeCode,
	    ix3.Definition AS MaintenanceType,
	    CONVERT(VARCHAR(3),i.[04]) AS MaintenanceReasonCode,
	    ix4.Definition AS MaintenanceReason,
	    CONVERT(VARCHAR(1),i.[05]) AS BenefitStatusCode,
	    ix5.Definition AS BenefitStatus,
	    CONVERT(VARCHAR(50),CASE i.[06] WHEN 'A' THEN 'Medicare Part A' 
				 WHEN 'B' THEN 'Medicare Part B'
				 WHEN 'C' THEN 'Medicare Part A and B'
				 WHEN 'D' THEN 'Medicare'
				 WHEN 'E' THEN 'No Medicare'
				 ELSE i.[06] END) AS MedicarePlan,
	    ix7.Definition AS QualifyingEvent,
	    ix8.Definition AS EmploymentStatus,
	    ix9.Definition AS StudentStatus,
	    CONVERT(VARCHAR(1),i.[10]) AS HandicapIndicator,
	    CONVERT(VARCHAR(35),i.[12]) AS DateOfDeath,
	    ix13.Definition AS Confidentiallity,
	    i.[17] AS BirthSequence
    FROM dbo.INS AS i
	    LEFT JOIN dbo.X12CodeList AS ix1 ON i.[02] = ix1.Code
									AND ix1.ElementId = 1069
	    LEFT JOIN dbo.X12CodeList AS ix3 ON i.[03] = ix3.Code
									AND ix3.ElementId = 875
	    LEFT JOIN dbo.X12CodeList AS ix4 ON i.[04] = ix4.Code
									AND ix4.ElementId = 1203
	    LEFT JOIN dbo.X12CodeList AS ix5 ON i.[05] = ix5.Code
									AND ix5.ElementId = 1216
	    LEFT JOIN dbo.X12CodeList AS ix7 ON i.[07] = ix7.Code
									AND ix7.ElementId = 1219
	    LEFT JOIN dbo.X12CodeList AS ix8 ON i.[08] = ix8.Code
									AND ix8.ElementId = 584
	    LEFT JOIN dbo.X12CodeList AS ix9 ON i.[09] = ix9.Code
									AND ix9.ElementId = 1220
	    LEFT JOIN dbo.X12CodeList AS ix13 ON i.[13] = ix13.Code
									AND ix13.ElementId = 1165

GO
