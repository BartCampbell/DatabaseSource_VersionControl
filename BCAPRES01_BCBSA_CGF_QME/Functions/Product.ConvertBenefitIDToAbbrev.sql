SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns the abbreviation associated with the specified BenefitID.
-- =============================================
CREATE FUNCTION [Product].[ConvertBenefitIDToAbbrev]
(
	@value smallint
)
RETURNS varchar(16)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Product.Benefits WITH(NOLOCK) WHERE (BenefitID = @value));
END

GO
GRANT EXECUTE ON  [Product].[ConvertBenefitIDToAbbrev] TO [Analyst]
GO
GRANT EXECUTE ON  [Product].[ConvertBenefitIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Product].[ConvertBenefitIDToAbbrev] TO [Submitter]
GO
