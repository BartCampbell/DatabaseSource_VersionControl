CREATE TABLE [dbo].[H_Client]
(
[H_Client_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Client_BK] [int] NOT NULL,
[ClientName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__H_Client__LoadDa__164452B1] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Client] ADD CONSTRAINT [PK_H_Client] PRIMARY KEY CLUSTERED  ([H_Client_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
