SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- um_getUsers 1,25,'','UN','DESC'
CREATE PROCEDURE [dbo].[um_removeUsers] 
	@User int,
	@RemovedBy int
AS
BEGIN
	INSERT INTO tblUserRemoved
			   ([RemovedBy_User_PK]
			   ,[Removed_date]
			   ,[User_PK]
			   ,[Username]
			   ,[Password]
			   ,[Lastname]
			   ,[Firstname]
			   ,[Email_Address]
			   ,[IsSuperUser]
			   ,[IsAdmin]
			   ,[IsScanTech]
			   ,[IsScheduler]
			   ,[IsReviewer]
			   ,[IsQA]
			   ,[IsActive]
			   ,[only_work_selected_hours]
			   ,[only_work_selected_zipcodes]
			   ,[deactivate_after])
	SELECT 
			   @RemovedBy [RemovedBy_User_PK],GetDate()
			   ,[User_PK]
			   ,[Username]
			   ,[Password]
			   ,[Lastname]
			   ,[Firstname]
			   ,[Email_Address]
			   ,[IsHRA]
			   ,[IsAdmin]
			   ,[IsScanTech]
			   ,[IsScheduler]
			   ,[IsReviewer]
			   ,[IsQA]
			   ,[IsActive]
			   ,[only_work_selected_hours]
			   ,[only_work_selected_zipcodes]
			   ,[deactivate_after]
	FROM tblUser WHERE User_PK=@User

	DELETE FROM tblUser WHERE User_PK=@User
END

GO
