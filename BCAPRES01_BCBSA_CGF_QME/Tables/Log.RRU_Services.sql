CREATE TABLE [Log].[RRU_Services]
(
[ADSCID] [smallint] NULL,
[BatchID] [int] NOT NULL,
[BeginDate] [datetime] NOT NULL,
[CodeID] [int] NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[Days] [int] NULL,
[DSClaimCodeID] [bigint] NULL,
[DSClaimLineID] [bigint] NULL,
[DSEntityID] [bigint] NULL,
[DSMemberID] [bigint] NULL,
[EndDate] [datetime] NULL,
[LogDate] [datetime] NOT NULL CONSTRAINT [DF_RRU_Services_LogDate] DEFAULT (getdate()),
[LogID] [bigint] NOT NULL IDENTITY(1, 1),
[LogUser] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RRU_Services_LogUser] DEFAULT (suser_sname()),
[OptionNbr] [tinyint] NOT NULL,
[PriceCtgyCodeID] [int] NULL,
[PriceCtgyID] [tinyint] NULL,
[Price] [decimal] (18, 4) NULL,
[RRUValTypeID] [tinyint] NOT NULL,
[Qty] [decimal] (18, 4) NULL,
[Value] [decimal] (18, 4) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Log].[RRU_Services] ADD CONSTRAINT [PK_Log_RRU_Services] PRIMARY KEY CLUSTERED  ([LogID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Log_RRU_Services_BatchID] ON [Log].[RRU_Services] ([BatchID], [DataRunID], [DataSetID], [DSMemberID], [LogID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Log_RRU_Services] ON [Log].[RRU_Services] ([DSMemberID]) ON [PRIMARY]
GO
