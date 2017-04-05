CREATE TABLE [BCBSA_GDIT2017].[ProviderSpecialty_Template]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowFileID] [int] NULL,
[JobRunTaskFileID] [uniqueidentifier] NULL,
[LoadInstanceID] [int] NULL,
[LoadInstanceFileID] [int] NULL,
[ProviderID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderSpecialtyID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHSpecialtyID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimarySpecialty] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
