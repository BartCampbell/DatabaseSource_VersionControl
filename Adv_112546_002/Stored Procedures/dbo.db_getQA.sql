SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Jun-25-2014
-- Description:	To get Finance Report Summary for Dashboad
-- =============================================
/* Sample Executions
db_getQA 0,1
PrepareCacheProviderOffice
*/
CREATE PROCEDURE [dbo].[db_getQA]
	@Project int,
	@User int
AS
BEGIN
	SELECT TOP 0 1000 Project_PK INTO #tmpProj
	IF @Project=0
	BEGIN
		IF EXISTS(SELECT * FROM tblUser WHERE User_PK=@User AND IsAdmin=1)
			INSERT INTO #tmpProj SELECT DISTINCT Project_PK FROM tblProject
		ELSE
			INSERT INTO #tmpProj SELECT DISTINCT Project_PK FROM tblUserProject WHERE User_PK=@User
	END
	ELSE
		INSERT INTO #tmpProj VALUES(@Project)
		
			
	SELECT COUNT(CD.CodedData_PK) [Total Coded Charts]
		,COUNT(QA.CodedData_PK) [QA Sample]
		,SUM(CAST(IsConfirmed AS TinyInt)) Confirmed 
		,SUM(CAST(IsChanged AS TinyInt)) Changed 
		,SUM(CAST(IsAdded AS TinyInt)) Added 
		,SUM(CAST(IsRemoved AS TinyInt)) Removed 
	FROM tblCodedData CD 
		INNER JOIN tblSuspect S ON S.Suspect_PK = CD.Suspect_PK
		INNER JOIN #tmpProj P ON P.Project_PK = S.Project_PK
		LEFT JOIN tblCodedDataQA QA ON CD.CodedData_PK = QA.CodedData_PK	
END
GO
