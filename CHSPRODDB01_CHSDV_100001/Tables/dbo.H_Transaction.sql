CREATE TABLE [dbo].[H_Transaction]
(
[H_Transaction_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[Transaction_BK] [varchar] (150) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Transaction] ADD CONSTRAINT [PK_H_Transaction] PRIMARY KEY CLUSTERED  ([H_Transaction_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
