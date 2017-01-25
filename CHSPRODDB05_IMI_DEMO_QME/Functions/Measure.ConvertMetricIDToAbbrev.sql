SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/19/2013
-- Description:	Returns the abbreviation associated with the specified MetricID.
-- =============================================
CREATE FUNCTION [Measure].[ConvertMetricIDToAbbrev]
(
	@value int
)
RETURNS varchar(64)
AS
BEGIN
	DECLARE @delimiter varchar(16);
	SET @delimiter = ' :: ';

	RETURN	(
				SELECT TOP 1 
						MMS.Abbrev + @delimiter + MX.Abbrev 
				FROM	Measure.Metrics AS MX WITH(NOLOCK)
						INNER JOIN Measure.Measures AS MM WITH(NOLOCK)
								ON MX.MeasureID = MM.MeasureID
						INNER JOIN Measure.MeasureSets AS MMS WITH(NOLOCK)
								ON MM.MeasureSetID = MMS.MeasureSetID
				WHERE	(MetricID = @value)
			);
END

GO
GRANT EXECUTE ON  [Measure].[ConvertMetricIDToAbbrev] TO [Analyst]
GO
GRANT EXECUTE ON  [Measure].[ConvertMetricIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertMetricIDToAbbrev] TO [Submitter]
GO
