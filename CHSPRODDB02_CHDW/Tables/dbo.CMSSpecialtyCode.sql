CREATE TABLE [dbo].[CMSSpecialtyCode]
(
[SpecialtyCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialtyCodeDesc] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMSAcceptableFlag] [bit] NULL,
[CMSSpecialtyID] [int] NOT NULL
) ON [PRIMARY]
GO
