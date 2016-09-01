SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sa_getTeams 1
CREATE PROCEDURE [dbo].[sa_getTeams] 
	@type int
AS
BEGIN
	IF (@type<>0) 
		SELECT Scheduler_User_PK FROM tblSchedulerTeamDetail WHERE SchedulerTeam_PK=@type
	ELSE IF (@type=0)
	BEGIN
		SELECT ST.SchedulerTeam_PK, Team_Name, U.Lastname+IsNull(', '+U.Firstname,'') Supervisor,ST.Supervisor_User_PK,ST.Location_PK
			FROM tblSchedulerTeam ST WITH (NOLOCK) 
			LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK =  ST.Supervisor_User_PK

		SELECT L.Location_PK,L.Location FROM tblLocation L WITH (NOLOCK) ORDER BY L.Location

		SELECT U.Lastname+IsNull(', '+U.Firstname,'') Scheduler,U.User_PK, IsScheduler, IsSchedulerSV,Location_PK
			FROM tblUser U WITH (NOLOCK)
			WHERE IsScheduler=1 OR IsSchedulerSV=1
			ORDER BY Scheduler
	END
END
GO
