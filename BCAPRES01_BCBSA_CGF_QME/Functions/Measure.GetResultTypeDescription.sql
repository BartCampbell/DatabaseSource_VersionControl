SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/17/2011
-- Description:	Returns the user-friendly description for the specified result type
-- =============================================
CREATE FUNCTION [Measure].[GetResultTypeDescription] 
(
	@ResultTypeID tinyint
)
RETURNS varchar(32)
AS
BEGIN
	DECLARE @Result varchar(32);

	SELECT	@Result = CASE @ResultTypeID
							WHEN 2 THEN 'Medical Record'
							WHEN 3 THEN 'Hybrid'
							ELSE 'Administrative'
						END;
							
	RETURN @Result;
END
GO
GRANT EXECUTE ON  [Measure].[GetResultTypeDescription] TO [Processor]
GO
