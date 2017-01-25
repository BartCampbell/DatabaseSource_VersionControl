SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/26/2014
-- Description:	Returns the abbreviation associated with the specified LOS Group.
-- =============================================
CREATE FUNCTION [Ncqa].[RRU_ConvertLosGroupIDToAbbrev]
(
	@value tinyint
)
RETURNS varchar(1)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Ncqa.RRU_LosGroups WITH(NOLOCK) WHERE (LosGroupID = @value));
END
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertLosGroupIDToAbbrev] TO [Analyst]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertLosGroupIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertLosGroupIDToAbbrev] TO [Submitter]
GO
