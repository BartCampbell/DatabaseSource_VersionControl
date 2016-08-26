SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- um_exportUsers
CREATE PROCEDURE [dbo].[um_exportUsers] 
AS
BEGIN
	SELECT CASE WHEN IsActive=1 THEN 'YES' END [Active]
		,Username,Lastname+', '+Firstname Fullname,Email_Address [Email]
		,CASE WHEN IsClient=1 THEN 'YES' END  [Client],CASE WHEN IsAdmin=1 THEN 'YES' END  [Admin]
		,CASE WHEN IsScanTechSV=1 THEN 'YES' END  [Scan Tech Supervisor],CASE WHEN IsScanTech=1 THEN 'YES' END  [Scan Tech]
		,CASE WHEN IsSchedulerSV=1 THEN 'YES' END  [Scheduler Supervisor],CASE WHEN IsScheduler=1 THEN 'YES' END  [Scheduler],sch_name [Scheduler Name for FXL],sch_tel [Scheduler Tel for FXL],sch_fax [Scheduler Fax for FXL]
		,CASE WHEN IsReviewer=1 THEN 'YES' END  [Coder]
		,CASE WHEN IsQA=1 THEN 'YES' END  [QA]
		,CASE WHEN IsHRA=1 THEN 'YES' END [Health Risk Accessor], linked_provider_id [Provider ID]
		,dbo.ca_udf_GetUserModules(User_PK) [Assigned Modules]
		,dbo.ca_udf_GetUserProjects(User_PK) [Assigned Projects]
		,[Last Login]
		FROM tblUser U 
		OUTER APPLY (SELECT MAX(SessionStart) [Last Login] FROM tblUserSession WHERE User_PK = U.User_PK) LL
END    
GO
