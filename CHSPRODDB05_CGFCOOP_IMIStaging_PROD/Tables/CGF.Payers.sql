CREATE TABLE [CGF].[Payers]
(
[Abbrev] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PayerGuid] [uniqueidentifier] NOT NULL,
[PayerID] [smallint] NOT NULL,
[ProductLineID] [smallint] NOT NULL,
[ProductTypeID] [smallint] NOT NULL,
[Payer] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Payers_Payer] ON [CGF].[Payers] ([Payer]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Payers] ON [CGF].[Payers] ([PayerGuid]) ON [PRIMARY]
GO
CREATE STATISTICS [spIX_Payers_Payer] ON [CGF].[Payers] ([Payer])
GO
CREATE STATISTICS [spIX_Payers] ON [CGF].[Payers] ([PayerGuid])
GO
