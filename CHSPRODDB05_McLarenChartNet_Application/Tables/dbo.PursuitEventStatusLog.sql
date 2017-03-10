CREATE TABLE [dbo].[PursuitEventStatusLog]
(
[PursuitEventStatusLogID] [int] NOT NULL IDENTITY(1, 1),
[PursuitEventID] [int] NOT NULL,
[PursuitID] [int] NOT NULL,
[AbstractionStatusID] [int] NOT NULL,
[AbstractionStatusChanged] [bit] NOT NULL CONSTRAINT [DF_PursuitEventStatusLog_AbstractionStatusChanged] DEFAULT ((1)),
[ChartStatusValueID] [int] NULL,
[ChartStatusChanged] [bit] NOT NULL CONSTRAINT [DF_PursuitEventStatusLog_ChartStatusChanged] DEFAULT ((1)),
[LogDate] [datetime] NOT NULL,
[LogUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PursuitEventStatusLog] ADD CONSTRAINT [PK_PursuitEventPursuitEventStatusLog] PRIMARY KEY CLUSTERED  ([PursuitEventStatusLogID]) ON [PRIMARY]
GO
