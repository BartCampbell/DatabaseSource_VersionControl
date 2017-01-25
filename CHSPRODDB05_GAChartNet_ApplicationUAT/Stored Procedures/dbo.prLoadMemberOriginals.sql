SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[prLoadMemberOriginals] 
AS
BEGIN
	SET NOCOUNT ON;

    UPDATE	dbo.Member
	SET		OriginalDateOfBirth = DateOfBirth,
			OriginalGender = Gender,
			CreatedUser = ISNULL(CreatedUser, 'system'),
			LastChangedUser = ISNULL(LastChangedUser, 'system')
	WHERE	(OriginalDateOfBirth IS NULL) AND
			(OriginalGender IS NULL);
			
END
GO
