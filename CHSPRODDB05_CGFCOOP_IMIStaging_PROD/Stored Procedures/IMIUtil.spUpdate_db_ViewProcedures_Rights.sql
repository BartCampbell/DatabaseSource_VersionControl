SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*************************************************************************************
Procedure:	
Author:		Leon Dowling
Copyright:	© 2014
Date:		2014.01.01
Purpose:	
Parameters: 
Depends On:	
Calls:		
Called By:	
Returns:	None
Notes:		
Update Log:

Process:	
Test Script: 
ToDo:		

*/

create PROC [IMIUtil].[spUpdate_db_ViewProcedures_Rights]

AS

-- Make sure role exists
DECLARE @rolelist TABLE (RoleName VARCHAR(200),RoleID INT, ISAppRole INT)

INSERT INTO @rolelist
	EXEC sp_helprole

IF NOT EXISTS (SELECT * FROM @rolelist WHERE RoleName = 'db_ViewProcedures')
	CREATE ROLE [db_ViewProcedures]	

-- Assign VIEW DEFINITION to all stored procs
DECLARE @vcCMD VARCHAR(MAX) = ''

SELECT @vcCMD = @vcCMD +  'GRANT VIEW DEFINITION ON ' + OBJECT_SCHEMA_NAME(id) + '.' + so.name + ' TO [db_ViewProcedures];' + CHAR(13)
--SELECT name, OBJECT_SCHEMA_NAME(id)
	FROM sys.sysobjects so
	WHERE xtype = 'P'

PRINT @vcCMD
EXEC (@vcCmd)

GO
GRANT VIEW DEFINITION ON  [IMIUtil].[spUpdate_db_ViewProcedures_Rights] TO [db_ViewProcedures]
GO
