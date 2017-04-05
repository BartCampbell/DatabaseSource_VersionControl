SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/26/2014
-- Description:	Returns the risk category associated with the specified abbreviation.
-- =============================================
CREATE FUNCTION [Ncqa].[RRU_ConvertRiskCtgyIDFromAbbrev]
(
	@value varchar(16)
)
RETURNS tinyint 
AS
BEGIN
	RETURN (SELECT TOP 1 RiskCtgyID FROM Ncqa.RRU_RiskCategories WITH(NOLOCK) WHERE (Abbrev = @value));
END

GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertRiskCtgyIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertRiskCtgyIDFromAbbrev] TO [Submitter]
GO
