SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/26/2016
-- Description:	Returns the DDMMYYYY representation of the specified date
-- =============================================
CREATE FUNCTION [dbo].[ConvertDateToDDMMYYYY]
(
	@value datetime
)
RETURNS char(8)
WITH SCHEMABINDING
AS
BEGIN
	RETURN (RIGHT(CONVERT(char(8), @value, 112), 2) + SUBSTRING(CONVERT(char(8), @value, 112), 5, 2) + LEFT(CONVERT(char(8), @value, 112), 4));
END
GO
