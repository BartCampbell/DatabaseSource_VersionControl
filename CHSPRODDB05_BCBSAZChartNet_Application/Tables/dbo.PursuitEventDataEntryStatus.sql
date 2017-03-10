CREATE TABLE [dbo].[PursuitEventDataEntryStatus]
(
[PursuitEventDataEntryStatusID] [int] NOT NULL IDENTITY(1, 1),
[PursuitEventID] [int] NOT NULL,
[MeasureComponentID] [int] NOT NULL,
[DataEntryComplete] [bit] NOT NULL CONSTRAINT [DF__PursuitEv__DataE__25C68D63] DEFAULT ((0)),
[CreatedDate] [datetime] NOT NULL,
[CreatedUser] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastChangedDate] [datetime] NULL,
[LastChangedUser] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PursuitEventDataEntryStatus] ADD CONSTRAINT [PK__PursuitE__8A1000422101D846] PRIMARY KEY CLUSTERED  ([PursuitEventDataEntryStatusID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PursuitEventDataEntryStatus] ADD CONSTRAINT [UQ__PursuitE__87004BC823DE44F1] UNIQUE NONCLUSTERED  ([PursuitEventID], [MeasureComponentID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PursuitEventDataEntryStatus] WITH NOCHECK ADD CONSTRAINT [FK__PursuitEv__Measu__27AED5D5] FOREIGN KEY ([MeasureComponentID]) REFERENCES [dbo].[MeasureComponent] ([MeasureComponentID])
GO
ALTER TABLE [dbo].[PursuitEventDataEntryStatus] ADD CONSTRAINT [FK__PursuitEv__Pursu__26BAB19C] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
