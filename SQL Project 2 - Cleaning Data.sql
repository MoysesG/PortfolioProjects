
-------Cleaning Data in SQL Project

select * from nashville


-- Standardize Date Format

select SalesDateConverted, CONVERT(date,saledate)
from nashville

update nashville 
set saledate = CONVERT(date,saledate)

--------------------------------------------------------------------------------------------------------------------

--populate Address Data

select PropertyAddress from Nashville
where PropertyAddress is null

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress) 
from Nashville a
join Nashville b
on a.ParcelID= b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]

update a
set propertyaddress= ISNULL(a.propertyaddress,b.PropertyAddress) 
from Nashville a
join Nashville b
on a.ParcelID= b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
----------------------------------------------------------------------------------------------------------

--Breaking  out Address into Individual Columns (Address,City, state)

select PropertyAddress from Nashville

select SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) as address,
SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1, len(propertyaddress))  as address
from Nashville


alter table nashville 
add PropertSplitAddress nvarchar (255);

update Nashville
set PropertSplitAddress =  SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) 

alter table nashville 
add PropertSplitcity nvarchar (255);

update Nashville
set PropertSplitcity = SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1, len(propertyaddress))

select owneraddress from Nashville

select
PARSENAME(REPLACE(owneraddress,',','.'),3),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),1)
from nashville

alter table nashville 
add OwenerSplitAddress nvarchar (255);

update Nashville
set OwenerSplitAddress = PARSENAME(REPLACE(owneraddress,',','.'),3)

alter table nashville 
add OwenerSplitCity nvarchar (255);

update Nashville
set OwenerSplitCity = PARSENAME(REPLACE(owneraddress,',','.'),2)


alter table nashville 
add OwenerSplitState nvarchar (255);

update Nashville
set OwenerSplitState = PARSENAME(REPLACE(owneraddress,',','.'),1)
------------------------------------------------------------------------------------------------------------

--Change to "Yes" or No" in "Sold as Vacant" Field

select soldasvacant,
case  when SoldAsVacant = 'y' then 'Yes'
      when Soldasvacant = 'n' then 'No'
	  else Soldasvacant 
end
from Nashville

update Nashville
set SoldAsVacant = case  when SoldAsVacant = 'y' then 'Yes'
      when Soldasvacant = 'n' then 'No'
	  else Soldasvacant 
end

-----------------------------------------------------------------------------------------------------

--Remove Duplicates

with RowNumCte as (
select *,
row_number() over(
partition by parcelid, propertyaddress,saleprice, saledate, legalreference
order by uniqueid) row_num

from Nashville)
delete from RowNumCte
where row_num> 1
--order by PropertyAddress
------------------------------------------------------------------------------------------------------
--Delete Unused Columns


alter table nashville
drop column owneraddress, taxdistrict, propertyaddress

select * from Nashville

alter table nashville
drop column saledate