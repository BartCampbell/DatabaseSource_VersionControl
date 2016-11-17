SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_x12_organization]
AS
SELECT     x12_organization_id, x12_organization_ud, x12_organization_nm, active, modified_date, created_date
FROM         dbo.x12_organization

GO
