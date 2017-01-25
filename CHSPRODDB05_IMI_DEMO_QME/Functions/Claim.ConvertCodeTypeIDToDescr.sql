SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns the description associated with the specified CodeTypeID.
-- =============================================
CREATE FUNCTION [Claim].[ConvertCodeTypeIDToDescr]
(
	@value tinyint
)
RETURNS varchar(32)
AS
BEGIN
	RETURN (SELECT TOP 1 Descr FROM Claim.CodeTypes WITH(NOLOCK) WHERE (CodeTypeID = @value));
END

GO
GRANT EXECUTE ON  [Claim].[ConvertCodeTypeIDToDescr] TO [Analyst]
GO
GRANT EXECUTE ON  [Claim].[ConvertCodeTypeIDToDescr] TO [Processor]
GO
GRANT EXECUTE ON  [Claim].[ConvertCodeTypeIDToDescr] TO [Submitter]
GO
