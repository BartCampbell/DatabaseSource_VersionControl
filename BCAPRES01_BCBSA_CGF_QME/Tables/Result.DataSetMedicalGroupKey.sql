CREATE TABLE [Result].[DataSetMedicalGroupKey]
(
[CustomerMedicalGroupID] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[MedGrpFullName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MedGrpID] [int] NOT NULL,
[MedGrpName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RegionName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubRegionName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[DataSetMedicalGroupKey] ADD CONSTRAINT [PK_DataSetMedicalGroupKey] PRIMARY KEY CLUSTERED  ([MedGrpID], [DataRunID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DataSetMedicalGroupKey] ON [Result].[DataSetMedicalGroupKey] ([RegionName], [SubRegionName], [DataRunID]) ON [PRIMARY]
GO
