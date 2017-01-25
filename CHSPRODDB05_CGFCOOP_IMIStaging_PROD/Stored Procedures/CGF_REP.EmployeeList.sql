SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE    PROC [CGF_REP].[EmployeeList]
(
	@Client				varchar(100) = 'All Client'
)
AS

DECLARE @Output TABLE ([ID] int IDENTITY(1,1), FieldValue varchar(50), DisplayValue varchar(50), Description varchar(100))

IF (@Client = 'CCI')
BEGIN 
	INSERT INTO @Output (FieldValue, DisplayValue, Description) SELECT NULL, 'All members', 'All CCI Commercial DATA'
	INSERT INTO @Output (FieldValue, DisplayValue, Description) SELECT 1, 'Employee', 'Employee" and "Employee Non-Active"'
	INSERT INTO @Output (FieldValue, DisplayValue, Description) SELECT 2, 'Non-Employee', '"Non-CCI" and "Non-Employee"'
END 
ELSE 
	INSERT INTO @Output (FieldValue, DisplayValue, Description) SELECT NULL, 'All members', 'All CCI Commercial DATA'

--INSERT INTO @Output (FieldValue, DisplayValue, Description) SELECT NULL, 'All members', 'All CCI Commercial DATA'
--INSERT INTO @Output (FieldValue, DisplayValue, Description) SELECT 1, 'Employee', 'CCI employees & dependents'
--INSERT INTO @Output (FieldValue, DisplayValue, Description) SELECT 2, 'Non-Employee', 'Not a CCI employee'

SELECT * FROM @Output 






GO
