CREATE TABLE [Claim].[ClaimTypes]
(
[Abbrev] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ClaimTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ClaimTypes_ClaimTypeGuid] DEFAULT (newid()),
[ClaimTypeID] [tinyint] NOT NULL,
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Claim].[ClaimTypes] ADD CONSTRAINT [PK_ClaimTypes] PRIMARY KEY CLUSTERED  ([ClaimTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ClaimTypes_Abbrev] ON [Claim].[ClaimTypes] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ClaimTypes_ClaimTypeGuid] ON [Claim].[ClaimTypes] ([ClaimTypeGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ClaimTypes_Descr] ON [Claim].[ClaimTypes] ([Descr]) ON [PRIMARY]
GO
