SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Converts the specified (M)ale/(F)emale value to the corresponding numeric value.
-- =============================================
CREATE FUNCTION [Member].[ConvertGenderFromMF]
(
	@value char(1)
)
RETURNS tinyint
WITH SCHEMABINDING
AS
BEGIN
	RETURN (SELECT CASE @value WHEN 'M' THEN 1 WHEN 'F' THEN 0 ELSE 2 END);
END
GO
GRANT EXECUTE ON  [Member].[ConvertGenderFromMF] TO [Processor]
GO
GRANT EXECUTE ON  [Member].[ConvertGenderFromMF] TO [Submitter]
GO
