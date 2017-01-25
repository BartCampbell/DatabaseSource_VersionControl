SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[ConvertDateTimeToVarchar] 
(
	@Value datetime
)
RETURNS varchar(32)
WITH SCHEMABINDING
AS
BEGIN

	--Example:  01/29/2015 02:56:53 PM
	
	RETURN (SELECT CONVERT(varchar(10), MONTH(@Value)) + '/' + CONVERT(varchar(10), DAY(@Value)) + '/' + CONVERT(varchar(10), YEAR(@Value)) + ' ' + 
					CONVERT(varchar(32), DATEPART(hh, @Value) + CASE WHEN DATEPART(hh, @Value) > 12 THEN -12 ELSE 0 END) + ':' + 
					CASE WHEN DATEPART(n, @Value) < 10 THEN '0' ELSE '' END + CONVERT(varchar(32), DATEPART(n, @Value)) + ':' + 
					CASE WHEN DATEPART(ss, @Value) < 10 THEN '0' ELSE '' END + CONVERT(varchar(32), DATEPART(ss, @Value)) + ' ' + 
					CASE WHEN DATEPART(hh, @Value) > 12 THEN 'PM' ELSE 'AM' END);

END

GO
GRANT EXECUTE ON  [dbo].[ConvertDateTimeToVarchar] TO [Processor]
GO
