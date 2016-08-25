CREATE TABLE [dbo].[tblMarket]
(
[Client_PK] [smallint] NULL,
[Market_PK] [int] NOT NULL IDENTITY(1, 1),
[Market_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMarket] ADD CONSTRAINT [PK_tblMarket] PRIMARY KEY CLUSTERED  ([Market_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblMarketClient] ON [dbo].[tblMarket] ([Client_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
