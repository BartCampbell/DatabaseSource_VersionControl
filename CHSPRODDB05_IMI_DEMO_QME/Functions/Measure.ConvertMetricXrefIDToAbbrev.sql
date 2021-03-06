SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/24/2013
-- Description:	Returns the abbreviation associated with the specified MetricXrefID.
-- =============================================
CREATE FUNCTION [Measure].[ConvertMetricXrefIDToAbbrev]
(
	@value int
)
RETURNS varchar(16)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Measure.MetricXrefs WITH(NOLOCK) WHERE (MetricXrefID = @value));
END



GO
GRANT EXECUTE ON  [Measure].[ConvertMetricXrefIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertMetricXrefIDToAbbrev] TO [Submitter]
GO
