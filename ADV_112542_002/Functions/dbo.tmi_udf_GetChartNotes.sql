SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--	SELECT dbo.tmi_udf_GetChartNotes(12)
Create FUNCTION [dbo].[tmi_udf_GetChartNotes]
(	
	@CodedDate_PK BIGINT
)
RETURNS VARCHAR(MAX) 
AS
BEGIN
	DECLARE @RETURN VARCHAR(MAX)
	DECLARE @Note VARCHAR(5) 
	
	SET @RETURN = '';

	DECLARE db_cursor CURSOR FOR  
		SELECT NoteText_PK FROM tblCodedDataNote WHERE CodedData_PK = @CodedDate_PK

	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @Note

	WHILE @@FETCH_STATUS = 0   
	BEGIN  
			IF (@RETURN<>'')
				SET @RETURN = @RETURN + ','
				
		   SET @RETURN = @RETURN + @Note

		   FETCH NEXT FROM db_cursor INTO @Note
	END   

	CLOSE db_cursor   
	DEALLOCATE db_cursor	
	
	RETURN @RETURN;
END


GO
