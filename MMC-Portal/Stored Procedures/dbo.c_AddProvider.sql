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
CREATE PROCEDURE [dbo].[c_AddProvider] 
	@department int,
	@Prv varchar(200),
	@specialty int
AS
BEGIN
	RETRY: -- Label RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		Insert Into tblProvider(department_pk,provider_name,istemp,Specialty_pk) VALUES (@department,@Prv,0,@specialty);
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
