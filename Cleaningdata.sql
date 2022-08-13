--Cleaning Data in SQL Queries--

--Change Date Format

SELECT saledateconverted, CONVERT(Date, saledate)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD SaleDateConverted date

UPDATE NashvilleHousing
SET SaleDateConverted= convert(date,saledate)

--Populate property address data

SELECT *
FROM PortfolioProject..NashvilleHousing
--where PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[uniqueID] <> b.[UniqueID]

UPDATE a
SET propertyaddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[uniqueID] <> b.[UniqueID]

--Breaking out Address into Individial Columns (Address, City, State)


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--ORDER BY ParcelID

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, 
LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress= SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing 
ADD PropertySplitCity nvarchar(255) 

UPDATE NashvilleHousing
SET PropertySplitCity= SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
FROM PortfolioProject..NashvilleHousing

Select OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE (OwnerAddress,',','.'), 3),
PARSENAME(REPLACE (OwnerAddress,',','.'), 2),
PARSENAME(REPLACE (OwnerAddress,',','.'), 1)
FROM PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE (OwnerAddress,',','.'), 3)


ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity nvarchar(255) 

UPDATE NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE (OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing 
ADD OwnerSplitState nvarchar(255) 

UPDATE NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE (OwnerAddress,',','.'), 1)


Select *
FROM PortfolioProject..NashvilleHousing


--Chaning Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsvacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN  SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN  SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing

--Remove Duplicates
WITH RowNumCTE AS(
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
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--Remove Unused Columns
Select *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate