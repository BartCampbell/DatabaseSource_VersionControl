SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/29/2011
-- Description:	Returns the ProductTypeID associated with the specified character abbreviation.
-- =============================================
CREATE FUNCTION [Product].[ConvertProductTypeIDFromAbbrev]
(
	@value varchar(8)
)
RETURNS tinyint 
AS
BEGIN
	RETURN (SELECT TOP 1 ProductTypeID FROM Product.ProductTypes WITH(NOLOCK) WHERE (Abbrev = @value));
END

GO
GRANT EXECUTE ON  [Product].[ConvertProductTypeIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Product].[ConvertProductTypeIDFromAbbrev] TO [Submitter]
GO
