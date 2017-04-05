CREATE TABLE [ChartNetImport].[Member]
(
[ProductLine] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Product] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SSN] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameFirst] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameLast] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameMiddleInitial] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NamePrefix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameSuffix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOfBirth] [datetime] NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Race] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ethnicity] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberLanguage] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InterpreterFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SecondaryRefID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [ChartNetImport].[Member] ADD CONSTRAINT [PK_Member] PRIMARY KEY CLUSTERED  ([CustomerMemberID], [ProductLine], [Product]) ON [PRIMARY]
GO
