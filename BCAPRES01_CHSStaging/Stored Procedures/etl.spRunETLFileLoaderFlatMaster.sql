SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****************************************************************************************************************************************************
Description:	Exec ETLFileLoaderFlatMaster.dtsx 
Use:

DECLARE @ExecutionStatus INT
EXEC etl.spRunETLFileLoaderFlatMaster
	100023 -- @FileSetID INT
	, @ExecutionStatus OUTPUT

SELECT @ExecutionStatus -- 7: Success

SELECT * FROM SSISDB.catalog.execution_parameter_values ORDER BY Execution_ID DESC

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2017-04-12	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROC [etl].[spRunETLFileLoaderFlatMaster]
    @FileSetID INT,
    @ExecutionStatus INT OUTPUT
AS
    SET NOCOUNT ON;

    BEGIN
	   
        --DECLARE @Environment AS NVARCHAR(100);
		DECLARE @ServerName AS NVARCHAR(100);
        DECLARE @ReferenceID BIGINT;
        DECLARE @execution_id BIGINT;

        SELECT  @ServerName = (SELECT CONVERT(NVARCHAR(100), SERVERPROPERTY('MachineName')) AS ServerName);
		/*
		--SET THE ENVIRONMENT BASED ON THE SERVER
		SELECT  @Environment = CASE @ServerName
			WHEN 'CHSDEVDB01' THEN 'DEV'
			ELSE 'PROD'
			END; 

        SELECT  @ReferenceID = ER.reference_id -- SELECT *
        FROM    
			SSISDB.catalog.environments AS E
			INNER JOIN SSISDB.catalog.folders AS F ON F.folder_id = E.folder_id
			INNER JOIN SSISDB.catalog.projects AS P ON P.folder_id = F.folder_id
			INNER JOIN SSISDB.catalog.environment_references AS ER ON ER.project_id = P.project_id
        WHERE
			1=1
			AND @Environment = 'DEV'
			AND F.name = 'Centauri'
			AND P.name = 'ETLFileLoader';
		*/

	   --GET THE EXECUTIONID
        EXEC SSISDB.catalog.create_execution 
			@package_name = N'ETLFileLoaderFlatMaster.dtsx'
			,@execution_id = @execution_id OUTPUT
			,@folder_name = N'Centauri'
            ,@project_name = N'ETLFileLoader'
			,@use32bitruntime = False
			--,@reference_id = @ReferenceID
			;

        SELECT  @execution_id AS Execution_ID;

	   -- Set package parameter values for the calling process: Use the value 20 to indicate a project parameter or the value 30 to indicate a package parameter.
		EXEC SSISDB.catalog.set_execution_parameter_value 
			@execution_id
			,@object_type = 30
			,@parameter_name = N'FileSetID'
			,@parameter_value = @FileSetID;

	   -- Set execution parameter for logging level
        DECLARE @var0 SMALLINT = 1;
        EXEC [SSISDB].[catalog].[set_execution_parameter_value] 
			@execution_id
			,@object_type = 50
			,@parameter_name = N'LOGGING_LEVEL'
			,@parameter_value = @var0;

		-- Set execution parameter for synchronized
		--DECLARE @synchronous SMALLINT = 1;
		--EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type = 50, @parameter_name = N'SYNCHRONIZED',
		--    @parameter_value = @synchronous;
	   
	   --EXECUTE THE PACKAGE
        EXEC [SSISDB].[catalog].[start_execution] @execution_id;

	   -- Show status
        SELECT @ExecutionStatus = [status] --AS [execution_status]
        FROM SSISDB.catalog.executions
        WHERE execution_id = @execution_id;

END


GO
