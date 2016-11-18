CREATE TABLE [dbo].[ICDtoHCCTemp]
(
[DXCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICDVersion] [int] NULL,
[CC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CCType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCCVersion] [int] NULL,
[HCCVersionYear] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICDtoHCCVersionID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
