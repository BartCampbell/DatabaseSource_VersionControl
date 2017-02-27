SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
 
 
-- ============================================= 
-- Author:		Travis Parker 
-- Create date:	02/09/2017 
-- Description:	Kicks off the TRR DV load  
-- Usage:			 
--		  EXECUTE dbo.spTRRLoadDataVault '' 
-- ============================================= 
CREATE PROC [dbo].[spTRRLoadDataVault] 
    --@FileLogXML XML 
    @FileName NVARCHAR(100) , 
    @ClientID NVARCHAR(20)  
AS 
    SET NOCOUNT ON; 
 
    DECLARE @SQLText NVARCHAR(MAX) --, 
        --@FileName NVARCHAR(100) , 
        --@ClientID NVARCHAR(20)  
 
    BEGIN TRY  
 
    --SELECT 'DO NOTHING YET' 
 
	   --SET VARIABLES FROM FILELOGXML 
	   --SELECT 
		  --  @FileName =			tr.a.value('(FileNameIntake/text())[1]', 'varchar(100)') 
		  --  ,@ClientID =			tr.a.value('(CentauriClientID/text())[1]', 'int') 
	   -- FROM @FileLogXML.nodes('/row') AS tr ( a ) 
 
	   -- SELECT @FileName, @ClientID 
   
	   --UPDATE MEMBER REFERENCES 
        SET @SQLText = N'EXECUTE CHSDV_' + @ClientID + '.dbo.spTRRUpdateMemberReference'; 
 
        EXEC sp_executesql @SQLText; 
 
	   --SPLIT RECORD TYPES 
	   SET @SQLText = N'EXECUTE CHSDV_' + @ClientID + '.dbo.spTRRSplitRecordTypes'; 
 
        EXEC sp_executesql @SQLText; 
	    
	   --PRINT @SQLText 
 
	   --UPDATE REFERENCE KEYS 
	   SET @SQLText = N'EXECUTE CHSDV_' + @ClientID + '.dbo.spTRRUpdateReferenceKeys'; 
 
        EXEC sp_executesql @SQLText; 
 
	   --LOAD HUBS 
	   SET @SQLText = N'EXECUTE CHSDV_' + @ClientID + '.dbo.spDV_TRR_LoadHubs'; 
 
        EXEC sp_executesql @SQLText; 
 
	   --LOAD LINKS 
	   SET @SQLText = N'EXECUTE CHSDV_' + @ClientID + '.dbo.spDV_TRR_LoadLinks'; 
 
        EXEC sp_executesql @SQLText; 
 
	   --LOAD SATELLITES 
	   SET @SQLText = N'EXECUTE CHSDV_' + @ClientID + '.dbo.spDV_TRR_LoadSats'; 
 
        EXEC sp_executesql @SQLText; 
 
 
 
    END TRY  
    BEGIN CATCH  
        THROW; 
    END CATCH; 
 
 
 
 
GO
