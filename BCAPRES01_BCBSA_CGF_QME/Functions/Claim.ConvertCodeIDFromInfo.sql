SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/20/2013
-- Description:	Returns the CodeID associated with the specified "code info".
-- =============================================
CREATE FUNCTION [Claim].[ConvertCodeIDFromInfo]
(
	@value varchar(16)
)
RETURNS int 
AS
BEGIN
	RETURN (SELECT TOP 1 CodeID FROM Claim.Codes WITH(NOLOCK) WHERE (CodeInfo = @value));
END

GO
GRANT EXECUTE ON  [Claim].[ConvertCodeIDFromInfo] TO [Processor]
GO
GRANT EXECUTE ON  [Claim].[ConvertCodeIDFromInfo] TO [Submitter]
GO
