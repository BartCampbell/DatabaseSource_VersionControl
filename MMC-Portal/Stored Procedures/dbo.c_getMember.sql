SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[c_getMember] 
	@MR varchar(50)
AS
BEGIN
	RETRY: -- Label RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @member_pk as INT = 0
		DECLARE @member_name as varchar(50) = ''
		DECLARE @member_DOB as date
		
		SELECT TOP 1 @member_pk=member_pk,@member_name=member_name,@member_DOB=DOB FROM tblMember WITH (NOLOCK) WHERE member_id=@MR
		
		if (@member_pk=0)
		BEGIN
			INsert INto tblMember(member_id,member_name) VALUES(@MR,'')
			SELECT @member_pk = @@IDENTITY;
		END
		
		SELECT @member_pk PK,@member_name member_name,@member_DOB member_DOB
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
END;

GO
