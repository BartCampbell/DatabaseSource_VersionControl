CREATE TABLE [Ncqa].[HAI_HospitalSIRs]
(
[HospitalID] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HospSirGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_HAI_HospitalSIRs_HospSirGuid] DEFAULT (newid()),
[HospSirID] [int] NOT NULL IDENTITY(1, 1),
[MeasureSetID] [int] NOT NULL,
[Metric] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SIRClass] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SIRScore] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[HAI_HospitalSIRs] ADD CONSTRAINT [PK_Ncqa_HAI_HospitalSIRs] PRIMARY KEY CLUSTERED  ([HospSirID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_HAI_HospitalSIRs_HospitalIDandMetric] ON [Ncqa].[HAI_HospitalSIRs] ([HospitalID], [MeasureSetID], [Metric]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_HAI_HospitalSIRs] ON [Ncqa].[HAI_HospitalSIRs] ([HospSirGuid]) ON [PRIMARY]
GO
