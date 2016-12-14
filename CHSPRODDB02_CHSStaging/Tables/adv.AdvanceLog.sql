CREATE TABLE [adv].[AdvanceLog]
(
[ALKey] [int] NOT NULL IDENTITY(1, 1),
[TableType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__AdvanceLo__LoadD__0A80C7A6] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ClusteredIndex-20161006-074930] ON [adv].[AdvanceLog] ([ALKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161006-074916] ON [adv].[AdvanceLog] ([LoadDate]) ON [PRIMARY]
GO
