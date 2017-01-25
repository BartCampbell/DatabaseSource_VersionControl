CREATE TABLE [ExtrCntrl].[ExtractAlerts]
(
[ExtractAlertID] [int] NOT NULL IDENTITY(1, 1),
[ExctractMasterID] [int] NULL,
[AlertType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserEmail] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserMobilePhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [ExtrCntrl].[ExtractAlerts] ADD CONSTRAINT [pk_ExtractAlerts] PRIMARY KEY CLUSTERED  ([ExtractAlertID]) ON [PRIMARY]
GO
