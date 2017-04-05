SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/18/2013
-- Description:	Returns the ClaimSrcTypeID associated with the specified character abbreviation.
-- =============================================
CREATE FUNCTION [Claim].[ConvertClaimSrcTypeIDFromAbbrev]
(
	@value varchar(8)
)
RETURNS tinyint 
WITH SCHEMABINDING
AS
BEGIN
	RETURN (SELECT TOP 1 ClaimSrcTypeID FROM Claim.SourceTypes WITH(NOLOCK) WHERE (Abbrev = @value));
END


GO
GRANT EXECUTE ON  [Claim].[ConvertClaimSrcTypeIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Claim].[ConvertClaimSrcTypeIDFromAbbrev] TO [Submitter]
GO
