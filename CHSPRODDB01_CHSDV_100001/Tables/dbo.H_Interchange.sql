CREATE TABLE [dbo].[H_Interchange]
(
[H_Interchange_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[Interchange_BK] [varchar] (100) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Interchange] ADD CONSTRAINT [PK_H_Interchange] PRIMARY KEY CLUSTERED  ([H_Interchange_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
