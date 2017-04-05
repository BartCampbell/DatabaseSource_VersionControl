SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns the BenefitID associated with the specified character abbreviation.
-- =============================================
CREATE FUNCTION [Product].[ConvertBenefitIDFromAbbrev]
(
	@value varchar(16)
)
RETURNS smallint 
AS
BEGIN
	RETURN (SELECT TOP 1 BenefitID FROM Product.Benefits WITH(NOLOCK) WHERE (Abbrev = @value));
END

GO
GRANT EXECUTE ON  [Product].[ConvertBenefitIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Product].[ConvertBenefitIDFromAbbrev] TO [Submitter]
GO
