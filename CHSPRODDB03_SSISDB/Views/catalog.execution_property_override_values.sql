SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [catalog].[execution_property_override_values]
AS
SELECT     [property_id], 
           [execution_id],
           [property_path], 
           [property_value], 
           [sensitive]
FROM       [internal].[execution_property_override_values]
WHERE      [execution_id] in (SELECT [id] FROM [internal].[current_user_readable_operations])
           OR (IS_MEMBER('ssis_admin') = 1)
           OR (IS_SRVROLEMEMBER('sysadmin') = 1)
GO
GRANT SELECT ON  [catalog].[execution_property_override_values] TO [public]
GO
