CREATE TABLE [dim].[ProviderLocation]
(
[ProviderLocationID] [int] NOT NULL IDENTITY(1, 1),
[ProviderID] [int] NOT NULL,
[Addr1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Addr2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Advance_Addr1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Advance_Zip] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Advance_Phone] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Advance_Fax] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_ProviderLocation_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ProviderLocation_LastUpdate] DEFAULT (getdate()),
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[ProviderLocation] ADD CONSTRAINT [PK_ProviderLocation] PRIMARY KEY CLUSTERED  ([ProviderLocationID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_ProviderLocation_17_640721335__K3_K5_K6_K7_K2_1] ON [dim].[ProviderLocation] ([Addr1], [City], [State], [Zip], [ProviderID]) INCLUDE ([ProviderLocationID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_ProviderLocation_17_1344723843__K2_K1_9_10_11_12] ON [dim].[ProviderLocation] ([ProviderID], [ProviderLocationID]) INCLUDE ([Advance_Addr1], [Advance_Fax], [Advance_Phone], [Advance_Zip]) ON [PRIMARY]
GO
CREATE STATISTICS [stat_1344723843_2_3_5_6] ON [dim].[ProviderLocation] ([ProviderID], [Addr1], [City], [State])
GO
ALTER TABLE [dim].[ProviderLocation] ADD CONSTRAINT [FK_ProviderLocation_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dim].[Provider] ([ProviderID])
GO
