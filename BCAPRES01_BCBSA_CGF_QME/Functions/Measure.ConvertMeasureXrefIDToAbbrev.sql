SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/24/2013
-- Description:	Returns the abbreviation associated with the specified MeasureXrefID.
-- =============================================
CREATE FUNCTION [Measure].[ConvertMeasureXrefIDToAbbrev]
(
	@value int
)
RETURNS varchar(16)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Measure.MeasureXrefs WITH(NOLOCK) WHERE (MeasureXrefID = @value));
END



GO
GRANT EXECUTE ON  [Measure].[ConvertMeasureXrefIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertMeasureXrefIDToAbbrev] TO [Submitter]
GO
