SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [internal].[deploy_project_internal] (@deploy_id [bigint], @version_id [bigint], @project_id [bigint], @project_name [nvarchar] (128))
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.ServerApi].[DeployProjectInternal]
GO
