CREATE TABLE [dbo].[LS_SuspectProvider]
(
[LS_SuspectProvider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_SuspectProvider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ProviderOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_SuspectProvider] ADD CONSTRAINT [PK_LS_SuspectProvider] PRIMARY KEY CLUSTERED  ([LS_SuspectProvider_RK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161025-111100] ON [dbo].[LS_SuspectProvider] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_SuspectProvider] ADD CONSTRAINT [FK_L_SuspectProvider_RK1] FOREIGN KEY ([L_SuspectProvider_RK]) REFERENCES [dbo].[L_SuspectProvider] ([L_SuspectProvider_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
