SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [BCBSA].[spLoadMember]
    @RowCount INT
   ,@DestinationTable VARCHAR(100)
AS --uncomment if running manually to test
/*
declare @Rowcount int=100
,@DestinationTable varchar(100)='Member_Tst100'
*/

    DECLARE @vcCmd NVARCHAR(MAX)
       ,@debug INT = 1;


--Drop destination Tables
    IF @DestinationTable = 'Member_Tst100'
        BEGIN 
            IF OBJECT_ID('bcbsa.Member_Tst100' , 'U') IS NOT NULL
                DROP TABLE bcbsa.Member_Tst100;
        END;
    IF @DestinationTable = 'Member_Tst4m'
        BEGIN
            IF OBJECT_ID('bcbsa.Member_Tst4m' , 'U') IS NOT NULL
                DROP TABLE bcbsa.Member_Tst4m;
        END;
      

       

 --Destination table insert
    SET @vcCmd = 'SELECT TOP ' + CAST(@rowCount AS VARCHAR(100)) + '	
NULL	ProductID
,CustomerMemberID	MemberID
,CustomerPersonNo	UniversalMemberID
,MedicareID	MedicareID
,MedicaidID	MedicaidID
,SSN	PIN
,NULL	Confidential
,NameLast	NameLast
,NameFirst	NameFirst
,NameMiddleInitial	NameMiddleInitial
,NameSuffix	NameSuffix
,DateOfBirth	DOB
,NULL	DOD
,Gender	Gender
,Race	Race
,NameLast	ContactLastName
,NameFirst	ContactFirstName
,NameMiddleInitial	ContactMiddleInitial
,Gender	ContactGender
,Address1	ContactAddress1
,Address2	ContactAddress2
,City	ContactCity
,County	ContactCounty
,State	ContactState
,ZipCode	ContactZipCode
,Phone	ContactTelephone
,SpokenLanguage	Language
,NULL	AltLanguage1
,NULL	AltLanguage2
,NULL	Hispanic
,InterpreterFlag	Interpreter
,SpokenLanguageSource	LanguageSource
,WrittenLanguage	WrittenLanguage
,WrittenLanguageSource	WrittenLanguageSource
,OtherLanguage	OtherLanguage
,OtherLanguageSource	OtherLanguageSource
,RaceSource	RaceSource
,EthnicitySource	EthnicitySource
,NULL	MemberCustom1
,NULL	MemberCustom2
,NULL	MemberCustom3
,NULL	MemberCustom4
,dateRowCreated	AsOfDate
,SourceSystem	SourceID


	   into  bcbsa.' + @DestinationTable + ' 
    FROM IMI_IMIStaging.dbo.Member  order by dateRowCreated desc
';

    IF @debug >= 2
        BEGIN 
            PRINT CHAR(13)
                + 'spLoadMember: EXEC INSERT INTO Destination Table'
                + CHAR(13) + @vcCmd;
        END; 
    IF @debug < 2
        AND @debug >= 1
        BEGIN
            PRINT CHAR(13)
                + 'spLoadMember: Print INSERT INTO Destination Table'
                + CHAR(13) + @vcCmd;
            EXEC (@vcCmd);
        END; 

	
	
	
GO
