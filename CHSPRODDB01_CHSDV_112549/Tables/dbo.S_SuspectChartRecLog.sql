CREATE TABLE [dbo].[S_SuspectChartRecLog]
(
[S_SuspectChartRecLog_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[User_PK] [smallint] NOT NULL,
[Log_Date] [smalldatetime] NULL,
[Log_Info] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_SuspectChartRecLog] ADD CONSTRAINT [PK_S_SuspectChartRecLog] PRIMARY KEY CLUSTERED  ([S_SuspectChartRecLog_RK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161003-081856] ON [dbo].[S_SuspectChartRecLog] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_SuspectChartRecLog] ADD CONSTRAINT [FK_H_Suspect_RK9] FOREIGN KEY ([H_Suspect_RK]) REFERENCES [dbo].[H_Suspect] ([H_Suspect_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
