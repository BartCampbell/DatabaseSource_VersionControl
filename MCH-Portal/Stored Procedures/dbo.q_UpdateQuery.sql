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
CREATE PROCEDURE [dbo].[q_UpdateQuery] 
	@response_text varchar(250),
	@QueryResponse_pk int,
	@user_pk int,
	@isCodedPosted tinyint,
	@Encounter_PK bigint
AS
BEGIN
	RETRY: -- Label RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		Update tblQuery SET response_text=@response_text,QueryResponse_pk=@QueryResponse_pk,updated_User_PK=@user_pk,updated_date=GetDate(),isCodedPosted=@isCodedPosted WHERE Encounter_PK=@Encounter_PK
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
