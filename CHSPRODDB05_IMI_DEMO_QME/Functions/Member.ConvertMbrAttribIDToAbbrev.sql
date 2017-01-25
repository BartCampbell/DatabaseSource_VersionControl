SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/29/2011
-- Description:	Returns the abbreviation associated with the specified MbrAttribID.
-- =============================================
CREATE FUNCTION [Member].[ConvertMbrAttribIDToAbbrev]
(
	@value smallint
)
RETURNS varchar(16)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Member.Attributes WITH(NOLOCK) WHERE (MbrAttribID = @value));
END


GO
GRANT EXECUTE ON  [Member].[ConvertMbrAttribIDToAbbrev] TO [Analyst]
GO
GRANT EXECUTE ON  [Member].[ConvertMbrAttribIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Member].[ConvertMbrAttribIDToAbbrev] TO [Submitter]
GO
