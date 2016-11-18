SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [catalog].[operations]
AS
SELECT     [operation_id], 
           [operation_type], 
           [created_time],
           [object_type],
           [object_id],
           [object_name],
           [status], 
           [start_time], 
           [end_time], 
           [caller_sid], 
           [caller_name], 
           [process_id],
           [stopped_by_sid],
           [stopped_by_name],
           [server_name],
           [machine_name]
FROM       internal.[operations]
WHERE      [operation_id] in (SELECT [id] FROM [internal].[current_user_readable_operations])
           OR (IS_MEMBER('ssis_admin') = 1)
           OR (IS_SRVROLEMEMBER('sysadmin') = 1)
GO
GRANT SELECT ON  [catalog].[operations] TO [public]
GO
