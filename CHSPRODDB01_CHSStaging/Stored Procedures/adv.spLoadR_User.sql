SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/22/2016
	-- Updated 09/15/2016 for Wellcare ClientID 112547
--				09/20/2016 fro VIVA PJ
				--09/28/2016 added 112542 PJ
-- 09/21/2016 changed to NOT IN (112551) PJ
--09/29/2016 Adding in three extra columns PJ
-- Description:	Load the R_User reference table and pull back the hashkey
-- =============================================
CREATE PROCEDURE [adv].[spLoadR_User] 
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(100)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

        IF @CCI NOT IN (112551)--,112549,112542,112548
            BEGIN
	-- Insert statements for procedure here
                INSERT  INTO CHSDV.[dbo].[R_AdvanceUser]
                        ( [ClientID] ,
                          [ClientUserID] ,
                          [LoadDate] ,
                          [RecordSource]
                        )
                        SELECT  DISTINCT
                                a.[CCI] ,
                                a.[User_PK] ,
                                a.LoadDate ,
                                a.[RecordSource]
                        FROM    CHSStaging.adv.tblUserWCStage a
                                LEFT OUTER JOIN CHSDV.[dbo].[R_AdvanceUser] b ON a.User_PK = b.ClientUserID AND a.CCI = b.ClientID AND b.RecordSource = a.RecordSource
                        WHERE   a.CCI = @CCI
                                AND b.ClientUserID IS NULL;
		

                UPDATE  CHSStaging.adv.tblUserWCStage
                SET     UserHashKey = b.UserHashKey ,
                        CUI = b.CentauriUserID
                FROM    CHSStaging.adv.tblUserWCStage a
                        INNER JOIN CHSDV.dbo.R_AdvanceUser b ON a.User_PK = b.ClientUserID AND b.RecordSource = a.RecordSource
                                                              AND a.CCI = b.ClientID;


                UPDATE  CHSStaging.adv.tblUserWCStage
                SET     ClientHashKey = b.[ClientHashKey]
                FROM    CHSStaging.adv.tblUserWCStage a
                        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


            END;

			/*IF @CCI  IN (112549,112542,112548)
            BEGIN
	-- Insert statements for procedure here
                INSERT  INTO CHSDV.[dbo].[R_AdvanceUser]
                        ( [ClientID] ,
                          [ClientUserID] ,
                          [LoadDate] ,
                          [RecordSource]
                        )
                        SELECT  DISTINCT
                                a.[CCI] ,
                                a.[User_PK] ,
                                a.LoadDate ,
                                a.[RecordSource]
                        FROM    CHSStaging.adv.tblUserBCStage a
                                LEFT OUTER JOIN CHSDV.[dbo].[R_AdvanceUser] b ON a.User_PK = b.ClientUserID AND a.CCI = b.ClientID
                        WHERE   a.CCI = @CCI
                                AND b.ClientUserID IS NULL;
		

                UPDATE  CHSStaging.adv.tblUserBCStage
                SET     UserHashKey = b.UserHashKey ,
                        CUI = b.CentauriUserID
                FROM    CHSStaging.adv.tblUserBCStage a
                        INNER JOIN CHSDV.dbo.R_AdvanceUser b ON a.User_PK = b.ClientUserID
                                                              AND a.CCI = b.ClientID;


                UPDATE  CHSStaging.adv.tblUserBCStage
                SET     ClientHashKey = b.[ClientHashKey]
                FROM    CHSStaging.adv.tblUserBCStage a
                        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


            END;
			*/
        IF @CCI  IN (112551)
            BEGIN
    -- Insert statements for procedure here
                INSERT  INTO CHSDV.[dbo].[R_AdvanceUser]
                        ( [ClientID] ,
                          [ClientUserID] ,
                          [LoadDate] ,
                          [RecordSource]
                        )
                        SELECT  DISTINCT
                                a.[CCI] ,
                                a.[User_PK] ,
                                a.LoadDate ,
                                a.[RecordSource]
                        FROM    CHSStaging.adv.tblUserStage a
                                LEFT OUTER JOIN CHSDV.[dbo].[R_AdvanceUser] b ON a.User_PK = b.ClientUserID AND a.CCI = b.ClientID AND b.RecordSource = a.RecordSource
                        WHERE   a.CCI = @CCI
                                AND b.ClientUserID IS NULL;
		

                UPDATE  CHSStaging.adv.tblUserStage
                SET     UserHashKey = b.UserHashKey,CUI = b.CentauriUserID
                FROM    CHSStaging.adv.tblUserStage a
                        INNER JOIN CHSDV.dbo.R_AdvanceUser b ON a.User_PK = b.ClientUserID AND b.RecordSource = a.RecordSource
                                                              AND a.CCI = b.ClientID;


                UPDATE  CHSStaging.adv.tblUserStage
                SET     ClientHashKey = b.[ClientHashKey]
                FROM    CHSStaging.adv.tblUserStage a
                        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;
						

--**LOAD SESSION HASH tables



                INSERT  INTO CHSDV.[dbo].[R_Session]
                        ( [ClientID] ,
                          [ClientSessionID] ,
                          [LoadDate] ,
                          [RecordSource]
                        )
                        SELECT  DISTINCT
                                a.[CCI] ,
                                a.Session_PK ,
                                a.LoadDate ,
                                a.[RecordSource]
                        FROM    CHSStaging.adv.tblUserSessionStage a
						LEFT OUTER JOIN CHSDV.[dbo].[R_Session] b ON b.RecordSource = a.RecordSource AND a.Session_PK=b.ClientSessionID AND a.CCI=b.ClientID
                        WHERE   CCI = @CCI AND b.CentauriSessionID is null;

                UPDATE  CHSStaging.adv.tblUserSessionStage
                SET     SessionHashKey = b.SessionHashKey
                FROM    CHSStaging.adv.tblUserSessionStage a
                        INNER JOIN CHSDV.dbo.R_Session b ON a.Session_PK = b.ClientSessionID AND a.CCI = b.ClientID AND b.RecordSource = a.RecordSource
                                                            AND a.CCI = b.ClientID;


                UPDATE  CHSStaging.adv.tblUserSessionStage
                SET     ClientHashKey = b.[ClientHashKey]
                FROM    CHSStaging.adv.tblUserSessionStage a
                        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


		
                UPDATE  CHSStaging.adv.tblUserSessionStage
                SET     CSI = b.CentauriSessionID
                FROM    CHSStaging.adv.tblUserSessionStage a
                        INNER JOIN CHSDV.dbo.R_Session b ON a.Session_PK = b.ClientSessionID AND b.RecordSource = a.RecordSource
                                                            AND a.CCI = b.ClientID;
								   

            END;
                                   
								   
--**UPDATE REMOVED Staging
        INSERT  INTO CHSDV.[dbo].[R_AdvanceUser]
                ( [ClientID] ,
                  [ClientUserID] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  DISTINCT
                        a.[CCI] ,
                        a.[User_PK] ,
                        a.LoadDate ,
                        a.[RecordSource]
                FROM    CHSStaging.adv.tblUserRemovedStage a
                        LEFT OUTER JOIN CHSDV.[dbo].[R_AdvanceUser] b ON a.User_PK = b.ClientUserID AND a.CCI = b.ClientID AND b.RecordSource = a.RecordSource
                WHERE   a.CCI = @CCI
                        AND b.ClientUserID IS NULL;


        UPDATE  CHSStaging.adv.tblUserRemovedStage
        SET     UserHashKey = b.UserHashKey,CUI = b.CentauriUserID
        FROM    CHSStaging.adv.tblUserRemovedStage a
                INNER JOIN CHSDV.dbo.R_AdvanceUser b ON a.User_PK = b.ClientUserID AND b.RecordSource = a.RecordSource
                                                        AND a.CCI = b.ClientID;


        UPDATE  CHSStaging.adv.tblUserRemovedStage
        SET     ClientHashKey = b.[ClientHashKey]
        FROM    CHSStaging.adv.tblUserRemovedStage a
                INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;

		
										   
        INSERT  INTO CHSDV.[dbo].[R_AdvanceUser]
                ( [ClientID] ,
                  [ClientUserID] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  DISTINCT
                        a.[CCI] ,
                        a.[RemovedBy_User_PK] ,
                        a.LoadDate ,
                        a.[RecordSource]
                FROM    CHSStaging.adv.tblUserRemovedStage a
                        LEFT OUTER JOIN CHSDV.[dbo].[R_AdvanceUser] b ON a.RemovedBy_User_PK = b.ClientUserID AND a.CCI = b.ClientID AND b.RecordSource = a.RecordSource
                WHERE   a.CCI = @CCI
                        AND b.ClientUserID IS NULL;


        UPDATE  CHSStaging.adv.tblUserRemovedStage
        SET     RemovedbyUserHashKey = b.UserHashKey
        FROM    CHSStaging.adv.tblUserRemovedStage a
                INNER JOIN CHSDV.dbo.R_AdvanceUser b ON a.RemovedBy_User_PK = b.ClientUserID AND b.RecordSource = a.RecordSource
                                                        AND a.CCI = b.ClientID;


    END;



GO
