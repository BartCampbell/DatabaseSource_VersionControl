CREATE TABLE [dbo].[Customer]
(
[CustomerID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Customer_CustomerID] DEFAULT (newid()),
[CustomerName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatabaseDW01] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatabaseDW01Prod] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatabaseIMIDataStore] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatabaseRDSM] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Customer] ADD CONSTRAINT [Customer_PK] PRIMARY KEY CLUSTERED  ([CustomerID]) ON [PRIMARY]
GO
