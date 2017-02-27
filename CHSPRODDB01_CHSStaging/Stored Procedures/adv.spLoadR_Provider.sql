SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/18/2016
--Update 09/16/2016 for Wellcare 
--		09/20/2016 for Viva PJ
-- 09/21/2016 changed to NOT IN (112551) PJ
-- 10/11/2016 Changed the R_Provider load to come from master PJ
-- 11/03/2016 Changed 11248 to be based on NPI (Not PIN) PJ
--01/17/2017 Added GuildNet 112567 PJ
--02/16/2017 Added BCBSWNY 112555 PJ
-- Description:	Load the R_Provider reference table and pull back the hashmemberkey
-- =============================================
CREATE PROCEDURE [adv].[spLoadR_Provider] 
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(100)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
        IF @CCI NOT IN ( 112551 )
            BEGIN
                INSERT  INTO CHSDV.[dbo].[R_ProviderOffice]
                        ( [ClientID] ,
                          [ClientProviderOfficeID] ,
                          [LoadDate] ,
                          [RecordSource]
                        )
                        SELECT  DISTINCT
                                a.[CCI] ,
                                a.ProviderOffice_PK ,
                                a.LoadDate ,
                                a.[RecordSource]
                        FROM    CHSStaging.adv.tblProviderOfficeWCStage a
                                LEFT OUTER JOIN CHSDV.[dbo].[R_ProviderOffice] b ON a.ProviderOffice_PK = b.[ClientProviderOfficeID] AND b.RecordSource = a.RecordSource
                                                                                    AND a.CCI = b.ClientID
                        WHERE   --a.CCI = @CCI                                AND 
						b.[ClientProviderOfficeID] IS NULL;
                        

                UPDATE  CHSStaging.adv.tblProviderOfficeWCStage
                SET     ProviderOfficeHashKey = b.ProviderOfficeHashKey ,
                        CPI = b.CentauriProviderOfficeID
                FROM    CHSStaging.adv.tblProviderOfficeWCStage a
                        INNER JOIN CHSDV.dbo.R_ProviderOffice b ON a.ProviderOffice_PK = b.ClientProviderOfficeID AND b.RecordSource = a.RecordSource
                                                                   AND a.CCI = b.ClientID;


                UPDATE  CHSStaging.adv.tblProviderOfficeWCStage
                SET     ClientHashKey = b.[ClientHashKey]
                FROM    CHSStaging.adv.tblProviderOfficeWCStage a
                        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


            END;
        ELSE
            BEGIN
                INSERT  INTO CHSDV.[dbo].[R_ProviderOffice]
                        ( [ClientID] ,
                          [ClientProviderOfficeID] ,
                          [LoadDate] ,
                          [RecordSource]
                        )
                        SELECT  DISTINCT
                                a.[CCI] ,
                                a.ProviderOffice_PK ,
                                a.LoadDate ,
                                a.[RecordSource]
                        FROM    CHSStaging.adv.tblProviderOfficeStage a
                                LEFT OUTER JOIN CHSDV.[dbo].[R_ProviderOffice] b ON a.ProviderOffice_PK = b.[ClientProviderOfficeID] AND b.RecordSource = a.RecordSource
                                                                                    AND a.CCI = b.ClientID
                        WHERE   a.CCI = @CCI
                                AND b.[ClientProviderOfficeID] IS NULL;
                        

                UPDATE  CHSStaging.adv.tblProviderOfficeStage
                SET     ProviderOfficeHashKey = b.ProviderOfficeHashKey
                FROM    CHSStaging.adv.tblProviderOfficeStage a
                        INNER JOIN CHSDV.dbo.R_ProviderOffice b ON a.ProviderOffice_PK = b.ClientProviderOfficeID AND b.RecordSource = a.RecordSource
                                                                   AND a.CCI = b.ClientID;


                UPDATE  CHSStaging.adv.tblProviderOfficeStage
                SET     ClientHashKey = b.[ClientHashKey]
                FROM    CHSStaging.adv.tblProviderOfficeStage a
                        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


                UPDATE  CHSStaging.adv.tblProviderOfficeStage
                SET     CPI = b.CentauriProviderOfficeID
                FROM    CHSStaging.adv.tblProviderOfficeStage a
                        INNER JOIN CHSDV.dbo.R_ProviderOffice b ON a.ProviderOffice_PK = b.ClientProviderOfficeID AND b.RecordSource = a.RecordSource
                                                                   AND a.CCI = b.ClientID;
            END;

        --INSERT  INTO CHSDV.[dbo].[R_ProviderMaster]
        --        ( [NPI] ,
        --          [ClientID] ,
        --          [ClientProviderMasterID] ,
        --          [LoadDate] ,
        --          [RecordSource]
        --        )
        --        SELECT  DISTINCT
        --                a.NPI ,
        --                a.[CCI] ,
        --                a.ProviderMaster_PK ,
        --                a.LoadDate ,
        --                a.[RecordSource]
        --        FROM    CHSStaging.adv.tblProviderMasterStage a
        --                LEFT OUTER JOIN CHSDV.[dbo].[R_ProviderMaster] b ON a.ProviderMaster_PK = b.[ClientProviderMasterID]
        --                                                      AND a.CCI = b.ClientID
        --                                                      AND a.CCI = b.ClientID
        --        WHERE   a.CCI = @CCI
        --                AND b.[ClientProviderMasterID] IS NULL;
                        

        --UPDATE  CHSStaging.adv.tblProviderMasterStage
        --SET     ProviderMasterHashKey = b.ProviderMasterHashKey
        --FROM    CHSStaging.adv.tblProviderMasterStage a
        --        INNER JOIN CHSDV.dbo.R_ProviderMaster b ON a.ProviderMaster_PK = b.ClientProviderMasterID
        --                                                   AND a.CCI = b.ClientID;


        --UPDATE  CHSStaging.adv.tblProviderMasterStage
        --SET     ClientHashKey = b.[ClientHashKey]
        --FROM    CHSStaging.adv.tblProviderMasterStage a
        --        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


        --UPDATE  CHSStaging.adv.tblProviderMasterStage
        --SET     CPI = b.CentauriProviderMasterID
        --FROM    CHSStaging.adv.tblProviderMasterStage a
        --        INNER JOIN CHSDV.dbo.R_ProviderMaster b ON a.ProviderMaster_PK = b.ClientProviderMasterID
        --                                                   AND a.CCI = b.ClientID;

        IF @CCI IN ( 112542, 112547 ,112567) AND (SELECT recordsource FROM adv.AdvanceVariables WHERE avkey =( SELECT VariableLoadKey FROM adv.AdvanceVariableLoad )) <> 'ADV_112542_003'

            BEGIN							
				DELETE FROM CHSStaging.adv.tblProviderMasterStage  WHERE Provider_ID LIKE 'SA%'

                INSERT  INTO CHSDV.[dbo].[R_Provider]
                        ( [ClientID] ,
                          [ClientProviderID] ,
						  NPI,
                          [LoadDate] ,
                          [RecordSource]
                        )
                        SELECT  DISTINCT
                                a.[CCI] ,
                                a.PIN ,
								a.NPI,
                                a.LoadDate ,
                                a.[RecordSource]
                         FROM    CHSStaging.adv.tblProviderMasterStage a
                                LEFT OUTER JOIN CHSDV.[dbo].[R_Provider] b ON CAST(a.Provider_ID AS VARCHAR) = b.CentauriProviderID
                                                                              AND a.CCI = b.ClientID  
                        WHERE  a.CCI = @CCI                                AND 					
							b.[ClientProviderID] IS NULL AND ISNULL(a.Provider_ID,'') ='';


												   
                INSERT  INTO CHSDV.[dbo].[R_Provider]
                        ( [ClientID] ,
                          [ClientProviderID] ,
						  NPI,
                          [LoadDate] ,
                          [RecordSource]
                        )
                        SELECT  DISTINCT
                                a.[CCI] ,
                                a.ProviderMaster_PK ,
								a.NPI,
                                a.LoadDate ,
                                a.[RecordSource]
                          FROM    CHSStaging.adv.tblProviderMasterStage a
                                LEFT OUTER JOIN CHSDV.[dbo].[R_Provider] b ON CAST(a.Provider_ID AS VARCHAR) = b.CentauriProviderID
                                                                              AND a.CCI = b.ClientID  
                        WHERE  a.CCI = @CCI                                AND 					
							b.[ClientProviderID] IS NULL AND ISNULL(a.Provider_ID,'') ='';



                UPDATE  CHSStaging.adv.tblProviderMasterStage
                SET     Provider_ID = b.CentauriProviderID
                FROM    CHSStaging.adv.tblProviderMasterStage a
                        INNER JOIN CHSDV.dbo.R_Provider b ON CAST(a.PIN AS VARCHAR) = b.ClientProviderID 
                                                             AND a.CCI = b.ClientID AND ISNULL(a.Provider_ID,'')=''
														WHERE ISNULL(a.PIN,'') <>'';

														
                UPDATE  CHSStaging.adv.tblProviderMasterStage
                SET     Provider_ID = b.CentauriProviderID
                FROM    CHSStaging.adv.tblProviderMasterStage a
                        INNER JOIN CHSDV.dbo.R_Provider b ON CAST(a.ProviderMaster_PK AS VARCHAR) = b.ClientProviderID
                                                             AND a.CCI = b.ClientID AND ISNULL(a.Provider_ID,'')='' 
														WHERE ISNULL(a.PIN,'') ='';

                        

                UPDATE  CHSStaging.adv.tblProviderMasterStage
                SET     ProviderMasterHashKey = b.ProviderHashKey
				FROM    CHSStaging.adv.tblProviderMasterStage a
                        INNER JOIN CHSDV.dbo.R_Provider b ON CAST(a.Provider_ID AS VARCHAR) = CAST(b.CentauriProviderID AS VARCHAR) 
                                                             AND a.CCI = b.ClientID;


                UPDATE  CHSStaging.adv.tblProviderMasterStage
                SET     ClientHashKey = b.[ClientHashKey]
                FROM    CHSStaging.adv.tblProviderMasterStage a
                        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;




                UPDATE  CHSStaging.adv.tblProviderMasterStage
                SET     CPI = Provider_ID;


        

            END; 


			

        IF @CCI IN ( 112549, 112550, 112546 ,112555) OR  (SELECT recordsource FROM adv.AdvanceVariables WHERE avkey =( SELECT VariableLoadKey FROM adv.AdvanceVariableLoad )) = 'ADV_112542_003'
            BEGIN
                INSERT  INTO CHSDV.[dbo].[R_Provider]
                        ( [ClientID] ,
                          [ClientProviderID] ,
                          NPI ,
                          [LoadDate] ,
                          [RecordSource]
                        )
                        SELECT  DISTINCT
                                a.[CCI] ,
                                a.PIN ,
                                a.NPI ,
                                a.LoadDate ,
                                a.[RecordSource]
                        FROM    CHSStaging.adv.tblProviderMasterStage a
                                LEFT OUTER JOIN CHSDV.[dbo].[R_Provider] b ON CAST(a.PIN AS VARCHAR) = b.ClientProviderID
                                                                              AND a.CCI = b.ClientID 
                        WHERE   a.CCI = @CCI
                                AND b.[ClientProviderID] IS NULL AND a.PIN IS NOT NULL;





                UPDATE  CHSStaging.adv.tblProviderMasterStage
                SET     ProviderMasterHashKey = b.ProviderHashKey ,
                        CPI = b.CentauriProviderID
                FROM    CHSStaging.adv.tblProviderMasterStage a
                        INNER JOIN CHSDV.dbo.R_Provider b ON CAST(a.PIN AS VARCHAR) = b.ClientProviderID 
                                                             AND a.CCI = b.ClientID;


                UPDATE  CHSStaging.adv.tblProviderMasterStage
                SET     ClientHashKey = b.[ClientHashKey]
                FROM    CHSStaging.adv.tblProviderMasterStage a
                        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


						DELETE FROM  CHSStaging.adv.tblProviderMasterStage WHERE CPI IS NULL
            END;


			IF @CCI IN ( 112548)
            BEGIN
                INSERT  INTO CHSDV.[dbo].[R_Provider]
                        ( [ClientID] ,
                          [ClientProviderID] ,
                          NPI ,
                          [LoadDate] ,
                          [RecordSource]
                        )
                        SELECT  DISTINCT
                                a.[CCI] ,
                                a.PIN ,
                                a.NPI ,
                                a.LoadDate ,
                                a.[RecordSource]
                        FROM    CHSStaging.adv.tblProviderMasterStage a
                                LEFT OUTER JOIN CHSDV.[dbo].[R_Provider] b ON CAST(a.NPI AS VARCHAR) = b.NPI
                                                                              AND a.CCI = b.ClientID 
                        WHERE   a.CCI = @CCI  AND 
								ISNULL(a.NPI ,'') <>'' AND
								b.[ClientProviderID] IS NULL;

		
                UPDATE  CHSStaging.adv.tblProviderMasterStage
                SET     ProviderMasterHashKey = b.ProviderHashKey ,
                        CPI = b.CentauriProviderID
                FROM    CHSStaging.adv.tblProviderMasterStage a
                        INNER JOIN CHSDV.dbo.R_Provider b ON CAST(a.NPI AS VARCHAR) = b.NPI
                                                             AND a.CCI = b.ClientID 
															 WHERE ISNULL(a.NPI ,'') <>'';


                UPDATE  CHSStaging.adv.tblProviderMasterStage
                SET     ClientHashKey = b.[ClientHashKey]
                FROM    CHSStaging.adv.tblProviderMasterStage a
                        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;



            END;
       							   
        --INSERT  INTO CHSDV.[dbo].[R_Provider]
        --        ( [ClientID] ,
        --          [ClientProviderID] ,
        --          [LoadDate] ,
        --          [RecordSource]
        --        )
        --        SELECT  DISTINCT
        --                a.[CCI] ,
        --                a.Provider_PK ,
        --                a.LoadDate ,
        --                a.[RecordSource]
        --        FROM    CHSStaging.adv.tblProviderMasterStage a
        --                LEFT OUTER JOIN CHSDV.[dbo].[R_Provider] b ON CAST(a.Provider_PK AS VARCHAR) = b.[ClientProviderID]
        --                                                      AND a.CCI = b.ClientID
        --        WHERE   a.CCI = @CCI
        --                AND b.[ClientProviderID] IS NULL;
                        

        --UPDATE  CHSStaging.adv.tblProviderStage
        --SET     ProviderHashKey = b.ProviderHashKey
        --FROM    CHSStaging.adv.tblProviderStage a
        --        INNER JOIN CHSDV.dbo.R_Provider b ON CAST(a.Provider_PK AS VARCHAR) = b.ClientProviderID
        --                                             AND a.CCI = b.ClientID;


        --UPDATE  CHSStaging.adv.tblProviderStage
        --SET     ClientHashKey = b.[ClientHashKey]
        --FROM    CHSStaging.adv.tblProviderStage a
        --        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


        --UPDATE  CHSStaging.adv.tblProviderStage
        --SET     CPI = b.CentauriProviderID
        --FROM    CHSStaging.adv.tblProviderStage a
        --        INNER JOIN CHSDV.dbo.R_Provider b ON CAST(a.Provider_PK AS VARCHAR) = b.ClientProviderID
        --                                             AND a.CCI = b.ClientID;
	   
        INSERT  INTO CHSDV.[dbo].[R_ProviderOfficeSchedule]
                ( [ClientID] ,
                  [ClientProviderOfficeScheduleID] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  DISTINCT
                        a.[CCI] ,
                        a.ProviderOfficeSchedule_PK ,
                        a.LoadDate ,
                        a.[RecordSource]
                FROM    CHSStaging.adv.tblProviderOfficeScheduleStage a
                        LEFT OUTER JOIN CHSDV.[dbo].[R_ProviderOfficeSchedule] b ON a.ProviderOfficeSchedule_PK = b.[ClientProviderOfficeScheduleID]
                                                                                    AND a.CCI = b.ClientID AND b.RecordSource = a.RecordSource
                WHERE   a.CCI = @CCI
                        AND b.[ClientProviderOfficeScheduleID] IS NULL;
                        

        UPDATE  CHSStaging.adv.tblProviderOfficeScheduleStage
        SET     ProviderOfficeScheduleHashKey = b.[ProviderOfficeScheduleHashKey]
        FROM    CHSStaging.adv.tblProviderOfficeScheduleStage a
                INNER JOIN CHSDV.dbo.R_ProviderOfficeSchedule b ON a.ProviderOfficeSchedule_PK = b.ClientProviderOfficeScheduleID AND b.RecordSource = a.RecordSource
                                                                   AND a.CCI = b.ClientID;


        UPDATE  CHSStaging.adv.tblProviderOfficeScheduleStage
        SET     ClientHashKey = b.[ClientHashKey]
        FROM    CHSStaging.adv.tblProviderOfficeScheduleStage a
                INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


        UPDATE  CHSStaging.adv.tblProviderOfficeScheduleStage
        SET     CPI = b.CentauriProviderOfficeScheduleID
        FROM    CHSStaging.adv.tblProviderOfficeScheduleStage a
                INNER JOIN CHSDV.dbo.R_ProviderOfficeSchedule b ON a.ProviderOfficeSchedule_PK = b.ClientProviderOfficeScheduleID AND b.RecordSource = a.RecordSource
                                                                   AND a.CCI = b.ClientID;
	

    END;

	
GO
