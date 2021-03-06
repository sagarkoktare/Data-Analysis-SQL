USE COVIDINFO

SELECT * FROM COVIDINFO..NationalHousing

-- Standardising Data Format

Select SaleDate from COVIDINFO.dbo.NationalHousing

Select SaleDate,CONVERT(Date,SaleDate) from COVIDINFO.dbo.NationalHousing

UPDATE NationalHousing
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE COVIDINFO.dbo.NationalHousing
ADD SaleDateconverted Date;

UPDATE COVIDINFO.dbo.NationalHousing
SET SaleDateconverted = CONVERT(Date,SaleDate)

Select SaleDate,SaleDateconverted from COVIDINFO.dbo.NationalHousing

-- POPULATE PROPERTY ADDRESS AREA
SELECT propertyAddress from COVIDINFO..NationalHousing where propertyAddress IS NULL

SELECT a.parcelID,a.propertyAddress, b.parcelID,b.propertyAddress, ISNULL(a.propertyAddress,b.propertyAddress)
from COVIDINFO..NationalHousing a
JOIN COVIDINFO..NationalHousing b
ON a.parcelID = b.parcelID
AND a.[UniqueID] <> b.[UniqueID]
where a.propertyAddress IS NULL

UPDATE a
SET propertyAddress = ISNULL(a.propertyAddress,b.propertyAddress)
from COVIDINFO..NationalHousing a
JOIN COVIDINFO..NationalHousing b
ON a.parcelID = b.parcelID
AND a.[UniqueID] <> b.[UniqueID]
where a.propertyAddress IS NULL

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, STATE, CITY)
SELECT propertyAddress
FROM COVIDINFO..NationalHousing

SELECT 
SUBSTRING(propertyAddress,1,CHARINDEX(',',propertyAddress) - 1) as Address
,SUBSTRING(propertyAddress,CHARINDEX(',',propertyAddress) + 1 ,LEN(propertyAddress)) AS address
FROM COVIDINFO..NationalHousing

ALTER TABLE COVIDINFO.dbo.NationalHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE COVIDINFO.dbo.NationalHousing
SET PropertySplitAddress = SUBSTRING(propertyAddress,1,CHARINDEX(',',propertyAddress) - 1)

ALTER TABLE COVIDINFO.dbo.NationalHousing
ADD PropertySplitCity nvarchar(255);

UPDATE COVIDINFO.dbo.NationalHousing
SET PropertySplitCity = SUBSTRING(propertyAddress,CHARINDEX(',',propertyAddress) + 1 ,LEN(propertyAddress))

SELECT *
FROM COVIDINFO.dbo.NationalHousing

SELECT OWNERADDRESS
FROM COVIDINFO.dbo.NationalHousing

-- BREAKING OUT OWNER ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, STATE, CITY)

SELECT OWNERADDRESS,
PARSENAME(REPLACE(OWNERADDRESS,',','.'),1),
PARSENAME(REPLACE(OWNERADDRESS,',','.'),2),
PARSENAME(REPLACE(OWNERADDRESS,',','.'),3)
FROM COVIDINFO.dbo.NationalHousing

ALTER TABLE COVIDINFO.dbo.NationalHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE COVIDINFO.dbo.NationalHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OWNERADDRESS,',','.'),3)

ALTER TABLE COVIDINFO.dbo.NationalHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE COVIDINFO.dbo.NationalHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OWNERADDRESS,',','.'),2)

ALTER TABLE COVIDINFO.dbo.NationalHousing
ADD OwnerSplitState nvarchar(255);

UPDATE COVIDINFO.dbo.NationalHousing
SET OwnerSplitState = PARSENAME(REPLACE(OWNERADDRESS,',','.'),1)

SELECT *
FROM COVIDINFO.dbo.NationalHousing

-- CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD
SELECT
DISTINCT(SOLDASVACANT),COUNT(SOLDASVACANT)
FROM COVIDINFO.dbo.NationalHousing
GROUP BY SOLDASVACANT

UPDATE COVIDINFO.dbo.NationalHousing
SET SOLDASVACANT = 'Yes' WHERE SOLDASVACANT = 'Y'

UPDATE COVIDINFO.dbo.NationalHousing
SET SOLDASVACANT = 'No' WHERE SOLDASVACANT = 'N'

SELECT SOLDASVACANT
, CASE WHEN SOLDASVACANT = 'Y' THEN 'Yes'
       WHEN SOLDASVACANT = 'N' THEN 'No'
       else SOLDASVACANT
  END
FROM COVIDINFO.dbo.NationalHousing

UPDATE COVIDINFO.dbo.NationalHousing
SET SOLDASVACANT = CASE WHEN SOLDASVACANT = 'Y' THEN 'Yes'
       WHEN SOLDASVACANT = 'N' THEN 'No'
       else SOLDASVACANT
  END
  
 -- REMOVE DUPLICATES
 
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY PARCELID,
				PROPERTYADDRESS,
				SALEPRICE,
				SALEDATE,
				LEGALREFERENCE
				ORDER BY 
				UNIQUEID
				)
FROM COVIDINFO.dbo.NationalHousing
-- ORDER BY PARCELID
)
SELECT * 
FROM RowNumCTE
WHERE ROW_NUM > 1
ORDER BY PROPERTYADDRESS

-- DELETE UNUSED COLUMNS
SELECT *
FROM COVIDINFO.dbo.NationalHousing

ALTER TABLE COVIDINFO.dbo.NationalHousing
DROP COLUMN OWNERADDRESS, TAXDISTRICT, PROPERTYADDRESS

ALTER TABLE COVIDINFO.dbo.NationalHousing
DROP COLUMN SALEDATE
