SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Paul Johnson
-- Create date:	10/25/2016
-- Description:	merges the stage to dim for advantage ProviderContact based on dbo.spADVMergeProviderContact
-- Usage:			
--		  EXECUTE dbo.spAdvMergeProviderOfficeContact
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeProviderOfficeContact]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.ProviderOfficeContact AS t
        USING
            ( SELECT   DISTINCT o.ProviderOfficeID ,
                        a.Phone ,
                        a.Fax,
						a.EmailAddress
                FROM      stage.ProviderContact_ADV a
			    INNER JOIN dim.ProviderOffice o ON a.CentauriProviderOfficeID = o.CentauriProviderOfficeID
		    
            ) AS s
        ON t.ProviderOfficeID = s.ProviderOfficeID
            AND ISNULL(t.Phone,'') = ISNULL(s.Phone,'')
            AND ISNULL(t.Fax,'') = ISNULL(s.Fax,'')
			AND ISNULL(t.EmailAddress,'') = ISNULL( t.EmailAddress,'')
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( ProviderOfficeID, Phone, Fax, EmailAddress )
            VALUES ( ProviderOfficeID, Phone, Fax, EmailAddress );

    END;     



GO
