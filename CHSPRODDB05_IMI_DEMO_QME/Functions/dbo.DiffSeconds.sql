SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 12/6/2013
-- Description:	Returns the number of seconds between to specified times.  
--				(Prevents overflow in second diffs greater than 25000+ days).
-- =============================================
CREATE FUNCTION [dbo].[DiffSeconds] 
(
	@BeginTime datetime,
	@EndTime datetime
)
RETURNS bigint
WITH SCHEMABINDING
AS
BEGIN
	DECLARE @BeginTimeOnly datetime;
	DECLARE @EndTimeOnly datetime;
	
	SET @BeginTimeOnly = DATEADD(second, DATEDIFF(second, DATEADD(dd, DATEDIFF(dd, 0, @BeginTime) - 1, 0), @BeginTime), 0);
	SET @EndTimeOnly = DATEADD(second, DATEDIFF(second, DATEADD(dd, DATEDIFF(dd, 0, @EndTime) - 1, 0), @EndTime), 0);

	RETURN (SELECT CONVERT(bigint, DATEDIFF(day, DATEADD(dd, DATEDIFF(dd, 0, @BeginTime) - 1, 0), DATEADD(dd, DATEDIFF(dd, 0, @EndTime) - 1, 0))) * 24 * 3600 +
					CONVERT(bigint, DATEDIFF(second, @BeginTimeOnly, @EndTimeOnly)));

END

GO
GRANT EXECUTE ON  [dbo].[DiffSeconds] TO [Processor]
GO
