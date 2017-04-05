SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 12/17/2013
-- Description:	Cleans UB Revenue and Type of Bill codes, ensuring they have 4 digits.
-- =============================================
CREATE FUNCTION [Import].[CleanUB]
(
	@Code varchar(16)
)
RETURNS varchar(16)
WITH SCHEMABINDING
AS
BEGIN
	RETURN (SELECT UPPER(CASE WHEN LEN(LTRIM(RTRIM(@Code))) = 3 THEN '0' + LTRIM(RTRIM(@Code)) WHEN LEN(LTRIM(RTRIM(@Code))) = 4 THEN NULLIF(LTRIM(RTRIM(@Code)), '') END));
END
GO
GRANT EXECUTE ON  [Import].[CleanUB] TO [Processor]
GO
