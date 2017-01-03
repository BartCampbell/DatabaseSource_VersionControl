SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sa_transferAssignments @PK=2,@schs
CREATE PROCEDURE [dbo].[sa_transferAssignments] 
	@PK int,
	@schs varchar(500),
	@sch_to int
AS
BEGIN
	DECLARE @SQL AS VARCHAR(MAX)

	SET @SQL = 'UPDATE tblProviderOffice SET AssignedUser_PK = '+CASE WHEN @sch_to=0 THEN 'NULL' ELSE Cast(@sch_to as varchar) END+' 
	WHERE Pool_PK = '+CAST(@PK AS VARCHAR)+' AND AssignedUser_PK IN ('+@schs+')'

	EXEC(@SQL);
END
GO
