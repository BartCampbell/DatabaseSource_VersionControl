CREATE TABLE [dbo].[ClaimExtension]
(
[ClaimID] [int] NOT NULL,
[ExtensionData] [xml] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClaimExtension] ADD CONSTRAINT [actClaimExtension_PK] PRIMARY KEY CLUSTERED  ([ClaimID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClaimExtension] ADD CONSTRAINT [actClaim_ClaimExtension_FK1] FOREIGN KEY ([ClaimID]) REFERENCES [dbo].[Claim] ([ClaimID])
GO
