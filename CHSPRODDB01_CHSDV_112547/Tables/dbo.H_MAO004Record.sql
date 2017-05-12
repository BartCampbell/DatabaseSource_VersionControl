CREATE TABLE [dbo].[H_MAO004Record]
(
[H_MAO004Record_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MAO004Record_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientMAO004RecordID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_MAO004Record] ADD CONSTRAINT [PK_H_MAO004Record] PRIMARY KEY CLUSTERED  ([H_MAO004Record_RK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_H_MAO004Record_34_1549248574__K3] ON [dbo].[H_MAO004Record] ([ClientMAO004RecordID]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_1549248574_3_1] ON [dbo].[H_MAO004Record] ([ClientMAO004RecordID], [H_MAO004Record_RK])
GO
