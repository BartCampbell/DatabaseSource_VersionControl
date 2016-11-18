CREATE TABLE [dim].[UserLocation]
(
[UserLocationID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [int] NOT NULL,
[AdvanceLocationID] [int] NULL,
[address] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zipcode_pk] [int] NULL,
[Latitude] [float] NULL,
[Longitude] [float] NULL,
[RecordStartDate] [datetime] NULL CONSTRAINT [DF_UserLocation_RecordStartDate] DEFAULT (getdate()),
[RecordEndDate] [datetime] NULL CONSTRAINT [DF_UserLocation_RecordEndUpdate] DEFAULT ('2999-12-31')
) ON [PRIMARY]
GO
ALTER TABLE [dim].[UserLocation] ADD CONSTRAINT [PK_UserLocation] PRIMARY KEY CLUSTERED  ([UserLocationID]) ON [PRIMARY]
GO
ALTER TABLE [dim].[UserLocation] ADD CONSTRAINT [FK_UserLocation_AdvanceLocation] FOREIGN KEY ([AdvanceLocationID]) REFERENCES [dim].[AdvanceLocation] ([AdvanceLocationID])
GO
ALTER TABLE [dim].[UserLocation] ADD CONSTRAINT [FK_UserLocation_User] FOREIGN KEY ([UserID]) REFERENCES [dim].[User] ([UserID])
GO
