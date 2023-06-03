/*

Cleaning Data in SQL Queries

*/

Select * 
From PortfolioProject1.dbo.NashvilleHousing

--Standardize Date Format

Select SaleDate2, CONVERT(Date, SaleDate)
From PortfolioProject1.dbo.NashvilleHousing

Update PortfolioProject1.dbo.NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table PortfolioProject1.dbo.NashvilleHousing
Add SaleDate2 Date;

Update PortfolioProject1.dbo.NashvilleHousing
Set SaleDate2 = CONVERT(Date, SaleDate)

---------------------------------------------------------------------------------------------------------------

--Populate Property Address data

Select *
From PortfolioProject1.dbo.NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is NULL
--------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual columns (Address,City, State)

Select PropertyAddress
From PortfolioProject1.dbo.NashvilleHousing
--where PropertyAddress is NULL
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject1.dbo.NashvilleHousing


Alter Table PortfolioProject1.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(250);

Update PortfolioProject1.dbo.NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


Alter Table PortfolioProject1.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(250);

Update PortfolioProject1.dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Alter Table PortfolioProject1.dbo.NashvilleHousing
Drop column SaleDate2

Select *
From PortfolioProject1.dbo.NashvilleHousing



Select OwnerAddress
From PortfolioProject1.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject1.dbo.NashvilleHousing

Alter Table PortfolioProject1.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(250);

Update PortfolioProject1.dbo.NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table PortfolioProject1.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(250);

Update PortfolioProject1.dbo.NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table PortfolioProject1.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(250);

Update PortfolioProject1.dbo.NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProject1.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold As Vacant" field

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject1.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
From PortfolioProject1.dbo.NashvilleHousing

Update PortfolioProject1.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End

---------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY
		UniqueID
		) row_num

From PortfolioProject1.dbo.NashvilleHousing
--Order By ParcelID
)
Select *
From RowNumCTE
WHere row_num > 1
--Order by PropertyAdress


Select * 
From PortfolioProject1.dbo.NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns


Select * 
From PortfolioProject1.dbo.NashvilleHousing

Alter Table PortfolioProject1.dbo.NashvilleHousing
Drop Column SaleDate, PropertyAddress, TaxDistrict, OwnerAddress