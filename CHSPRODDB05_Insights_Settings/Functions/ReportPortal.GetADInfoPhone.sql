SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/11/2015
-- Description:	Returns the user's phone number from active directory info XML.  
-- =============================================
CREATE FUNCTION [ReportPortal].[GetADInfoPhone]
(
	@ADInfo xml,
	@PrincipalTypeID tinyint
)
RETURNS varchar(64)
WITH SCHEMABINDING
AS
BEGIN
	RETURN (CASE 
				WHEN @PrincipalTypeID = 1 AND @ADInfo IS NOT NULL AND @ADInfo.exist('user[1]/@phone') = 1 
				THEN LOWER(@ADInfo.value('user[1]/@phone', 'varchar(64)')) 
				END);
END;

GO
GRANT EXECUTE ON  [ReportPortal].[GetADInfoPhone] TO [PortalApp]
GO
