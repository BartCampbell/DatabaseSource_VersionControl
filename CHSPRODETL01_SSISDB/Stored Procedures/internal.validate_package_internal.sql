SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [internal].[validate_package_internal] (@project_id [bigint], @package_id [bigint], @version_id [bigint], @validation_id [bigint], @environment_scope [nchar] (1), @use32bitruntime [smallint])
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.ServerApi].[ValidatePackageInternal]
GO
