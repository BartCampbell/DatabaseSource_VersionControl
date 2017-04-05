SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/24/2011
-- Description:	Returns the abbreviation associated with the specified MeasureID.
-- =============================================
CREATE FUNCTION [Measure].[ConvertMeasureIDToAbbrev_v1]
(
	@value int
)
RETURNS varchar(16)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Measure.Measures WITH(NOLOCK) WHERE (MeasureID = @value));
END


GO
GRANT EXECUTE ON  [Measure].[ConvertMeasureIDToAbbrev_v1] TO [Processor]
GO
