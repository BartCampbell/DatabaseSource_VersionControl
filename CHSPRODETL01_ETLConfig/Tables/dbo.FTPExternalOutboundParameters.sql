CREATE TABLE [dbo].[FTPExternalOutboundParameters]
(
[FTPEOutboundID] [int] NOT NULL IDENTITY(1, 1),
[FTPOutboundID] [int] NULL,
[Hostname] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pword] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConnectType] [int] NULL,
[PORT] [int] NULL,
[SubFolder] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL CONSTRAINT [DF__FTPExtern__Creat__7B7B4DDC] DEFAULT (getdate()),
[MAXSSL] [int] NULL,
[SSL] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FTPExternalOutboundParameters] ADD CONSTRAINT [PK_FTPEOutboundID] PRIMARY KEY CLUSTERED  ([FTPEOutboundID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FTPExternalOutboundParameters] ADD CONSTRAINT [FK_FTPOutboundID_FK] FOREIGN KEY ([FTPOutboundID]) REFERENCES [dbo].[FTPOutboundConfig] ([FTPOutboundID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
