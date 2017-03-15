SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [internal].[start_execution_internal] (@project_id [bigint], @execution_id [bigint], @version_id [bigint], @use32BitRuntime [smallint])
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.ServerApi].[StartExecutionInternal]
GO
