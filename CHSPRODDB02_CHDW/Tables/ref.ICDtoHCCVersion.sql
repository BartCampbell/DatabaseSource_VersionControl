CREATE TABLE [ref].[ICDtoHCCVersion]
(
[DXCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICDVersion] [int] NULL,
[CC] [int] NULL,
[CCType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCCVersion] [int] NULL,
[HCCVersionYear] [int] NULL,
[ICDtoHCCVersionID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [ref].[ICDtoHCCVersion] ADD CONSTRAINT [PK_ICDtoHCCVersion] PRIMARY KEY CLUSTERED  ([ICDtoHCCVersionID]) ON [PRIMARY]
GO
