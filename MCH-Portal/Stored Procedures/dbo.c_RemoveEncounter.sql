SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Sajid Ali
-- Alter date: Aug-07-2014
-- Description:	
-- =============================================
-- um_UpdateAddUser 'demoe'
CREATE PROCEDURE [dbo].[c_RemoveEncounter] 
	@id int
AS
BEGIN
	RETRY: -- Label RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		DELETE tblEncounter WHERE encounter_pk=@id
		DELETE FROM tblOneLevelData WHERE encounter_pk=@id
		DELETE FROM tblOneLevelText WHERE encounter_pk=@id
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
