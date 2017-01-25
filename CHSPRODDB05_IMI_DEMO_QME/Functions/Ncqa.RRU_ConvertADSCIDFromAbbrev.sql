SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/26/2014
-- Description:	Returns the ADSCID associated with the specified abbreviation.
-- =============================================
CREATE FUNCTION [Ncqa].[RRU_ConvertADSCIDFromAbbrev]
(
	@value varchar(4)
)
RETURNS smallint 
AS
BEGIN
	RETURN (SELECT TOP 1 ADSCID FROM Ncqa.RRU_ADSC WITH(NOLOCK) WHERE (Abbrev = @value));
END
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertADSCIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertADSCIDFromAbbrev] TO [Submitter]
GO
