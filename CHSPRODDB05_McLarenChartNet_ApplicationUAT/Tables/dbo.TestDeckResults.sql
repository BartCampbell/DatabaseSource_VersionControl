CREATE TABLE [dbo].[TestDeckResults]
(
[TestDeckResultsID] [int] NOT NULL IDENTITY(1, 1),
[PursuitEventID] [int] NOT NULL,
[Comments] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientName] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TestDeckResults] ADD CONSTRAINT [PK__TestDeckResults__6C5905DD] PRIMARY KEY CLUSTERED  ([TestDeckResultsID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TestDeckResults] ADD CONSTRAINT [TestDeckResults_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
