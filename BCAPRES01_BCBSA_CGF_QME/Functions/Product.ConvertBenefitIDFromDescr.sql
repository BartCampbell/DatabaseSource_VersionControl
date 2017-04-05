SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns the BenefitID associated with the specified description.
-- =============================================
CREATE FUNCTION [Product].[ConvertBenefitIDFromDescr]
(
	@value varchar(64)
)
RETURNS smallint 
AS
BEGIN
	RETURN (SELECT TOP 1 BenefitID FROM Product.Benefits WITH(NOLOCK) WHERE (Descr = @value));
END

GO
GRANT EXECUTE ON  [Product].[ConvertBenefitIDFromDescr] TO [Processor]
GO
GRANT EXECUTE ON  [Product].[ConvertBenefitIDFromDescr] TO [Submitter]
GO
