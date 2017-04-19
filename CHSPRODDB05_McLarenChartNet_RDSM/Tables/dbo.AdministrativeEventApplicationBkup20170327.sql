CREATE TABLE [dbo].[AdministrativeEventApplicationBkup20170327]
(
[AdministrativeEventID] [int] NOT NULL IDENTITY(1, 1),
[CustomerAdministrativeEventID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MeasureID] [int] NULL,
[HEDISSubMetricID] [int] NULL,
[MemberID] [int] NULL,
[ProviderID] [int] NULL,
[ServiceDate] [datetime] NULL,
[ProcedureCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOINC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LabResult] [numeric] (12, 3) NULL,
[NDCCode] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NDCDescription] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPT_IICode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Data_Source] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
