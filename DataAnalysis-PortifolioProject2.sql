/*
Cleaning Data in SQL Queries
*/


select * from PortifolioProject..NashvilleHousing;
------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDateConverted, CONVERT(date, SaleDate)
from PortifolioProject..NashvilleHousing;

update PortifolioProject..NashvilleHousing
set SaleDate = CONVERT(date,SaleDate);

alter table PortifolioProject..NashvilleHousing
add SaleDateConverted Date;

update PortifolioProject..NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate);

------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

select * 
from PortifolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortifolioProject..NashvilleHousing a
join PortifolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
--where a.PropertyAddress is null;

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortifolioProject..NashvilleHousing a
join PortifolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

---------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortifolioProject..NashvilleHousing;

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from PortifolioProject..NashvilleHousing;

Alter table PortifolioProject..NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update PortifolioProject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

Alter table PortifolioProject..NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update PortifolioProject..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select *
from PortifolioProject..NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------

-- Imporve the Owner Address too

select OwnerAddress
from PortifolioProject..NashvilleHousing;


select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortifolioProject..NashvilleHousing;

Alter table PortifolioProject..NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Alter table PortifolioProject..NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Alter table PortifolioProject..NashvilleHousing
add OwnerSplitState Nvarchar(255)

update PortifolioProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

update PortifolioProject..NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

update PortifolioProject..NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

select *
from PortifolioProject..NashvilleHousing;

--------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'SoldAsVacant' field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortifolioProject..NashvilleHousing
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case
	when SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'Y' then 'Yes'
	else SoldAsVacant
end
from PortifolioProject..NashvilleHousing;

Update PortifolioProject..NashvilleHousing
set SoldAsVacant = case
	when SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'Y' then 'Yes'
	else SoldAsVacant
end


---------------------------------------------------------------------------------------

-- Remove Duplicates

-- Below Query is checkiing if there are duplicates by partitioning the rows and store the data on CTE

WITH RowNumCTE as (
select *,
	ROW_NUMBER() OVER(
		PARTITION BY 
		ParcelId,
		SalePrice,
		LegalReference,
		PropertyAddress,
		SaleDate
		ORDER BY UniqueID 
	)
	as row_num
from PortifolioProject..NashvilleHousing
)
select * from RowNumCTE
where row_num > 1;


--- Below is the query to delele the duplicates from the table using the created CTE

WITH RowNumCTE as (
select *,
	ROW_NUMBER() OVER(
		PARTITION BY 
		ParcelId,
		SalePrice,
		LegalReference,
		PropertyAddress,
		SaleDate
		ORDER BY UniqueID 
	)
	as row_num
from PortifolioProject..NashvilleHousing
)
delete from RowNumCTE
where row_num > 1;


select * from PortifolioProject..NashvilleHousing;


---------------------------------------------------------------------------------------------------------------

-- Deleting Unused Columns

select * from PortifolioProject..NashvilleHousing;

alter table PortifolioProject..NashvilleHousing
drop column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate;

alter table PortifolioProject..NashvilleHousing
drop column SaleDate;