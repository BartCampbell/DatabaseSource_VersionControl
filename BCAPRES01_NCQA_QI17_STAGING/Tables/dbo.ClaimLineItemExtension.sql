CREATE TABLE [dbo].[ClaimLineItemExtension]
(
[ClaimLineItemID] [int] NOT NULL,
[ExtensionData] [xml] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClaimLineItemExtension] ADD CONSTRAINT [actClaimLineItemExtension_PK] PRIMARY KEY CLUSTERED  ([ClaimLineItemID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClaimLineItemExtension] ADD CONSTRAINT [FK_ClaimLineItemExtension_ClaimLineItem] FOREIGN KEY ([ClaimLineItemID]) REFERENCES [dbo].[ClaimLineItem] ([ClaimLineItemID])
GO
