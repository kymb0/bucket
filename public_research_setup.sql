-- Create the database
CREATE DATABASE public_research;
GO

-- Use the new database
USE public_research;
GO

-- Create a table for public research papers
CREATE TABLE ResearchPapers (
    PaperID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(255),
    Author NVARCHAR(255),
    Abstract NVARCHAR(MAX),
    PublicationDate DATE,
    Keywords NVARCHAR(255)
);
GO

-- Insert dummy data into the ResearchPapers table
INSERT INTO ResearchPapers (Title, Author, Abstract, PublicationDate, Keywords)
VALUES
('The Future of Viral Therapy', 'William Birkin', 'Exploring the potential of viral therapy in treating genetic disorders.', '2023-01-15', 'Viral Therapy, Genetic Disorders, Biotechnology'),
('Advancements in Vaccine Development', 'William Birkin', 'A comprehensive study on new techniques in vaccine development.', '2023-02-10', 'Vaccine Development, Immunology, Public Health'),
('Urban Health and Epidemic Prevention', 'Nicholai Zinoviev', 'Examining strategies for epidemic prevention in urban areas.', '2023-03-22', 'Epidemic Prevention, Urban Health, Public Health'),
('Regenerative Medicine: Current Trends', 'Alexia Ashford', 'An overview of current trends and future directions in regenerative medicine.', '2023-04-18', 'Regenerative Medicine, Biotechnology, Healthcare'),
('Umbrella’s Contributions to Public Health', 'Albert Wesker', 'Highlighting Umbrella Corporation’s contributions to public health initiatives.', '2023-05-05', 'Public Health, Corporate Contributions, Healthcare'),
('Innovations in Medical Robotics', 'Sergei Vladimir', 'A study on the latest innovations in medical robotics and their applications.', '2023-06-12', 'Medical Robotics, Innovations, Healthcare'),
('Neuroscience and Cognitive Enhancement', 'Oswell E. Spencer', 'Investigating recent advancements in cognitive enhancement through neuroscience.', '2023-07-19', 'Neuroscience, Cognitive Enhancement, Healthcare'),
('Emerging Pathogens and Global Health', 'James Marcus', 'A study on emerging pathogens and their implications for global health.', '2023-08-25', 'Emerging Pathogens, Global Health, Epidemiology'),
('Efficient Models for Medical Research', 'Alexander Ashford', 'Evaluating efficient models and methodologies in medical research.', '2023-09-30', 'Medical Research, Methodologies, Efficiency'),
('Genetic Engineering: Ethical Considerations', 'Alexia Ashford', 'Discussing the ethical considerations in genetic engineering.', '2023-10-15', 'Genetic Engineering, Ethics, Biotechnology');
GO

-- Verify the inserted data
SELECT * FROM ResearchPapers;
GO
