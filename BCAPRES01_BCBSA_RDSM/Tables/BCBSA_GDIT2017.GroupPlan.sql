CREATE TABLE [BCBSA_GDIT2017].[GroupPlan]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowFileID] [int] NULL,
[JobRunTaskFileID] [uniqueidentifier] NULL,
[LoadInstanceID] [int] NULL,
[LoadInstanceFileID] [int] NULL,
[GroupID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Company] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MktSegmentCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MktSegmentDesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BusinessMktSegCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BusinessMktSegDesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Region] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AltPopID1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AltPopID2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NationalEmployerID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupCustom1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupCustom2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupCustom3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupCustom4] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HIOSID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AsOfDate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [BCBSA_GDIT2017_GroupPlan]
GO
CREATE NONCLUSTERED INDEX [idxGroupPlan] ON [BCBSA_GDIT2017].[GroupPlan] ([GroupID]) ON [BCBSA_GDIT2017_GroupPlan_IDX]
GO
CREATE CLUSTERED INDEX [clidxGroupPlan] ON [BCBSA_GDIT2017].[GroupPlan] ([RowID]) ON [BCBSA_GDIT2017_GroupPlan]
GO
CREATE STATISTICS [spidxGroupPlan] ON [BCBSA_GDIT2017].[GroupPlan] ([GroupID])
GO
CREATE STATISTICS [spclidxGroupPlan] ON [BCBSA_GDIT2017].[GroupPlan] ([RowID])
GO
