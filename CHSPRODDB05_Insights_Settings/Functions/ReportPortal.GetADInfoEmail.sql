SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/11/2015
-- Description:	Returns the user's email address from active directory info XML.  
-- =============================================
CREATE FUNCTION [ReportPortal].[GetADInfoEmail]
(
	@ADInfo xml,
	@PrincipalTypeID tinyint
)
RETURNS varchar(256)
WITH SCHEMABINDING
AS
BEGIN
	RETURN (CASE 
				WHEN @PrincipalTypeID = 1 AND @ADInfo IS NOT NULL AND @ADInfo.exist('user[1]/@email') = 1 
				THEN LOWER(@ADInfo.value('user[1]/@email', 'varchar(256)')) 
				END);
END;

GO
GRANT EXECUTE ON  [ReportPortal].[GetADInfoEmail] TO [PortalApp]
GO
