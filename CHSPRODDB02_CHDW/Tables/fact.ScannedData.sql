CREATE TABLE [fact].[ScannedData]
(
[ScannedDataID] [int] NOT NULL IDENTITY(1, 1),
[CentauriScannedDataID] [int] NOT NULL,
[SuspectID] [int] NULL,
[DocumentTypeID] [int] NULL,
[UserID] [int] NULL,
[FileName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtInsert] [smalldatetime] NULL,
[is_deleted] [bit] NULL,
[CodedStatus] [tinyint] NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_ScannedData_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ProviderScannedData_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [fact].[ScannedData] ADD CONSTRAINT [PK_ScannedData] PRIMARY KEY CLUSTERED  ([ScannedDataID]) ON [PRIMARY]
GO
ALTER TABLE [fact].[ScannedData] ADD CONSTRAINT [FK_ScannedData_DocumentType] FOREIGN KEY ([DocumentTypeID]) REFERENCES [dim].[DocumentType] ([DocumentTypeID])
GO
ALTER TABLE [fact].[ScannedData] ADD CONSTRAINT [FK_ScannedData_Suspect] FOREIGN KEY ([SuspectID]) REFERENCES [fact].[Suspect] ([SuspectID])
GO
ALTER TABLE [fact].[ScannedData] ADD CONSTRAINT [FK_ScannedData_User] FOREIGN KEY ([UserID]) REFERENCES [dim].[User] ([UserID])
GO
