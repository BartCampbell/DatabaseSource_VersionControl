CREATE TABLE [dbo].[Member]
(
[MemberID] [int] NOT NULL IDENTITY(1, 1),
[Address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerMemberID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSubscriberID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerPersonNo] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOfBirth] [datetime] NULL,
[DateRowCreated] [datetime] NULL,
[DateValidBegin] [datetime] NULL,
[DateValidEnd] [datetime] NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashValue] [binary] (16) NULL,
[ihds_member_id] [int] NULL,
[IsSubscriber] [bit] NULL,
[NameFirst] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameLast] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameMiddleInitial] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubscriberID] [int] NULL,
[ZipCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NULL,
[Ethnicity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InterpreterFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberLanguage] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Race] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicaidID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicareID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerDiamondID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalRecordNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneMobile] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneWork] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneHome] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EthnicitySource] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherLanguage] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherLanguageSource] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RaceSource] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RaceEthnicitySource] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpokenLanguage] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpokenLanguageSource] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WrittenLanguage] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WrittenLanguageSource] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberLanguageCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssignedClinic] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceSystem] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmployeeNo] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Member] ADD CONSTRAINT [pk_Member] PRIMARY KEY CLUSTERED  ([MemberID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx5] ON [dbo].[Member] ([ihds_member_id]) ON [PRIMARY]
GO
CREATE STATISTICS [sp_pk_Member] ON [dbo].[Member] ([MemberID])
GO
