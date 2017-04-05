SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/14/2012
-- Description:	Returns the abbreviation associated with the specified ExclusionTypeID.
-- =============================================
CREATE FUNCTION [Measure].[ConvertExclusionTypeIDToAbbrev]
(
	@value tinyint
)
RETURNS varchar(16)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Measure.ExclusionTypes WITH(NOLOCK) WHERE (ExclusionTypeID = @value));
END


GO
GRANT EXECUTE ON  [Measure].[ConvertExclusionTypeIDToAbbrev] TO [Analyst]
GO
GRANT EXECUTE ON  [Measure].[ConvertExclusionTypeIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertExclusionTypeIDToAbbrev] TO [Submitter]
GO
