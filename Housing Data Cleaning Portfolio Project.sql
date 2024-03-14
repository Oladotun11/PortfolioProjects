SELECT *
FROM PortfolioProject..NashvilleHousing

--standardizing date format


SELECT SaleDateConverted,
	convert(DATE, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = convert(DATE, SaleDate)

ALTER TABLE NashvilleHousing ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = convert(DATE, SaleDate)


--populate property address data


SELECT *
FROM PortfolioProject..NashvilleHousing
--where PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	isnull(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--breaking out address into individual columns (address, city, state)


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

--where PropertyAddress is null
--order by ParcelID
SELECT substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) AS address,
	substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) AS address
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT parsename(replace(OwnerAddress, ',', '.'), 3),
	parsename(replace(OwnerAddress, ',', '.'), 2),
	parsename(replace(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)


--change y and n to yes and no in 'sold as vacant' field


SELECT DISTINCT (SoldAsVacant),
	count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y'
			THEN 'Yes'
		WHEN SoldAsVacant = 'N'
			THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y'
			THEN 'Yes'
		WHEN SoldAsVacant = 'N'
			THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..NashvilleHousing


--removing duplicates


WITH RowNumCTE AS (
	SELECT *,
		row_number() OVER (
			PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference ORDER BY UniqueID
			) row_num
	FROM PortfolioProject..NashvilleHousing
	)

DELETE
FROM RowNumCTE
WHERE row_num > 1


--deleting unused columns


ALTER TABLE PortfolioProject..NashvilleHousing

DROP COLUMN OwnerAddress,
	TaxDistrict,
	PropertyAddress,
	SaleDate