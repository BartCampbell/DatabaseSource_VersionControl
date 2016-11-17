CREATE TABLE [dbo].[S_RemovedUserDetails]
(
[S_RemovedUserDetails_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[RemovedBy_User_PK] [int] NOT NULL,
[Removed_date] [smalldatetime] NULL,
[IsSuperUser] [bit] NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_RemovedUserDetails] ADD CONSTRAINT [PK_S_RemovedUserDetails] PRIMARY KEY CLUSTERED  ([S_RemovedUserDetails_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_RemovedUserDetails] ADD CONSTRAINT [FK_H_User_RK5] FOREIGN KEY ([H_User_RK]) REFERENCES [dbo].[H_User] ([H_User_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
