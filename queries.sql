-- Створення схеми
CREATE SCHEMA pandemic;

-- Вибір схеми за замовчуванням
USE pandemic;

-- pandemic.infectious_cases definition

CREATE TABLE `infectious_cases` (
  `Entity` varchar(50) DEFAULT NULL,
  `Code` varchar(50) DEFAULT NULL,
  `Year` int DEFAULT NULL,
  `Number_yaws` varchar(50) DEFAULT NULL,
  `polio_cases` int DEFAULT NULL,
  `cases_guinea_worm` int DEFAULT NULL,
  `Number_rabies` double DEFAULT NULL,
  `Number_malaria` double DEFAULT NULL,
  `Number_hiv` double DEFAULT NULL,
  `Number_tuberculosis` double DEFAULT NULL,
  `Number_smallpox` varchar(50) DEFAULT NULL,
  `Number_cholera_cases` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM infectious_cases;


#2.Для нормалізації даних до 3НФ створимо такі таблиці:
-- Створення таблиці для країн (усуваємо повторення Entity та Code)
CREATE TABLE countries (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    entity VARCHAR(100),
    code VARCHAR(10),
    UNIQUE KEY (entity, code)
);

-- Створення нормалізованої таблиці з випадками захворювань
CREATE TABLE disease_cases (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    country_id INT,
    year INT,
    Number_yaws VARCHAR(50),
    polio_cases VARCHAR(50),
    cases_guinea_worm VARCHAR(50),
    Number_rabies VARCHAR(50),
    Number_malaria VARCHAR(50),
    Number_hiv VARCHAR(50),
    Number_tuberculosis VARCHAR(50),
    Number_smallpox VARCHAR(50),
    Number_cholera_cases VARCHAR(50),
    FOREIGN KEY (country_id) REFERENCES countries(country_id)
);
 
-- Заповнення таблиці країн унікальними значеннями
INSERT INTO countries (entity, code)
SELECT DISTINCT Entity, Code 
FROM infectious_cases;
 
-- Заповнення нормалізованої таблиці даними
INSERT INTO disease_cases (country_id, year, Number_yaws, polio_cases, 
    cases_guinea_worm, Number_rabies, Number_malaria, Number_hiv, 
    Number_tuberculosis, Number_smallpox, Number_cholera_cases)
SELECT c.country_id, ic.Year, ic.Number_yaws, ic.polio_cases,
    ic.cases_guinea_worm, ic.Number_rabies, ic.Number_malaria, ic.Number_hiv,
    ic.Number_tuberculosis, ic.Number_smallpox, ic.Number_cholera_cases
FROM infectious_cases ic
INNER JOIN countries c ON ic.Entity = c.entity AND ic.Code = c.code;


# 3.Аналіз даних для Number_rabies
SELECT 
    c.entity,
    c.code,
    AVG(CAST(dc.Number_rabies AS DECIMAL(10,2))) as avg_rabies,
    MIN(CAST(dc.Number_rabies AS DECIMAL(10,2))) as min_rabies,
    MAX(CAST(dc.Number_rabies AS DECIMAL(10,2))) as max_rabies,
    SUM(CAST(dc.Number_rabies AS DECIMAL(10,2))) as total_rabies
FROM disease_cases dc
JOIN countries c ON dc.country_id = c.country_id
WHERE dc.Number_rabies != ''
GROUP BY c.entity, c.code
ORDER BY avg_rabies DESC
LIMIT 10;

#4. Побудова колонки різниці в роках
SELECT
    c.entity,
    c.code,
    dc.Year,
    DATE(CONCAT(dc.Year, '-01-01')) as year_date,
    CURDATE() as today_date,
    TIMESTAMPDIFF(YEAR,
        DATE(CONCAT(dc.Year, '-01-01')),
        CURDATE()
    ) as year_diff
FROM disease_cases dc
JOIN countries c ON dc.country_id = c.country_id;


#5. Створення власної функції для обчислення різниці в роках:
DELIMITER //

DROP FUNCTION IF EXISTS calculate_years_difference //

CREATE FUNCTION calculate_years_difference(input_year INT) 
RETURNS INT 
DETERMINISTIC 
BEGIN 
    RETURN TIMESTAMPDIFF(YEAR, STR_TO_DATE(CONCAT(input_year, '-01-01'), '%Y-%m-%d'), CURDATE());
END //

DELIMITER ;

-- Використання функції
SELECT 
    Year,
    calculate_years_difference(Year) as years_passed
FROM disease_cases;

SELECT 
    Year,
    calculate_years_difference(Year) as years_passed
FROM disease_cases;








