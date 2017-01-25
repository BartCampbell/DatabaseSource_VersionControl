CREATE TABLE [dbo].[AbstractionOverRead]
(
[AbstractionOverReadID] [int] NOT NULL IDENTITY(1, 1),
[PursuitEventID] [int] NOT NULL,
[ReviewerID] [int] NOT NULL,
[ReviewDate] [datetime] NOT NULL,
[ErrorsFound] [bit] NOT NULL,
[Notes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsFixed] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AbstractionOverRead] ADD CONSTRAINT [PK_AbstractionOverRead] PRIMARY KEY CLUSTERED  ([AbstractionOverReadID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AbstractionOverRead] ADD CONSTRAINT [FK_AbstractionOverRead_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
ALTER TABLE [dbo].[AbstractionOverRead] ADD CONSTRAINT [FK_AbstractionOverRead_Reviewer] FOREIGN KEY ([ReviewerID]) REFERENCES [dbo].[Reviewer] ([ReviewerID])
GO
