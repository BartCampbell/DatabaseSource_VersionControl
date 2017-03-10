SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[UnlockAllUsers]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Users TABLE
	(
		UnlockedUserName varchar(50) NOT NULL,
		FirstName varchar(50) NOT NULL,
		LastName varchar(50) NOT NULL
	)  

    UPDATE	dbo.PortalUser 
	SET		[Enabled] = 1, 
			LoginAttempt = 0 
	OUTPUT	INSERTED.UserName, INSERTED.FirstName, INSERTED.LastName INTO @Users
	WHERE	[Enabled] = 0 OR LoginAttempt > 0;

	SELECT * FROM @Users ORDER BY UnlockedUserName;

END
GO
