CREATE TABLE [dbo].[FTPExternalParameters]
(
[FTPEConfigID] [int] NOT NULL IDENTITY(1, 1),
[FTPConfigID] [int] NULL,
[Hostname] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pword] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConnectType] [int] NULL,
[PORT] [int] NULL,
[SubFolder] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL CONSTRAINT [DF__FTPExtern__Creat__74CE504D] DEFAULT (getdate()),
[MAXSSL] [int] NULL,
[SSL] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FTPExternalParameters] ADD CONSTRAINT [PK_FTPEConfig] PRIMARY KEY CLUSTERED  ([FTPEConfigID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FTPExternalParameters] ADD CONSTRAINT [FK_FTPCOnfigID_FK] FOREIGN KEY ([FTPConfigID]) REFERENCES [dbo].[FTPConfig] ([FTPConfigID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
