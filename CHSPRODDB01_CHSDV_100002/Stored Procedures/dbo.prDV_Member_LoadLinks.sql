SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 12/14/2015
-- Description:	Load all Link Tables from the provider staging raw table. 
-- =============================================
CREATE PROCEDURE [dbo].[prDV_Member_LoadLinks]
	-- Add the parameters for the stored procedure here

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
	 rw.LoadDate, 
	 rw.RecordSource,
	 null
	 from CHSStaging..Member_Stage_Raw rw with(nolock)
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CCI,'')))
			))
			),2)) not in (Select L_MemberClient_RK from L_MemberClient where RecordEndDate is null)
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CCI,'')))
						))
			),2)),
		rw.MemberHashKey,
		rw.ClientHashKey,
		rw.LoadDate,		
		rw.RecordSource


		--*** INSERT INTO L_MEMBERCONTACT

		INSERT INTO L_MemberContact
		SELECT
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Phone,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Fax,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Email,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)),
			MemberHashKey,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.Phone,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Fax,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Email,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
			))
			),2)),
			LoadDate,
			RecordSource,
			Null
		From CHSStaging..Member_Stage_Raw rw
		Where 
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Phone,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Fax,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Email,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2))
		 not in(Select L_MemberContact_RK from L_MemberContact where RecordEndDate is null)
		GROUP BY
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Phone,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Fax,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Email,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)),
			MemberHashKey,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.Phone,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Fax,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Email,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
			))
			),2)),
			LoadDate,
			RecordSource

---**** INSERT INTO L_PROVIDERLOCATION

		INSERT INTO L_MemberLocation
			Select 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CMI,''))),':',
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
					RTRIM(LTRIM(COALESCE(Address2,''))),':',
					RTRIM(LTRIM(COALESCE(City,''))),':',
					RTRIM(LTRIM(COALESCE([State],''))),':',
					RTRIM(LTRIM(COALESCE(Zip,'')))
					))
				),2)),
				rw.MemberHashKey, 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
					RTRIM(LTRIM(COALESCE(Address2,''))),':',
					RTRIM(LTRIM(COALESCE(City,''))),':',
					RTRIM(LTRIM(COALESCE([State],''))),':',
					RTRIM(LTRIM(COALESCE(Zip,'')))
					))
				),2)),
				LoadDate,
				RecordSource,
				Null
			FROM CHSStaging..Member_Stage_Raw rw
			WHERE
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CMI,''))),':',
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
					RTRIM(LTRIM(COALESCE(Address2,''))),':',
					RTRIM(LTRIM(COALESCE(City,''))),':',
					RTRIM(LTRIM(COALESCE([State],''))),':',
					RTRIM(LTRIM(COALESCE(Zip,'')))
					))
				),2)) not in (Select L_MemberLocation_RK from L_MemberLocation where RecordEndDate is null)
			GROUP BY
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CMI,''))),':',
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
					RTRIM(LTRIM(COALESCE(Address2,''))),':',
					RTRIM(LTRIM(COALESCE(City,''))),':',
					RTRIM(LTRIM(COALESCE([State],''))),':',
					RTRIM(LTRIM(COALESCE(Zip,'')))
					))
				),2)),
				rw.MemberHashKey, 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
					RTRIM(LTRIM(COALESCE(Address2,''))),':',
					RTRIM(LTRIM(COALESCE(City,''))),':',
					RTRIM(LTRIM(COALESCE([State],''))),':',
					RTRIM(LTRIM(COALESCE(Zip,'')))
					))
				),2)),
				LoadDate,
				RecordSource
			

END
GO
