SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RefreshLastActivity]
(
	@UserName nvarchar(128)
)
AS
BEGIN
	SET NOCOUNT ON;

    UPDATE	AL
	SET		LastActivityDate = GETDATE()
	FROM	dbo.ActivityLog AS AL
	WHERE	(AL.UserName = @UserName) AND
			(AL.LogID IN (SELECT TOP 1 LogID FROM dbo.ActivityLog AS tAL WHERE tAL.UserName = @UserName ORDER BY tAL.LogDate DESC, tAL.LogID DESC));
END
GO
