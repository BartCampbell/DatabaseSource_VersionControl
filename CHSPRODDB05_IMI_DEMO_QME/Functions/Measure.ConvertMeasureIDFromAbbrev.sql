SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/19/2013
-- Description:	Returns the MeasureID associated with the specified character abbreviation.
-- =============================================
CREATE FUNCTION [Measure].[ConvertMeasureIDFromAbbrev]
(
	@value varchar(64)
)
RETURNS int 
AS
BEGIN
	DECLARE @delimiter varchar(16);
	SET @delimiter = ' :: ';

	DECLARE @MeasureAbbrev varchar(16);
	DECLARE @MeasureSetAbbrev varchar(16);
	
	IF CHARINDEX(@delimiter, @value) > 0
		BEGIN;
			SET @MeasureAbbrev = SUBSTRING(@value, CHARINDEX(@delimiter, @value) + DATALENGTH(@delimiter), LEN(@value) - CHARINDEX(@delimiter, @value) - DATALENGTH(@delimiter) + 1);
			SET @MeasureSetAbbrev = SUBSTRING(@value, 1, CHARINDEX(@delimiter, @value) - 1);
		END;
	
	RETURN	(
				SELECT TOP 1 
						MeasureID 
				FROM	Measure.Measures AS MM WITH(NOLOCK) 
						INNER JOIN Measure.MeasureSets AS MMS WITH(NOLOCK) 
								ON MM.MeasureSetID = MMS.MeasureSetID  
				WHERE	(MM.Abbrev = @MeasureAbbrev) AND
						(MMS.Abbrev = @MeasureSetAbbrev)
			);
END

GO
GRANT EXECUTE ON  [Measure].[ConvertMeasureIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertMeasureIDFromAbbrev] TO [Submitter]
GO
