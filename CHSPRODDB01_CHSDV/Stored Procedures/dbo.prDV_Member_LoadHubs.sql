SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 12/23/2015
-- Description:	Load all Hubs from the Member_Stage_Raw table. 
-- =============================================
CREATE PROCEDURE [dbo].[prDV_Member_LoadHubs]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** LOAD H_Member
INSERT INTO H_Member
	SELECT 
		DISTINCT MemberHashKey, CMI, ClientMemberID, SSN,  LoadDate, RecordSource
	FROM 
		CHSStaging..Member_Stage_Raw with(nolock)
	WHERE
		MemberHashKey not in (Select H_Member_RK from H_Member)
		

--** LOAD H_CLIENT
INSERT INTO H_Client
	SELECT 
		DISTINCT ClientHashKey, CCI, ClientName, RecordSource, LoadDate
	FROM 
		CHSStaging..Member_Stage_Raw with(nolock)
	WHERE
		ClientHashKey not in (Select H_Client_RK from H_Client)
	

--*** LOAD H_CONTACT
Insert into H_Contact
	Select 
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)),
		Concat(rw.Phone, rw.Mobile, rw.Fax, rw.Email),
		LoadDate,
		RecordSource
	 FROM 
		CHSStaging..Member_Stage_Raw rw
		where 
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2))
		not in (Select H_Contact_RK from H_Contact)
	GROUP BY
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)),
		Concat(rw.Phone, rw.Mobile, rw.Fax, rw.Email),
		LoadDate,
		RecordSource


	---*** LOAD H_Location
	INSERT INTO H_Location
		Select 
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(Zip,'')))
				))
				),2)),
				Concat(Address1,
				Address2,
				City,
				[State],
				Zip),				
				LoadDate,
				RecordSource
		FROM CHSStaging..Member_Stage_Raw
		where 
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(Zip,'')))
				))
				),2)) not in (Select H_Location_RK from H_Location)
		GROUP BY
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(Zip,'')))
				))
				),2)),
				Concat(Address1,
				Address2,
				City,
				[State],
				Zip),	
				LoadDate,			
				RecordSource

End
GO
