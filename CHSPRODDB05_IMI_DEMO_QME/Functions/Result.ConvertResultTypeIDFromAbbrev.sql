SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/27/2011
-- Description:	Returns the ResultTypeID associated with the specified character abbreviation.
-- =============================================
CREATE FUNCTION [Result].[ConvertResultTypeIDFromAbbrev]
(
	@value char(1)
)
RETURNS tinyint 
AS
BEGIN
	RETURN (SELECT TOP 1 ResultTypeID FROM Result.ResultTypes WITH(NOLOCK) WHERE (Abbrev = @value));
END

GO
GRANT EXECUTE ON  [Result].[ConvertResultTypeIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Result].[ConvertResultTypeIDFromAbbrev] TO [Submitter]
GO
