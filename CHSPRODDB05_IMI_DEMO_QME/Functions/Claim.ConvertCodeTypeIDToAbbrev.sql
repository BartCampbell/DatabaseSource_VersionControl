SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns the abbreviation associated with the specified CodeTypeID.
-- =============================================
CREATE FUNCTION [Claim].[ConvertCodeTypeIDToAbbrev]
(
	@value tinyint
)
RETURNS varchar(16)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Claim.CodeTypes WITH(NOLOCK) WHERE (CodeTypeID = @value));
END

GO
GRANT EXECUTE ON  [Claim].[ConvertCodeTypeIDToAbbrev] TO [Analyst]
GO
GRANT EXECUTE ON  [Claim].[ConvertCodeTypeIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Claim].[ConvertCodeTypeIDToAbbrev] TO [Submitter]
GO
