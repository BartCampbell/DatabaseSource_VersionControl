SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 12/6/2013
-- Description:	Returns the number of milliseconds between to specified times.  
--				(Prevents overflow in millisecond diffs greater than 25 days).
-- =============================================
CREATE FUNCTION [dbo].[DiffMilliseconds] 
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
	
	SET @BeginTimeOnly = DATEADD(millisecond, DATEDIFF(millisecond, DATEADD(dd, DATEDIFF(dd, 0, @BeginTime) - 1, 0), @BeginTime), 0);
	SET @EndTimeOnly = DATEADD(millisecond, DATEDIFF(millisecond, DATEADD(dd, DATEDIFF(dd, 0, @EndTime) - 1, 0), @EndTime), 0);

	RETURN (SELECT CONVERT(bigint, DATEDIFF(day, DATEADD(dd, DATEDIFF(dd, 0, @BeginTime) - 1, 0), DATEADD(dd, DATEDIFF(dd, 0, @EndTime) - 1, 0))) * 24 * 3600 * 1000 +
					CONVERT(bigint, DATEDIFF(millisecond, @BeginTimeOnly, @EndTimeOnly)));

END
GO
GRANT EXECUTE ON  [dbo].[DiffMilliseconds] TO [Processor]
GO
