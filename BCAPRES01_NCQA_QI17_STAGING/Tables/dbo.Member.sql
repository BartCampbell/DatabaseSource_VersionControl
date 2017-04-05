CREATE TABLE [dbo].[Member]
(
[MemberID] [int] NOT NULL IDENTITY(1, 1),
[Address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOfBirth] [datetime] NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ihds_member_id] [int] NULL,
[legacy_ihds_member_id] [int] NULL,
[NameFirst] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameLast] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameMiddleInitial] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NamePrefix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameSuffix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RelationshipToSubscriber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSN] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubscriberID] [int] NULL,
[ZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Race] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ethnicity] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberLanguage] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InterpreterFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RaceEthnicitySource] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RaceSource] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EthnicitySource] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpokenLanguage] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpokenLanguageSource] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WrittenLanguage] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WrittenLanguageSource] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherLanguage] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherLanguageSource] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NULL,
[HashValue] [binary] (16) NULL,
[County] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Member] ADD CONSTRAINT [actMember_PK] PRIMARY KEY CLUSTERED  ([MemberID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ixMember_CustomerMemberID] ON [dbo].[Member] ([CustomerMemberID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fk_ihds_member_id] ON [dbo].[Member] ([ihds_member_id]) ON [PRIMARY]
GO
CREATE STATISTICS [sp_ixMember_CustomerMemberID] ON [dbo].[Member] ([CustomerMemberID])
GO
CREATE STATISTICS [sp_fk_ihds_member_id] ON [dbo].[Member] ([ihds_member_id])
GO
CREATE STATISTICS [sp_actMember_PK] ON [dbo].[Member] ([MemberID])
GO
ALTER TABLE [dbo].[Member] ADD CONSTRAINT [actSubscriber_Member_FK1] FOREIGN KEY ([SubscriberID]) REFERENCES [dbo].[Subscriber] ([SubscriberID])
GO
