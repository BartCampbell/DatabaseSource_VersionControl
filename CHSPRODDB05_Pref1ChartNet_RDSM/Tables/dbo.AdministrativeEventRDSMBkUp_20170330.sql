CREATE TABLE [dbo].[AdministrativeEventRDSMBkUp_20170330]
(
[AdministrativeEventID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HEDISMeasure] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HEDISSubMetric] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerProviderID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceDate] [datetime] NULL,
[ProcedureCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOINC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LabResult] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NDCCode] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NDCDescription] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPT_IICode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Data_Source] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
