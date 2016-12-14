SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/22/2016
	-- Updated 09/15/2016 For Client 112547 Wellcare
	--Update 09/21/2016 for Viva PJ
	-- 09/21/2016 changed to NOT IN (112551) PJ
	-- 09/28/2016 adding 112542 PJ
-- Description:	Updates the adv.tblUserStage table with the metadata needed to load to the DataVault 
-- =============================================
CREATE PROCEDURE [adv].[spUpdateUserStage]
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
		/*IF @ClientID  IN (112549,112542,112548)
            BEGIN
--SET THE RECORDSOURCE FOR THIS DATAFILE
                UPDATE  adv.tblUserBCStage
                SET     RecordSource = @RecordsSource;
                UPDATE  adv.tblUserRemovedStage
                SET     RecordSource = @RecordsSource;

--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
                UPDATE  adv.tblUserBCStage
                SET     CCI = @ClientID;
                UPDATE  adv.tblUserBCStage
                SET     Client = @ClientName;
                UPDATE  adv.tblUserRemovedStage
                SET     CCI = @ClientID;
                UPDATE  adv.tblUserRemovedStage
                SET     Client = @ClientName;


--SET LOAD DATE
                
                UPDATE  adv.tblUserBCStage
                SET     LoadDate = @LoadDate;
                UPDATE  adv.tblUserRemovedStage
                SET     LoadDate = @LoadDate;
		
            END; 

    */
        
        IF @ClientID  IN (112551)
		    BEGIN	
--SET THE RECORDSOURCE FOR THIS DATAFILE
                UPDATE  adv.tblUserStage
                SET     RecordSource = @RecordsSource;
                UPDATE  adv.tblUserSessionStage
                SET     RecordSource = @RecordsSource;
                UPDATE  adv.tblUserRemovedStage
                SET     RecordSource = @RecordsSource;

--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
                UPDATE  adv.tblUserStage
                SET     CCI = @ClientID;
                UPDATE  adv.tblUserStage
                SET     Client = @ClientName;
                UPDATE  adv.tblUserSessionStage
                SET     CCI = @ClientID;
                UPDATE  adv.tblUserSessionStage
                SET     Client = @ClientName;

                UPDATE  adv.tblUserRemovedStage
                SET     CCI = @ClientID;
                UPDATE  adv.tblUserRemovedStage
                SET     Client = @ClientName;


--SET LOAD DATE
                
                UPDATE  adv.tblUserStage
                SET     LoadDate = @LoadDate;
	
                UPDATE  adv.tblUserPageStage
                SET     LoadDate = @LoadDate;
	
                UPDATE  adv.tblUserPasswordLogStage
                SET     LoadDate = @LoadDate;
	
                UPDATE  adv.tblUserProjectStage
                SET     LoadDate = @LoadDate;
	
                UPDATE  adv.tblUserRemovedStage
                SET     LoadDate = @LoadDate;

                UPDATE  adv.tblUserSessionLogStage
                SET     LoadDate = @LoadDate;

                UPDATE  adv.tblUserSessionStage
                SET     LoadDate = @LoadDate;

                UPDATE  adv.tblUserWorkingHourStage
                SET     LoadDate = @LoadDate;

                UPDATE  adv.tblUserZipCodeStage
                SET     LoadDate = @LoadDate;
	
            END;


			    -- Insert statements for procedure here
        IF @ClientID NOT IN (112551) --,112549,112542,112548)
            BEGIN
--SET THE RECORDSOURCE FOR THIS DATAFILE
                UPDATE  adv.tblUserWCStage
                SET     RecordSource = @RecordsSource;
                UPDATE  adv.tblUserRemovedStage
                SET     RecordSource = @RecordsSource;

--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
                UPDATE  adv.tblUserWCStage
                SET     CCI = @ClientID;
                UPDATE  adv.tblUserWCStage
                SET     Client = @ClientName;
                UPDATE  adv.tblUserRemovedStage
                SET     CCI = @ClientID;
                UPDATE  adv.tblUserRemovedStage
                SET     Client = @ClientName;


--SET LOAD DATE
                
                UPDATE  adv.tblUserWCStage
                SET     LoadDate = @LoadDate;
                UPDATE  adv.tblUserRemovedStage
                SET     LoadDate = @LoadDate;
		
            END; 

    END;


GO
