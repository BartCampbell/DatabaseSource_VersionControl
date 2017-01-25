CREATE TABLE [dbo].[PortalMailQueue]
(
[PortalMailQueueID] [uniqueidentifier] NOT NULL,
[ApplicationID] [uniqueidentifier] NULL,
[AttemptedSendCount] [tinyint] NOT NULL CONSTRAINT [DF_PortalMailQueue_AttemptedSendCount] DEFAULT ((0)),
[AttemptedSendLimit] [tinyint] NOT NULL CONSTRAINT [DF_PortalMailQueue_AttemptedSendLimit] DEFAULT ((3)),
[HTMLBody] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PortalMailStatusID] [tinyint] NOT NULL CONSTRAINT [DF_PortalMailQueue_PortalMailStatusID] DEFAULT ((1)),
[Priority] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PortalMailQueue_Priority] DEFAULT ('normal'),
[SenderAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SenderName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subject] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TextBody] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeInQueue] [datetime] NOT NULL CONSTRAINT [DF_PortalMailQueue_TimeInQueue] DEFAULT (getdate()),
[TimeProcessed] [datetime] NULL,
[TimeToProcessInSeconds] AS (case  when [TimeProcessed] IS NULL then (0) else datediff(second,[TimeInQueue],[TimeProcessed]) end)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalMailQueue] ADD CONSTRAINT [PortalMailQueue_PK] PRIMARY KEY CLUSTERED  ([PortalMailQueueID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalMailQueue] WITH NOCHECK ADD CONSTRAINT [PortalMailStatus_PortalMailQueue_FK1] FOREIGN KEY ([PortalMailStatusID]) REFERENCES [dbo].[PortalMailStatus] ([PortalMailStatusID])
GO
