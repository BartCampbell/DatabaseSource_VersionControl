SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Converts the specified gender number value to the corresponding (M)ale/(F)emale value.
-- =============================================
CREATE FUNCTION [Member].[ConvertGenderToMF]
(
	@value tinyint 
)
RETURNS char(1)
WITH SCHEMABINDING
AS
BEGIN
	RETURN (SELECT CASE @value WHEN 0 THEN 'F' WHEN 1 THEN 'M' END)
END
GO
GRANT EXECUTE ON  [Member].[ConvertGenderToMF] TO [Analyst]
GO
GRANT EXECUTE ON  [Member].[ConvertGenderToMF] TO [Processor]
GO
GRANT EXECUTE ON  [Member].[ConvertGenderToMF] TO [Submitter]
GO
