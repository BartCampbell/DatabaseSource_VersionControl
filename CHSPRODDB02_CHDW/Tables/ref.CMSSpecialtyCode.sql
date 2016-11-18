CREATE TABLE [ref].[CMSSpecialtyCode]
(
[SpecialtyCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialtyCodeDesc] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMSAcceptableFlag] [bit] NULL,
[CMSSpecialtyID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[CMSSpecialtyCode] ADD CONSTRAINT [PK_CMSSpecialtyCode] PRIMARY KEY CLUSTERED  ([CMSSpecialtyID]) ON [PRIMARY]
GO
