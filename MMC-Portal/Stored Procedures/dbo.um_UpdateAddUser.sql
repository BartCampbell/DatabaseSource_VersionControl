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
CREATE PROCEDURE [dbo].[um_UpdateAddUser] 
	@id int,
	@username varchar(200),
	@email varchar(200),
	@pwd varchar(200),
	@lastname varchar(200),
	@firstname varchar(200),
	@isCoder bit,
	@isCoderSupervisor bit,
	@isClient bit,
	@isAdmin bit,
	@isActive bit,
	@isManager bit
AS
BEGIN
	RETRY: -- Label RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		IF (@id=0)
		BEGIN
			INSERT INTO tblUser(Username,[Password],Lastname,Firstname,Email_Address,IsAdmin,IsCoder,isCoderSupervisor,isClient,IsActive,IsManager)
			VALUES(@Username,@pwd,@lastname,@firstname,@email,@IsAdmin,@IsCoder,@isCoderSupervisor,@isClient,@IsActive,@IsManager)
			
			SELECT @id=@@IDENTITY;
		END
		ELSE
		BEGIN
			Update tblUser SET Lastname=@Lastname,Firstname=@Firstname,Email_Address=@email,
				IsAdmin=@IsAdmin,IsCoder=@IsCoder,isCoderSupervisor=@isCoderSupervisor,isClient=@isClient,IsActive=@isActive,IsManager=@isManager
			WHERE User_PK=@id
			
			IF (@pwd<>'')
				Update tblUser SET [Password]=@pwd WHERE User_PK=@id
		END
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
