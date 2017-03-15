SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[Entity]
  AS
select  l.Id as EntityId, l.EntityIdentifierCode, eic.Definition as EntityIdentifier
, l.InterchangeId, l.TransactionSetId, l.TransactionSetCode, l.ParentLoopId, l.SpecLoopId, l.StartingSegmentId
, Name = isnull(n1.[02], case nm1.[02] when '2' then nm1.[03] when '1' then nm1.[03] + ', ' + nm1.[04] + isnull(' ' + nm1.[05],'') end)
, IsPerson = case nm1.[02] when '1' then 1 else 0 end
, LastName = nm1.[03]
, FirstName = nm1.[04]
, MiddleName = nm1.[05]
, NamePrefix = nm1.[06]
, NameSuffix = nm1.[07]
, IdQualifier = isnull(n1.[03],nm1.[08])
, Identification = isnull(n1.[04],nm1.[09])
, Ssn = case when n1.[03] = '34' then n1.[04]
             when nm1.[08] = '34' then nm1.[09] 
             else (select top 1 [02] from [dbo].REF where l.Id = ref.ParentLoopId and [01] = 'SY') end
, Npi = case when n1.[03] = 'XX' then n1.[04]
             when nm1.[08] = 'XX' then nm1.[09]
             else (select top 1 [02] from [dbo].REF where l.Id = ref.ParentLoopId and [01] = 'HPI') end
, TelephoneNumber = coalesce((select top 1 [04] from [dbo].PER where per.ParentLoopId = l.Id and per.[03]='TE')
                    ,(select top 1 [06] from [dbo].PER where per.ParentLoopId = l.Id and per.[05]='TE')
                    ,(select top 1 [08] from [dbo].PER where per.ParentLoopId = l.Id and per.[07]='TE'))
, AddressLine1 = n3.[01]
, AddressLine2 = n3.[02]
, City = n4.[01]
, StateCode = n4.[02]
, PostalCode = n4.[03]
, County = case n4.[05] when 'CY' then n4.[06] else null end
, CountryCode = n4.[07]
, DateOfBirth = dmg.[02]
, Gender = dmg.[03]
from [dbo].[Loop] l
left join [dbo].X12CodeList eic on l.EntityIdentifierCode = eic.Code and eic.ElementId = '98'
left join [dbo].[N1] on l.Id = n1.LoopId
left join [dbo].[NM1] on l.Id = nm1.LoopId
left join [dbo].N3 on l.Id = n3.ParentLoopId
left join [dbo].N4 on l.Id = n4.ParentLoopId
left join [dbo].[DMG] on l.Id = dmg.ParentLoopId
where l.StartingSegmentId in ('N1','NM1','ENT','NX1','PT','IN1','NX1') 
GO
