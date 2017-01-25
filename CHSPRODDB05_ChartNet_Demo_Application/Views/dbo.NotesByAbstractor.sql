SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[NotesByAbstractor] AS 
select	A.AbstractorName,
		M.CustomerMemberID,
		M.NameLast,
		M.NameFirst,
		M.DateOfBirth,
		Me.HEDISMeasure,
		PEN.NoteText
from	PursuitEventNote PEN
		inner join PursuitEvent PE on
			PEN.PursuitEventID = PE.PursuitEventID
		inner join Pursuit P on
			PE.PursuitID = P.PursuitID
		inner join Member M on
			P.MemberID = M.MemberID 
		inner join Measure Me on
			PE.MeasureID = Me.MeasureID 
		inner join Abstractor A on
			P.AbstractorID = A.AbstractorID 

GO
