SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--PRINT dbo.tmi_udf_CodedHCCs(62)
CREATE FUNCTION [dbo].[tmi_udf_CodedHCCs]
(	
	@Suspect BigInt
)
RETURNS VARCHAR(MAX) 
AS
BEGIN
	DECLARE @RETURN VARCHAR(MAX)
	DECLARE @HCC int
	
	SET @RETURN = '';
	DECLARE db_cursor CURSOR FOR  
		SELECT DISTINCT MC.V22HCC
		FROM tblModelCode MC
			INNER JOIN tblCodedData CD ON CD.DiagnosisCode = MC.DiagnosisCode AND MC.V22HCC IS NOT NULL
		WHERE CD.Suspect_PK=@Suspect
		
	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @HCC

	WHILE @@FETCH_STATUS = 0   
	BEGIN  
		IF (@RETURN<>'')
				SET @RETURN = @RETURN  + ' ,'
				
		   SET @RETURN = @RETURN + CAST(@HCC AS VARCHAR)

		   FETCH NEXT FROM db_cursor INTO @HCC
	END   

	CLOSE db_cursor   
	DEALLOCATE db_cursor	
	
	RETURN @RETURN;
END
GO
