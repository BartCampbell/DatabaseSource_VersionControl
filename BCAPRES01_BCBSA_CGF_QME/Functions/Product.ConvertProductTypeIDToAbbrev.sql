SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/29/2011
-- Description:	Returns the abbreviation associated with the specified ProductTypeID.
-- =============================================
CREATE FUNCTION [Product].[ConvertProductTypeIDToAbbrev]
(
	@value tinyint
)
RETURNS varchar(8)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Product.ProductTypes WITH(NOLOCK) WHERE (ProductTypeID = @value));
END

GO
GRANT EXECUTE ON  [Product].[ConvertProductTypeIDToAbbrev] TO [Analyst]
GO
GRANT EXECUTE ON  [Product].[ConvertProductTypeIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Product].[ConvertProductTypeIDToAbbrev] TO [Submitter]
GO
