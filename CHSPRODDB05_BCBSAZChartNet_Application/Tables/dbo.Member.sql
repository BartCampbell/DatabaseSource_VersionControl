CREATE TABLE [dbo].[Member]
(
[MemberID] [int] NOT NULL IDENTITY(1, 1),
[ProductLine] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Product] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SSN] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameFirst] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NameLast] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NameMiddleInitial] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NamePrefix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameSuffix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOfBirth] [datetime] NOT NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Race] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ethnicity] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberLanguage] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InterpreterFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalDateOfBirth] [datetime] NULL,
[OriginalGender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Changed] AS (CONVERT([bit],case  when isnull([Gender],'')<>isnull([OriginalGender],'') OR isnull([DateOfBirth],CONVERT([datetime],(0),(0)))<>isnull([OriginalDateOfBirth],CONVERT([datetime],(0),(0))) then (1) else (0) end,(0))) PERSISTED,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_Member_CreatedDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_Member_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Member] ADD CONSTRAINT [PK_Member] PRIMARY KEY CLUSTERED  ([MemberID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Member] ON [dbo].[Member] ([CustomerMemberID], [ProductLine], [Product]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Member_NameLast] ON [dbo].[Member] ([NameLast]) ON [PRIMARY]
GO
