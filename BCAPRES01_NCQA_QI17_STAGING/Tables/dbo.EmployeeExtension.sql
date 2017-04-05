CREATE TABLE [dbo].[EmployeeExtension]
(
[EmployeeID] [int] NOT NULL,
[ExtensionData] [xml] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmployeeExtension] ADD CONSTRAINT [actEmployeeExtension_PK] PRIMARY KEY CLUSTERED  ([EmployeeID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmployeeExtension] ADD CONSTRAINT [actEmployee_EmployeeExtension_FK1] FOREIGN KEY ([EmployeeID]) REFERENCES [dbo].[Employee] ([EmployeeID])
GO
