SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns the description associated with the specified BenefitID.
-- =============================================
CREATE FUNCTION [Product].[ConvertBenefitIDToDescr]
(
	@value smallint
)
RETURNS varchar(64)
AS
BEGIN
	RETURN (SELECT TOP 1 Descr FROM Product.Benefits WITH(NOLOCK) WHERE (BenefitID = @value));
END

GO
GRANT EXECUTE ON  [Product].[ConvertBenefitIDToDescr] TO [Analyst]
GO
GRANT EXECUTE ON  [Product].[ConvertBenefitIDToDescr] TO [Processor]
GO
GRANT EXECUTE ON  [Product].[ConvertBenefitIDToDescr] TO [Submitter]
GO
