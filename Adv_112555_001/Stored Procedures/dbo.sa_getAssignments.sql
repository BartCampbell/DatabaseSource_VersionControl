SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sa_getAssignments @PK=2
CREATE PROCEDURE [dbo].[sa_getAssignments] 
	@PK int
AS
BEGIN
	SELECT U.User_PK, U.Lastname+ISNULL(', '+U.Firstname,'') Scheduler,COUNT(ProviderOffice_PK) Offices 
	FROM tblProviderOffice PO WITH (NoLOCK) INNER JOIN tblUser U  WITH (NOLOCK) ON U.User_PK = PO.AssignedUser_PK 
	WHERE PO.Pool_PK = @PK
	GROUP BY U.User_PK, U.Lastname+ISNULL(', '+U.Firstname,'')

	SELECT U.User_PK, U.Lastname+ISNULL(', '+U.Firstname,'') Scheduler 
	FROM tblPool P WITH (NOLOCK)
		INNER JOIN tblSchedulerTeamDetail STD WITH (NOLOCK) ON STD.SchedulerTeam_PK = P.SchedulerTeam_PK
		INNER JOIN tblUser U WITH (NOLOCK) ON U.User_PK = STD.Scheduler_User_PK
	WHERE P.Pool_PK = @PK
END
GO
