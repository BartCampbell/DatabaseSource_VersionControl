SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
-- ============================================= 
-- Author:		PAUL JOHNSON
-- Create date:	05/02/2017
-- Description:	LOAD MAO004 HUBS 
-- ============================================= 
CREATE PROCEDURE [dbo].[spDV_MAO004_LoadHubs]
    @filelog VARCHAR(100) ,
    @cci INT
-- Add the parameters for the stored procedure here 
AS
    BEGIN 
 
        DECLARE @CurrentDate DATETIME = GETDATE();  
 
        SET NOCOUNT ON; 
 
	   --LOAD TRR HUB 
        INSERT  INTO dbo.H_MAO004Record
                ( H_MAO004Record_RK ,
                  MAO004Record_BK ,
                  ClientMAO004RecordID ,
                  RecordSource ,
                  LoadDate
                )
                SELECT DISTINCT
                        b.MAO004HashKey,
                        b.CentaurirecordID ,
                        a.EncounterICN ,
                        @filelog ,
                        @CurrentDate
                FROM    CHSStaging.dbo.MAO004Detail a
                        INNER JOIN CHSDV.dbo.R_MAO004Record b ON b.EncounterICN = a.EncounterICN
                                                                 AND b.ClientID = @cci

                WHERE   b.MAO004HashKey NOT IN ( SELECT H_MAO004Record_RK
                                                 FROM   dbo.H_MAO004Record )
												 AND a.FileName=@filelog
												 ; 
 
 
    END; 
 
GO
