SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns the ClaimTypeID associated with the specified description.
-- =============================================
CREATE FUNCTION [Claim].[ConvertClaimTypeIDFromDescr]
(
	@value varchar(32)
)
RETURNS tinyint 
WITH SCHEMABINDING
AS
BEGIN
	RETURN (SELECT TOP 1 ClaimTypeID FROM Claim.ClaimTypes WITH(NOLOCK) WHERE (Descr = @value));
END
GO
GRANT EXECUTE ON  [Claim].[ConvertClaimTypeIDFromDescr] TO [Processor]
GO
GRANT EXECUTE ON  [Claim].[ConvertClaimTypeIDFromDescr] TO [Submitter]
GO
