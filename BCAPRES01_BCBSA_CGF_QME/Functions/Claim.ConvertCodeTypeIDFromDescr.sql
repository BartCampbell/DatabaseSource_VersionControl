SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns the CodeTypeID associated with the specified description.
-- =============================================
CREATE FUNCTION [Claim].[ConvertCodeTypeIDFromDescr]
(
	@value varchar(32)
)
RETURNS tinyint 
AS
BEGIN
	RETURN (SELECT TOP 1 CodeTypeID FROM Claim.CodeTypes WITH(NOLOCK) WHERE (Descr = @value));
END

GO
GRANT EXECUTE ON  [Claim].[ConvertCodeTypeIDFromDescr] TO [Processor]
GO
GRANT EXECUTE ON  [Claim].[ConvertCodeTypeIDFromDescr] TO [Submitter]
GO
