SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwSuspectMember]
AS
    SELECT  h.ClientSuspectID AS Suspect_PK ,
            s.ChaseID ,
            m.Member_BK AS CentauriMemberID ,
            m.ClientMemberID ,
            ISNULL(mh.HICNumber,'') AS HICN ,
            d.FirstName ,
            d.LastName
    FROM    dbo.H_Suspect AS h
            INNER JOIN dbo.S_SuspectDetail AS s ON s.H_Suspect_RK = h.H_Suspect_RK AND s.RecordEndDate IS NULL 
            INNER JOIN dbo.L_SuspectMember AS l ON l.H_Suspect_RK = h.H_Suspect_RK
            INNER JOIN dbo.H_Member AS m ON m.H_Member_RK = l.H_Member_RK
            INNER JOIN dbo.S_MemberDemo AS d ON d.H_Member_RK = m.H_Member_RK AND d.RecordEndDate IS NULL 
		  LEFT JOIN dbo.S_MemberHICN AS mh ON mh.H_Member_RK = m.H_Member_RK AND mh.RecordEndDate IS NULL 		  --730608



GO
