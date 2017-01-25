SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/29/2011
-- Description:	Returns the MbrAttribID associated with the specified abbreviation.
-- =============================================
CREATE FUNCTION [Member].[ConvertMbrAttribIDFromAbbrev]
(
	@value varchar(16)
)
RETURNS smallint 
AS
BEGIN
	RETURN (SELECT TOP 1 MbrAttribID FROM Member.Attributes WITH(NOLOCK) WHERE (Abbrev = @value));
END


GO
GRANT EXECUTE ON  [Member].[ConvertMbrAttribIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Member].[ConvertMbrAttribIDFromAbbrev] TO [Submitter]
GO
