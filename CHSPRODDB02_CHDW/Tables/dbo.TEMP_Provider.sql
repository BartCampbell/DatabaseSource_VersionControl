CREATE TABLE [dbo].[TEMP_Provider]
(
[ProviderID] [int] NOT NULL,
[NetworkID] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NetworkName] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderTypeDescription] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderTypeCode] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderLastName] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFirstName] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimarySpecialty] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialtyTypeCode] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VidaProID] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHSClientID] [int] NULL,
[Phone] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
