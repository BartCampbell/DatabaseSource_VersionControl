SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/18/2016
--Updated 09/26/2016 Added record end date cleanup code PJ
--Update 10/04/2016 Replaced RecordEndDate in Link with Link Satellite PJ
-- Description:	Load all Link Tables from the tblMemberWCStage table.  BAsed on CHSDV.dbo.prDV_Member_LoadLinks
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Member_LoadLinks]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** Load L_MEMBERCLIENT
	Insert into L_MemberClient
	Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CCI,'')))
			))
			),2)),
		rw.MemberHashKey,
		rw.ClientHashKey,		
	rw.LoadDate , 
	 rw.RecordSource,
	 null
	 from CHSStaging.adv.tblMemberWCStage rw with(nolock)
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CCI,'')))
			))
			),2)) not in (Select L_MemberClient_RK from L_MemberClient where RecordEndDate is null)
			AND rw.CCI = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CCI,'')))
						))
			),2)),
		rw.MemberHashKey,
		rw.ClientHashKey,
		 rw.LoadDate  ,		
		rw.RecordSource



		--*** INSERT INTO L_MEMBERCONTACT

		INSERT INTO L_MemberContact
		SELECT
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Cell_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)),
			MemberHashKey,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
			RTRIM(LTRIM(COALESCE(Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Cell_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
			))
			),2)),
			 rw.LoadDate ,
			RecordSource,
			Null
		From CHSStaging.adv.tblMemberWCStage rw
		Where 
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Cell_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2))
		 not in(Select L_MemberContact_RK from L_MemberContact where RecordEndDate is null)
		 AND rw.CCI = @CCI
		GROUP BY
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Cell_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)),
			MemberHashKey,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Cell_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
			))
			),2)),
			 rw.LoadDate  ,
			RecordSource

		

	
--**LS_MemberContactType LOAD

INSERT INTO [dbo].[LS_MemberContactType]
           ([LS_MemberContactType_RK]
           ,[LoadDate]
           ,[L_MemberContact_RK]
           ,[ContactType]
           ,[HashDiff]
           ,[RecordSource]
)

                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('NoPrefix' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        LoadDate ,
                       upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Cell_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)), 
                       'NoPrefix',
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('NoPrefix' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('NoPrefix' ,
                                                                                                                         
                                                              '')))))), 2)) NOT IN (
                        SELECT  LS_MemberContactType_RK
                        FROM    LS_MemberContactType
                         WHERE RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('NoPrefix' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        LoadDate ,
                       upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Cell_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)), 
                      
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('NoPrefix' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        RecordSource;



---**** INSERT INTO L_PROVIDERLOCATION

		INSERT INTO L_MemberLocation
			Select 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CMI,''))),':',					
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE(ZipCode_PK,'')))
					))
				),2)),
				rw.MemberHashKey, 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE(ZipCode_PK,'')))
					))
				),2)),
				 rw.LoadDate ,
				RecordSource,
				Null
			FROM CHSStaging.adv.tblMemberWCStage rw
			WHERE
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CMI,''))),':',
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE(ZipCode_PK,'')))
					))
				),2)) not in (Select L_MemberLocation_RK from L_MemberLocation where RecordEndDate is null)
				AND rw.CCI = @CCI
			GROUP BY
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CMI,''))),':',
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE(ZipCode_PK,'')))
					))
				),2)),
				rw.MemberHashKey, 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE(ZipCode_PK,'')))
					))
				),2)),
				 rw.LoadDate,
				RecordSource
			


			
--**LS_MemberLocationType LOAD

INSERT INTO [dbo].[LS_MemberLocationType]
           ([LS_MemberLocationType_RK]
           ,[LoadDate]
           ,[L_MemberLocation_RK]
           ,[LocationType]
           ,[HashDiff]
           ,[RecordSource]
)

                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('NoPrefix' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        LoadDate ,
                       upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(CMI,''))),':',					
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE(ZipCode_PK,'')))
				))
				),2)), 
                       'NoPrefix',
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('NoPrefix' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('NoPrefix' ,
                                                                                                                         
                                                              '')))))), 2)) NOT IN (
                        SELECT  LS_MemberLocationType_RK
                        FROM    LS_MemberLocationType
                         WHERE RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('NoPrefix' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        LoadDate ,
                       upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(CMI,''))),':',					
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE(ZipCode_PK,'')))
				))
				),2)), 
                       
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('NoPrefix' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        RecordSource;

						


--*** INSERT INTO L_MEMBERCONTACT

INSERT INTO [dbo].[L_MemberContact]
           ([L_MemberContact_RK]
           ,[H_Member_RK]
           ,[H_Contact_RK]
           ,[LoadDate]
           ,[RecordSource]
  )


		SELECT
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(Home_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Home_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)),
			MemberHashKey,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
			RTRIM(LTRIM(COALESCE(Home_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Home_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
			))
			),2)),
			 rw.LoadDate ,
			RecordSource
		From CHSStaging.adv.tblMemberWCStage rw
		Where 
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(Home_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Home_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2))
		 not in(Select L_MemberContact_RK from L_MemberContact where RecordEndDate is null)
		 AND rw.CCI = @CCI
		GROUP BY
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(Home_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Home_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)),
			MemberHashKey,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(Home_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Home_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
			))
			),2)),
			 rw.LoadDate  ,
			RecordSource



			
--**LS_MemberContactType LOAD

INSERT INTO [dbo].[LS_MemberContactType]
           ([LS_MemberContactType_RK]
           ,[LoadDate]
           ,[L_MemberContact_RK]
           ,[ContactType]
           ,[HashDiff]
           ,[RecordSource]
)

                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Home' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        LoadDate ,
                       upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(Home_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Home_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)), 
                       'Home',
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Home' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Home' ,
                                                                                                                         
                                                              '')))))), 2)) NOT IN (
                        SELECT  LS_MemberContactType_RK
                        FROM    LS_MemberContactType
                         WHERE RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Home' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        LoadDate ,
                       upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(Home_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Home_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)), 
                      
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Home' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        RecordSource;





---**** INSERT INTO L_PROVIDERLOCATION

		INSERT INTO L_MemberLocation
			Select 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CMI,''))),':',					
					RTRIM(LTRIM(COALESCE([Home_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(Home_ZipCode_PK,'')))
					))
				),2)),
				rw.MemberHashKey, 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE([Home_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(Home_ZipCode_PK,'')))
					))
				),2)),
				 rw.LoadDate ,
				RecordSource,
				Null
			FROM CHSStaging.adv.tblMemberWCStage rw
			WHERE
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CMI,''))),':',
					RTRIM(LTRIM(COALESCE([Home_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(Home_ZipCode_PK,'')))
					))
				),2)) not in (Select L_MemberLocation_RK from L_MemberLocation where RecordEndDate is null)
				AND rw.CCI = @CCI
			GROUP BY
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CMI,''))),':',
					RTRIM(LTRIM(COALESCE([Home_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(Home_ZipCode_PK,'')))
					))
				),2)),
				rw.MemberHashKey, 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE([Home_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(Home_ZipCode_PK,'')))
					))
				),2)),
				 rw.LoadDate,
				RecordSource
			
			
--**LS_MemberLocationType LOAD

INSERT INTO [dbo].[LS_MemberLocationType]
           ([LS_MemberLocationType_RK]
           ,[LoadDate]
           ,[L_MemberLocation_RK]
           ,[LocationType]
           ,[HashDiff]
           ,[RecordSource]
)

                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Home' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        LoadDate ,
                       upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(CMI,''))),':',					
					RTRIM(LTRIM(COALESCE([Home_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(Home_ZipCode_PK,'')))
				))
				),2)), 
                       'Home',
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Home' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Home' ,
                                                                                                                         
                                                              '')))))), 2)) NOT IN (
                        SELECT  LS_MemberLocationType_RK
                        FROM    LS_MemberLocationType
                         WHERE RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Home' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        LoadDate ,
                       upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(CMI,''))),':',					
					RTRIM(LTRIM(COALESCE([Home_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(Home_ZipCode_PK,'')))
				))
				),2)), 
                       
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Home' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        RecordSource;




--*** INSERT INTO L_MEMBERCONTACT
	--Orig_

INSERT INTO [dbo].[L_MemberContact]
           ([L_MemberContact_RK]
           ,[H_Member_RK]
           ,[H_Contact_RK]
           ,[LoadDate]
           ,[RecordSource]
  )


		SELECT
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(Orig_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Orig_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)),
			MemberHashKey,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
			RTRIM(LTRIM(COALESCE(Orig_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Orig_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
			))
			),2)),
			 rw.LoadDate ,
			RecordSource
		From CHSStaging.adv.tblMemberWCStage rw
		Where 
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(Orig_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Orig_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2))
		 not in(Select L_MemberContact_RK from L_MemberContact where RecordEndDate is null)
		 AND rw.CCI = @CCI
		GROUP BY
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(Orig_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Orig_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)),
			MemberHashKey,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(Orig_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Orig_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
			))
			),2)),
			 rw.LoadDate  ,
			RecordSource

	

	
--**LS_MemberContactType LOAD
--Orig_

INSERT INTO [dbo].[LS_MemberContactType]
           ([LS_MemberContactType_RK]
           ,[LoadDate]
           ,[L_MemberContact_RK]
           ,[ContactType]
           ,[HashDiff]
           ,[RecordSource]
)

                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Orig' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        LoadDate ,
                       upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(Orig_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Orig_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)), 
                       'Orig',
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Orig' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Orig' ,
                                                                                                                         
                                                              '')))))), 2)) NOT IN (
                        SELECT  LS_MemberContactType_RK
                        FROM    LS_MemberContactType
                         WHERE RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Orig' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        LoadDate ,
                       upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(Orig_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(Orig_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)), 
                      
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Orig' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        RecordSource;


---**** INSERT INTO L_PROVIDERLOCATION
--Orig_

		INSERT INTO L_MemberLocation
			Select 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CMI,''))),':',					
					RTRIM(LTRIM(COALESCE([Orig_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(Orig_ZipCode_PK,'')))
					))
				),2)),
				rw.MemberHashKey, 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE([Orig_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(Orig_ZipCode_PK,'')))
					))
				),2)),
				 rw.LoadDate ,
				RecordSource,
				Null
			FROM CHSStaging.adv.tblMemberWCStage rw
			WHERE
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CMI,''))),':',
					RTRIM(LTRIM(COALESCE([Orig_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(Orig_ZipCode_PK,'')))
					))
				),2)) not in (Select L_MemberLocation_RK from L_MemberLocation where RecordEndDate is null)
				AND rw.CCI = @CCI
			GROUP BY
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CMI,''))),':',
					RTRIM(LTRIM(COALESCE([Orig_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(Orig_ZipCode_PK,'')))
					))
				),2)),
				rw.MemberHashKey, 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE([Orig_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(Orig_ZipCode_PK,'')))
					))
				),2)),
				 rw.LoadDate,
				RecordSource
			


--**LS_MemberLocationType LOAD
--Orig_

INSERT INTO [dbo].[LS_MemberLocationType]
           ([LS_MemberLocationType_RK]
           ,[LoadDate]
           ,[L_MemberLocation_RK]
           ,[LocationType]
           ,[HashDiff]
           ,[RecordSource]
)

                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Orig' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        LoadDate ,
                       upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(CMI,''))),':',					
					RTRIM(LTRIM(COALESCE([Orig_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(Orig_ZipCode_PK,'')))
				))
				),2)), 
                       'Orig',
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Orig' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Orig' ,
                                                                                                                         
                                                              '')))))), 2)) NOT IN (
                        SELECT  LS_MemberLocationType_RK
                        FROM    LS_MemberLocationType
                         WHERE RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Orig' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        LoadDate ,
                       upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(CMI,''))),':',					
					RTRIM(LTRIM(COALESCE([Orig_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(Orig_ZipCode_PK,'')))
				))
				),2)), 
                       
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('Orig' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        RecordSource;

						
--*** INSERT INTO L_MEMBERCONTACT
	--POA_
INSERT INTO [dbo].[L_MemberContact]
           ([L_MemberContact_RK]
           ,[H_Member_RK]
           ,[H_Contact_RK]
           ,[LoadDate]
           ,[RecordSource]
  )


		SELECT
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(POA_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(POA_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)),
			MemberHashKey,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
			RTRIM(LTRIM(COALESCE(POA_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(POA_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
			))
			),2)),
			 rw.LoadDate ,
			RecordSource
		From CHSStaging.adv.tblMemberWCStage rw
		Where 
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(POA_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(POA_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2))
		 not in(Select L_MemberContact_RK from L_MemberContact where RecordEndDate is null)
		 AND rw.CCI = @CCI
		GROUP BY
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(POA_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(POA_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)),
			MemberHashKey,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(POA_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(POA_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
			))
			),2)),
			 rw.LoadDate  ,
			RecordSource


--**LS_MemberContactType LOAD
--POA_

INSERT INTO [dbo].[LS_MemberContactType]
           ([LS_MemberContactType_RK]
           ,[LoadDate]
           ,[L_MemberContact_RK]
           ,[ContactType]
           ,[HashDiff]
           ,[RecordSource]
)

                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('POA' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        LoadDate ,
                       upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(POA_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(POA_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)), 
                       'POA',
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('POA' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('POA' ,
                                                                                                                         
                                                              '')))))), 2)) NOT IN (
                        SELECT  LS_MemberContactType_RK
                        FROM    LS_MemberContactType
                         WHERE RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('POA' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        LoadDate ,
                       upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(POA_Contact_Number,''))),':',
				RTRIM(LTRIM(COALESCE(POA_Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)), 
                      
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('POA' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        RecordSource;


---**** INSERT INTO L_PROVIDERLOCATION
	--POA_

		INSERT INTO L_MemberLocation
			Select 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CMI,''))),':',					
					RTRIM(LTRIM(COALESCE([POA_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(POA_ZipCode_PK,'')))
					))
				),2)),
				rw.MemberHashKey, 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE([POA_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(POA_ZipCode_PK,'')))
					))
				),2)),
				 rw.LoadDate ,
				RecordSource,
				Null
			FROM CHSStaging.adv.tblMemberWCStage rw
			WHERE
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CMI,''))),':',
					RTRIM(LTRIM(COALESCE([POA_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(POA_ZipCode_PK,'')))
					))
				),2)) not in (Select L_MemberLocation_RK from L_MemberLocation where RecordEndDate is null)
				AND rw.CCI = @CCI
			GROUP BY
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CMI,''))),':',
					RTRIM(LTRIM(COALESCE([POA_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(POA_ZipCode_PK,'')))
					))
				),2)),
				rw.MemberHashKey, 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE([POA_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(POA_ZipCode_PK,'')))
					))
				),2)),
				 rw.LoadDate,
				RecordSource
			

--**LS_MemberLocationType LOAD
	--POA_

INSERT INTO [dbo].[LS_MemberLocationType]
           ([LS_MemberLocationType_RK]
           ,[LoadDate]
           ,[L_MemberLocation_RK]
           ,[LocationType]
           ,[HashDiff]
           ,[RecordSource]
)

                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('POA' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        LoadDate ,
                       UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
			UPPER(CONCAT(
				RTRIM(LTRIM(COALESCE(CMI,''))),':',					
					RTRIM(LTRIM(COALESCE([POA_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(POA_ZipCode_PK,'')))
				))
				),2)), 
                       'POA',
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('POA' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('POA' ,
                                                                                                                         
                                                              '')))))), 2)) NOT IN (
                        SELECT  LS_MemberLocationType_RK
                        FROM    LS_MemberLocationType
                         WHERE RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('POA' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        LoadDate ,
                       UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
			UPPER(CONCAT(
				RTRIM(LTRIM(COALESCE(CMI,''))),':',					
					RTRIM(LTRIM(COALESCE([POA_Address],''))),':',		
					RTRIM(LTRIM(COALESCE(POA_ZipCode_PK,'')))
				))
				),2)), 
                       
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE('POA' ,
                                                                                                                         
                                                              '')))))), 2)) ,
                        RecordSource;



	--RECORD END DATE CLEANUP
        UPDATE    dbo.LS_MemberContactType
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_MemberContactType z
                                  WHERE     z.L_MemberContact_RK = a.L_MemberContact_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_MemberContactType a
        WHERE   RecordEndDate IS NULL;

--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_MemberLocationType
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_MemberLocationType z
                                  WHERE     z.L_MemberLocation_RK = a.L_MemberLocation_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_MemberLocationType a
        WHERE   RecordEndDate IS NULL; 
	
		----RECORD END DATE CLEANUP
  --      UPDATE   dbo.L_MemberContact 
  --      SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
  --                                FROM      dbo.L_MemberContact z
  --                                WHERE     z.[H_Member_RK] = a.[H_Member_RK]
  --                                          AND z.LoadDate > a.LoadDate
  --                              )
  --      FROM    dbo.L_MemberContact a
  --      WHERE   a.RecordEndDate IS NULL; 

		--	--RECORD END DATE CLEANUP
  --      UPDATE  dbo.L_MemberLocation
  --      SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
  --                                FROM      dbo.L_MemberLocation z
  --                                WHERE     z.[H_Member_RK] = a.[H_Member_RK]
  --                                          AND z.LoadDate > a.LoadDate
  --                              )
  --      FROM    dbo.L_MemberLocation a
  --      WHERE   a.RecordEndDate IS NULL; 



END

GO
