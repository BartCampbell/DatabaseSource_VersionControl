SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [catalog].[get_version_log_size]()
RETURNS bigint
AS 
BEGIN
    DECLARE @value bigint
    SELECT @value = internal.get_space_used('internal.object_versions')
    RETURN @value
END
GO
GRANT EXECUTE ON  [catalog].[get_version_log_size] TO [ssis_admin]
GO
