SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[tmi_udf_GetOfficeContactNotes]
(	
	@Office INT,
	@Project INT
)
RETURNS VARCHAR(MAX) 
AS
BEGIN
	DECLARE @RETURN VARCHAR(MAX)
	DECLARE @Note VARCHAR(150)
	DECLARE @NoteDetail VARCHAR(500)
	DECLARE @NoteDate DateTime
	
	SET @RETURN = '';
	--,ContactNote_Text,LastUpdated_Date
	DECLARE db_cursor CURSOR FOR  
		SELECT DISTINCT ContactNoteText FROM tblContactNotesOffice CNO
			--INNER JOIN tblContactNote CN ON CN.ContactNote_PK = CNO.ContactNote_PK
		WHERE CNO.Office_PK = @Office AND CNO.Project_PK = @Project AND CNO.ContactNote_PK=19
		--ORDER BY ContactNoteText DESC
		
	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @NoteDetail--, @Note , @NoteDate 

	WHILE @@FETCH_STATUS = 0   
	BEGIN  
			IF (@RETURN<>'')
				SET @RETURN = @RETURN + CHAR(13)+CHAR(10)
				
		   SET @RETURN = @RETURN +@NoteDetail --+ ' - ' +@Note+' ('+CAST(MONTH(@NoteDate) AS VARCHAR)+'/'+CAST(DAY(@NoteDate) AS VARCHAR)+'/'+CAST(Year(@NoteDate) AS VARCHAR)+')'

		   FETCH NEXT FROM db_cursor INTO @NoteDetail --@Note, @NoteDetail, @NoteDate
	END   

	CLOSE db_cursor   
	DEALLOCATE db_cursor	
	
	RETURN @RETURN;
END
GO
