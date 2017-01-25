SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/3/2015
-- Description:	Returns the SAM account name from active directory info XML.  
-- =============================================
CREATE FUNCTION [ReportPortal].[GetADInfoSamAccountName]
(
	@ADInfo xml,
	@PrincipalTypeID tinyint
)
RETURNS nvarchar(128)
WITH SCHEMABINDING
AS
BEGIN
	RETURN (CASE 
				WHEN @PrincipalTypeID = 1 AND @ADInfo IS NOT NULL AND @ADInfo.exist('user[1]/@samaccountname') = 1 
				THEN LOWER(@ADInfo.value('user[1]/@samaccountname', 'nvarchar(128)')) 
				WHEN @PrincipalTypeID = 2 AND @ADInfo IS NOT NULL AND @ADInfo.exist('group[1]/@samaccountname') = 1 
				THEN LOWER(@ADInfo.value('group[1]/@samaccountname', 'nvarchar(128)')) 
				END);
END;

GO
GRANT EXECUTE ON  [ReportPortal].[GetADInfoSamAccountName] TO [PortalApp]
GO
