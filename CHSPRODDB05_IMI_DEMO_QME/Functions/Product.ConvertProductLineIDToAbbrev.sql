SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/24/2011
-- Description:	Returns the abbreviation associated with the specified ProductLineID.
-- =============================================
CREATE FUNCTION [Product].[ConvertProductLineIDToAbbrev]
(
	@value smallint
)
RETURNS varchar(8)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Product.ProductLines WITH(NOLOCK) WHERE (ProductLineID = @value));
END

GO
GRANT EXECUTE ON  [Product].[ConvertProductLineIDToAbbrev] TO [Analyst]
GO
GRANT EXECUTE ON  [Product].[ConvertProductLineIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Product].[ConvertProductLineIDToAbbrev] TO [Submitter]
GO
