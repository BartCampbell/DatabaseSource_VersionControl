SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwReferenceInformation]
AS
     SELECT
	    r.InterchangeId,
	    r.PositionInInterchange,
	    r.TransactionSetId,
	    r.LoopId,
	    r.ParentLoopId,
	    l.SpecLoopId,
	    x1.Definition AS ReferenceType,
	    CAST(r.[02] AS VARCHAR(50)) AS ReferenceValue
    FROM dbo.REF r 
	    LEFT JOIN dbo.Loop l ON r.ParentLoopId = l.Id
	    LEFT JOIN dbo.X12CodeList x1 ON r.[01] = x1.Code AND x1.ElementId = 128
GO
