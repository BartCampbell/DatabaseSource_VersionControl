SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/18/2016	
--Update 09/21/2016 to add Viva PJ
-- 09/21/2016 changed to NOT IN (112551) PJ
-- Description:	Updates the adv.tblMemberStage table with the metadata needed to load to the DataVault based on dbo.prUpdateMemberStagingRaw
-- =============================================

CREATE PROCEDURE [adv].[spUpdateMemberStage]
	-- Add the parameters for the stored procedure here
    @ClientID VARCHAR(32) ,
    @ClientName VARCHAR(100) ,
    @RecordsSource VARCHAR(200)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;


        DECLARE @LoadDate DATETIME = GETDATE();
        IF @ClientID NOT IN( 112551)
            BEGIN
			
--SET THE RECORDSOURCE FOR THIS DATAFILE
                UPDATE  adv.tblMemberWCStage
                SET     RecordSource = @RecordsSource;

--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
                UPDATE  adv.tblMemberWCStage
                SET     CCI = @ClientID;
                UPDATE  adv.tblMemberWCStage
                SET     Client = @ClientName;

----GENERATE MD5 HASH for the CLIENTHASHKEY AND UPDATE IT
--SET LOAD DATE
	
                UPDATE  adv.tblMemberWCStage
                SET     LoadDate = @LoadDate;
            END; 
        ELSE
            BEGIN

--SET THE RECORDSOURCE FOR THIS DATAFILE
                UPDATE  adv.tblMemberStage
                SET     RecordSource = @RecordsSource;

--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
                UPDATE  adv.tblMemberStage
                SET     CCI = @ClientID;
                UPDATE  adv.tblMemberStage
                SET     Client = @ClientName;

----GENERATE MD5 HASH for the CLIENTHASHKEY AND UPDATE IT
--SET LOAD DATE
	
                UPDATE  adv.tblMemberStage
                SET     LoadDate = @LoadDate;
            END;

    END;


GO
