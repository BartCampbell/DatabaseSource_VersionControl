SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[ConvertDateToVarchar] 
(
	@Value datetime
)
RETURNS varchar(10)
WITH SCHEMABINDING
AS
BEGIN
	
	RETURN (SELECT CONVERT(varchar(10), MONTH(@Value)) + '/' + CONVERT(varchar(10), DAY(@Value)) + '/' + CONVERT(varchar(10), YEAR(@Value)));

END
GO
