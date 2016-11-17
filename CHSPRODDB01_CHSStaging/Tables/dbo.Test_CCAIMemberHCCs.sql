CREATE TABLE [dbo].[Test_CCAIMemberHCCs]
(
[RecordID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCC] [int] NULL,
[HCCDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Test_CCAIMemberHCCs] ADD CONSTRAINT [UQ__Test_CCA__FBDF78C82F79E27D] UNIQUE NONCLUSTERED  ([RecordID]) ON [PRIMARY]
GO
