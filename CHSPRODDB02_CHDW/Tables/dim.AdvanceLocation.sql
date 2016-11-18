CREATE TABLE [dim].[AdvanceLocation]
(
[AdvanceLocationID] [int] NOT NULL IDENTITY(1, 1),
[CentauriAdvanceLocationID] [int] NULL,
[Location] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_AdvanceLocation_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_AdvanceLocation_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dim].[AdvanceLocation] ADD CONSTRAINT [PK_AdvanceLocation] PRIMARY KEY CLUSTERED  ([AdvanceLocationID]) ON [PRIMARY]
GO
