SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/27/2011
-- Description:	Returns the abbreviation associated with the specified ResultTypeID.
-- =============================================
CREATE FUNCTION [Result].[ConvertResultTypeIDToAbbrev]
(
	@value tinyint
)
RETURNS char(1)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Result.ResultTypes WITH(NOLOCK) WHERE (ResultTypeID = @value));
END


GO
GRANT EXECUTE ON  [Result].[ConvertResultTypeIDToAbbrev] TO [Analyst]
GO
GRANT EXECUTE ON  [Result].[ConvertResultTypeIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Result].[ConvertResultTypeIDToAbbrev] TO [Submitter]
GO
