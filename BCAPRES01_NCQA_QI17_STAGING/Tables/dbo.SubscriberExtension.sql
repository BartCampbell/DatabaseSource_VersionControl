CREATE TABLE [dbo].[SubscriberExtension]
(
[SubscriberID] [int] NOT NULL,
[ExtensionData] [xml] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[SubscriberExtension] ADD CONSTRAINT [actSubscriberExtension_PK] PRIMARY KEY CLUSTERED  ([SubscriberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SubscriberExtension] ADD CONSTRAINT [actSubscriber_SubscriberExtension_FK1] FOREIGN KEY ([SubscriberID]) REFERENCES [dbo].[Subscriber] ([SubscriberID])
GO
