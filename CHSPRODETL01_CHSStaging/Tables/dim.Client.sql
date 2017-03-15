CREATE TABLE [dim].[Client]
(
[ClientID] [int] NOT NULL,
[CentauriClientID] [int] NOT NULL,
[ClientName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL,
[LastUpdate] [datetime] NULL
) ON [PRIMARY]
GO
