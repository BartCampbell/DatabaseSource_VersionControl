SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--EXEC [dbo].[spDV_Member_LoadSats] 112559

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/18/2016
--Update 09/21/2016 to tie up hashdiff with OEC load PJ
--Update 09/22/2016 to add Member_PK to S_MemberDetails PJ
-- Description:	Data Vault Member Load - based on CHSDV.[dbo].[prDV_Member_LoadSats]
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Member_LoadSats]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

--**S_MemberDEMO LOAD
        INSERT  INTO S_MemberDemo
                ( S_MemberDemo_RK ,
                  LoadDate ,
                  H_Member_RK ,
                  FirstName ,
                  LastName ,
                  Gender ,
                  DOB ,
                  HashDiff ,
                  RecordSource
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[LoadDate], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[RecordSource], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Firstname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Lastname], ''))), ':', RTRIM(LTRIM(COALESCE(rw.DOB, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.Gender, '')))))), 2)) ,
                        LoadDate ,
                        MemberHashKey ,
                        [Firstname] ,
                        [Lastname] ,
                        Gender ,
                        DOB ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Lastname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Firstname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CONVERT(INT, CONVERT(VARCHAR(10), DOB, 112)), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.Gender, '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Lastname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Firstname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CONVERT(INT, CONVERT(VARCHAR(10), DOB, 112)), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.Gender, '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_MemberDemo
                        WHERE   H_Member_RK = rw.MemberHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[LoadDate], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[RecordSource], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[Firstname], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[Lastname], ''))), ':', RTRIM(LTRIM(COALESCE(rw.DOB, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.Gender, '')))))), 2)) ,
                        LoadDate ,
                        MemberHashKey ,
                        [Firstname] ,
                        [Lastname] ,
                        Gender ,
                        DOB ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Lastname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Firstname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CONVERT(INT, CONVERT(VARCHAR(10), DOB, 112)), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.Gender, '')))))), 2)) ,
                        RecordSource;
	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_MemberDemo
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_MemberDemo z
                                  WHERE     z.H_Member_RK = a.H_Member_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_MemberDemo a
        WHERE   RecordEndDate IS NULL; 
	

    
	
--**S_MemberDetail LOAD

        INSERT  INTO [dbo].[S_MemberDetail]
                ( [S_MemberDetail_RK] ,
                  [LoadDate] ,
                  [H_Member_RK] ,
                  [Member_ID] ,
                  Member_PK ,
                  [Latitude] ,
                  [Longitude] ,
                  [parent_gardian] ,
                  [preferred_practitioner_gender] ,
                  [does_not_speak_english] ,
                  [unable_to_determine_language] ,
                  [speaking_language] ,
                  [language_line_will_be_required_for_the_visit] ,
                  [plan_unable_to_validate_client_vendor_relationship] ,
                  [preferred_method_of_contact] ,
                  [permission_to_leave_voicemail] ,
                  [place_of_assessment_is_not_members_home] ,
                  [members_power_of_attorney] ,
                  [POA_Name] ,
                  [Client_PK] ,
                  [Eff_Date] ,
                  [Exp_date] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Member_ID], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Member_PK], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Latitude], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Longitude], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[parent_gardian], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[preferred_practitioner_gender], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[does_not_speak_english], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[unable_to_determine_language], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[speaking_language], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[language_line_will_be_required_for_the_visit], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[plan_unable_to_validate_client_vendor_relationship], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[preferred_method_of_contact], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[permission_to_leave_voicemail], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[place_of_assessment_is_not_members_home], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[members_power_of_attorney], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[POA_Name], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Client_PK], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Eff_Date], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Exp_Date], '')))))), 2)) ,
                        LoadDate ,
                        MemberHashKey ,
                        [Member_ID] ,
                        Member_PK ,
                        [Latitude] ,
                        [Longitude] ,
                        [parent_gardian] ,
                        [preferred_practitioner_gender] ,
                        [does_not_speak_english] ,
                        [unable_to_determine_language] ,
                        [speaking_language] ,
                        [language_line_will_be_required_for_the_visit] ,
                        [plan_unable_to_validate_client_vendor_relationship] ,
                        [preferred_method_of_contact] ,
                        [permission_to_leave_voicemail] ,
                        [place_of_assessment_is_not_members_home] ,
                        [members_power_of_attorney] ,
                        [POA_Name] ,
                        [Client_PK] ,
                        [Eff_Date] ,
                        [Exp_Date] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[Member_ID], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Member_PK], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Latitude], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Longitude], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[parent_gardian], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[preferred_practitioner_gender], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[does_not_speak_english], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[unable_to_determine_language], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[speaking_language], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[language_line_will_be_required_for_the_visit], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[plan_unable_to_validate_client_vendor_relationship], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[preferred_method_of_contact], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[permission_to_leave_voicemail], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[place_of_assessment_is_not_members_home], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[members_power_of_attorney], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[POA_Name], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Client_PK], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Eff_Date], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Exp_Date], '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[Member_ID], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Member_PK], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Latitude], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Longitude], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[parent_gardian], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[preferred_practitioner_gender], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[does_not_speak_english], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[unable_to_determine_language], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[speaking_language], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[language_line_will_be_required_for_the_visit], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[plan_unable_to_validate_client_vendor_relationship], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[preferred_method_of_contact], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[permission_to_leave_voicemail], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[place_of_assessment_is_not_members_home], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[members_power_of_attorney], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[POA_Name], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Client_PK], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Eff_Date], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Exp_Date], '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_MemberDetail
                        WHERE   H_Member_RK = rw.MemberHashKey
                                --AND RecordEndDate IS NULL
								 )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Member_ID], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[Member_PK], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[Latitude], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[Longitude], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[parent_gardian], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[preferred_practitioner_gender], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[does_not_speak_english], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[unable_to_determine_language], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[speaking_language], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[language_line_will_be_required_for_the_visit], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[plan_unable_to_validate_client_vendor_relationship], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[preferred_method_of_contact], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[permission_to_leave_voicemail], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[place_of_assessment_is_not_members_home], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[members_power_of_attorney], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[POA_Name], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[Client_PK], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[Eff_Date], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[Exp_Date], '')))))), 2)) ,
                        LoadDate ,
                        MemberHashKey ,
                        [Member_ID] ,
                        Member_PK ,
                        [Latitude] ,
                        [Longitude] ,
                        [parent_gardian] ,
                        [preferred_practitioner_gender] ,
                        [does_not_speak_english] ,
                        [unable_to_determine_language] ,
                        [speaking_language] ,
                        [language_line_will_be_required_for_the_visit] ,
                        [plan_unable_to_validate_client_vendor_relationship] ,
                        [preferred_method_of_contact] ,
                        [permission_to_leave_voicemail] ,
                        [place_of_assessment_is_not_members_home] ,
                        [members_power_of_attorney] ,
                        [POA_Name] ,
                        rw.[Client_PK] ,
                        [Eff_Date] ,
                        [Exp_Date] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[Member_ID], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Member_PK], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Latitude], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Longitude], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[parent_gardian], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[preferred_practitioner_gender], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[does_not_speak_english], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[unable_to_determine_language], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[speaking_language], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[language_line_will_be_required_for_the_visit], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[plan_unable_to_validate_client_vendor_relationship], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[preferred_method_of_contact], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[permission_to_leave_voicemail], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[place_of_assessment_is_not_members_home], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[members_power_of_attorney], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[POA_Name], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Client_PK], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Eff_Date], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Exp_Date], '')))))), 2)) ,
                        RecordSource;



							--RECORD END DATE CLEANUP
        UPDATE  dbo.S_MemberDetail
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_MemberDetail z
                                  WHERE     z.H_Member_RK = a.H_Member_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_MemberDetail a
        WHERE   RecordEndDate IS NULL; 

--**** S_MEMBERCHASE LOAD
        INSERT  INTO [dbo].[S_MemberChase]
                ( [S_MemberChase_RK] ,
                  [LoadDate] ,
                  [H_Member_RK] ,
                  [PID] ,
                  [Segment_PK] ,
                  [ChartPriority] ,
                  [Ref_Number] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.PID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Segment_PK AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.ChartPriority, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.Ref_Number, '')))))), 2)) ,
                        LoadDate ,
                        MemberHashKey ,
                        [PID] ,
                        [Segment_PK] ,
                        [ChartPriority] ,
                        [Ref_Number] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.PID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Segment_PK AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.ChartPriority, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.Ref_Number, '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.PID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Segment_PK AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.ChartPriority, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.Ref_Number, '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_MemberChase
                        WHERE   H_Member_RK = rw.MemberHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.PID, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(rw.Segment_PK AS VARCHAR), ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.ChartPriority, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.Ref_Number, '')))))), 2)) ,
                        LoadDate ,
                        MemberHashKey ,
                        [PID] ,
                        [Segment_PK] ,
                        [ChartPriority] ,
                        [Ref_Number] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.PID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Segment_PK AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.ChartPriority, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.Ref_Number, '')))))), 2)) ,
                        RecordSource;

	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_MemberChase
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_MemberChase z
                                  WHERE     z.H_Member_RK = a.H_Member_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_MemberChase a
        WHERE   RecordEndDate IS NULL; 


--***** INSERT INTO S_MEMBERHICN

        INSERT  INTO S_MemberHICN
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.LoadDate, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.RecordSource, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.HICNumber, '')))))), 2)) ,
                        LoadDate ,
                        MemberHashKey ,
                        HICNumber ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.HICNumber, '')))))), 2)) ,
                        RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblMemberWCStage rw WITH ( NOLOCK )
                WHERE   HICNumber IS NOT NULL
                        AND UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.HICNumber, '')))))), 2)) NOT IN (
                        SELECT  [HashDiff]
                        FROM    S_MemberHICN )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.LoadDate, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.RecordSource, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.HICNumber, '')))))), 2)) ,
                        LoadDate ,
                        MemberHashKey ,
                        HICNumber ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CMI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.HICNumber, '')))))), 2)) ,
                        RecordSource;

	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_MemberHICN
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_MemberHICN z
                                  WHERE     z.H_Member_RK = a.H_Member_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_MemberHICN a
        WHERE   RecordEndDate IS NULL; 

--*** Insert into S_LOCATION

        INSERT  INTO [dbo].[S_Location]
                ( [S_Location_RK] ,
                  [LoadDate] ,
                  [H_Location_RK] ,
                  [Address1] ,
                  [Zip] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Address], ''))), ':', RTRIM(LTRIM(COALESCE(ZipCode_PK, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Address], ''))), ':', RTRIM(LTRIM(COALESCE(ZipCode_PK, '')))))), 2)) ,
                        Address ,
                        ZipCode_PK ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Address], ''))), ':', RTRIM(LTRIM(COALESCE(ZipCode_PK, '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Address], ''))), ':', RTRIM(LTRIM(COALESCE(ZipCode_PK, '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_Location
                        WHERE   RecordEndDate IS NULL )
                        --AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Address], ''))), ':', RTRIM(LTRIM(COALESCE(ZipCode_PK, '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Address], ''))), ':', RTRIM(LTRIM(COALESCE(ZipCode_PK, '')))))), 2)) ,
                        Address ,
                        ZipCode_PK ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Address], ''))), ':', RTRIM(LTRIM(COALESCE(ZipCode_PK, '')))))), 2)) ,
                        RecordSource;

						
-- Home_
        INSERT  INTO [dbo].[S_Location]
                ( [S_Location_RK] ,
                  [LoadDate] ,
                  [H_Location_RK] ,
                  [Address1] ,
                  [Zip] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Home_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Home_ZipCode_PK, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Home_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Home_ZipCode_PK, '')))))), 2)) ,
                        Home_Address ,
                        Home_ZipCode_PK ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Home_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Home_ZipCode_PK, '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Home_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Home_ZipCode_PK, '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_Location
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Home_Address], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(Home_ZipCode_PK, '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Home_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Home_ZipCode_PK, '')))))), 2)) ,
                        Home_Address ,
                        Home_ZipCode_PK ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Home_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Home_ZipCode_PK, '')))))), 2)) ,
                        RecordSource;





-- Orig_
        INSERT  INTO [dbo].[S_Location]
                ( [S_Location_RK] ,
                  [LoadDate] ,
                  [H_Location_RK] ,
                  [Address1] ,
                  [Zip] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Orig_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Orig_ZipCode_PK, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Orig_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Orig_ZipCode_PK, '')))))), 2)) ,
                        Orig_Address ,
                        Orig_ZipCode_PK ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Orig_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Orig_ZipCode_PK, '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Orig_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Orig_ZipCode_PK, '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_Location
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Orig_Address], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(Orig_ZipCode_PK, '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Orig_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Orig_ZipCode_PK, '')))))), 2)) ,
                        Orig_Address ,
                        Orig_ZipCode_PK ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([Orig_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Orig_ZipCode_PK, '')))))), 2)) ,
                        RecordSource;


-- POA_
        INSERT  INTO [dbo].[S_Location]
                ( [S_Location_RK] ,
                  [LoadDate] ,
                  [H_Location_RK] ,
                  [Address1] ,
                  [Zip] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([POA_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(POA_ZipCode_PK, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([POA_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(POA_ZipCode_PK, '')))))), 2)) ,
                        POA_Address ,
                        POA_ZipCode_PK ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([POA_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(POA_ZipCode_PK, '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblMemberWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([POA_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(POA_ZipCode_PK, '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_Location
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE([POA_Address], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(POA_ZipCode_PK, '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([POA_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(POA_ZipCode_PK, '')))))), 2)) ,
                        POA_Address ,
                        POA_ZipCode_PK ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([POA_Address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(POA_ZipCode_PK, '')))))), 2)) ,
                        RecordSource;


--RECORD END DATE CLEANUP
        UPDATE  dbo.S_Location
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_Location z
                                  WHERE     z.H_Location_RK = a.H_Location_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_Location a
        WHERE   RecordEndDate IS NULL; 

	

	--*** INSERT INTO S_CONTACT
        INSERT  INTO [dbo].[S_Contact]
                ( [S_Contact_RK] ,
                  [LoadDate] ,
                  [H_Contact_RK] ,
                  [Phone] ,
                  [Cell] ,
                  [EmailAddress] ,
                  [HashDiff] ,
                  [RecordSource] ,
                  [RecordEndDate]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Contact_Number, ''))), ':', RTRIM(LTRIM(COALESCE(Cell_Number, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Contact_Number, ''))), ':', RTRIM(LTRIM(COALESCE(Cell_Number, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LTRIM(RTRIM(ISNULL([Contact_Number],'') )),
                        LTRIM(RTRIM(ISNULL([Cell_Number],'') )),
                        LTRIM(RTRIM(ISNULL([Email_Address],'') )),
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Contact_Number, ''))), ':', RTRIM(LTRIM(COALESCE(Cell_Number, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblMemberWCStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Contact_Number, ''))), ':', RTRIM(LTRIM(COALESCE(Cell_Number, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_Contact
                        WHERE   RecordEndDate IS NULL )
                       AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Contact_Number, ''))), ':', RTRIM(LTRIM(COALESCE(Cell_Number, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Contact_Number, ''))), ':', RTRIM(LTRIM(COALESCE(Cell_Number, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LTRIM(RTRIM(ISNULL([Contact_Number],'') )),
                        LTRIM(RTRIM(ISNULL([Cell_Number],'') )),
                        LTRIM(RTRIM(ISNULL([Email_Address],'') )),
						UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Contact_Number, ''))), ':', RTRIM(LTRIM(COALESCE(Cell_Number, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        RecordSource;


						

--Home

        INSERT  INTO [dbo].[S_Contact]
                ( [S_Contact_RK] ,
                  [LoadDate] ,
                  [H_Contact_RK] ,
                  [Phone] ,
                  [EmailAddress] ,
                  [HashDiff] ,
                  [RecordSource] ,
                  [RecordEndDate]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Home_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Home_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Home_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Home_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LTRIM(RTRIM(ISNULL([Home_Contact_Number],'') )),
                        LTRIM(RTRIM(ISNULL([Home_Email_Address],'') )),
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Home_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Home_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblMemberWCStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Home_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Home_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_Contact
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Home_Contact_Number, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(Home_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Home_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Home_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LTRIM(RTRIM(ISNULL([Home_Contact_Number],'') )),
                        LTRIM(RTRIM(ISNULL([Home_Email_Address],'') )),
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Home_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Home_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        RecordSource;


						
--Orig

        INSERT  INTO [dbo].[S_Contact]
                ( [S_Contact_RK] ,
                  [LoadDate] ,
                  [H_Contact_RK] ,
                  [Phone] ,
                  [EmailAddress] ,
                  [HashDiff] ,
                  [RecordSource] ,
                  [RecordEndDate]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Orig_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Orig_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Orig_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Orig_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LTRIM(RTRIM(ISNULL([Orig_Contact_Number],''))) ,
                        LTRIM(RTRIM(ISNULL([Orig_Email_Address],''))) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Orig_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Orig_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblMemberWCStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Orig_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Orig_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_Contact
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Orig_Contact_Number, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(Orig_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Orig_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Orig_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LTRIM(RTRIM(ISNULL([Orig_Contact_Number],''))) ,
                        LTRIM(RTRIM(ISNULL([Orig_Email_Address],''))) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Orig_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Orig_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        RecordSource;


											
--POA

        INSERT  INTO [dbo].[S_Contact]
                ( [S_Contact_RK] ,
                  [LoadDate] ,
                  [H_Contact_RK] ,
                  [Phone] ,
                  [EmailAddress] ,
                  [HashDiff] ,
                  [RecordSource] ,
                  [RecordEndDate]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(POA_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(POA_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(POA_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(POA_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LTRIM(RTRIM(ISNULL([POA_Contact_Number],''))) ,
                        LTRIM(RTRIM(ISNULL([POA_Email_Address],''))) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(POA_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(POA_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblMemberWCStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(POA_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(POA_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_Contact
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(POA_Contact_Number, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(POA_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(POA_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(POA_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        LTRIM(RTRIM(ISNULL([POA_Contact_Number],''))) ,
                        LTRIM(RTRIM(ISNULL([POA_Email_Address],''))) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(POA_Contact_Number, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(POA_Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        RecordSource;
		--RECORD END DATE CLEANUP
        UPDATE  dbo.S_Contact
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_Contact z
                                  WHERE     z.H_Contact_RK = a.H_Contact_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_Contact a
        WHERE   RecordEndDate IS NULL; 
    END;
    
	



GO
