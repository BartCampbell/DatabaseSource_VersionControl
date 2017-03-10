SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[prLoadMember]
--***********************************************************************
--***********************************************************************
/*
Loads ChartNet Application table: Member, from Client Import table: Member
*/
--select * from Member
--***********************************************************************
--***********************************************************************
AS 
BEGIN;
	BEGIN TRAN TLoadMember;

	INSERT  INTO Member
			(ProductLine,
			 Product,
			 CustomerMemberID,
			 SSN,
			 NameFirst,
			 NameLast,
			 NameMiddleInitial,
			 NamePrefix,
			 NameSuffix,
			 DateOfBirth,
			 Gender,
			 Address1,
			 Address2,
			 City,
			 State,
			 ZipCode,
			 Race,
			 Ethnicity,
			 MemberLanguage,
			 InterpreterFlag	
			)
			SELECT  ProductLine = ProductLine,
					Product = Product,
					CustomerMemberID = LTRIM(RTRIM(CustomerMemberID)),
					SSN = SSN,
					NameFirst = LTRIM(RTRIM(NameFirst)),
					NameLast = LTRIM(RTRIM(NameLast)),
					NameMiddleInitial = LTRIM(RTRIM(NameMiddleInitial)),
					NamePrefix = LTRIM(RTRIM(NamePrefix)),
					NameSuffix = LTRIM(RTRIM(NameSuffix)),
					DateOfBirth = DateOfBirth,
					Gender = Gender,
					Address1 = LTRIM(RTRIM(Address1)),
					Address2 = LTRIM(RTRIM(Address2)),
					City = LTRIM(RTRIM(City)),
					State = LTRIM(RTRIM(State)),
					ZipCode = LTRIM(RTRIM(ZipCode)),
					Race = Race,
					Ethnicity = Ethnicity,
					MemberLanguage = MemberLanguage,
					InterpreterFlag = InterpreterFlag
			FROM    RDSM.Member;

	EXEC dbo.prLoadMemberOriginals;

	COMMIT TRAN TLoadMember;
END;






GO
