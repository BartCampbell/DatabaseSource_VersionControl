CREATE TABLE [fact].[SuspectDOS]
(
[SuspectDOSID] [int] NOT NULL IDENTITY(1, 1),
[SuspectID] [int] NOT NULL,
[SuspectDOS_PK] [bigint] NOT NULL,
[DOS_From] [smalldatetime] NULL,
[DOS_To] [smalldatetime] NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_SuspectDOS_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ProviderSuspectDOS_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [fact].[SuspectDOS] ADD CONSTRAINT [PK_SuspectDOS] PRIMARY KEY CLUSTERED  ([SuspectDOSID]) ON [PRIMARY]
GO
ALTER TABLE [fact].[SuspectDOS] ADD CONSTRAINT [FK_SuspectDOS_Suspect] FOREIGN KEY ([SuspectID]) REFERENCES [fact].[Suspect] ([SuspectID])
GO
