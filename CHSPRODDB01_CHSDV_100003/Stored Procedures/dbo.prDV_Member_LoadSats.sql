SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 12/23/2015
-- Description:	Data Vault Member Load
-- =============================================
CREATE PROCEDURE [dbo].[prDV_Member_LoadSats]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--**S_MemberDEMO LOAD
	INSERT INTO S_MemberDemo
	(S_MemberDemo_RK, LoadDate, H_Member_RK, FirstName, LastName, Gender, DOB, HashDiff, RecordSource)
	SELECT
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Member First Name],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Member Last Name],''))),':',
			RTRIM(LTRIM(COALESCE(rw.Gender,''))),':',
			RTRIM(LTRIM(COALESCE(rw.BirthDate,'')))
			))
			),2)),
	 LoadDate, 
	 MemberHashKey,
	 [Member First Name], 
	 [Member Last Name],
	 Gender,
	 Birthdate,
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.[Member First Name],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Member Last Name],''))),':',
			RTRIM(LTRIM(COALESCE(rw.Gender,''))),':',
			RTRIM(LTRIM(COALESCE(rw.BirthDate,'')))
			))
			),2)),
	RecordSource
	FROM CHSStaging..Member_Stage_Raw rw with(nolock)
	WHERE
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.[Member First Name],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Member Last Name],''))),':',
			RTRIM(LTRIM(COALESCE(rw.Gender,''))),':',
			RTRIM(LTRIM(COALESCE(rw.BirthDate,'')))
			))
			),2))
	not in (SELECT HashDiff FROM S_MemberDemo WHERE 
					H_Member_RK = rw.MemberHashKey and RecordEndDate is null)
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Member First Name],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Member Last Name],''))),':',
			RTRIM(LTRIM(COALESCE(rw.Gender,''))),':',
			RTRIM(LTRIM(COALESCE(rw.BirthDate,'')))
			))
			),2)),
			CMI,
			LoadDate,
	 MemberHashKey,
	 [Member First Name], 
	 [Member Last Name],
	 Gender,
	 Birthdate,
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.[Member First Name],''))),':',
			RTRIM(LTRIM(COALESCE(rw.[Member Last Name],''))),':',
			RTRIM(LTRIM(COALESCE(rw.Gender,''))),':',
			RTRIM(LTRIM(COALESCE(rw.BirthDate,'')))
			))
			),2)),
	RecordSource

	--RECORD END DATE CLEANUP
	UPDATE dbo.S_MemberDemo set
	RecordEndDate = (
	 Select 
	  DATEADD(ss,-1,Min(z.LoadDate))
	 From
	 dbo.S_MemberDemo z
	 Where
	  z.H_Member_RK = a.H_Member_RK
	  and z.LoadDate > a.LoadDate
	  )
	FROM 
	 dbo.S_MemberDemo a
	Where RecordEndDate Is Null 
	

    


--**** S_MEMBERELIGIBILITY LOAD
INSERT INTO S_MemberEligibility
	(S_MemberElig_RK, LoadDate, H_Member_RK, EffectiveStartDate, EffectiveEndDate, GroupEffectiveDate, Payor, HashDiff, RecordSource)
	SELECT
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.PlanEffectiveDate,''))),':',
			RTRIM(LTRIM(COALESCE(rw.TerminationDate,''))),':',
			RTRIM(LTRIM(COALESCE(rw.PHO_IPA_EffectiveDate,''))),':',
			RTRIM(LTRIM(COALESCE(rw.Payor,'')))
			))
			),2)),
	LoadDate, 
	 MemberHashKey,
	PlanEffectiveDate, 
	TerminationDate,
	PHO_IPA_EffectiveDate, 
	payor,	 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.PlanEffectiveDate,''))),':',
			RTRIM(LTRIM(COALESCE(rw.TerminationDate,''))),':',
			RTRIM(LTRIM(COALESCE(rw.PHO_IPA_EffectiveDate,''))),':',
			RTRIM(LTRIM(COALESCE(rw.Payor,'')))
			))
			),2)),
	RecordSource
	FROM CHSStaging..Member_Stage_Raw rw with(nolock)
	WHERE
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.PlanEffectiveDate,''))),':',
			RTRIM(LTRIM(COALESCE(rw.TerminationDate,''))),':',
			RTRIM(LTRIM(COALESCE(rw.PHO_IPA_EffectiveDate,''))),':',
			RTRIM(LTRIM(COALESCE(rw.Payor,'')))
			))
			),2))
	not in (SELECT HashDiff FROM S_MemberEligibility WHERE 
					H_Member_RK = rw.MemberHashKey and RecordEndDate is null)
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.PlanEffectiveDate,''))),':',
			RTRIM(LTRIM(COALESCE(rw.TerminationDate,''))),':',
			RTRIM(LTRIM(COALESCE(rw.PHO_IPA_EffectiveDate,''))),':',
			RTRIM(LTRIM(COALESCE(rw.Payor,'')))
			))
			),2)),
			LoadDate,
	 MemberHashKey,
	PlanEffectiveDate, 
	TerminationDate,
	PHO_IPA_EffectiveDate, 
	payor,	 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.PlanEffectiveDate,''))),':',
			RTRIM(LTRIM(COALESCE(rw.TerminationDate,''))),':',
			RTRIM(LTRIM(COALESCE(rw.PHO_IPA_EffectiveDate,''))),':',
			RTRIM(LTRIM(COALESCE(rw.Payor,'')))
			))
			),2)),
	RecordSource

	--RECORD END DATE CLEANUP
	UPDATE dbo.S_MemberEligibility set
	RecordEndDate = (
	 Select 
	  DATEADD(ss,-1,Min(z.LoadDate))
	 From
	 dbo.S_MemberEligibility z
	 Where
	  z.H_Member_RK = a.H_Member_RK
	  and z.LoadDate > a.LoadDate
	  )
	FROM 
	 dbo.S_MemberEligibility a
	Where RecordEndDate Is Null 


--***** INSERT INTO S_MEMBERHICN

	INSERT INTO S_MemberHICN
	Select 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.HICNumber,'')))
			))
			),2)),
			LoadDate,
			MemberHashKey,
			HICNumber,
			RecordSource,
			Null
	FROM CHSStaging..Member_Stage_Raw rw with(nolock)
	where HICNumber is not null
	and upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.HICNumber,'')))
			))
			),2)) not in (Select S_MemberHICN_RK from S_MemberHICN)
	GROUP BY
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CMI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.HICNumber,'')))
			))
			),2)),
			LoadDate,
			MemberHashKey,
			HICNumber,
			RecordSource

	--RECORD END DATE CLEANUP
	UPDATE dbo.S_MemberHICN set
	RecordEndDate = (
	 Select 
	  DATEADD(ss,-1,Min(z.LoadDate))
	 From
	 dbo.S_MemberHICN z
	 Where
	  z.H_Member_RK = a.H_Member_RK
	  and z.LoadDate > a.LoadDate
	  )
	FROM 
	 dbo.S_MemberHICN a
	Where RecordEndDate Is Null 

--*** Insert into S_LOCATION

	Insert into S_Location
		Select
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(Zip,''))),':',
				RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(Zip,''))),':',
				RTRIM(LTRIM(COALESCE(County,'')))
				))
				),2)),
			LoadDate,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(Zip,'')))
				))
				),2)),
				Address1,
				Address2,
				City,
				[State],
				Zip,
				County,
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
					RTRIM(LTRIM(COALESCE(Address2,''))),':',
					RTRIM(LTRIM(COALESCE(City,''))),':',
					RTRIM(LTRIM(COALESCE([State],''))),':',
					RTRIM(LTRIM(COALESCE(Zip,''))),':',
					RTRIM(LTRIM(COALESCE(County,'')))
					))
				),2)),
				RecordSource,
				Null
		FROM CHSStaging..Member_Stage_Raw rw WITH(NOLOCK)
		Where 
			upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
					RTRIM(LTRIM(COALESCE(Address2,''))),':',
					RTRIM(LTRIM(COALESCE(City,''))),':',
					RTRIM(LTRIM(COALESCE([State],''))),':',
					RTRIM(LTRIM(COALESCE(Zip,''))),':',
					RTRIM(LTRIM(COALESCE(County,'')))
					))
				),2)) not in (Select HashDiff from S_Location where RecordEndDate is null)
		GROUP BY
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(Zip,''))),':',
				RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(Zip,''))),':',
				RTRIM(LTRIM(COALESCE(County,'')))
				))
				),2)),
				LoadDate,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(Zip,'')))
				))
				),2)),
				Address1,
				Address2,
				City,
				[State],
				Zip,
				County,
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
					RTRIM(LTRIM(COALESCE(Address2,''))),':',
					RTRIM(LTRIM(COALESCE(City,''))),':',
					RTRIM(LTRIM(COALESCE([State],''))),':',
					RTRIM(LTRIM(COALESCE(Zip,''))),':',
					RTRIM(LTRIM(COALESCE(County,'')))
					))
				),2)),
				RecordSource

--RECORD END DATE CLEANUP
	UPDATE dbo.S_Location set
	RecordEndDate = (
	 Select 
	  DATEADD(ss,-1,Min(z.LoadDate))
	 From
	 dbo.S_Location z
	 Where
	  z.H_Location_RK = a.H_Location_RK
	  and z.LoadDate > a.LoadDate
	  )
	FROM 
	 dbo.S_Location a
	Where RecordEndDate Is Null 

	

	--*** INSERT INTO S_CONTACT
	Insert into S_Contact
		Select 
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))),':',
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)),
		LoadDate,
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)),
		rw.Phone, 
		rw.Mobile, 
		rw.Fax, 
		rw.Email,
		Null,
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)),
		RecordSource,
		Null
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
		not in (Select HashDiff from S_Contact where RecordEndDate is null)
	GROUP BY
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))),':',
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)),
		LoadDate,
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)),
		rw.Phone, 
		rw.Mobile, 
		rw.Fax, 
		rw.Email,
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)),
		RecordSource

		--RECORD END DATE CLEANUP
			UPDATE dbo.S_Contact set
			RecordEndDate = (
			 Select 
			  DATEADD(ss,-1,Min(z.LoadDate))
			 From
			 dbo.S_Contact z
			 Where
			  z.H_Contact_RK = a.H_Contact_RK
			  and z.LoadDate > a.LoadDate
			  )
			FROM 
			 dbo.S_Contact a
			Where RecordEndDate Is Null 
END
    
	
GO
