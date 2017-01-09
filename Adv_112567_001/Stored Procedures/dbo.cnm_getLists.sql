SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cnm_getLists 1 
Create PROCEDURE [dbo].[cnm_getLists]  
	@user int 
AS 
BEGIN 
	SELECT Channel_PK, Channel_Name FROM tblChannel ORDER BY Channel_Name 
 
	SELECT DISTINCT CS.ChaseStatusGroup_PK, CS.ChaseStatus, MIN(CS.ChaseStatus_PK) ChaseStatus_PK,CS.ChartResolutionCode FROM tblChaseStatus CS 
	GROUP BY CS.ChaseStatusGroup_PK, CS.ChaseStatus, CS.ChartResolutionCode 
	ORDER BY  CS.ChaseStatus, CS.ChartResolutionCode 
END 
GO
