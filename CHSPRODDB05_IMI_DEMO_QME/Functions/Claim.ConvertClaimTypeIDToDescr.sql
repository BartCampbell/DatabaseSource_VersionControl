SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns the description associated with the specified ClaimTypeID.
-- =============================================
CREATE FUNCTION [Claim].[ConvertClaimTypeIDToDescr]
(
	@value tinyint
)
RETURNS varchar(32)
AS
BEGIN
	RETURN (SELECT TOP 1 Descr FROM Claim.ClaimTypes WITH(NOLOCK) WHERE (ClaimTypeID = @value));
END
GO
GRANT EXECUTE ON  [Claim].[ConvertClaimTypeIDToDescr] TO [Analyst]
GO
GRANT EXECUTE ON  [Claim].[ConvertClaimTypeIDToDescr] TO [Processor]
GO
GRANT EXECUTE ON  [Claim].[ConvertClaimTypeIDToDescr] TO [Submitter]
GO
