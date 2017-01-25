SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/14/2011
-- Description:	Returns the ExclusionTypeID associated with the specified character abbreviation.
-- =============================================
CREATE FUNCTION [Measure].[ConvertExclusionTypeIDFromAbbrev]
(
	@value varchar(16)
)
RETURNS tinyint 
AS
BEGIN
	RETURN (SELECT TOP 1 ExclusionTypeID FROM Measure.ExclusionTypes WITH(NOLOCK) WHERE (Abbrev = @value));
END


GO
GRANT EXECUTE ON  [Measure].[ConvertExclusionTypeIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertExclusionTypeIDFromAbbrev] TO [Submitter]
GO
