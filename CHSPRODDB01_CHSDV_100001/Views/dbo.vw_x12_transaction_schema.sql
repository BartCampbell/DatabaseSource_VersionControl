SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_x12_transaction_schema]
AS
SELECT     x12_transaction_schema_id, x12_transaction_schema_ud, x12_transaction_schema_nm, schema_namespace, standards_version, 
                      transaction_id_code, functional_group_id_code, functional_version_id_code, table_nm, active, modified_date, created_date
FROM         dbo.x12_transaction_schema

GO
