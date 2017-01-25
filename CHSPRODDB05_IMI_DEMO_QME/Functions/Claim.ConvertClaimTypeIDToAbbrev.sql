SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns the abbreviation associated with the specified ClaimTypeID.
-- =============================================
CREATE FUNCTION [Claim].[ConvertClaimTypeIDToAbbrev]
(
	@value tinyint
)
RETURNS varchar(8)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Claim.ClaimTypes WITH(NOLOCK) WHERE (ClaimTypeID = @value));
END
GO
GRANT EXECUTE ON  [Claim].[ConvertClaimTypeIDToAbbrev] TO [Analyst]
GO
GRANT EXECUTE ON  [Claim].[ConvertClaimTypeIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Claim].[ConvertClaimTypeIDToAbbrev] TO [Submitter]
GO
