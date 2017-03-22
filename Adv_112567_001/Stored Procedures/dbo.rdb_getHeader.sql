SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Sample Executions
rdb_getHeader '1,2','0','0','0','0'
*/
CREATE PROCEDURE [dbo].[rdb_getHeader]
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@Status1 varchar(1000),
	@Status2 varchar(1000)
AS
BEGIN
	IF (@Channel<>'0')
		EXEC ('SELECT DISTINCT Channel_Name FROM tblChannel T WHERE Channel_PK IN ('+@Channel+')')	
	ELSE
		SELECT 'All'

	IF (@Projects<>'0')
		EXEC ('SELECT DISTINCT Project_Name FROM tblProject WHERE Project_PK IN ('+@Projects+')')
	ELSE
		SELECT 'All'

	IF (@ProjectGroup<>'0')
		EXEC ('SELECT DISTINCT ProjectGroup FROM tblProject P WHERE ProjectGroup_PK IN ('+@ProjectGroup+')')
	ELSE
		SELECT 'All'		

	IF (@Status1<>'0')
		EXEC ('SELECT DISTINCT ChaseStatus FROM tblChaseStatus T WHERE ChaseStatusGroup_PK IN ('+@Status1+')')	
	ELSE
		SELECT 'All'
				
	IF (@Status2<>'0')
		EXEC ('SELECT DISTINCT ChartResolutionCode FROM tblChaseStatus T WHERE ChaseStatus_PK IN ('+@Status2+')')						 
	ELSE
		SELECT 'All'

END
GO
