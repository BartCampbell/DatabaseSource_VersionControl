SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/19/2013
-- Description:	Returns the MetricID associated with the specified character abbreviation.
-- =============================================
CREATE FUNCTION [Measure].[ConvertMetricIDFromAbbrev]
(
	@value varchar(64)
)
RETURNS int 
AS
BEGIN
	DECLARE @delimiter varchar(16);
	SET @delimiter = ' :: ';

	DECLARE @MeasureSetAbbrev varchar(16);
	DECLARE @MetricAbbrev varchar(16);
	
	IF CHARINDEX(@delimiter, @value) > 0
		BEGIN;
			SET @MeasureSetAbbrev = SUBSTRING(@value, 1, CHARINDEX(@delimiter, @value) - 1);
			SET @MetricAbbrev = SUBSTRING(@value, CHARINDEX(@delimiter, @value) + DATALENGTH(@delimiter), LEN(@value) - CHARINDEX(@delimiter, @value) - DATALENGTH(@delimiter) + 1);
		END;
		
	RETURN	(
				SELECT TOP 1 
						MetricID 
				FROM	Measure.Metrics AS MX WITH(NOLOCK)
						INNER JOIN Measure.Measures AS MM WITH(NOLOCK)
								ON MX.MeasureID = MM.MeasureID
						INNER JOIN Measure.MeasureSets AS MMS WITH(NOLOCK)
								ON MM.MeasureSetID = MMS.MeasureSetID
				WHERE	(MMS.Abbrev = @MeasureSetAbbrev) AND
						(MX.Abbrev = @MetricAbbrev)
			);
END

GO
GRANT EXECUTE ON  [Measure].[ConvertMetricIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertMetricIDFromAbbrev] TO [Submitter]
GO
