CREATE TABLE [dbo].[TradingPartnerFile]
(
[TradingPartnerFileID] [int] NOT NULL IDENTITY(1, 1),
[TradingPartner] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SenderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReceiverID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TradingPartnerFile] ADD CONSTRAINT [PK_TradingPartnerFile] PRIMARY KEY CLUSTERED  ([TradingPartnerFileID]) ON [PRIMARY]
GO
