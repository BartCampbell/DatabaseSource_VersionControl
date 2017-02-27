CREATE TABLE [dbo].[S_GNClaims160807Details]
(
[S_GNClaims160807Details_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[H_Claims_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-FILE-IND] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-0003-SITE-ID] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1001-CLAIM-NUMBER] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1415-RELATIONSHIP] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-3017-MBR-FAMLY-LINK] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-3816-MEDICAL-GRP] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-3113-PCP-ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-3808-PC-MG-ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-SERV-MGCT] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-4302-EMPL-GROUP-ID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-EMP-GRP1] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    FILLER] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-4332-LOB] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-4428-MBR-ORIGIN] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-2616-REIMBURSE-IND] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-4173-BENSET-ID] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1206-TYPE-OF-SERVICE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1207-PLACE-OF-SERVICE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-BEG-DOS] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-END-DOS] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-2045-OUT-OF-PLAN-IND] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1208-PRIMARY-DIAG-CODE] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1211-SECOND-DIAG-CODE] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1218-PROC-CODE] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1219-PROC-MODIFY] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-4508-ANESTHESIA-UNITS] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-4508-ANESTHESIA-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-6003-REC-TYPE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1721-ADMIT-SOURCE] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1531-ADMIT-TYPE] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1503-ADMIT-DT] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1510-ADMIT-HOUR] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1513-ATTEND-PHYSICIAN] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1481-OTHER-PHYSICIAN] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1700-BILL-TYPE] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1445-BIRTH-WEIGHT] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1512-COVERED-DAYS] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-1512-COVERED-DAYS-N] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1430-NON-COVERED-DAYS] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-1430-NON-COVERED-DAYS-N] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1653-DRG] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-DISCHARGE-DT] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1511-DISCHARGE-HOUR] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1704-DISCHARGE-STATUS] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-LOS] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1519-CAT-OF-SERVICE] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-4684-DISC-CATEGORY] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-TARGETED-SVC-CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1097-CLAIM-SOURCE] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-OUTLIER-DAYS] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-OUTLIER-DAYS-N] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-OUTLIER-AMT] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1668-OUTLIER-TYPE] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1130-MAN-PRICE-DOC-IND] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-MEMBER-ON-FILE-IND] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-MEMBER-ELIGIBLE-IND] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1495-INFANT-NEWBORN-IND] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-6001-PA-NUMBER] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1017-DT-RECEIVED] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-TYPE-OF-ASSISTANCE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1096-LCHANGE-OP-ID] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1539-EST-AMOUNT-DUE-1] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1539-EST-AMT-DUE-1-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1717-EMPLOY-STATUS-CD-1] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1539-EST-AMOUNT-DUE-2] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1539-EST-AMT-DUE-2-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1717-EMPLOY-STATUS-CD-2] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1539-EST-AMOUNT-DUE-3] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1539-EST-AMT-DUE-3-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1717-EMPLOY-STATUS-CD-3] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1709-OCCURANCE-CODE(1) OCCURS 20 TIMES] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-REV-TABLE-CNTR] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-REVENUE-TABLE] [varchar] (3564) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-REV-TBL(1) OCCURS 99 TIMES] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-1714-REVENUE-CODE(1)] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-REVENUE-UNITS(1)] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-REVENUE-UNITS-SIGN(1)] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-REVENUE-CHARGES(1)] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-REVENUE-CHARGES-SIGN(1)] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-REVENUE-ADJUD-AMT(1)] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-REVENUE-ADJUD-AMT-SIGN(1)] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-VALUE-TBL-CNTR] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-VALUE-TABLE] [varchar] (432) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-VALUE-TBL(1) OCCURS 36 TIMES] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-1715-VALUE-CODE(1)] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-1543-VALUE-AMOUNT(1)] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-VALUE-AMOUNT-SIGN(1)] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ERROR-TBL-CNTR] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ERROR-TABLE] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ERROR-TBL REDEFINES CL-EXT-ERROR-TABLE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ERROR-TBL(1) OCCURS 15 TIMES] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-1061-ERROR-RSN(1)] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1216-PRIN-DIAG-CODE] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1208-ICD9-DIAG-CODE(1) OCCURS 14 TIMES] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1506-PRIN-PROC-CODE] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1506-ICD9-PROC-CODE(1) OCCURS 14 TIMES] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ANCILLARY-RATE] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1218-PROCEDURE-CODE] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-1218-PROC-CD] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-1219-MODIFIER] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-1219-MODIFIER-2] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-PAYMT-STATUS-1] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-PAYMT-DATE-1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-CHECK-NUM-1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-BILLED-AMT-1] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-BILLED-AMT-1-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-PAID-AMT-1] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-PAID-AMT-1-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ADJUD-AMT-1] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ADJUD-AMT-1-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-UNITS-1] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-UNITS-N-1] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-FFS-OR-CAP-IND-1] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-AMOUNT-APPROVED-1] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-AMT-APPROVED-1-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-REVIEWED-AMOUNT-1] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-REVIEWED-AMOUNT-1-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ALLOWED-AMOUNT-1] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ALLOWED-AMOUNT-1-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ENCOUNTER-AMOUNT-1] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ENCOUNTER-AMOUNT-1-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1222-CPT4-AMOUNT-1] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1222-CPT4-AMT-1-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-PAYMT-STATUS-2] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-PAYMT-DATE-2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-CHECK-NUM-2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-BILLED-AMT-2] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-BILLED-AMT-2-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-PAID-AMT-2] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-PAID-AMT-2-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ADJUD-AMT-2] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ADJUD-AMT-2-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-UNITS-2] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-UNITS-N-2] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-FFS-OR-CAP-IND-2] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-AMOUNT-APPROVED-2] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-AMT-APPROVED-2-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-REVIEWED-AMOUNT-2] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-REVIEWED-AMOUNT-2-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ALLOWED-AMOUNT-2] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ALLOWED-AMOUNT-2-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ENCOUNTER-AMOUNT-2] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ENCOUNTER-AMOUNT-2-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1222-CPT4-AMOUNT-2] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1222-CPT4-AMT-2-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-PAYMT-STATUS-3] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-PAYMT-DATE-3] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-CHECK-NUM-3] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-BILLED-AMT-3] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-BILLED-AMT-3-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-PAID-AMT-3] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-PAID-AMT-3-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ADJUD-AMT-3] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ADJUD-AMT-3-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-UNITS-3] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-UNITS-N-3] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-FFS-OR-CAP-IND-3] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-AMOUNT-APPROVED-3] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-AMT-APPROVED-3-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-REVIEWED-AMOUNT-3] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-REVIEWED-AMOUNT-3-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ALLOWED-AMOUNT-3] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ALLOWED-AMOUNT-3-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ENCOUNTER-AMOUNT-3] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-ENCOUNTER-AMOUNT-3-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1222-CPT4-AMOUNT-3] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1222-CPT4-AMT-3-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-MP-EOC] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-INTEREST-1] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-INTEREST-1-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-INTEREST-2] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-INTEREST-2-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-INTEREST-3] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-INTEREST-3-SIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-CHECK-ACCT-1] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-CHECK-ACCT-2] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-CHECK-ACCT-3] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1027-PROV-REF-QUAL] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1027-PROV-REF-NPI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-0506-PROV-AFF-QUAL] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-0506-PROV-AFF-NPI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-9999-PROV-BILL-QUAL] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-9999-PROV-BILL-NPI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1508-PAT-ACCT-NO] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-PAR-IND] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1532-MEDICAL-RECORD-NO] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-9999-ICD-INDICATOR] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1701-CONDITION-CODE(1) OCCURS 30 TIMES] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1541-OCCURANCE-DT(1) OCCURS 20 TIMES] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1517-PRIN-PROC-DT] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1435-ICD9-PROC-DT(1) OCCURS 14 TIMES] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1039-OTHER-INS-PAID-1] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1039-OTHER-INS-PAID-2] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1039-OTHER-INS-PAID-3] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1056-DEDUCTIBLE-1] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1056-DEDUCTIBLE-2] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1056-DEDUCTIBLE-3] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1040-CO-PAY-1] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1040-CO-PAY-2] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1040-CO-PAY-3] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1047-COINS-AMOUNT-1] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1047-COINS-AMOUNT-2] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1047-COINS-AMOUNT-3] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1057-DISCT-AMOUNT-1] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1057-DISCT-AMOUNT-2] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1057-DISCT-AMOUNT-3] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1224-WITHHOLD-1] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1224-WITHHOLD-2] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1224-WITHHOLD-3] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1231-COB-PAYOUT-AMT-1] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1231-COB-PAYOUT-AMT-2] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1231-COB-PAYOUT-AMT-3] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-2783-NETWORK-ID] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-FILLER-01] [varchar] (111) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_GNClaims160807Details] ADD CONSTRAINT [PK_S_GNClaims160807Details] PRIMARY KEY CLUSTERED  ([S_GNClaims160807Details_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_GNClaims160807Details] ADD CONSTRAINT [FK_S_GNClaims160807Details_H_Claims] FOREIGN KEY ([H_Claims_RK]) REFERENCES [dbo].[H_Claims] ([H_Claims_RK])
GO
