CREATE TABLE [dbo].[Network]
(
[NetworkID] [int] NOT NULL IDENTITY(1, 1),
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContractStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateContractBegin] [datetime] NULL,
[DateContractEnd] [datetime] NULL,
[HealthPlanID] [int] NOT NULL
) ON [PRIMARY]
GO
