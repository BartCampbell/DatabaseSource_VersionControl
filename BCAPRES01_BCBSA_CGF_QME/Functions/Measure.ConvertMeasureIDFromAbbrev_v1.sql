SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns the MeasureID associated with the specified character abbreviation.
-- =============================================
CREATE FUNCTION [Measure].[ConvertMeasureIDFromAbbrev_v1]
(
	@value varchar(16)
)
RETURNS int 
AS
BEGIN
	RETURN (SELECT TOP 1 MeasureID FROM Measure.Measures WITH(NOLOCK) WHERE (Abbrev = @value));
END


GO
GRANT EXECUTE ON  [Measure].[ConvertMeasureIDFromAbbrev_v1] TO [Processor]
GO
