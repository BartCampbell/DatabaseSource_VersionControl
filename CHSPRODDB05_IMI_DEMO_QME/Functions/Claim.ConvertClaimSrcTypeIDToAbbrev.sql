SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/18/2013
-- Description:	Returns the abbreviation associated with the specified ClaimSrcTypeID.
-- =============================================
CREATE FUNCTION [Claim].[ConvertClaimSrcTypeIDToAbbrev]
(
	@value tinyint
)
RETURNS varchar(8)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Claim.SourceTypes WITH(NOLOCK) WHERE (ClaimSrcTypeID = @value));
END

GO
GRANT EXECUTE ON  [Claim].[ConvertClaimSrcTypeIDToAbbrev] TO [Analyst]
GO
GRANT EXECUTE ON  [Claim].[ConvertClaimSrcTypeIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Claim].[ConvertClaimSrcTypeIDToAbbrev] TO [Submitter]
GO
