CREATE TABLE [stage].[ReassignCodingDiscrepancies2]
(
[ChaseID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Assign To] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Edge Enrollee ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DX Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[First Coder Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Second Coder Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[From DOS] [datetime] NULL,
[Thru DOS] [datetime] NULL,
[Provider ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCC] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[First Coder OutCome] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Second Coder OutCome] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Coded Flag] [float] NULL,
[Coded Source] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[New DOS Flag] [float] NULL,
[Total Dx Codes] [float] NULL,
[Total Dx Codes Validated] [float] NULL,
[Total Dx Codes Deleted] [float] NULL,
[Total Dx Codes Added] [float] NULL,
[Total Dx Codes Suspected] [float] NULL,
[Total Dx Codes NULL] [float] NULL,
[Coding Category] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldUser_PK] [int] NULL,
[NewUser_PK] [int] NULL
) ON [PRIMARY]
GO
