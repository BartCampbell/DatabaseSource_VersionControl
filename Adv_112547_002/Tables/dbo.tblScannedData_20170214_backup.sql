CREATE TABLE [dbo].[tblScannedData_20170214_backup]
(
[ChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsScanned] [bit] NULL,
[IsCoded] [bit] NULL,
[CoderLevel] [tinyint] NULL,
[Suspect_PK] [bigint] NULL,
[User_PK] [smallint] NULL,
[dtInserted] [smalldatetime] NULL,
[IsCompleted] [bit] NULL,
[ReceivedAdditionalPages] [bit] NULL
) ON [PRIMARY]
GO
