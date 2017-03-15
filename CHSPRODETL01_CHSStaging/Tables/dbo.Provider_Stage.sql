CREATE TABLE [dbo].[Provider_Stage]
(
[ProviderTypeDescription] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderTypeCode] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderLastName] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFirstName] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimarySpecialty] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialtyTypeCode] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CPI] [int] NOT NULL IDENTITY(1, 1),
[LoadDate] [datetime] NULL,
[IsActive] [bit] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Provider_Stage] ADD CONSTRAINT [PK_Provider_Stage] PRIMARY KEY CLUSTERED  ([CPI]) ON [PRIMARY]
GO
