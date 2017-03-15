SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwProviderAssignment]
AS
    SELECT
	    InterchangeId,
	    PositionInInterchange,
	    TransactionSetId,
	    LoopId,
	    l.[01] AS ProviderAssignedNo
    FROM dbo.LX AS l
GO
