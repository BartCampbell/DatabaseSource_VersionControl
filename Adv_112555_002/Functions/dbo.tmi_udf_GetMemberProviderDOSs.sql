SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- SELECT [dbo].[tmi_udf_GetMemberProviderDOSs](2,'PRV000176')
CREATE FUNCTION [dbo].[tmi_udf_GetMemberProviderDOSs]
(	
	@Member_PK BIGINT,
	@ProviderID VARCHAR(50)
)
RETURNS VARCHAR(MAX) 
AS
BEGIN
	DECLARE @RETURN VARCHAR(MAX)
	DECLARE @DOS DATE
	
	SET @RETURN = '';

	DECLARE db_cursor CURSOR FOR  
		SELECT DISTINCT CAST(DOS_Thru AS DATE) DOS 
			FROM tblClaimData CD 
				--INNER JOIN tblProvider P ON P.Provider_PK=CD.Provider_PK 
			WHERE Member_PK=@Member_PK --AND P.Provider_ID=@ProviderID

	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @DOS

	WHILE @@FETCH_STATUS = 0   
	BEGIN  
			IF (@RETURN<>'')
				SET @RETURN = @RETURN + ', '
				
		   SET @RETURN = @RETURN + CAST(MONTH(@DOS) AS VARCHAR)+'-'+CAST(Day(@DOS) AS VARCHAR)+'-'+CAST(Year(@DOS) AS VARCHAR)

		   FETCH NEXT FROM db_cursor INTO @DOS
	END   

	CLOSE db_cursor   
	DEALLOCATE db_cursor	
	
	RETURN @RETURN;
END
GO
