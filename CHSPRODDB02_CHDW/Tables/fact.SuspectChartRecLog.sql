CREATE TABLE [fact].[SuspectChartRecLog]
(
[SuspectChartRecLogID] [int] NOT NULL IDENTITY(1, 1),
[SuspectID] [int] NOT NULL,
[UserID] [int] NOT NULL,
[Log_Date] [smalldatetime] NULL,
[Log_Info] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_SuspectChartRecLog_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ProviderSuspectChartRecLog_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [fact].[SuspectChartRecLog] ADD CONSTRAINT [PK_SuspectChartRecLog] PRIMARY KEY CLUSTERED  ([SuspectChartRecLogID]) ON [PRIMARY]
GO
ALTER TABLE [fact].[SuspectChartRecLog] ADD CONSTRAINT [FK_SuspectChartRecLog_Suspect] FOREIGN KEY ([SuspectID]) REFERENCES [fact].[Suspect] ([SuspectID])
GO
ALTER TABLE [fact].[SuspectChartRecLog] ADD CONSTRAINT [FK_SuspectChartRecLog_User] FOREIGN KEY ([UserID]) REFERENCES [dim].[User] ([UserID])
GO
