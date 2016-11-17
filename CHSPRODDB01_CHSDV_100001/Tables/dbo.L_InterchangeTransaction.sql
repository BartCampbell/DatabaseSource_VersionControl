CREATE TABLE [dbo].[L_InterchangeTransaction]
(
[L_InterchangeTransaction_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[H_Interchange_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[H_Transaction_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_InterchangeTransaction] ADD CONSTRAINT [FK_L_InterchangeTransaction_H_Interchange] FOREIGN KEY ([H_Interchange_RK]) REFERENCES [dbo].[H_Interchange] ([H_Interchange_RK])
GO
ALTER TABLE [dbo].[L_InterchangeTransaction] ADD CONSTRAINT [FK_L_InterchangeTransaction_H_Transaction] FOREIGN KEY ([H_Transaction_RK]) REFERENCES [dbo].[H_Transaction] ([H_Transaction_RK])
GO
