SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwMemberAddress]
AS
    SELECT
	    n3.InterchangeID,
	    n3.PositionInInterchange,
	    n3.TransactionSetID,
	    n3.ParentLoopId,
	    n3.[01] AS Addr1,
	    n3.[02] AS Addr2,
	    n4.[01] AS City,
	    n4.[02] AS State,
	    n4.[03] AS Zip,
	    n4.[04] AS Country,
	    n4x5.Definition AS LocationType,
	    n4.[06] AS Location,
	    n4.[07] AS CountrySubdivisionCode
    FROM  N3 AS n3
		LEFT JOIN N4 n4 ON n3.InterchangeId = n4.InterchangeId and n3.ParentLoopId = n4.ParentLoopId
		LEFT JOIN X12CodeList AS n4x5 ON n4.[05] = n4x5.Code
								  AND n4x5.ElementId = 309
GO
