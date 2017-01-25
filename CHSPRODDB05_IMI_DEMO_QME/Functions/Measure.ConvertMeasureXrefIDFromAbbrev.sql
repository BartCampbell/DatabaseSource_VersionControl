SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/24/2013
-- Description:	Returns the MeasureXrefID associated with the specified character abbreviation.
-- =============================================
CREATE FUNCTION [Measure].[ConvertMeasureXrefIDFromAbbrev]
(
	@value varchar(16)
)
RETURNS int 
AS
BEGIN
	RETURN (SELECT TOP 1 MeasureXrefID FROM Measure.MeasureXrefs WITH(NOLOCK) WHERE (Abbrev = @value));
END



GO
GRANT EXECUTE ON  [Measure].[ConvertMeasureXrefIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertMeasureXrefIDFromAbbrev] TO [Submitter]
GO
