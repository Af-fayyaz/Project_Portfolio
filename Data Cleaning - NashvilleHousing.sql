/*

Cleaning Data in SQL Queries

*/
use ProjectPortfolio

select * from NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
select SaleDate, convert(Date, SaleDate)
from NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate)

select SaleDate, SaleDateConverted
from NashvilleHousing
 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
select * from NashvilleHousing

select ParcelID, PropertyAddress 
from NashvilleHousing
order by ParcelID
--to populate PA we are going to do a self join so see how this works
select a.ParcelID, a.PropertyAddress
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
--furher check the self join 
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 
--now that I have checked the join with select its time to update the PropertyAddress
update a 
set PropertyAddress =  b.PropertyAddress
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
select PropertyAddress from NashvilleHousing
-- for this we will use sub string and char index
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) as Address
from NashvilleHousing
--this includes , so doing -1 the comma is gone 
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
from NashvilleHousing
--Next we start from ,
select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as AddressTwo
from NashvilleHousing
--so now that we can see the PropertAddress is properly segregated we can add two new olumns to update it in the table
alter table NashvilleHousing
add PropertySplitAddress nvarchar(255),
PropertySplitCity nvarchar(255)
--Now populate the two columns
update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))
--now check
select * from NashvilleHousing

--doing owner address now with parse
select OwnerAddress from NashvilleHousing
--Parsename is only useful with periods so replace the commas with period then parsename will work
select 
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing
--Parsename works backward that's why we are getting the last part so update it accordingly
select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing
--now add 3 new columns and update it with the same
alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255),
OwnerSplitCity nvarchar(255),
OwnerSplitState nvarchar(255)

update NashvilleHousing
set
OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing

--check the same
select * from NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field
--checking what types are there -Y,N,Yes,No and how many of each 
select distinct SoldAsVacant, COUNT(SoldAsVacant) 
from NashvilleHousing
Group by SoldAsVacant
order by 2
--so changing Y,N to Yes and No 
select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from NashvilleHousing
--Now you can update it
update NashvilleHousing
set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
--now you can check by running the dictinct statement again only yes and no appear

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
--with CTEs - Common Table Expressions and row numbers to calculate duplicates
WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDateConverted,
				 SalePrice,
				 LegalReference
				 Order by UniqueID
				 )row_num
from NashvilleHousing
--order by ParcelId
)
select * 
from RowNumCTE 
where row_num > 1
order by ParcelID

-- so to delete these duplicate rows after the CTE add the delete statement
WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDateConverted,
				 SalePrice,
				 LegalReference
				 Order by UniqueID
				 )row_num
from NashvilleHousing
--order by ParcelId
)
delete 
from RowNumCTE 
where row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate













-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------















