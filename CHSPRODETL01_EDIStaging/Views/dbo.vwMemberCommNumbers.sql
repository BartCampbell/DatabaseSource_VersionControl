SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwMemberCommNumbers]
AS
     SELECT
	    p.InterchangeId,
	    p.PositionInInterchange,
	    p.TransactionSetId,
	    p.LoopId,
	    p.ParentLoopId,
	    l.SpecLoopId,
	    x1.Definition AS MemberContact,
	    x3.Definition AS NumberType1,
	    p.[04] AS Number1,
	    x5.Definition AS NumberType2,
	    p.[06] AS Number2,
	    x7.Definition AS NumberType3,
	    p.[08] AS Number3
    FROM dbo.PER p 
	    LEFT JOIN dbo.Loop l ON p.ParentLoopId = l.Id
	    LEFT JOIN dbo.X12CodeList x1 ON p.[01] = x1.Code AND x1.ElementId = 366
	    LEFT JOIN dbo.X12CodeList x3 ON p.[03] = x3.Code AND x3.ElementId = 365
	    LEFT JOIN dbo.X12CodeList x5 ON p.[05] = x5.Code AND x5.ElementId = 365
	    LEFT JOIN dbo.X12CodeList x7 ON p.[07] = x7.Code AND x7.ElementId = 365
GO
