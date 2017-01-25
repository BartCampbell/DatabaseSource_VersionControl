CREATE TABLE [dbo].[FaxLogPursuits]
(
[FaxLogID] [int] NOT NULL,
[PursuitID] [int] NOT NULL,
[Selected] [bit] NOT NULL CONSTRAINT [DF_FaxLogPursuits_Received] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxLogPursuits] ADD CONSTRAINT [PK_FaxLogPursuits] PRIMARY KEY CLUSTERED  ([FaxLogID], [PursuitID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxLogPursuits] ADD CONSTRAINT [FK_FaxLogPursuits_FaxLog] FOREIGN KEY ([FaxLogID]) REFERENCES [dbo].[FaxLog] ([FaxLogID])
GO
ALTER TABLE [dbo].[FaxLogPursuits] ADD CONSTRAINT [FK_FaxLogPursuits_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
