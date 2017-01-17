SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwSuspectProvider]
AS
    SELECT  h.ClientSuspectID AS Suspect_PK ,
            s.ChaseID ,
            p.Provider_BK AS CentauriProviderID ,
            p.ClientProviderID ,
            d.NPI ,
            d.FirstName ,
            d.LastName
    FROM    dbo.H_Suspect AS h
            INNER JOIN dbo.S_SuspectDetail AS s ON s.H_Suspect_RK = h.H_Suspect_RK
            INNER JOIN dbo.L_SuspectProvider AS l ON l.H_Suspect_RK = h.H_Suspect_RK
            INNER JOIN dbo.H_Provider AS p ON p.H_Provider_RK = l.H_Provider_RK
            INNER JOIN dbo.S_ProviderMasterDemo AS d ON d.H_Provider_RK = l.H_Provider_RK
    WHERE   ( s.RecordEndDate IS NULL )
            AND ( d.RecordEndDate IS NULL );
		  



GO
