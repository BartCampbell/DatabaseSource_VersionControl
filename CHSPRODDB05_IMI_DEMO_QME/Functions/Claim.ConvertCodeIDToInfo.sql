SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/20/6013
-- Description:	Returns the "code info" associated with the specified CodeID.
-- =============================================
CREATE FUNCTION [Claim].[ConvertCodeIDToInfo]
(
	@value int
)
RETURNS varchar(16)
AS
BEGIN
	RETURN (SELECT TOP 1 CodeInfo FROM Claim.Codes WITH(NOLOCK) WHERE (CodeID = @value));
END


GO
GRANT EXECUTE ON  [Claim].[ConvertCodeIDToInfo] TO [Analyst]
GO
GRANT EXECUTE ON  [Claim].[ConvertCodeIDToInfo] TO [Processor]
GO
GRANT EXECUTE ON  [Claim].[ConvertCodeIDToInfo] TO [Submitter]
GO
