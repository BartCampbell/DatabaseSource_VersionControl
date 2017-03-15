SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwPatientHierarchy]
AS
     SELECT
	    h.InterchangeId,
	    h.PositionInInterchange,
	    h.TransactionSetId,
	    h.LoopId,
	    h.ParentLoopId,
	    CONVERT(VARCHAR(12),h.[01]) AS Patient,
	    CONVERT(VARCHAR(12),h.[02]) AS Parent,
	    hx3.Definition AS PatientHierarchy,
	    hx4.Definition AS MoreSubordinates
    FROM Interchange AS i
	    INNER JOIN FunctionalGroup AS fg ON i.id = fg.InterchangeId
	    INNER JOIN TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
								    AND ts.InterchangeId = i.Id
	    INNER JOIN LastRevHL AS h ON i.id = h.InterchangeId
							   AND ts.id = h.TransactionSetId
	    LEFT JOIN X12CodeList AS hx3 ON h.[03] = hx3.Code
								 AND hx3.ElementId = 735
	    LEFT JOIN X12CodeList AS hx4 ON h.[04] = hx4.Code
								 AND hx4.ElementId = 736




GO
