SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sync_getSuspect 2,2,'1/1/2014'
CREATE PROCEDURE [dbo].[sync_getSuspect]
	@Project smallint,
	@User int,
	@LastSync smalldatetime
AS
BEGIN
	DECLARE @IsScheduler AS BIT
	SELECT @IsScheduler=IsNull(IsScheduler,0) FROM tblUser WHERE User_PK=@User

	if (@Project=0)
	BEGIN
		SELECT 0 Provider_PK,0 Member_PK,0 Suspect_PK,0 IsScanned,0 IsCNA,GETDATE() Scanned_Date,GETDATE() CNA_Date,0 IsInvoiced,0 Project_PK
		UNION 
		SELECT DISTINCT S.Provider_PK,S.Member_PK,S.Suspect_PK,S.IsScanned,S.IsCNA,S.Scanned_Date,S.CNA_Date, IsNull(IsInvoiced,0) IsInvoiced,S.Project_PK
		FROM tblProvider P
				INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK
				INNER JOIN tblSuspectAssignment SA ON SA.Suspect_PK = S.Suspect_PK AND SA.User_PK=@User
		WHERE SA.LastUpdated_Date>=@LastSync
		UNION 
		SELECT DISTINCT S.Provider_PK,S.Member_PK,S.Suspect_PK,S.IsScanned,S.IsCNA,S.Scanned_Date,S.CNA_Date, IsNull(IsInvoiced,0) IsInvoiced,S.Project_PK
		FROM tblProvider P
				INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK
				INNER JOIN tblProviderOfficeSchedule POS ON POS.ProviderOffice_PK=P.ProviderOffice_PK AND POS.Sch_User_PK=@User 
		WHERE POS.LastUpdated_Date>=@LastSync
	END
	ELSE if (@IsScheduler=1)
	BEGIN
		SELECT 0 Provider_PK,0 Member_PK,0 Suspect_PK,0 IsScanned,0 IsCNA,GETDATE() Scanned_Date,GETDATE() CNA_Date,0 IsInvoiced,0 Project_PK
		UNION 
		SELECT DISTINCT S.Provider_PK,S.Member_PK,S.Suspect_PK,S.IsScanned,S.IsCNA,S.Scanned_Date,S.CNA_Date, IsNull(IsInvoiced,0) IsInvoiced,S.Project_PK
		FROM tblProvider P
				INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK
		WHERE S.Project_PK=@Project AND S.LastUpdated>=@LastSync
--			 AND (S.LastUpdated>=@LastSync OR S.Scanned_Date>=@LastSync OR S.CNA_Date>=@LastSync)
	END
	ELSE
	BEGIN
		SELECT 0 Provider_PK,0 Member_PK,0 Suspect_PK,0 IsScanned,0 IsCNA,GETDATE() Scanned_Date,GETDATE() CNA_Date,0 IsInvoiced,0 Project_PK
		UNION 
		SELECT DISTINCT S.Provider_PK,S.Member_PK,S.Suspect_PK,S.IsScanned,S.IsCNA,S.Scanned_Date,S.CNA_Date, IsNull(IsInvoiced,0) IsInvoiced,S.Project_PK
		FROM tblProvider P
				INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK
				INNER JOIN tblProviderOfficeSchedule POS ON POS.ProviderOffice_PK=P.ProviderOffice_PK AND POS.Sch_User_PK=@User 
		WHERE S.Project_PK=@Project AND POS.LastUpdated_Date>=@LastSync
	END	
END
GO
