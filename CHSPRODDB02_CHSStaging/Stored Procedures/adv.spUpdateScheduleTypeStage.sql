SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/29/2016
-- Description:	Updates the adv.tblScheduleTypeStage table with the metadata needed to load to the DataVault 
-- =============================================
CREATE PROCEDURE [adv].[spUpdateScheduleTypeStage]
	-- Add the parameters for the stored procedure here
    @ClientID VARCHAR(32) ,
    @ClientName VARCHAR(100) ,
    @RecordsSource VARCHAR(200)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;
	
    -- Insert statements for procedure here
		
--SET THE RECORDSOURCE FOR THIS DATAFILE
        UPDATE  adv.tblScheduleTypeStage
        SET     RecordSource = @RecordsSource;
       
--SET THE CLIENTID AND CLIENT NAME FOR THIS FILE
        UPDATE  adv.tblScheduleTypeStage
        SET     CCI = @ClientID;
        UPDATE  adv.tblScheduleTypeStage
        SET     Client = @ClientName;

       --SET LOAD DATE
        DECLARE @LoadDate DATETIME = GETDATE();
	
        UPDATE  adv.tblScheduleTypeStage
        SET     LoadDate = @LoadDate;
       
    END;
GO
