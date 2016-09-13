SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- SELECT [dbo].[ca_udf_GetUserModules](54)
CREATE FUNCTION [dbo].[ca_udf_GetUserModules]
(	
	@UserPK INT
)
RETURNS VARCHAR(MAX) 
AS
BEGIN
	DECLARE @RETURN VARCHAR(MAX)
	DECLARE @PROJECT VARCHAR(100)
	SET @RETURN = '';

	DECLARE db_cursor CURSOR FOR  
		SELECT DISTINCT P.page_caption 
			FROM tblPage P  
				INNER JOIN tblUserPage UP ON UP.Page_PK=P.Page_PK
			WHERE UP.User_PK=@UserPK AND P.isActive=0

	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @PROJECT

	WHILE @@FETCH_STATUS = 0   
	BEGIN  
			IF (@RETURN<>'')
				SET @RETURN = @RETURN + ', '
				
		   SET @RETURN = @RETURN + @PROJECT

		   FETCH NEXT FROM db_cursor INTO @PROJECT
	END   

	CLOSE db_cursor   
	DEALLOCATE db_cursor	
	
	RETURN @RETURN;
END
GO
