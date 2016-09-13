SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sa_refreshPools
CREATE PROCEDURE [dbo].[sa_refreshPools] 
AS
BEGIN
	DECLARE @Pool AS INT
	DECLARE db_cursor CURSOR FOR  
	SELECT Pool_PK FROM tblPool WHERE IsAutoRefreshPool=1 ORDER BY Pool_Priority

	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @Pool   

	WHILE @@FETCH_STATUS = 0   
	BEGIN   
		   EXEC sa_execPool @Pool;

		   FETCH NEXT FROM db_cursor INTO @Pool   
	END   

	CLOSE db_cursor   
	DEALLOCATE db_cursor
END
GO
