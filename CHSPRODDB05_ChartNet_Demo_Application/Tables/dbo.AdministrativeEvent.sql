CREATE TABLE [dbo].[AdministrativeEvent]
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
ALTER TABLE [dbo].[AdministrativeEvent] ADD CONSTRAINT [PK_AdministrativeEvent] PRIMARY KEY CLUSTERED  ([AdministrativeEventID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AdministrativeEvent_DataSource] ON [dbo].[AdministrativeEvent] ([Data_Source], [MemberID], [ServiceDate]) INCLUDE ([CPT_IICode], [HEDISSubMetricID], [LabResult], [LOINC], [MeasureID], [ProcedureCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AdministrativeEvent_Metric] ON [dbo].[AdministrativeEvent] ([MemberID], [HEDISSubMetricID], [ServiceDate]) INCLUDE ([CPT_IICode], [Data_Source], [LabResult], [LOINC], [MeasureID], [ProcedureCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AdministrativeEvent_Measure] ON [dbo].[AdministrativeEvent] ([MemberID], [MeasureID], [ServiceDate]) INCLUDE ([CPT_IICode], [Data_Source], [HEDISSubMetricID], [LabResult], [LOINC], [ProcedureCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AdministrativeEvent_Member] ON [dbo].[AdministrativeEvent] ([MemberID], [ServiceDate]) INCLUDE ([CPT_IICode], [Data_Source], [HEDISSubMetricID], [LabResult], [LOINC], [MeasureID], [ProcedureCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AdministrativeEvent] WITH NOCHECK ADD CONSTRAINT [FK_AdministrativeEvent_HEDISSubMetric] FOREIGN KEY ([HEDISSubMetricID]) REFERENCES [dbo].[HEDISSubMetric] ([HEDISSubMetricID])
GO
ALTER TABLE [dbo].[AdministrativeEvent] WITH NOCHECK ADD CONSTRAINT [FK_AdministrativeEvent_Measure] FOREIGN KEY ([MeasureID]) REFERENCES [dbo].[Measure] ([MeasureID])
GO
ALTER TABLE [dbo].[AdministrativeEvent] ADD CONSTRAINT [FK_AdministrativeEvent_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[Member] ([MemberID])
GO
ALTER TABLE [dbo].[AdministrativeEvent] ADD CONSTRAINT [FK_AdministrativeEvent_Providers] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Providers] ([ProviderID])
GO
