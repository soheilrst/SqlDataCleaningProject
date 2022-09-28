select top 10  * from dbo.NashwillHousing

--veraendern wir die saledate format von datetime in time

alter table dbo.NashwillHousing 
add SaleDate1 date

update dbo.NashwillHousing 
set SaleDate1=convert(date,SaleDate)

select SaleDate1 from dbo.NashwillHousing

--wir sehen dass manche eintraege haben keine Anschrift,so wir versuchen die fehlende addresse zu finden.
--wenn die parcalId gleich ist,dann die wohnungen mussen die gleiche addresse haben.das heisst wir wenden die addresse
--von der andere eintrag statt unsere fehlende adresse an.


--joining the table mit sich selbst und fullen wir die fehlende addresse mit isnull function


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isNull(a.PropertyAddress,b.PropertyAddress)
from dbo.NashwillHousing a join dbo.NashwillHousing b 
on a.ParcelID =b.ParcelID and a.UniqueID <> b.UniqueID
and a.PropertyAddress is null

update a 
set PropertyAddress=isNull(a.PropertyAddress,b.PropertyAddress)
from dbo.NashwillHousing a join dbo.NashwillHousing b 
on a.ParcelID =b.ParcelID and a.UniqueID <> b.UniqueID
and a.PropertyAddress is null



-- erstellen eine temp table 
create table #Nashi (UniqueID float,ParcelID nvarchar(255),LandUse nvarchar(255),
PropertyAddress nvarchar(255),SaleDate datetime ,SalePrice float,LegalReference nvarchar(255)
,SoldAsVacant nvarchar(255),OwnerName nvarchar(255),OwnerAddress nvarchar(255),Acreage float,
TaxDistrict nvarchar(255),LandValue float,BuildingValue float,TotalValue float,YearBuilt float,
Bedrooms float,FullBath float,HalfBath float)


alter table #Nashi 
add SaleDate1 date
insert into #Nashi select * from dbo.NashwillHousing where PropertyAddress is null

--wir wollen die Addresse column in (address,city,state) zerteilen
 

select substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)as Address
from dbo.NashwillHousing 


select substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))as City
from dbo.NashwillHousing

alter table dbo.NashwillHousing 
add PropretySplitAdress nvarchar(255)

update dbo.NashwillHousing
set PropretySplitAdress=substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

alter  table  dbo.NashwillHousing 
add City nvarchar(255)


update dbo.NashwillHousing
set City=substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))

select  * from dbo.NashwillHousing




--ersetzen wir alle Y mit Yes and alle N mit No in SaleAsVacant Column,um einhaltlichkeit von unsere Daten zu verbessern

update dbo.NashwillHousing
set SoldAsVacant= case when SoldAsVacant='Y' then 'Yes'
					when SoldAsVacant='N' then 'No'
					Else SoldAsVacant
					End

select * from dbo.NashwillHousing where SoldAsVacant='N' 
				



--remove duplicates using row_number and cte

with row_num_cte as(select *, row_number() Over( partition by  ParcelID,PropertyAddress,SalePrice,SaleDate,
LegalReference Order by UniqueID ) row_num from dbo.NashwillHousing)

select * from row_num_cte where row_num >1

--deleting the unusefull columns

alter  table dbo.NashwillHousing 
drop column SaleDate , TaxDistrict,OwnerAddress

select top 10 * from dbo.NashwillHousing






