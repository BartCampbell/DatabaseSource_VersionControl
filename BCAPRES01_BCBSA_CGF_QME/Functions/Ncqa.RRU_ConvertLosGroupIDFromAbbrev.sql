SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/26/2014
-- Description:	Returns the LOS Group associated with the specified abbreviation.
-- =============================================
CREATE FUNCTION [Ncqa].[RRU_ConvertLosGroupIDFromAbbrev]
(
	@value varchar(1)
)
RETURNS tinyint 
AS
BEGIN
	RETURN (SELECT TOP 1 LosGroupID FROM Ncqa.RRU_LosGroups WITH(NOLOCK) WHERE (Abbrev = @value));
END
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertLosGroupIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertLosGroupIDFromAbbrev] TO [Submitter]
GO
