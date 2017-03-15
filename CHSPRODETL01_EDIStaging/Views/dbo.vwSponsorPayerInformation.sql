SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwSponsorPayerInformation]
AS
    SELECT
	    n.InterchangeID,
	    n.PositionInInterchange,
	    n.TransactionSetID,
	    n.LoopId,
	    l.SpecLoopId,
	    nx1.Definition AS Sponsor,
	    CONVERT(VARCHAR(80),n.[02]) AS SponsorName,
	    nx3.Definition AS IdentificationType,
	    CONVERT(VARCHAR(80),n.[04]) AS IdentificationNo
    FROM  N1 AS n
	     INNER JOIN Loop l ON n.LoopId = l.Id
		LEFT JOIN X12CodeList AS nx1 ON n.[01] = nx1.Code
								  AND nx1.ElementId = 98
		LEFT JOIN X12CodeList AS nx3 ON n.[03] = nx3.Code
								  AND nx3.ElementId = 66

GO
