SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns the CodeTypeID associated with the specified character abbreviation.
-- =============================================
CREATE FUNCTION [Claim].[ConvertCodeTypeIDFromAbbrev]
(
	@value varchar(16)
)
RETURNS tinyint 
AS
BEGIN
	RETURN (SELECT TOP 1 CodeTypeID FROM Claim.CodeTypes WITH(NOLOCK) WHERE (Abbrev = @value));
END

GO
GRANT EXECUTE ON  [Claim].[ConvertCodeTypeIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Claim].[ConvertCodeTypeIDFromAbbrev] TO [Submitter]
GO
