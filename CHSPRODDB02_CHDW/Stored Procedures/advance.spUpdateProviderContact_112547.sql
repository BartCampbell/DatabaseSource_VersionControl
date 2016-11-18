SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Travis Parker
-- Create date:	06/28/2016
-- Description:	updates the provider contact data for advance for the specified chart retrieval
-- Usage:			
--		  EXECUTE advance.spUpdateProviderContact_112547 '001', 112547
-- =============================================
CREATE PROC [advance].[spUpdateProviderContact_112547]
    @ProjectID VARCHAR(20) ,
    @CentauriClientID INT
AS
    DECLARE @CurrentDate DATETIME = GETDATE();
    
    SET NOCOUNT ON; 

    IF OBJECT_ID('tempdb..#PhoneList') IS NOT NULL
        DROP TABLE #PhoneList;
    IF OBJECT_ID('tempdb..#FaxList') IS NOT NULL
        DROP TABLE #FaxList;

    SELECT  pc.Phone ,
            pl.Advance_Addr1 ,
            pl.Advance_Zip ,
            p.ClientProviderID ,
            COUNT(*) AS PhoneCount ,
            ROW_NUMBER() OVER ( PARTITION BY pl.Advance_Addr1, pl.Advance_Zip, p.ClientProviderID ORDER BY COUNT(*) DESC ) rown
    INTO    #PhoneList
    FROM    fact.OEC o
            INNER JOIN dim.ProviderContact pc ON o.ProviderContactID = pc.ProviderContactID
            INNER JOIN dim.OECProject op ON op.OECProjectID = o.OECProjectID
            INNER JOIN dim.Client c ON op.ClientID = c.ClientID
            INNER JOIN dim.ProviderLocation pl ON pl.ProviderLocationID = o.ProviderLocationID
            INNER JOIN dim.ProviderClient p ON p.ClientID = op.ClientID
                                               AND p.ProviderID = o.ProviderID
    WHERE   op.ProjectID = @ProjectID
            AND c.CentauriClientID = @CentauriClientID
    GROUP BY pl.Advance_Addr1 ,
            pl.Advance_Zip ,
            p.ClientProviderID ,
            pc.Phone
    ORDER BY pl.Advance_Addr1 ,
            pl.Advance_Zip ,
            PhoneCount DESC; 

    SELECT  pc.Fax ,
            pl.Advance_Addr1 ,
            pl.Advance_Zip ,
            p.ClientProviderID ,
            COUNT(*) AS FaxCount ,
            ROW_NUMBER() OVER ( PARTITION BY pl.Advance_Addr1, pl.Advance_Zip, p.ClientProviderID ORDER BY COUNT(*) DESC ) rown
    INTO    #FaxList
    FROM    fact.OEC o
            INNER JOIN dim.ProviderContact pc ON o.ProviderContactID = pc.ProviderContactID
            INNER JOIN dim.OECProject op ON op.OECProjectID = o.OECProjectID
            INNER JOIN dim.Client c ON op.ClientID = c.ClientID
            INNER JOIN dim.ProviderLocation pl ON pl.ProviderLocationID = o.ProviderLocationID
            INNER JOIN dim.ProviderClient p ON p.ClientID = op.ClientID
                                               AND p.ProviderID = o.ProviderID
    WHERE   op.ProjectID = @ProjectID
            AND c.CentauriClientID = @CentauriClientID
    GROUP BY pl.Advance_Addr1 ,
            pl.Advance_Zip ,
            p.ClientProviderID ,
            pc.Fax
    ORDER BY pl.Advance_Addr1 ,
            pl.Advance_Zip ,
            FaxCount DESC; 

    CREATE CLUSTERED INDEX IDX_Addr_Zip_Provider_Phone ON #PhoneList(Advance_Addr1,Advance_Zip,ClientProviderID,Phone);
    CREATE CLUSTERED INDEX IDX_Addr_Zip_Provider_Phone ON #FaxList(Advance_Addr1,Advance_Zip,ClientProviderID,Fax);

--    SELECT * FROM #PhoneList

--    SELECT DISTINCT
--      fileid
--    , STUFF((
--        SELECT N', ' + CAST([filename] AS VARCHAR(255))
--        FROM tblFile f2
--        WHERE f1.fileid = f2.fileid ---- string with grouping by fileid
--        FOR XML PATH (''), TYPE), 1, 2, '') AS FileNameString
--FROM tblFile f1


    UPDATE  pl
    SET     pl.Advance_Phone = t.AdvancePhone ,
            pl.LastUpdate = @CurrentDate
    FROM    fact.OEC o
            INNER JOIN dim.OECProject op ON op.OECProjectID = o.OECProjectID
            INNER JOIN dim.Client c ON op.ClientID = c.ClientID
            INNER JOIN dim.ProviderLocation pl ON pl.ProviderLocationID = o.ProviderLocationID
            INNER JOIN dim.ProviderClient p ON p.ClientID = op.ClientID
                                               AND p.ProviderID = o.ProviderID
            INNER JOIN ( SELECT DISTINCT
                                a2.Advance_Addr1 ,
                                a2.Advance_Zip ,
                                a2.ClientProviderID ,
                                ISNULL(SUBSTRING(( SELECT   ',' + a1.Phone AS [text()]
                                                   FROM     #PhoneList a1
                                                   WHERE    a1.Advance_Addr1 = a2.Advance_Addr1
                                                            AND a1.Advance_Zip = a2.Advance_Zip
                                                            AND a1.ClientProviderID = a2.ClientProviderID
                                                            AND a1.Phone <> ''
                                                   ORDER BY a1.Advance_Addr1 ,
                                                            a1.Advance_Zip ,
                                                            a1.rown
                                                 FOR
                                                   XML PATH('')
                                                 ), 2, 1000), '') AdvancePhone
                         FROM   #PhoneList a2
                       ) t ON pl.Advance_Addr1 = t.Advance_Addr1
                              AND pl.Advance_Zip = t.Advance_Zip
                              AND p.ClientProviderID = t.ClientProviderID;  

    UPDATE  pl
    SET     pl.Advance_Fax = t.AdvanceFax ,
            pl.LastUpdate = @CurrentDate
    FROM    fact.OEC o
            INNER JOIN dim.OECProject op ON op.OECProjectID = o.OECProjectID
            INNER JOIN dim.Client c ON op.ClientID = c.ClientID
            INNER JOIN dim.ProviderLocation pl ON pl.ProviderLocationID = o.ProviderLocationID
            INNER JOIN dim.ProviderClient p ON p.ClientID = op.ClientID
                                               AND p.ProviderID = o.ProviderID
            INNER JOIN ( SELECT DISTINCT
                                a2.Advance_Addr1 ,
                                a2.Advance_Zip ,
                                a2.ClientProviderID ,
                                ISNULL(SUBSTRING(( SELECT   ',' + a1.Fax AS [text()]
                                                   FROM     #FaxList a1
                                                   WHERE    a1.Advance_Addr1 = a2.Advance_Addr1
                                                            AND a1.Advance_Zip = a2.Advance_Zip
                                                            AND a1.ClientProviderID = a2.ClientProviderID
                                                            AND a1.Fax <> ''
                                                   ORDER BY a1.Advance_Addr1 ,
                                                            a1.Advance_Zip ,
                                                            a1.rown
                                                 FOR
                                                   XML PATH('')
                                                 ), 2, 1000), '') AdvanceFax
                         FROM   #FaxList a2
                       ) t ON pl.Advance_Addr1 = t.Advance_Addr1
                              AND pl.Advance_Zip = t.Advance_Zip
                              AND p.ClientProviderID = t.ClientProviderID;  



		  
GO
