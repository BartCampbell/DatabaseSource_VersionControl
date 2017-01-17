SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/15/2016
-- Description:	Load all Hubs from the User staging table.  
-- =============================================
CREATE PROCEDURE [dbo].[spDV_User_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** LOAD H_PROVIDER
INSERT INTO [dbo].[H_User]
           ([H_User_RK]
           ,[User_PK]
           ,[ClientUserID]
           ,[RecordSource]
           ,[LoadDate])
 
SELECT	DISTINCT UserHashKey, CUI, User_PK,RecordSource,LoadDate
	FROM 
		CHSStaging.adv.tblUserWCStage
	WHERE
		UserHashKey not in (Select H_User_RK from H_User)
		AND CCI = @CCI


INSERT INTO [dbo].[H_User]
           ([H_User_RK]
           ,[User_PK]
           ,[ClientUserID]
           ,[RecordSource]
           ,[LoadDate])
 
SELECT	DISTINCT UserHashKey, CUI, User_PK,RecordSource,LoadDate
	FROM 
		CHSStaging.adv.tblUserRemovedStage
	WHERE
		UserHashKey not in (Select H_User_RK from H_User)
		AND CCI = @CCI



--** LOAD H_CLIENT
INSERT INTO H_Client
	SELECT 
		DISTINCT ClientHashKey, CCI, Client, RecordSource,  LoadDate
	FROM 
		CHSStaging.adv.tblUserWCStage
	WHERE
		ClientHashKey not in (Select H_Client_RK from H_Client)
			AND CCI = @CCI


INSERT INTO H_Client
	SELECT 
		DISTINCT ClientHashKey, CCI, Client, RecordSource,  LoadDate
	FROM 
		CHSStaging.adv.tblUserRemovedStage
	WHERE
		ClientHashKey not in (Select H_Client_RK from H_Client)
			AND CCI = @CCI

--*** LOAD H_CONTACT
INSERT INTO [dbo].[H_Contact]
           ([H_Contact_RK]
           ,[Contact_BK]
           ,[RecordSource]
           ,[LoadDate])
 Select 
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE([sch_Tel],''))),':',
				RTRIM(LTRIM(COALESCE([sch_Fax],''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)),
		Concat(RTRIM(LTRIM(COALESCE([sch_Tel],''))),RTRIM(LTRIM(COALESCE([sch_Fax],''))),RTRIM(LTRIM(COALESCE(Email_Address,'')))),
			RecordSource,
			LoadDate 
	 FROM 
		CHSStaging.adv.tblUserWCStage rw
		where 
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE([sch_Tel],''))),':',
				RTRIM(LTRIM(COALESCE([sch_Fax],''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2))
		not in (Select H_Contact_RK from H_Contact)
		AND CCI= @CCI
	GROUP BY
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE([sch_Tel],''))),':',
				RTRIM(LTRIM(COALESCE([sch_Fax],''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)),
		Concat(RTRIM(LTRIM(COALESCE([sch_Tel],''))),RTRIM(LTRIM(COALESCE([sch_Fax],''))),RTRIM(LTRIM(COALESCE(Email_Address,'')))),
		LoadDate,
		RecordSource



INSERT INTO [dbo].[H_Contact]
           ([H_Contact_RK]
           ,[Contact_BK]
           ,[RecordSource]
           ,[LoadDate])
 Select 
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)),
		RTRIM(LTRIM(COALESCE(Email_Address,''))),
			RecordSource,
			LoadDate 
	 FROM 
		CHSStaging.adv.tblUserRemovedStage rw
		where 
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
					RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2))
		not in (Select H_Contact_RK from H_Contact)
		AND CCI= @CCI
	GROUP BY
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)),
		RTRIM(LTRIM(COALESCE(Email_Address,''))),
		LoadDate,
		RecordSource


	---*** LOAD H_Location
	INSERT INTO H_Location
		Select 
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE([Address],''))),':',
				RTRIM(LTRIM(COALESCE(CAST(ZipCode_PK AS VARCHAR),'')))
				))
				),2)),
				Concat(RTRIM(LTRIM(COALESCE([Address],''))),ZipCode_PK),				
				LoadDate,
				RecordSource
		FROM CHSStaging.adv.tblUserWCStage
		where 
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE([Address],''))),':',
				RTRIM(LTRIM(COALESCE(CAST(ZipCode_PK AS VARCHAR),'')))
				))
				),2)) not in (Select H_Location_RK from H_Location)
				AND CCI= @CCI
		GROUP BY
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE([Address],''))),':',
				RTRIM(LTRIM(COALESCE(CAST(ZipCode_PK AS VARCHAR),'')))
				))
				),2)),
				Concat(RTRIM(LTRIM(COALESCE([Address],''))),ZipCode_PK),	
				LoadDate,			
				RecordSource



END





GO
