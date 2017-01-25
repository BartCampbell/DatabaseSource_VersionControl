SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/3/2015
-- Description:	Returns the domain's unique ID from active directory info XML.  
-- =============================================
CREATE FUNCTION [ReportPortal].[GetADInfoGuid]
(
	@ADInfo xml,
	@PrincipalTypeID tinyint
)
RETURNS uniqueidentifier
WITH SCHEMABINDING
AS
BEGIN
	RETURN (CASE 
				WHEN @PrincipalTypeID = 1 AND @ADInfo IS NOT NULL AND @ADInfo.exist('user[1]/@id') = 1 
				THEN LOWER(@ADInfo.value('user[1]/@id', 'uniqueidentifier')) 
				WHEN @PrincipalTypeID = 2 AND @ADInfo IS NOT NULL AND @ADInfo.exist('group[1]/@id') = 1 
				THEN LOWER(@ADInfo.value('group[1]/@id', 'uniqueidentifier')) 
				END);
END;


GO
GRANT EXECUTE ON  [ReportPortal].[GetADInfoGuid] TO [PortalApp]
GO
