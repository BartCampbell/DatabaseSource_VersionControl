SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/26/2014
-- Description:	Returns the abbreviation associated with the specified PriceCtgyID.
-- =============================================
CREATE FUNCTION [Ncqa].[RRU_ConvertPriceCtgyIDToAbbrev]
(
	@value tinyint
)
RETURNS varchar(16)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Ncqa.RRU_PriceCategories WITH(NOLOCK) WHERE (PriceCtgyID = @value));
END
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertPriceCtgyIDToAbbrev] TO [Analyst]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertPriceCtgyIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertPriceCtgyIDToAbbrev] TO [Submitter]
GO
