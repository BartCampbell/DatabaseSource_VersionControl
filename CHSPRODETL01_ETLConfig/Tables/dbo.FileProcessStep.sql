CREATE TABLE [dbo].[FileProcessStep]
(
[FileProcessStepID] [int] NOT NULL IDENTITY(100000, 1),
[FileProcessID] [int] NOT NULL,
[FileProcessStepOrder] [int] NOT NULL,
[ETLPackageID] [int] NOT NULL,
[FileProcessStepName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileProcessStepDesc] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETLPackageChild1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF__FileProce__IsAct__4924D839] DEFAULT ((0)),
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF__FileProce__Creat__4A18FC72] DEFAULT (getdate()),
[LastUpdated] [datetime] NOT NULL CONSTRAINT [DF__FileProce__LastU__4B0D20AB] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FileProcessStep] ADD CONSTRAINT [PK_FileProcessStep_FileProcessStepID] PRIMARY KEY CLUSTERED  ([FileProcessStepID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FileProcessStep] ADD CONSTRAINT [UQ_FileProcessStep_ETLPackageID] UNIQUE NONCLUSTERED  ([FileProcessID], [ETLPackageID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FileProcessStep] ADD CONSTRAINT [UQ_FileProcessStep_FileProcessStepOrder] UNIQUE NONCLUSTERED  ([FileProcessID], [FileProcessStepOrder]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FileProcessStep] ADD CONSTRAINT [FK_FileProcessStep_ETLPackage] FOREIGN KEY ([ETLPackageID]) REFERENCES [dbo].[ETLPackage] ([ETLPackageID])
GO
ALTER TABLE [dbo].[FileProcessStep] ADD CONSTRAINT [FK_FileProcessStep_FileProcess] FOREIGN KEY ([FileProcessID]) REFERENCES [dbo].[FileProcess] ([FileProcessID])
GO
