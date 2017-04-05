SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/19/2013
-- Description:	Returns the abbreviation associated with the specified MeasureID.
-- =============================================
CREATE FUNCTION [Measure].[ConvertMeasureIDToAbbrev]
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
						MMS.Abbrev + @delimiter + MM.Abbrev
				FROM	Measure.Measures AS MM WITH(NOLOCK) 
						INNER JOIN Measure.MeasureSets AS MMS WITH(NOLOCK)
								ON MM.MeasureSetID = MMS.MeasureSetID
				WHERE	(MeasureID = @value)
			);
END

GO
GRANT EXECUTE ON  [Measure].[ConvertMeasureIDToAbbrev] TO [Analyst]
GO
GRANT EXECUTE ON  [Measure].[ConvertMeasureIDToAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertMeasureIDToAbbrev] TO [Submitter]
GO
