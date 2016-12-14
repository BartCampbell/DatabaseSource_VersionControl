SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/18/2016
	-- Update 09/16/2016 for Wellcare 
	--	09/20/2016 for VIVA PJ	
	-- 09/21/2016 changed to NOT IN (112551) PJ
-- Description:	Load the R_Member reference table and pull back the hashmemberkey
-- =============================================

CREATE PROCEDURE [adv].[spLoadR_Member] 
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(100)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;



        IF @CCI NOT IN ( 112551)
            BEGIN
                INSERT  INTO CHSDV.dbo.[R_Member]
                        ( [HICN] ,
                          [ClientID] ,
                          [ClientMemberID] ,
                          [LoadDate] ,
                          [RecordSource]
                        )
                        SELECT  MAX(a.[HICNumber]) ,
                                a.[CCI] ,
                                a.[Member_ID] ,
                                a.[LoadDate] ,
                                a.[RecordSource]
                        FROM    CHSStaging.adv.tblMemberWCStage a
                                LEFT OUTER JOIN CHSDV.dbo.[R_Member] b ON a.Member_ID = b.ClientMemberID
                                                              AND a.CCI = b.ClientID
                        WHERE   a.CCI = @CCI
                                AND b.ClientMemberID IS NULL
                        GROUP BY a.[CCI] ,
                                a.[Member_ID] ,
                                a.[LoadDate] ,
                                a.[RecordSource];

                UPDATE  CHSStaging.adv.tblMemberWCStage
                SET     MemberHashKey = b.MemberHashKey ,
                        CMI = b.CentauriMemberID
                FROM    CHSStaging.adv.tblMemberWCStage a
                        INNER JOIN CHSDV.dbo.R_Member b ON a.Member_ID = b.ClientMemberID
                                                           AND a.CCI = b.ClientID;


                UPDATE  CHSStaging.adv.tblMemberWCStage
                SET     ClientHashKey = b.[ClientHashKey]
                FROM    CHSStaging.adv.tblMemberWCStage a
                        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


            END;
        ELSE
            BEGIN

                INSERT  INTO CHSDV.dbo.[R_Member]
                        ( [HICN] ,
                          [ClientID] ,
                          [ClientMemberID] ,
                          [LoadDate] ,
                          [RecordSource]
                        )
                        SELECT  MAX(a.[HICNumber]) ,
                                a.[CCI] ,
                                a.[Member_ID] ,
                                a.[LoadDate] ,
                                a.[RecordSource]
                        FROM    CHSStaging.adv.tblMemberStage a
                                LEFT OUTER JOIN CHSDV.dbo.[R_Member] b ON a.Member_ID = b.ClientMemberID
                                                              AND a.CCI = b.ClientID
                        WHERE   a.CCI = @CCI
                                AND b.ClientMemberID IS NULL
                        GROUP BY a.[CCI] ,
                                a.[Member_ID] ,
                                a.[LoadDate] ,
                                a.[RecordSource];

                UPDATE  CHSStaging.adv.tblMemberStage
                SET     MemberHashKey = b.MemberHashKey ,
                        CMI = b.CentauriMemberID
                FROM    CHSStaging.adv.tblMemberStage a
                        INNER JOIN CHSDV.dbo.R_Member b ON a.Member_ID = b.ClientMemberID
                                                           AND a.CCI = b.ClientID;


                UPDATE  CHSStaging.adv.tblMemberStage
                SET     ClientHashKey = b.[ClientHashKey]
                FROM    CHSStaging.adv.tblMemberStage a
                        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


            END;
    END;


GO
