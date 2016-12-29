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
	Create TABLE #Pool(Pool_PK INT,SOrder1 INT,SOrder2 INT)
	INSERT INTO #Pool
	SELECT Pool_PK,1 SOrder1,ROW_NUMBER() OVER(ORDER BY Pool_Priority) AS SOrder2 FROM tblPool WHERE IsAutoRefreshPool=1 AND IsForcedAllocationAllowed=0
	INSERT INTO #Pool
	SELECT Pool_PK,2 SOrder1,ROW_NUMBER() OVER(ORDER BY Pool_Priority DESC) AS SOrder2  FROM tblPool WHERE IsAutoRefreshPool=1 AND IsForcedAllocationAllowed=1

	DECLARE @Pool AS INT
	DECLARE db_cursor CURSOR FOR  
	SELECT Pool_PK FROM #Pool ORDER BY SOrder1, SOrder2

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
