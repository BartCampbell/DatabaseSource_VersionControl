SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Sajid Ali
-- Alter date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- um_UpdateAddUser 'demoe'
CREATE PROCEDURE [dbo].[c_AddStaff] 
	@staff varchar(200)
AS
BEGIN
	RETRY: -- Label RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO tblUser([Username],[Password],[Lastname],[Firstname],[Email_Address],[IsAdmin],[IsCoder],[IsCoderSupervisor],[IsClientStaff],[IsClient],[IsActive]) VALUES ('','',@staff,'','',0,0,0,1,0,0);
		SELECT @@IDENTITY;
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		PRINT 'Rollback Transaction'
		ROLLBACK TRANSACTION
		IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
		BEGIN
			WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
			GOTO RETRY -- Go to Label RETRY
		END
	END CATCH
END



GO
