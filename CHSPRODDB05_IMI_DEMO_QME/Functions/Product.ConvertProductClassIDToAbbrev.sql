SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/29/2011
-- Description:	Returns the abbreviation associated with the specified ProductClassID.
-- =============================================
CREATE FUNCTION [Product].[ConvertProductClassIDToAbbrev]
(
	@value tinyint
)
RETURNS varchar(8)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Product.ProductClasses WITH(NOLOCK) WHERE (ProductClassID = @value));
END

GO
GRANT EXECUTE ON  [Product].[ConvertProductClassIDToAbbrev] TO [Analyst]
GO
GRANT EXECUTE ON  [Product].[ConvertProductClassIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Product].[ConvertProductClassIDToAbbrev] TO [Submitter]
GO
