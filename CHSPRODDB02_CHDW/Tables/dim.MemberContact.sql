CREATE TABLE [dim].[MemberContact]
(
[MemberContactID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[Phone] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordStartDate] [datetime] NULL CONSTRAINT [DF_MemberContact_CreateDate] DEFAULT (getdate()),
[RecordEndDate] [datetime] NULL CONSTRAINT [DF_MemberContact_RecordEndDate] DEFAULT ('2999-12-31'),
[Cell] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[MemberContact] ADD CONSTRAINT [PK_MemberContact] PRIMARY KEY CLUSTERED  ([MemberContactID]) ON [PRIMARY]
GO
ALTER TABLE [dim].[MemberContact] ADD CONSTRAINT [FK_MemberContact_Member] FOREIGN KEY ([MemberID]) REFERENCES [dim].[Member] ([MemberID])
GO
