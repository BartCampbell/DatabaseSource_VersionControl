SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[vwHealthCoverage]
AS
    SELECT
	    h.InterchangeId,
	    h.PositionInInterchange,
	    h.TransactionSetId,
	    h.LoopId,
	    h.ParentLoopID,
	    CONVERT(VARCHAR(3),h.[01]) AS MaintenanceTypeCode,
	    hx1.Definition AS MaintenanceType,
	    CONVERT(VARCHAR(3),h.[03]) AS InsuranceLineCode,
	    hx3.Definition AS InsuranceLine,
	    CONVERT(VARCHAR(50),h.[04]) AS PlanCvrgDescription,
	    CONVERT(VARCHAR(3),h.[05]) AS CoverageLevelCode,
	    hx5.Definition AS CoverageLevel,
	    CONVERT(VARCHAR(1),h.[09]) AS LateEnrollment
    FROM dbo.HD AS h
	    LEFT JOIN dbo.X12CodeList AS hx1 ON h.[01] = hx1.Code
									AND hx1.ElementId = 875
	    LEFT JOIN dbo.X12CodeList AS hx3 ON h.[03] = hx3.Code
									AND hx3.ElementId = 1205
	    LEFT JOIN dbo.X12CodeList AS hx5 ON h.[05] = hx5.Code
									AND hx5.ElementId = 1207;

GO
