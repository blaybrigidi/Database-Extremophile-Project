-- Drop existing database and create a new one
DROP DATABASE IF EXISTS ProjectDB;
CREATE DATABASE ProjectDB;
USE ProjectDB;

-- Table creation
-- Taxonomy table: Stores hierarchical classification of organisms
CREATE TABLE Taxonomy (
    TaxonomicID INT AUTO_INCREMENT PRIMARY KEY,
    Domain ENUM('Archaea', 'Bacteria', 'Eukarya') NOT NULL,
    Phylum VARCHAR(255) NOT NULL,
    Class VARCHAR(255) NOT NULL,
    `Order` VARCHAR(255) NOT NULL,
    Family VARCHAR(255) NOT NULL,
    UNIQUE KEY (TaxonomicID, Domain),
    INDEX (Phylum),
    INDEX (Class),
    INDEX (`Order`),
    INDEX (Family)
);

-- Ecosystem table: Stores different types of ecosystems
CREATE TABLE Ecosystem (
    EcosystemID INT AUTO_INCREMENT PRIMARY KEY,
    EcosystemName VARCHAR(255) NOT NULL UNIQUE,
    Description TEXT,
    LocationType ENUM('Natural', 'Artificial') NOT NULL
);

-- Environment table: Stores different types of environments
CREATE TABLE Environment (
    EnvironmentID INT AUTO_INCREMENT PRIMARY KEY,
    EnvironmentName VARCHAR(255) NOT NULL UNIQUE,
    ClimateType ENUM('Tropical', 'Arid', 'Temperate', 'Cold', 'Polar') NOT NULL,
    TypicalFloraAndFauna TEXT
);

-- ProjectInfo table: Stores information about research projects
CREATE TABLE ProjectInfo (
    ProjectID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL UNIQUE,
    Description TEXT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    CHECK (EndDate > StartDate)
);

-- Organism table: Stores information about different organisms
CREATE TABLE Organism (
    OrganismID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL UNIQUE,
    TaxonomicID INT NOT NULL,
    EcosystemID INT NOT NULL,
    EnvironmentID INT NOT NULL,
    EnergySource ENUM('Organotroph', 'Chemoautotroph', 'Heterotroph') NOT NULL,
    Metabolism ENUM('Methanotroph', 'Autotroph', 'Respiratory', 'Fermentative') NOT NULL,
    MetabolismExtended TEXT,
    OxygenRequirement ENUM('Aerobic', 'Anaerobic', 'Facultative Anaerobic') NOT NULL,
    Note TEXT,
    FOREIGN KEY (TaxonomicID) REFERENCES Taxonomy(TaxonomicID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (EcosystemID) REFERENCES Ecosystem(EcosystemID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (EnvironmentID) REFERENCES Environment(EnvironmentID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- EnvironmentalCondition table: Stores environmental conditions for each organism
CREATE TABLE EnvironmentalCondition (
    ConditionID INT AUTO_INCREMENT PRIMARY KEY,
    OrganismID INT NOT NULL UNIQUE,
    MinpH DECIMAL(5, 2) DEFAULT 0,
    MaxpH DECIMAL(5, 2) DEFAULT 14,
    AvgOptimumpH DECIMAL(5, 2),
    MinTemp DECIMAL(5, 2) DEFAULT -273.15,
    MaxTemp DECIMAL(5, 2),
    AvgOptimumTemp DECIMAL(5, 2),
    PressureForOptTemp DECIMAL(10, 2) DEFAULT 101.325,
    OptimumPressure DECIMAL(10, 2) DEFAULT 101.325,
    AvgOptSalinity DECIMAL(5, 2) DEFAULT 0,
    CHECK (MinpH <= MaxpH),
    CHECK (MinTemp <= MaxTemp),
    CHECK (MinpH >= 0 AND MaxpH <= 14),
    CHECK (MinTemp >= -273.15),
    CHECK (AvgOptSalinity >= 0),
    FOREIGN KEY (OrganismID) REFERENCES Organism(OrganismID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- BioSource table: Stores sources of biological information
CREATE TABLE BioSource (
    SourceID INT AUTO_INCREMENT PRIMARY KEY,
    OrganismID INT NOT NULL,
    SourceURL VARCHAR(255) NOT NULL,
    UNIQUE KEY (OrganismID, SourceURL),
    FOREIGN KEY (OrganismID) REFERENCES Organism(OrganismID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ProjectStatus table: Stores the status of each project
CREATE TABLE ProjectStatus (
    ProjectID INT PRIMARY KEY,
    Status ENUM('Ongoing', 'Completed', 'Cancelled', 'On Hold') NOT NULL DEFAULT 'Ongoing',
    FOREIGN KEY (ProjectID) REFERENCES ProjectInfo(ProjectID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ProjectFunding table: Stores funding information for each project
CREATE TABLE ProjectFunding (
    ProjectID INT,
    FundingSource VARCHAR(255) NOT NULL,
    FundingAmount_millionsdollars Double NOT NULL,
    PRIMARY KEY (ProjectID, FundingSource),
    FOREIGN KEY (ProjectID) REFERENCES ProjectInfo(ProjectID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Organism_ResearchProject table: Links organisms to research projects (many-to-many relationship)
CREATE TABLE Organism_ResearchProject (
    OrganismProjectID INT AUTO_INCREMENT PRIMARY KEY,
    OrganismID INT NOT NULL,
    ProjectID INT NOT NULL,
    UNIQUE KEY (OrganismID, ProjectID),
    FOREIGN KEY (OrganismID) REFERENCES Organism(OrganismID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (ProjectID) REFERENCES ProjectInfo(ProjectID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Add indexes to improve query performance
ALTER TABLE Organism ADD INDEX idx_taxonomic_id (TaxonomicID);
ALTER TABLE Organism ADD INDEX idx_ecosystem_id (EcosystemID);
ALTER TABLE Organism ADD INDEX idx_environment_id (EnvironmentID);
ALTER TABLE EnvironmentalCondition ADD INDEX idx_organism_id (OrganismID);
ALTER TABLE BioSource ADD INDEX idx_organism_id (OrganismID);
ALTER TABLE Organism_ResearchProject ADD INDEX idx_organism_id (OrganismID);
ALTER TABLE Organism_ResearchProject ADD INDEX idx_project_id (ProjectID);

-- Insert data into tables
INSERT INTO Taxonomy (TaxonomicID, Domain, Phylum, Class, `Order`, Family) VALUES 
(1, 'Archaea', 'Euryarchaeota', 'Methanomicrobia', 'Methanosarcinales', 'Methanosarcinaceae'),
(2, 'Archaea', 'Crenarchaeota', 'Thermoprotei', 'Desulfurococcales', 'Pyrodictiaceae'),
(3, 'Bacteria', 'Proteobacteria', 'Gammaproteobacteria', 'Enterobacterales', 'Enterobacteriaceae'),
(4, 'Bacteria', 'Firmicutes', 'Bacilli', 'Bacillales', 'Bacillaceae'),
(5, 'Bacteria', 'Actinobacteria', 'Actinobacteria', 'Actinomycetales', 'Actinomycetaceae'),
(6, 'Eukarya', 'Ascomycota', 'Saccharomycetes', 'Saccharomycetales', 'Saccharomycetaceae'),
(7, 'Eukarya', 'Basidiomycota', 'Agaricomycetes', 'Agaricales', 'Agaricaceae');

INSERT INTO Ecosystem (EcosystemID, EcosystemName, Description, LocationType) VALUES 
(1, 'Aquatic', 'Water-based ecosystems', 'Natural'),
(2, 'Terrestrial', 'Land-based ecosystems', 'Natural'),
(3, 'Marine', 'Saltwater ecosystems', 'Natural'),
(4, 'Freshwater', 'Freshwater ecosystems', 'Natural'),
(5, 'Forest', 'Diverse ecosystems dominated by trees', 'Natural'),
(6, 'Desert', 'Arid ecosystems with sparse vegetation', 'Natural'),
(7, 'Tundra', 'Cold, treeless ecosystems', 'Natural');

INSERT INTO Environment (EnvironmentID, EnvironmentName, ClimateType, TypicalFloraAndFauna) VALUES 
(1, 'Hydrothermal vent', 'Tropical', 'Chemosynthetic bacteria, tubeworms'),
(2, 'Solfataric waters', 'Arid', 'Thermophilic archaea'),
(3, 'Soil', 'Temperate', 'Various bacteria, fungi, plants'),
(4, 'Water', 'Temperate', 'Various fish, amphibians, invertebrates'),
(5, 'Air', 'Temperate', 'Birds, insects'),
(6, 'Sediment', 'Tropical', 'Benthic invertebrates, bacteria'),
(7, 'Rock', 'Polar', 'Lichens, extremophiles');

INSERT INTO ProjectInfo (ProjectID, Title, Description, StartDate, EndDate) VALUES 
(1, 'Implications For Astrobiology: Life in Extreme Environments', 'Investigating the survival mechanisms of extremophiles to understand the potential for life on other planets' , '2023-01-01', '2023-12-31'),
(2, 'Exploring Deep-Sea Hydrothermal Vent Microorganisms', 'Studying extremophiles in deep-sea hydrothermal vents to understand their unique metabolic pathways', '2023-02-01', '2023-11-30'),
(3, 'Survival Strategies of Antartic Extremophiles', 'Investigating the adaptations of extremophiles in the Antartic to understand their resilience to extreme cold', '2023-03-01', '2023-10-31'),
(4, 'Acidophiles in Bioleaching and Metal Recovery', 'Exploring the use of acidophilic extremophiles in bioleaching to enhance metal recovery from ores', '2023-04-01', '2023-09-30'),
(5, 'Project E', 'Description E', '2023-05-01', '2023-08-31'),
(6, 'Project F', 'Description F', '2023-06-01', '2023-07-31'),
(7, 'Project G', 'Description G', '2023-07-01', '2023-08-31');  

INSERT INTO Organism (OrganismID, Name, TaxonomicID, EcosystemID, EnvironmentID, EnergySource, Metabolism, MetabolismExtended, OxygenRequirement, Note) VALUES 
(1, 'Methanopyrus kandleri 116', 1, 1, 1, 'Organotroph', 'Methanotroph', 'Extended metabolism information', 'Aerobic', 'Note1'),
(2, 'Geogemma barossii 121', 2, 1, 1, 'Chemoautotroph', 'Autotroph', 'Extended metabolism information', 'Anaerobic', 'Note2'),
(3, 'Escherichia coli', 3, 3, 3, 'Heterotroph', 'Respiratory', 'Extended metabolism information', 'Facultative Anaerobic', 'Note3'),
(4, 'Bacillus subtilis', 4, 4, 4, 'Heterotroph', 'Respiratory', 'Extended metabolism information', 'Aerobic', 'Note4'),
(5, 'Streptomyces coelicolor', 5, 5, 5, 'Heterotroph', 'Respiratory', 'Extended metabolism information', 'Aerobic', 'Note5'),
(6, 'Saccharomyces cerevisiae', 6, 6, 6, 'Organotroph', 'Fermentative', 'Extended metabolism information', 'Facultative Anaerobic', 'Note6'),
(7, 'Agaricus bisporus', 7, 7, 7, 'Heterotroph', 'Respiratory', 'Extended metabolism information', 'Aerobic', 'Note7');

INSERT INTO EnvironmentalCondition (ConditionID, OrganismID, MinpH, MaxpH, AvgOptimumpH, MinTemp, MaxTemp, AvgOptimumTemp, PressureForOptTemp, OptimumPressure, AvgOptSalinity) VALUES 
(1, 1, 6.1, 7.0, 6.5, 90.0, 122.0, 105.0, 40000, 40, 0.03),
(2, 2, 5.0, 6.0, 5.5, 85.0, 121.0, 106.0, 200, 0, 0.02),
(3, 3, 6.0, 8.0, 7.0, 37.0, 42.0, 39.0, 101.3, 0.1, 0.9),
(4, 4, 6.0, 8.0, 7.0, 25.0, 37.0, 30.0, 101.3, 0.1, 0.9),
(5, 5, 6.0, 8.0, 7.0, 25.0, 37.0, 30.0, 101.3, 0.1, 0.9),
(6, 6, 4.0, 6.0, 5.0, 30.0, 37.0, 32.0, 101.3, 0.1, 0.9),
(7, 7, 6.0, 8.0, 7.0, 25.0, 30.0, 28.0, 101.3, 0.1, 0.9);

INSERT INTO BioSource (SourceID, OrganismID, SourceURL) VALUES 
(1, 1, 'https://www.pnas.org/content/105/31/10949'),
(2, 2, 'https://pubmed.ncbi.nlm.nih.gov/12920290/'),
(3, 3, 'https://pubmed.ncbi.nlm.nih.gov/10403342/'),
(4, 4, 'https://pubmed.ncbi.nlm.nih.gov/10383949/'),
(5, 5, 'https://pubmed.ncbi.nlm.nih.gov/10974122/'),
(6, 6, 'https://pubmed.ncbi.nlm.nih.gov/10940049/'),
(7, 7, 'https://pubmed.ncbi.nlm.nih.gov/10786642/');

INSERT INTO ProjectStatus (ProjectID, Status) VALUES 
(1, 'Completed'),
(2, 'Ongoing'),
(3, 'Completed'),
(4, 'Ongoing'),
(5, 'Completed'),
(6, 'Ongoing'),
(7, 'Completed');

INSERT INTO ProjectFunding (ProjectID, FundingSource, FundingAmount_millionsdollars) VALUES 
(1, 'NASA Astrobiology Institute', 7.9),
(2, 'National Oceanic and Atmospheric Administration', 2.45),
(3, 'Australian Antarctic Division', 2.01),
(4, 'National Institute of Standards and Technology', 3.5),
(5, 'FundingSource E', 0.2),
(6, 'FundingSource F', 0.9),
(7, 'FundingSource G', 0.1);

INSERT INTO Organism_ResearchProject (OrganismProjectID, OrganismID, ProjectID) VALUES 
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5),
(6, 6, 6),
(7, 7, 7);

-- Create Views

-- Student View: List organisms with their taxonomic information and ecosystem
CREATE VIEW Student_Organism_Taxonomy_Ecosystem AS
SELECT DISTINCT o.Name, t.Domain, t.Phylum, t.Class, t.`Order`, t.Family, e.EcosystemName
FROM Organism o
INNER JOIN Taxonomy t ON o.TaxonomicID = t.TaxonomicID
INNER JOIN Ecosystem e ON o.EcosystemID = e.EcosystemID;

-- Student View: Find average optimal temperature for organisms in each ecosystem
CREATE VIEW Student_Avg_Optimum_Temp_By_Ecosystem AS
SELECT e.EcosystemName, AVG(ec.AvgOptimumTemp) AS AverageOptimalTemp
FROM Ecosystem e
LEFT JOIN Organism o ON e.EcosystemID = o.EcosystemID
LEFT JOIN EnvironmentalCondition ec ON o.OrganismID = ec.OrganismID
GROUP BY e.EcosystemName
HAVING AverageOptimalTemp IS NOT NULL
ORDER BY AverageOptimalTemp DESC;

-- Researcher View: Organisms with extreme temperature requirements
CREATE VIEW Researcher_Extreme_Temperature_Organisms AS
SELECT o.Name, ec.MinTemp, ec.MaxTemp, (ec.MaxTemp - ec.MinTemp) AS TempRange
FROM Organism o
INNER JOIN EnvironmentalCondition ec ON o.OrganismID = ec.OrganismID
WHERE ec.MinTemp < 10 OR ec.MaxTemp > 100
ORDER BY TempRange DESC;

-- Researcher View: Funding sources for projects related to aquatic ecosystems
CREATE VIEW Researcher_Funding_Aquatic_Projects AS
SELECT DISTINCT pf.FundingSource, pi.Title
FROM ProjectFunding pf
INNER JOIN ProjectInfo pi ON pf.ProjectID = pi.ProjectID
INNER JOIN Organism_ResearchProject orp ON pi.ProjectID = orp.ProjectID
INNER JOIN Organism o ON orp.OrganismID = o.OrganismID
INNER JOIN Ecosystem e ON o.EcosystemID = e.EcosystemID
WHERE e.EcosystemName IN ('Aquatic', 'Marine', 'Freshwater')
ORDER BY pf.FundingSource;

-- Researcher View: Analysis organisms and projects by domain and ecosystem
CREATE VIEW Researcher_Organisms_Projects_Domain_Ecosystem AS
SELECT t.Domain, e.EcosystemName, COUNT(DISTINCT o.OrganismID) AS OrganismCount
FROM Taxonomy t
INNER JOIN Organism o ON t.TaxonomicID = o.TaxonomicID
INNER JOIN Ecosystem e ON o.EcosystemID = e.EcosystemID
GROUP BY t.Domain, e.EcosystemName
HAVING OrganismCount > 0
ORDER BY t.Domain, OrganismCount DESC;

-- Researcher View: Organism names, average optimum temperature, and associated project titles
CREATE VIEW Researcher_Organism_Temperature_Project AS
SELECT o.Name AS OrganismName, ec.AvgOptimumTemp, 
       pi.Title AS ProjectTitle, ps.Status
FROM Organism o
LEFT OUTER JOIN EnvironmentalCondition ec ON o.OrganismID = ec.OrganismID
LEFT OUTER JOIN Organism_ResearchProject orp ON o.OrganismID = orp.OrganismID
LEFT OUTER JOIN ProjectInfo pi ON orp.ProjectID = pi.ProjectID
LEFT OUTER JOIN ProjectStatus ps ON pi.ProjectID = ps.ProjectID
WHERE ec.AvgOptimumTemp > 50 AND o.Name LIKE 'M%'
ORDER BY ec.AvgOptimumTemp DESC;

-- Administrator View: List all projects with their status and count of associated organisms
CREATE VIEW Admin_Projects_Status_OrganismCount AS
SELECT DISTINCT pi.Title, ps.Status, COUNT(orp.OrganismID) AS OrganismCount
FROM ProjectInfo pi
INNER JOIN ProjectStatus ps ON pi.ProjectID = ps.ProjectID
LEFT JOIN Organism_ResearchProject orp ON pi.ProjectID = orp.ProjectID
GROUP BY pi.ProjectID, pi.Title, ps.Status
HAVING OrganismCount > 0;

-- Administrator View: Find organisms without any associated projects
CREATE VIEW Admin_Organisms_Without_Projects AS
SELECT DISTINCT o.Name, t.Domain, t.Phylum
FROM Organism o
LEFT JOIN Organism_ResearchProject orp ON o.OrganismID = orp.OrganismID
INNER JOIN Taxonomy t ON o.TaxonomicID = t.TaxonomicID
WHERE orp.ProjectID IS NULL;

-- Administrator View: Calculate the duration of each project and list associated organisms
CREATE VIEW Admin_Project_Duration_Organisms AS
WITH ProjectDuration AS (
    SELECT ProjectID, Title, 
           DATEDIFF(EndDate, StartDate) AS DurationDays
    FROM ProjectInfo
)
SELECT DISTINCT pd.Title, pd.DurationDays, o.Name AS OrganismName, t.Domain
FROM ProjectDuration pd
INNER JOIN Organism_ResearchProject orp ON pd.ProjectID = orp.ProjectID
INNER JOIN Organism o ON orp.OrganismID = o.OrganismID
INNER JOIN Taxonomy t ON o.TaxonomicID = t.TaxonomicID
ORDER BY pd.DurationDays DESC, o.Name;

-- Administrator View: View temperature statistics for specific ecosystems
CREATE VIEW Admin_Temperature_Stats_By_Ecosystem AS
SELECT e.EcosystemName, 
       COUNT(o.OrganismID) AS TotalOrganisms,
       AVG(ec.AvgOptimumTemp) AS AvgTemperature,
       MAX(ec.MaxTemp) AS MaxTemperature,
       MIN(ec.MinTemp) AS MinTemperature
FROM Ecosystem e
INNER JOIN Organism o ON e.EcosystemID = o.EcosystemID
INNER JOIN EnvironmentalCondition ec ON o.OrganismID = ec.OrganismID
WHERE e.EcosystemName IN ('Aquatic', 'Marine', 'Terrestrial')
GROUP BY e.EcosystemName
ORDER BY TotalOrganisms DESC, AvgTemperature DESC;

-- Administrator View: High-funded projects and associated organisms
CREATE VIEW Admin_High_Funded_Projects AS
WITH HighFundedProjects AS (
    SELECT 
        pi.ProjectID,
        pi.Title AS ProjectTitle,
        SUM(pf.FundingAmount_millionsdollars) AS TotalFunding,
        ps.Status AS ProjectStatus
    FROM 
        ProjectInfo pi
    INNER JOIN 
        ProjectFunding pf ON pi.ProjectID = pf.ProjectID
    INNER JOIN 
        ProjectStatus ps ON pi.ProjectID = ps.ProjectID
    GROUP BY 
        pi.ProjectID, pi.Title, ps.Status
    HAVING 
        TotalFunding > 2.00
)
SELECT 
    hfp.ProjectTitle,
    hfp.TotalFunding,
    hfp.ProjectStatus,
    o.Name AS OrganismName,
    t.Domain,
    e.EcosystemName
FROM 
    HighFundedProjects hfp
LEFT JOIN 
    Organism_ResearchProject orp ON hfp.ProjectID = orp.ProjectID
LEFT JOIN 
    Organism o ON orp.OrganismID = o.OrganismID
LEFT JOIN 
    Taxonomy t ON o.TaxonomicID = t.TaxonomicID
LEFT JOIN 
    Ecosystem e ON o.EcosystemID = e.EcosystemID
ORDER BY 
    hfp.TotalFunding DESC, hfp.ProjectTitle, o.Name;

-- Organism Profiles View
CREATE VIEW Organism_Profile AS
SELECT o.OrganismID, o.Name, t.Domain, t.Phylum, t.Class, t.`Order`, t.Family, 
       e.EcosystemName, env.EnvironmentName, o.EnergySource, o.Metabolism, 
       o.MetabolismExtended, o.OxygenRequirement, o.Note
FROM Organism o
INNER JOIN Taxonomy t ON o.TaxonomicID = t.TaxonomicID
INNER JOIN Ecosystem e ON o.EcosystemID = e.EcosystemID
INNER JOIN Environment env ON o.EnvironmentID = env.EnvironmentID;

-- Sample queries to output data from views

-- Query from Student_Organism_Taxonomy_Ecosystem
SELECT * FROM Student_Organism_Taxonomy_Ecosystem;

-- Query from Student_Avg_Optimum_Temp_By_Ecosystem
SELECT * FROM Student_Avg_Optimum_Temp_By_Ecosystem;

-- Query from Researcher_Extreme_Temperature_Organisms
SELECT * FROM Researcher_Extreme_Temperature_Organisms;

-- Query from Researcher_Funding_Aquatic_Projects
SELECT * FROM Researcher_Funding_Aquatic_Projects;

-- Query from Researcher_Organisms_Projects_Domain_Ecosystem
SELECT * FROM Researcher_Organisms_Projects_Domain_Ecosystem;

-- Query from Researcher_Organism_Temperature_Project
SELECT * FROM Researcher_Organism_Temperature_Project;

-- Query from Admin_Projects_Status_OrganismCount
SELECT * FROM Admin_Projects_Status_OrganismCount;

-- Query from Admin_Organisms_Without_Projects
SELECT * FROM Admin_Organisms_Without_Projects;

-- Query from Admin_Project_Duration_Organisms
SELECT * FROM Admin_Project_Duration_Organisms;

-- Query from Admin_Temperature_Stats_By_Ecosystem
SELECT * FROM Admin_Temperature_Stats_By_Ecosystem;

-- Query from Admin_High_Funded_Projects
SELECT * FROM Admin_High_Funded_Projects;

-- Query from Organism_Profile
SELECT * FROM Organism_Profile;