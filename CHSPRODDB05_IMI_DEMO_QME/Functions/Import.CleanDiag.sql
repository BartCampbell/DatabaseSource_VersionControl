SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/9/2016
-- Description:	Cleans ICD-9 and ICD-10 codes, ensuring they meet standards (such as trimming ending periods).
-- =============================================
CREATE FUNCTION [Import].[CleanDiag]
(
	@Code varchar(16)
)
RETURNS varchar(16)
WITH SCHEMABINDING
AS
BEGIN
	RETURN (SELECT UPPER(CASE WHEN RIGHT(LTRIM(RTRIM(@Code)), 1) = '.' THEN LEFT(LTRIM(RTRIM(@Code)), LEN(LTRIM(RTRIM(@Code))) - 1) ELSE NULLIF(LTRIM(RTRIM(@Code)), '') END));
END

GO
GRANT EXECUTE ON  [Import].[CleanDiag] TO [Processor]
GO
