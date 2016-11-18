SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- =============================================
-- Author:		Travis Parker
-- Create date:	08/08/2016
-- Description:	Executes the Business Rules Engine
-- Usage:			
--		  EXECUTE bre.spRunBusinessRulesEngine
-- =============================================
CREATE PROC [bre].[spRunBusinessRulesEngine]
    @CallingProcess NVARCHAR(50),
    @ExecutionStatus INT OUTPUT
AS
    SET NOCOUNT ON;

    BEGIN
	   
        DECLARE @Environment AS NVARCHAR(100);
        DECLARE @ServerName AS NVARCHAR(100);
        DECLARE @referenceid BIGINT;
        DECLARE @execution_id BIGINT;

        SELECT  @ServerName = ( SELECT  CONVERT(NVARCHAR(100), SERVERPROPERTY('MachineName')) AS ServerName
                              );

	   --SET THE ENVIRONMENT BASED ON THE SERVER
        SELECT  @Environment = CASE @ServerName
                                 WHEN 'CHSDEVDB01' THEN 'DEV'
                                 ELSE 'PROD'
                               END; 


	   --GET THE REFERENCEID FOR THE BRE
        SELECT  @referenceid = ER.reference_id
        FROM    SSISDB.catalog.environments AS E
                INNER JOIN SSISDB.catalog.folders AS F ON F.folder_id = E.folder_id
                INNER JOIN SSISDB.catalog.projects AS P ON P.folder_id = F.folder_id
                INNER JOIN SSISDB.catalog.environment_references AS ER ON ER.project_id = P.project_id
        WHERE   @Environment = 'DEV'
                AND F.name = 'Centauri'
                AND P.name = 'BusinessRuleEngine';

	   --GET THE EXECUTIONID
        EXEC [SSISDB].[catalog].[create_execution] @package_name = N'BRE_Main.dtsx', @execution_id = @execution_id OUTPUT, @folder_name = N'Centauri',
            @project_name = N'BusinessRuleEngine', @use32bitruntime = False, @reference_id = @referenceid;
        SELECT  @execution_id;

	   -- Set package parameter value for the calling process
	   EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id
		   ,@object_type = 30
		   ,@parameter_name = N'CallingProcess'
		   ,@parameter_value = @CallingProcess

	   -- Set execution parameter for logging level
        DECLARE @var0 SMALLINT = 1;
        EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type = 50, @parameter_name = N'LOGGING_LEVEL', @parameter_value = @var0;

	   -- Set execution parameter for synchronized
        DECLARE @synchronous SMALLINT = 1;
        EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type = 50, @parameter_name = N'SYNCHRONIZED',
            @parameter_value = @synchronous;
	   
	   --EXECUTE THE PACKAGE
        EXEC [SSISDB].[catalog].[start_execution] @execution_id;

	   -- Show status
        SELECT  @ExecutionStatus = [status] --AS [execution_status]
        FROM    SSISDB.catalog.executions
        WHERE   execution_id = @execution_id;

    END;     

GO
