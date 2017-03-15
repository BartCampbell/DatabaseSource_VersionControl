CREATE TABLE [dbo].[ETLPackage]
(
[ETLPackageID] [int] NOT NULL IDENTITY(100000, 1),
[ETLPackageName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ETLPackageDesc] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF__ETLPackag__IsAct__436BFEE3] DEFAULT ((0)),
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF__ETLPackag__Creat__4460231C] DEFAULT (getdate()),
[LastUpdated] [datetime] NOT NULL CONSTRAINT [DF__ETLPackag__LastU__45544755] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ETLPackage] ADD CONSTRAINT [PK_ETLPackage_ETLPackageID] PRIMARY KEY CLUSTERED  ([ETLPackageID]) ON [PRIMARY]
GO
