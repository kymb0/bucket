-- Create the database
CREATE DATABASE _5G_enzyme_experimental;
GO

-- Use the new database
USE _5G_enzyme_experimental;
GO

-- Create a table for experimental enzyme data
CREATE TABLE ExperimentalEnzymes (
    ExperimentID INT IDENTITY(1,1) PRIMARY KEY,
    EnzymeName NVARCHAR(255),
    LeadResearcher NVARCHAR(255),
    Objective NVARCHAR(MAX),
    Findings NVARCHAR(MAX),
    Status NVARCHAR(50),
    ConfidentialityLevel NVARCHAR(50),
    LastUpdated DATE
);
GO

-- Insert confidential data into the ExperimentalEnzymes table
INSERT INTO ExperimentalEnzymes (EnzymeName, LeadResearcher, Objective, Findings, Status, ConfidentialityLevel, LastUpdated)
VALUES
('5G Enzyme Alpha', 'William Birkin', 'Enhance cellular regeneration to counteract aging.', 'Successful in initial trials; potential side effects include rapid cell mutation.', 'Ongoing', 'Top Secret', '2023-01-15'),
('5G Enzyme Beta', 'Albert Wesker', 'Develop a bioweapon to target specific genetic markers.', 'Highly effective; ethical concerns raised regarding deployment.', 'Classified', 'Top Secret', '2023-02-10'),
('5G Enzyme Gamma', 'James Marcus', 'Increase cognitive abilities beyond natural limits.', 'Subjects showed increased intelligence but also severe psychological instability.', 'Suspended', 'Confidential', '2023-03-22'),
('5G Enzyme Delta', 'Alexia Ashford', 'Create a virus-resistant immune system.', 'Partial success; immune systems were enhanced but caused autoimmune disorders.', 'Ongoing', 'Top Secret', '2023-04-18'),
('5G Enzyme Epsilon', 'Oswell E. Spencer', 'Develop a method for rapid tissue regeneration.', 'Achieved rapid healing; adverse reactions include uncontrolled tissue growth.', 'Ongoing', 'Top Secret', '2023-05-05'),
('5G Enzyme Zeta', 'Nicholai Zinoviev', 'Improve human endurance and strength.', 'Subjects exhibited superhuman strength but suffered from severe muscle degradation.', 'Suspended', 'Classified', '2023-06-12'),
('5G Enzyme Eta', 'Sergei Vladimir', 'Create a universal antidote for viral infections.', 'Effective against known viruses; further testing required for novel strains.', 'Ongoing', 'Confidential', '2023-07-19'),
('5G Enzyme Theta', 'Alexander Ashford', 'Develop a stealth enzyme for undetectable bio-weapons.', 'Enzyme remains undetected; ethical and legal concerns.', 'Classified', 'Top Secret', '2023-08-25'),
('5G Enzyme Iota', 'Eva Fisher', 'Enhance human sensory perception.', 'Enhanced senses achieved; side effects include sensory overload and neural damage.', 'Ongoing', 'Top Secret', '2023-09-30'),
('5G Enzyme Kappa', 'Franklin Carter', 'Genetically modify plants to produce pharmaceutical compounds.', 'Plants produced desired compounds; environmental impact under review.', 'Ongoing', 'Confidential', '2023-10-15');
GO

-- Verify the inserted data
SELECT * FROM ExperimentalEnzymes;
GO
