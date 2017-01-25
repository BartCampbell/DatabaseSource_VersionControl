SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/5/2011
-- Description:	Returns a value indicating whether or not the specified entity has corresponding enrollment records assigned.
-- =============================================
CREATE FUNCTION [Measure].[HasEntityEnrollment]
(
	@EntityID int
)
RETURNS bit
AS
BEGIN
	DECLARE @Result bit;

	IF EXISTS (SELECT TOP 1 1 FROM Measure.EntityEnrollment WHERE EntityID = @EntityID)
		SET @Result = 1;
	ELSE
		SET @Result = 0;

	RETURN @Result;
END
GO
GRANT EXECUTE ON  [Measure].[HasEntityEnrollment] TO [Processor]
GO
