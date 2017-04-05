SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns the ClaimTypeID associated with the specified character abbreviation.
-- =============================================
CREATE FUNCTION [Claim].[ConvertClaimTypeIDFromAbbrev]
(
	@value varchar(8)
)
RETURNS tinyint 
WITH SCHEMABINDING
AS
BEGIN
	RETURN (SELECT TOP 1 ClaimTypeID FROM Claim.ClaimTypes WITH(NOLOCK) WHERE (Abbrev = @value));
END
GO
GRANT EXECUTE ON  [Claim].[ConvertClaimTypeIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Claim].[ConvertClaimTypeIDFromAbbrev] TO [Submitter]
GO
