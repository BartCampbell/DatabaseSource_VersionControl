SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sa_saveTeam 0
CREATE PROCEDURE [dbo].[sa_saveTeam] 
	@PK int,
	@team_name varchar(100),
	@location int,
	@supervisor int,
	@schedulers varchar(max)
AS
BEGIN
	if @PK=0
	BEGIN
		INSERT INTO tblSchedulerTeam(Team_Name,Supervisor_User_PK,Location_PK) VALUES (@team_name,@supervisor,@location)
		SELECT @PK=@@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE tblSchedulerTeam SET Team_Name=@team_name,Supervisor_User_PK=@supervisor,Location_PK=@location WHERE SchedulerTeam_PK = @PK
		DELETE FROM tblSchedulerTeamDetail WHERE SchedulerTeam_PK = @PK
	END	

	SET @schedulers = 'INSERT INTO tblSchedulerTeamDetail(SchedulerTeam_PK,Scheduler_User_PK)
	SELECT '+CAST(@PK as varchar)+',User_PK FROM tblUser WHERE User_PK IN ('+ @schedulers +')'

	EXEC(@schedulers)

	SELECT ST.SchedulerTeam_PK, Team_Name, U.Lastname+IsNull(', '+U.Firstname,'') Supervisor,ST.Supervisor_User_PK,ST.Location_PK
		FROM tblSchedulerTeam ST WITH (NOLOCK) 
		LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK =  ST.Supervisor_User_PK
END
GO
