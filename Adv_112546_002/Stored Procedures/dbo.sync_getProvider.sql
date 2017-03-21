SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sync_getProvider 1,2,'1/1/2014'
CREATE PROCEDURE [dbo].[sync_getProvider] 
	@Project smallint,
	@User int,
	@LastSync smalldatetime
AS
BEGIN
	DECLARE @IsScheduler AS BIT
	SELECT @IsScheduler=IsNull(IsScheduler,0) FROM tblUser WHERE User_PK=@User

	if (@Project=0)
	BEGIN
		SELECT DISTINCT P.Provider_PK,PM.Provider_ID,PM.Lastname,PM.Firstname
		FROM tblProvider P
				INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK
				INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
				INNER JOIN tblSuspectAssignment SA ON SA.Suspect_PK = S.Suspect_PK AND SA.User_PK=@User
		WHERE SA.LastUpdated_Date>=@LastSync
		UNION
		SELECT DISTINCT P.Provider_PK,PM.Provider_ID,PM.Lastname,PM.Firstname
		FROM tblProvider P
				INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK
				INNER JOIN tblProviderOfficeSchedule POS ON POS.ProviderOffice_PK=P.ProviderOffice_PK AND POS.Sch_User_PK=@User
				INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		WHERE POS.LastUpdated_Date>=@LastSync
	END
	ELSE if (@IsScheduler=1)
	BEGIN
		SELECT DISTINCT P.Provider_PK,PM.Provider_ID,PM.Lastname,PM.Firstname
		FROM tblProvider P
				INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK
				INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		WHERE S.Project_PK=@Project AND S.LastUpdated>=@LastSync
	END
	ELSE
	BEGIN
		SELECT DISTINCT P.Provider_PK,PM.Provider_ID,PM.Lastname,PM.Firstname
		FROM tblProvider P
				INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK
				INNER JOIN tblProviderOfficeSchedule POS ON POS.ProviderOffice_PK=P.ProviderOffice_PK AND POS.Sch_User_PK=@User
				INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		WHERE S.Project_PK=@Project AND POS.LastUpdated_Date>=@LastSync
	END	
END
GO
