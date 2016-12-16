SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/18/2016
-- Description:	Load all Hubs from the Advantage tblMemberWCStagetable. (Based on [CHSDV].dbo.prDV_Member_LoadHubs)
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Member_LoadHubs]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;


--** LOAD H_Member

        INSERT  INTO [dbo].[H_Member]
                ( [H_Member_RK] ,
                  [Member_BK] ,
                  [ClientMemberID] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT 
		DISTINCT        MemberHashKey ,
                        CMI ,
                        Member_ID ,
                        LoadDate ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage WITH ( NOLOCK )
                WHERE   MemberHashKey NOT IN ( SELECT   H_Member_RK
                                               FROM     H_Member )
                        AND CCI = @CCI;
		

--** LOAD H_CLIENT
-- NoPrefix_
        INSERT  INTO [dbo].[H_Client]
                ( [H_Client_RK] ,
                  [Client_BK] ,
                  [ClientName] ,
                  [RecordSource] ,
                  [LoadDate]
                )
                SELECT 
		DISTINCT        ClientHashKey ,
                        CCI ,
                        Client ,
                        RecordSource ,
                        LoadDate
                FROM    CHSStaging.adv.tblMemberWCStage WITH ( NOLOCK )
                WHERE   ClientHashKey NOT IN ( SELECT   H_Client_RK
                                               FROM     H_Client )
                        AND CCI = @CCI;

--*** LOAD H_CONTACT
        INSERT  INTO [dbo].[H_Contact]
                ( [H_Contact_RK] ,
                  [Contact_BK] ,
                  [RecordSource] ,
                  [LoadDate]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Contact_Number,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Cell_Number,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) ,
                        CONCAT(rw.Contact_Number, rw.Cell_Number,
                               rw.Email_Address) ,
                        RecordSource ,
                        LoadDate
                FROM    CHSStaging.adv.tblMemberWCStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Contact_Number,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Cell_Number,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) NOT IN (
                        SELECT  H_Contact_RK
                        FROM    H_Contact )
                        AND CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Contact_Number,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Cell_Number,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) ,
                        CONCAT(rw.Contact_Number, rw.Cell_Number,
                               rw.Email_Address) ,
                        LoadDate ,
                        RecordSource;

		
--_Home
        INSERT  INTO [dbo].[H_Contact]
                ( [H_Contact_RK] ,
                  [Contact_BK] ,
                  [RecordSource] ,
                  [LoadDate]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Home_Contact_Number,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Home_Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) ,
                        CONCAT(rw.Home_Contact_Number, rw.Home_Email_Address) ,
                        RecordSource ,
                        LoadDate
                FROM    CHSStaging.adv.tblMemberWCStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Home_Contact_Number,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Home_Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) NOT IN (
                        SELECT  H_Contact_RK
                        FROM    H_Contact )
                        AND CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Home_Contact_Number,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Home_Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) ,
                        CONCAT(rw.Home_Contact_Number, rw.Home_Email_Address) ,
                        LoadDate ,
                        RecordSource;

--Orig_

        INSERT  INTO [dbo].[H_Contact]
                ( [H_Contact_RK] ,
                  [Contact_BK] ,
                  [RecordSource] ,
                  [LoadDate]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Orig_Contact_Number,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Orig_Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) ,
                        CONCAT(rw.Orig_Contact_Number, rw.Orig_Email_Address) ,
                        RecordSource ,
                        LoadDate
                FROM    CHSStaging.adv.tblMemberWCStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Orig_Contact_Number,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Orig_Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) NOT IN (
                        SELECT  H_Contact_RK
                        FROM    H_Contact )
                        AND CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Orig_Contact_Number,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Orig_Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) ,
                        CONCAT(rw.Orig_Contact_Number, rw.Orig_Email_Address) ,
                        LoadDate ,
                        RecordSource;


		--POA_

        INSERT  INTO [dbo].[H_Contact]
                ( [H_Contact_RK] ,
                  [Contact_BK] ,
                  [RecordSource] ,
                  [LoadDate]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(POA_Contact_Number,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(POA_Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) ,
                        CONCAT(rw.POA_Contact_Number, rw.POA_Email_Address) ,
                        RecordSource ,
                        LoadDate
                FROM    CHSStaging.adv.tblMemberWCStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(POA_Contact_Number,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(POA_Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) NOT IN (
                        SELECT  H_Contact_RK
                        FROM    H_Contact )
                        AND CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(POA_Contact_Number,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(POA_Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) ,
                        CONCAT(rw.POA_Contact_Number, rw.POA_Email_Address) ,
                        LoadDate ,
                        RecordSource;

	---*** LOAD H_Location
        INSERT  INTO H_Location
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(ZipCode_PK,
                                                              '')))))), 2)) ,
                        CONCAT([Address], ZipCode_PK) ,
                        LoadDate ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(ZipCode_PK,
                                                              '')))))), 2)) NOT IN (
                        SELECT  H_Location_RK
                        FROM    H_Location )
                        AND CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(ZipCode_PK,
                                                              '')))))), 2)) ,
                        CONCAT([Address], ZipCode_PK) ,
                        LoadDate ,
                        RecordSource;

				
--Home_

        INSERT  INTO H_Location
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Home_Address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Home_ZipCode_PK,
                                                              '')))))), 2)) ,
                        CONCAT([Home_Address], Home_ZipCode_PK) ,
                        LoadDate ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Home_Address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Home_ZipCode_PK,
                                                              '')))))), 2)) NOT IN (
                        SELECT  H_Location_RK
                        FROM    H_Location )
                        AND CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Home_Address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Home_ZipCode_PK,
                                                              '')))))), 2)) ,
                        CONCAT([Home_Address], Home_ZipCode_PK) ,
                        LoadDate ,
                        RecordSource;

--Orig_

        INSERT  INTO H_Location
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Orig_Address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Orig_ZipCode_PK,
                                                              '')))))), 2)) ,
                        CONCAT([Orig_Address], Orig_ZipCode_PK) ,
                        LoadDate ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Orig_Address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Orig_ZipCode_PK,
                                                              '')))))), 2)) NOT IN (
                        SELECT  H_Location_RK
                        FROM    H_Location )
                        AND CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Orig_Address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Orig_ZipCode_PK,
                                                              '')))))), 2)) ,
                        CONCAT([Orig_Address], Orig_ZipCode_PK) ,
                        LoadDate ,
                        RecordSource;

--POA_

        INSERT  INTO H_Location
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([POA_Address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(POA_ZipCode_PK,
                                                              '')))))), 2)) ,
                        CONCAT([POA_Address], POA_ZipCode_PK) ,
                        LoadDate ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([POA_Address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(POA_ZipCode_PK,
                                                              '')))))), 2)) NOT IN (
                        SELECT  H_Location_RK
                        FROM    H_Location )
                        AND CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE([POA_Address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(POA_ZipCode_PK,
                                                              '')))))), 2)) ,
                        CONCAT([POA_Address], POA_ZipCode_PK) ,
                        LoadDate ,
                        RecordSource;



    END;
GO
