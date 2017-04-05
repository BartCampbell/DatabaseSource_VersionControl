CREATE TABLE [dbo].[EligibilityExtension]
(
[EligibilityID] [int] NOT NULL,
[ExtensionData] [xml] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[EligibilityExtension] ADD CONSTRAINT [actEligibilityExtension_PK] PRIMARY KEY CLUSTERED  ([EligibilityID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EligibilityExtension] ADD CONSTRAINT [actEligibility_EligibilityExtension_FK1] FOREIGN KEY ([EligibilityID]) REFERENCES [dbo].[Eligibility] ([EligibilityID])
GO
