CREATE TABLE Departments (
	
DepartmentID int PRIMARY KEY,
DepartmentName VARCHAR(100) NOT NULL
);

-- Create Patients table
CREATE TABLE Patients (
PatientID int PRIMARY KEY,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
DOB DATE,
Gender VARCHAR(10),
ContactNumber VARCHAR(15),
Email VARCHAR(100),
Address TEXT,
City VARCHAR(100)

);

-- Create Doctors table
CREATE TABLE Doctors (
DoctorID int PRIMARY KEY,
doctor_FirstName VARCHAR(50) NOT NULL,
doctor_LastName VARCHAR(50) NOT NULL,
Specialization VARCHAR(100),
ContactNumber VARCHAR(15),
Email VARCHAR(100),
DepartmentID INT,
FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- Create Nurses table
CREATE TABLE Nurses (
NurseID int PRIMARY KEY,
nurse_FirstName VARCHAR(50) NOT NULL,
nurse_LastName VARCHAR(50) NOT NULL,
ContactNumber VARCHAR(15),
Email VARCHAR(100),
DepartmentID INT,
FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- Create Appointments table
CREATE TABLE Appointments (
AppointmentID int ,
PatientID INT,
DoctorID INT,
AppointmentDate DATE,
AppointmentTime TIME ,
Status VARCHAR(50),
NurseID INT,
Reason VARCHAR(100),
Patient_status VARCHAR(15),

PRIMARY KEY(AppointmentID,AppointmentTime),
FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
FOREIGN KEY (NurseID) REFERENCES Nurses(NurseID)
	
);

-- Create Treatments table
CREATE TABLE Treatments (
TreatmentID int PRIMARY KEY,
TreatmentName VARCHAR(100) NOT NULL,
Treatment_Description TEXT
);

-- Create Symptoms table
CREATE TABLE Symptoms (
SymptomID int PRIMARY KEY,
SymptomName VARCHAR(100) NOT NULL,
Symptoms_Description TEXT
);

CREATE TABLE Medical_History (

     HistoryID int PRIMARY KEY,
     PatientID INT,
     AppointmentID INT,
     AppointmentTime TIME,
     SymptomID INT,
     TreatmentID INT, 
     DiagnosisDate DATE,
     Notes TEXT,
     registered_time TIMESTAMP,
     doctor_visited_time TIMESTAMP,
     treatment_time TIMESTAMP,
     counseling_time TIMESTAMP,
     waiting_time_for_bed TIMESTAMP,
     patient_type VARCHAR(50),
     days_stayed INT,

     RightEye_SnellenChartResult VARCHAR(10),
     LeftEye_SnellenChartResult VARCHAR(10),

     RightEye_IOP DECIMAL(5, 2),    
     LeftEye_IOP DECIMAL(5, 2),
     RightEye_LensOpacity VARCHAR(50),
     LeftEye_LensOpacity VARCHAR(50),
     RightEye_PupilReactionTime DECIMAL(5, 2),
     LeftEye_PupilReactionTime DECIMAL(5, 2),

     blood_pressure Decimal(5,2),
     -- Post-Operation Right Eye Fields

     PostOp_RightEye_SnellenChartResult VARCHAR(10),
     PostOp_LeftEye_SnellenChartResult VARCHAR(10),
     PostOp_RightEye_IOP DECIMAL(5, 2),
     PostOp_LeftEye_IOP DECIMAL(5, 2),
     PostOp_RightEye_LensOpacity VARCHAR(50),
     PostOp_LeftEye_LensOpacity VARCHAR(50),
     PostOp_RightEye_PupilReactionTime DECIMAL(5, 2),
     PostOp_LeftEye_PupilReactionTime DECIMAL(5, 2),
	     PostOp_blood_pressure Decimal(5,2),
     Medications TEXT,
     NextVisitDate DATE,
     ScansToBeTaken TEXT,

     FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
     FOREIGN KEY (AppointmentID, AppointmentTime) REFERENCES Appointments(AppointmentID, AppointmentTime),
     FOREIGN KEY (SymptomID) REFERENCES Symptoms(SymptomID),
     FOREIGN KEY (TreatmentID) REFERENCES Treatments(TreatmentID)
);


CREATE TABLE Billing (
    BillingID int PRIMARY KEY,
    PatientID INT,
    AppointmentID INT,
    AppointmentTime TIME,
    Amount DECIMAL(10, 2),
    BillingDate DATE,
    PaymentStatus VARCHAR(50),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (AppointmentID, AppointmentTime) REFERENCES Appointments(AppointmentID, AppointmentTime)
);

INSERT INTO Departments (DepartmentID, DepartmentName) VALUES
(1, 'Cataract'),
(2, 'Glaucoma'),
(3, 'Retina'),
(4, 'Cornea');



INSERT INTO Patients (PatientID, FirstName, LastName, DOB, Gender, ContactNumber, Email, Address, City) VALUES
(1, 'Saravana', 'Kumar', '2010-01-15', 'Male', '9998887770', 'saravana.kumar@example.com', '123 Main St', 'Madurai'),
(2, 'Meena', 'Lakshmi', '1990-02-20', 'Female', '9998887771', 'meena.lakshmi@example.com', '456 Park Ave', 'Chennai'),
(3, 'Anand', 'Rao', '1982-03-10', 'Male', '9998887772', 'anand.rao@example.com', '789 Oak Dr', 'Coimbatore'),
(4, 'Latha', 'Sundaram', '1975-04-25', 'Female', '9998887773', 'latha.sundaram@example.com', '101 Pine St', 'Tiruchirappalli'),
(5, 'Arun', 'Kumar', '1988-05-30', 'Male', '9998887774', 'arun.kumar@example.com', '202 Birch Ln', 'Salem'),
(6, 'Priya', 'Nair', '1992-06-15', 'Female', '9998887775', 'priya.nair@example.com', '303 Cedar Ct', 'Tirunelveli'),
(7, 'Ravi', 'Shankar', '1980-07-10', 'Male', '9998887776', 'ravi.shankar@example.com', '404 Maple St', 'Madurai'),
(8, 'Anitha', 'M', '1978-08-05', 'Female', '9998887777', 'anitha.m@example.com', '505 Elm Rd', 'Chennai'),
(9, 'Lakshmi', 'R', '1995-09-10', 'Female', '9998887778', 'lakshmi.r@example.com', '606 Spruce Dr', 'Coimbatore'),
(10, 'Kavitha', 'N', '2012-10-15', 'Female', '9998887779', 'kavitha.n@example.com', '707 Willow Ct', 'Tiruchirappalli'),
(11, 'Vijay', 'Kumar', '1990-01-20', 'Male', '9998887780', 'vijay.kumar@example.com', '111 Cedar St', 'Salem'),
(12, 'Rekha', 'S', '1989-03-30', 'Female', '9998887781', 'rekha.s@example.com', '222 Birch St', 'Madurai'),
(13, 'Suresh', 'B', '1982-07-15', 'Male', '9998887782', 'suresh.b@example.com', '333 Oak Ln', 'Chennai'),
(14, 'Geetha', 'N', '1991-05-25', 'Female', '9998887783', 'geetha.n@example.com', '444 Pine Dr', 'Coimbatore'),
(15, 'Ramesh', 'V', '1985-12-12', 'Male', '9998887784', 'ramesh.v@example.com', '555 Maple Ln', 'Tiruchirappalli'),
(16, 'Anjali', 'D', '1986-04-14', 'Female', '9998887785', 'anjali.d@example.com', '666 Elm St', 'Salem'),
(17, 'Sundar', 'K', '1979-06-18', 'Male', '9998887786', 'sundar.k@example.com', '777 Spruce Ln', 'Tirunelveli'),
(18, 'Rajesh', 'P', '1983-08-09', 'Male', '9998887787', 'rajesh.p@example.com', '888 Willow Dr', 'Madurai'),
(19, 'Nisha', 'R', '1992-11-02', 'Female', '9998887788', 'nisha.r@example.com', '999 Cedar Ct', 'Chennai'),
(20, 'Vikram', 'T', '1981-09-21', 'Male', '9998887789', 'vikram.t@example.com', '101 Pine Ave', 'Coimbatore'),
(21, 'Lakshman', 'S', '1988-12-05', 'Male', '9998887790', 'lakshman.s@example.com', '202 Birch Rd', 'Tiruchirappalli'),
(22, 'Pooja', 'M', '1990-10-15', 'Female', '9998887791', 'pooja.m@example.com', '303 Oak Ct', 'Salem'),
(23, 'Karthik', 'N', '1985-05-17', 'Male', '9998887792', 'karthik.n@example.com', '404 Maple Ln', 'Tirunelveli'),
(24, 'Divya', 'S', '1991-03-12', 'Female', '9998887793', 'divya.s@example.com', '505 Elm Dr', 'Madurai'),
(25, 'Ajay', 'K', '1978-07-25', 'Male', '9998887794', 'ajay.k@example.com', '606 Spruce St', 'Chennai'),
(26, 'Suman', 'R', '1986-09-20', 'Female', '9998887795', 'suman.r@example.com', '707 Willow Ln', 'Coimbatore'),
(27, 'Vimal', 'P', '1983-04-30', 'Male', '9998887796', 'vimal.p@example.com', '808 Cedar Dr', 'Tiruchirappalli'),
(28, 'Sneha', 'D', '1989-11-10', 'Female', '9998887797', 'sneha.d@example.com', '909 Birch Ct', 'Salem'),
(29, 'Arjun', 'T', '1984-06-25', 'Male', '9998887798', 'arjun.t@example.com', '1010 Pine Dr', 'Tirunelveli'),
(30, 'Shalini', 'V', '1987-08-18', 'Female', '9998887799', 'shalini.v@example.com', '1111 Maple Ct', 'Madurai'),
(31, 'Mohan', 'B', '1979-10-25', 'Male', '9998887800', 'mohan.b@example.com', '1212 Elm Ln', 'Chennai'),
(32, 'Gayathri', 'S', '1991-07-20', 'Female', '9998887801', 'gayathri.s@example.com', '1313 Spruce Dr', 'Coimbatore'),
(33, 'Ravi', 'T', '1985-05-30', 'Male', '9998887802', 'ravi.t@example.com', '1414 Willow Ct', 'Tiruchirappalli'),
(34, 'Swetha', 'N', '1983-03-12', 'Female', '9998887803', 'swetha.n@example.com', '1515 Cedar Ln', 'Salem'),
(35, 'Raj', 'K', '1978-09-17', 'Male', '9998887804', 'raj.k@example.com', '1616 Birch Dr', 'Tirunelveli'),
(36, 'Shiva', 'P', '1984-06-25', 'Male', '9998887805', 'shiva.p@example.com', '1717 Pine Ct', 'Madurai'),
(37, 'Aarthi', 'V', '1987-05-14', 'Female', '9998887806', 'aarthi.v@example.com', '1818 Maple Dr', 'Chennai'),
(38, 'Vishal', 'R', '1980-11-02', 'Male', '9998887807', 'vishal.r@example.com', '1919 Elm Ct', 'Coimbatore'),
(39, 'Pallavi', 'S', '1985-07-25', 'Female', '9998887808', 'pallavi.s@example.com', '2020 Spruce Ln', 'Tiruchirappalli'),
(40, 'Manoj', 'B', '1989-01-30', 'Male', '9998887809', 'manoj.b@example.com', '2121 Willow Dr', 'Salem'),
(41, 'Priya', 'D', '1983-04-12', 'Female', '9998887810', 'priya.d@example.com', '2222 Cedar Ct', 'Tirunelveli'),
(42, 'Kiran', 'T', '1986-08-30', 'Male', '9998887811', 'kiran.t@example.com', '2323 Birch Dr', 'Madurai'),
(43, 'Shweta', 'P', '1992-10-15', 'Female', '9998887812', 'shweta.p@example.com', '2424 Pine Ln', 'Chennai'),
(44, 'Aravind', 'N', '1979-03-20', 'Male', '9998887813', 'aravind.n@example.com', '2525 Maple Ct', 'Coimbatore'),
(45, 'Neha', 'V', '1990-07-25', 'Female', '9998887814', 'neha.v@example.com', '2626 Elm Dr', 'Tiruchirappalli'),
(46, 'Santhosh', 'K', '1988-02-18', 'Male', '9998887815', 'santhosh.k@example.com', '2727 Spruce Ct', 'Salem'),
(47, 'Divya', 'R', '1981-05-12', 'Female', '9998887816', 'divya.r@example.com', '2828 Willow Ln', 'Tirunelveli'),
(48, 'Hari', 'T', '1984-09-20', 'Male', '9998887817', 'hari.t@example.com', '2929 Cedar Dr', 'Madurai'),
(49, 'Meena', 'P', '1991-11-10', 'Female', '9998887818', 'meena.p@example.com', '3030 Birch Ct', 'Chennai'),
(50, 'Anu', 'G', '1991-07-20', 'Female', '9998887801', 'gayathri.s@example.com', '1313 Spruce Dr', 'Coimbatore');



-- Insert into Doctors
INSERT INTO Doctors (DoctorID, doctor_FirstName, doctor_LastName, Specialization, ContactNumber, Email, DepartmentID) VALUES
(1, 'Doctor', 'One', 'Cataract', '1234567890', 'doctor1@xyz_eyehospital.com', 1),
(2, 'Doctor', 'Two', 'Glaucoma', '1234567891', 'doctor2@xyz_eyehospital.com', 2),
(3, 'Doctor', 'Three', 'Retina', '1234567892', 'doctor3@xyz_eyehospital.com', 3),
(4, 'Doctor', 'Four', 'Cornea', '1234567893', 'doctor4@xyz_eyehospital.com', 4),
(5, 'Doctor', 'Five', 'Glaucoma', '1234567894', 'doctor5@xyz_eyehospital.com', 2);

-- Insert into Nurses
INSERT INTO Nurses (NurseID, nurse_FirstName, nurse_LastName, ContactNumber, Email, DepartmentID) VALUES
(1, 'Nurse', 'One', '1234567890', 'nurse1@xyz_eyehospital.com', 1),
(2, 'Nurse', 'Two', '1234567891', 'nurse2@xyz_eyehospital.com', 2),
(3, 'Nurse', 'Three', '1234567892', 'nurse3@xyz_eyehospital.com', 3),
(4, 'Nurse', 'Four', '1234567893', 'nurse4@xyz_eyehospital.com', 4),
(5, 'Nurse', 'Five', '1234567894', 'nurse5@xyz_eyehospital.com', 1);



-- Insert into Treatments
INSERT INTO Treatments (TreatmentID, TreatmentName, Treatment_Description) VALUES
(1, 'Cataract Surgery', 'Surgical removal of the lens of the eye'),
(2, 'Glaucoma Treatment', 'Medication and surgery to lower eye pressure'),
(3, 'Retina Surgery', 'Surgery to repair retinal damage'),
(4, 'Cornea Transplant', 'Replacement of damaged cornea with a donor cornea'),
(5, 'Laser Treatment', 'Use of laser to treat eye conditions');

-- Insert into Symptoms
INSERT INTO Symptoms (SymptomID, SymptomName, Symptoms_Description) VALUES
(1, 'Blurred Vision', 'Lack of sharpness of vision'),
(2, 'Eye Pain', 'Pain in the eye'),
(3, 'Redness', 'Redness of the eye'),
(4, 'Tearing', 'Excessive tear production'),
(5, 'Dry Eyes', 'Lack of adequate tears');





INSERT INTO Appointments (
    AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentTime, 
    Status, NurseID, Reason, Patient_status
) VALUES 
(1, 1, 1, '2024-07-01', '09:00:00', 'Completed', 1, 'New patient checkup', 'Outpatient'),
(2, 2, 2, '2024-07-01', '10:00:00', 'Completed', 2, 'New patient checkup', 'Outpatient'),
(3, 3, 3, '2024-07-01', '11:00:00', 'Completed', 3, 'New patient checkup', 'Outpatient'),
(4, 4, 4, '2024-07-01', '13:00:00', 'Completed', 4, 'New patient checkup', 'Inpatient'),
(5, 5, 5, '2024-07-01', '14:00:00', 'Completed', 5, 'New patient checkup', 'Inpatient'),
	
(6, 1, 1, '2024-07-02', '09:00:00', 'Completed', 1, 'Follow-up', 'Inpatient'),
(7, 2, 2, '2024-07-02', '10:00:00', 'Completed', 2, 'Follow-up', 'Outpatient'),
(8, 3, 3, '2024-07-02', '11:00:00', 'Completed', 3, 'Follow-up', 'Outpatient'),
(9, 6, 4, '2024-07-02', '13:00:00', 'Completed', 4, 'New patient checkup', 'Outpatient'),
(10, 7, 5, '2024-07-02', '14:00:00', 'Completed', 5, 'New patient checkup', 'Outpatient'),
(11, 8, 1, '2024-07-02', '15:00:00', 'Completed', 1, 'New patient checkup', 'Outpatient'),
	
(12, 4, 2, '2024-07-03', '09:00:00', 'Completed', 2, 'Follow-up', 'Outpatient'),
(13, 5, 3, '2024-07-03', '10:00:00', 'Completed', 3, 'Follow-up', 'Outpatient'),
(14, 6, 4, '2024-07-03', '11:00:00', 'Completed', 4, 'Follow-up', 'Outpatient'),
(15, 1, 5, '2024-07-03', '13:00:00', 'Completed', 5, 'Follow-up', 'Outpatient'),
(16, 9, 1, '2024-07-03', '14:00:00', 'Completed', 1, 'New patient checkup', 'Outpatient'),
(17, 10, 2, '2024-07-03', '15:00:00', 'Completed', 2, 'New patient checkup', 'Outpatient'),


(18, 11, 2, '2024-07-04', '14:00:00', 'Completed', 2, 'Follow-up', 'Returning'),
(19, 12, 2, '2024-07-05', '14:00:00', 'Completed', 2, 'Follow-up', 'Returning'),
(20, 13, 2, '2024-07-06', '14:00:00', 'Completed', 2, 'Follow-up', 'Returning'),
(21, 14, 2, '2024-07-07', '14:00:00', 'Completed', 2, 'Follow-up', 'Returning'),


(22, 15, 1, '2024-07-07', '09:00:00', 'Completed', 1, 'New patient checkup', 'Outpatient'),
(23, 16, 2, '2024-07-07', '10:00:00', 'Completed', 2, 'New patient checkup', 'Outpatient'),
(24, 17, 3, '2024-07-07', '11:00:00', 'Completed', 3, 'New patient checkup', 'Outpatient'),
(25, 18, 4, '2024-07-07', '13:00:00', 'Completed', 4, 'New patient checkup', 'Outpatient'),
(26, 19, 5, '2024-07-07', '14:00:00', 'Completed', 5, 'New patient checkup', 'Outpatient'),
	
(27, 21, 1, '2024-07-09', '09:00:00', 'Completed', 1, 'New patient checkup', 'Outpatient'),
(28, 22, 2, '2024-07-09', '10:00:00', 'Completed', 2, 'New patient checkup', 'Outpatient'),
(29, 23, 3, '2024-07-09', '11:00:00', 'Completed', 3, 'New patient checkup', 'Outpatient'),
(30, 24, 4, '2024-07-09', '13:00:00', 'Completed', 4, 'New patient checkup', 'Outpatient'),
(31, 25, 5, '2024-07-09', '14:00:00', 'Completed', 5, 'New patient checkup', 'Outpatient'),
	
(32, 25, 1, '2024-07-10', '09:00:00', 'Completed', 1, 'New patient checkup', 'Outpatient'),
(33, 26, 2, '2024-07-10', '10:00:00', 'Completed', 2, 'New patient checkup', 'Outpatient'),
(34, 27, 3, '2024-07-10', '11:00:00', 'Completed', 3, 'New patient checkup', 'Outpatient'),
(35, 28, 4, '2024-07-10', '13:00:00', 'Completed', 4, 'New patient checkup', 'Outpatient'),
(36, 29, 5, '2024-07-10', '14:00:00', 'Completed', 5, 'New patient checkup', 'Outpatient'),
	
(37, 30, 1, '2024-07-11', '09:00:00', 'Completed', 1, 'New patient checkup', 'Outpatient'),
(38, 31, 2, '2024-07-11', '10:00:00', 'Completed', 2, 'New patient checkup', 'Outpatient'),
(39, 32, 3, '2024-07-11', '11:00:00', 'Completed', 3, 'New patient checkup', 'Outpatient'),
(40, 33, 4, '2024-07-11', '13:00:00', 'Completed', 4, 'New patient checkup', 'Outpatient'),
(41, 34, 5, '2024-07-11', '14:00:00', 'Completed', 5, 'New patient checkup', 'Outpatient'),
	
(42, 35, 1, '2024-07-12', '09:00:00', 'Completed', 1, 'New patient checkup', 'Outpatient'),
(43, 36, 2, '2024-07-12', '10:00:00', 'Completed', 2, 'New patient checkup', 'Outpatient'),
(44, 37, 3, '2024-07-12', '11:00:00', 'Completed', 3, 'New patient checkup', 'Outpatient'),
(45, 38, 4, '2024-07-12', '13:00:00', 'Completed', 4, 'New patient checkup', 'Outpatient'),
(46, 39, 5, '2024-07-12', '14:00:00', 'Completed', 5, 'New patient checkup', 'Outpatient'),

(47, 40, 1, '2024-07-15', '09:00:00', 'Completed', 1, 'New patient checkup', 'Outpatient'),
(48, 41, 2, '2024-07-15', '10:00:00', 'Completed', 2, 'New patient checkup', 'Outpatient'),
(49, 42, 3, '2024-07-15', '11:00:00', 'Completed', 3, 'New patient checkup', 'Outpatient'),
(50, 43, 4, '2024-07-15', '13:00:00', 'Completed', 4, 'New patient checkup', 'Outpatient');









INSERT INTO Medical_History (
    HistoryID, PatientID, AppointmentID, AppointmentTime, SymptomID, TreatmentID,DiagnosisDate, Notes, registered_time, doctor_visited_time, treatment_time,     counseling_time, waiting_time_for_bed, patient_type, days_stayed, RightEye_SnellenChartResult,LeftEye_SnellenChartResult, RightEye_IOP, LeftEye_IOP, RightEye_LensOpacity, LeftEye_LensOpacity, RightEye_PupilReactionTime,LeftEye_PupilReactionTime, blood_pressure, PostOp_RightEye_SnellenChartResult, 
    PostOp_LeftEye_SnellenChartResult, PostOp_RightEye_IOP, PostOp_LeftEye_IOP, 
    PostOp_RightEye_LensOpacity, PostOp_LeftEye_LensOpacity, 
    PostOp_RightEye_PupilReactionTime, PostOp_LeftEye_PupilReactionTime, 
    PostOp_blood_pressure, Medications, NextVisitDate, ScansToBeTaken
) VALUES 
(1, 1, 1, '09:00:00', 1, 1, '2024-07-01', 'Initial checkup', '2024-07-01 08:30:00', '2024-07-01 09:00:00', '2024-07-01 09:30:00', '2024-07-01 10:00:00', NULL, 'Outpatient', NULL, '20/40', '20/30', 18.50, 17.50, 'Mild', 'Clear', 0.30, 0.30, 120.50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Eyedrops', '2024-07-15', 'OCT'),
(2, 2, 2, '10:00:00', 2, 2, '2024-07-01', 'Initial checkup', '2024-07-01 09:30:00', '2024-07-01 10:00:00', '2024-07-01 10:30:00', '2024-07-01 11:00:00', NULL, 'Outpatient', NULL, '20/50', '20/60', 22.00, 21.50, 'Moderate', 'Mild', 0.40, 0.40, 130.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Pressure-lowering drops', '2024-07-16', 'Visual Field Test'),
(3, 3, 3, '11:00:00', 3, 3, '2024-07-01', 'Initial checkup', '2024-07-01 10:30:00', '2024-07-01 11:00:00', '2024-07-01 11:30:00', '2024-07-01 12:00:00', NULL, 'Outpatient', NULL, '20/30', '20/40', 16.00, 16.50, 'Clear', 'Clear', 0.30, 0.30, 118.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Artificial tears', '2024-07-17', 'Fundus Photography'),
(4, 4, 4, '13:00:00', 4, 4, '2024-07-01', 'Admitted for observation', '2024-07-01 12:30:00', '2024-07-01 13:00:00', '2024-07-01 13:30:00', '2024-07-01 14:00:00', '2024-07-01 14:30:00', 'Inpatient', 2, '20/200', '20/100', 25.00, 24.50, 'Severe', 'Moderate', 0.60, 0.50, 135.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Antibiotic eyedrops', '2024-07-18', 'Corneal Topography'),
(5, 5, 5, '14:00:00', 5, 5, '2024-07-01', 'Admitted for treatment', '2024-07-01 13:30:00', '2024-07-01 14:00:00', '2024-07-01 14:30:00', '2024-07-01 15:00:00', '2024-07-01 15:30:00', 'Inpatient', 2, '20/70', '20/80', 19.50, 20.00, 'Mild', 'Moderate', 0.40, 0.50, 125.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Steroid eyedrops', '2024-07-19', 'Ultrasound'),
(6, 1, 6, '09:00:00', 1, 1, '2024-07-02', 'Follow-up and admitted', '2024-07-02 08:30:00', '2024-07-02 09:00:00', '2024-07-02 09:30:00', '2024-07-02 10:00:00', '2024-07-02 10:30:00', 'Inpatient', 1, '20/30', '20/25', 17.50, 17.00, 'Mild', 'Clear', 0.30, 0.30, 118.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Eyedrops', '2024-07-16', 'OCT'),
(7, 2, 7, '10:00:00', 2, 2, '2024-07-02', 'Follow-up', '2024-07-02 09:30:00', '2024-07-02 10:00:00', '2024-07-02 10:30:00', '2024-07-02 11:00:00', NULL, 'Outpatient', NULL, '20/40', '20/50', 20.50, 20.00, 'Moderate', 'Mild', 0.40, 0.40, 128.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Pressure-lowering drops', '2024-07-17', 'Visual Field Test'),
(8, 3, 8, '11:00:00', 3, 3, '2024-07-02', 'Follow-up', '2024-07-02 10:30:00', '2024-07-02 11:00:00', '2024-07-02 11:30:00', '2024-07-02 12:00:00', NULL, 'Outpatient', NULL, '20/25', '20/30', 15.50, 16.00, 'Clear', 'Clear', 0.30, 0.30, 117.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Artificial tears', '2024-07-18', 'Fundus Photography'),
(9, 6, 9, '13:00:00', 4, 4, '2024-07-02', 'Initial checkup', '2024-07-02 12:30:00', '2024-07-02 13:00:00', '2024-07-02 13:30:00', '2024-07-02 14:00:00', NULL, 'Outpatient', NULL, '20/40', '20/50', 18.00, 18.50, 'Mild', 'Mild', 0.40, 0.40, 122.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Antibiotic eyedrops', '2024-07-16', 'Corneal Topography'),
(10, 7, 10, '14:00:00', 5, 5, '2024-07-02', 'Initial checkup', '2024-07-02 13:30:00', '2024-07-02 14:00:00', '2024-07-02 14:30:00', '2024-07-02 15:00:00', NULL, 'Outpatient', NULL, '20/30', '20/30', 17.00, 17.50, 'Clear', 'Clear', 0.30, 0.30, 120.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Lubricating eyedrops', '2024-07-17', 'OCT'),

(11, 8, 11, '15:00:00', 1, 1, '2024-07-02', 'Initial checkup', '2024-07-02 14:30:00', '2024-07-02 15:00:00', '2024-07-02 15:30:00', '2024-07-02 16:00:00', NULL, 'Outpatient', NULL, '20/50', '20/60', 19.00, 19.50, 'Mild', 'Moderate', 0.40, 0.50, 126.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Eyedrops', '2024-07-18', 'Visual Field Test'),
(12, 4, 12, '09:00:00', 2, 2, '2024-07-03', 'Follow-up after discharge', '2024-07-03 08:30:00', '2024-07-03 09:00:00', '2024-07-03 09:30:00', '2024-07-03 10:00:00', NULL, 'Outpatient', NULL, '20/100', '20/80', 22.50, 22.00, 'Moderate', 'Mild', 0.50, 0.40, 130.00, '20/70', '20/60', 20.00, 19.50, 'Mild', 'Clear', 0.40, 0.30, 125.00, 'Antibiotic eyedrops', '2024-07-17', 'OCT'),
(13, 5, 13, '10:00:00', 3, 3, '2024-07-03', 'Follow-up after discharge', '2024-07-03 09:30:00', '2024-07-03 10:00:00', '2024-07-03 10:30:00', '2024-07-03 11:00:00', NULL, 'Outpatient', NULL, '20/60', '20/70', 18.50, 19.00, 'Mild', 'Moderate', 0.40, 0.50, 122.00, '20/40', '20/50', 17.50, 18.00, 'Clear', 'Mild', 0.30, 0.40, 120.00, 'Steroid eyedrops', '2024-07-18', 'Fundus Photography'),
(14, 6, 14, '11:00:00', 4, 4, '2024-07-03', 'Follow-up', '2024-07-03 10:30:00', '2024-07-03 11:00:00', '2024-07-03 11:30:00', '2024-07-03 12:00:00', NULL, 'Outpatient', NULL, '20/30', '20/40', 17.50, 18.00, 'Clear', 'Mild', 0.30, 0.40, 120.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Antibiotic eyedrops', '2024-07-17', 'Corneal Topography'),
(15, 1, 15, '13:00:00', 5, 5, '2024-07-03', 'Follow-up after discharge', '2024-07-03 12:30:00', '2024-07-03 13:00:00', '2024-07-03 13:30:00', '2024-07-03 14:00:00', NULL, 'Outpatient', NULL, '20/25', '20/20', 16.50, 16.00, 'Clear', 'Clear', 0.30, 0.30, 116.00, '20/20', '20/20', 16.00, 16.00, 'Clear', 'Clear', 0.30, 0.30, 115.00, 'Eyedrops', '2024-07-17', 'OCT'),
(16, 9, 16, '14:00:00', 1, 1, '2024-07-03', 'Initial checkup', '2024-07-03 13:30:00', '2024-07-03 14:00:00', '2024-07-03 14:30:00', '2024-07-03 15:00:00', NULL, 'Outpatient', NULL, '20/40', '20/50', 18.50, 19.00, 'Mild', 'Mild', 0.40, 0.40, 124.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Lubricating eyedrops', '2024-07-17', 'Visual Field Test'),
(17, 10, 17, '15:00:00', 2, 2, '2024-07-03', 'Initial checkup', '2024-07-03 14:30:00', '2024-07-03 15:00:00', '2024-07-03 15:30:00', '2024-07-03 16:00:00', NULL, 'Outpatient', NULL, '20/30', '20/40', 17.00, 17.50, 'Clear', 'Mild', 0.30, 0.40, 118.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Pressure-lowering drops', '2024-07-18', 'OCT');




INSERT INTO Medical_History (
    HistoryID, PatientID, AppointmentID, AppointmentTime, SymptomID, TreatmentID, 
    DiagnosisDate, Notes, registered_time, doctor_visited_time, treatment_time, 
    counseling_time, waiting_time_for_bed, patient_type, days_stayed, 
    RightEye_SnellenChartResult, LeftEye_SnellenChartResult, RightEye_IOP, LeftEye_IOP, 
    RightEye_LensOpacity, LeftEye_LensOpacity, RightEye_PupilReactionTime, 
    LeftEye_PupilReactionTime, blood_pressure, PostOp_RightEye_SnellenChartResult, 
    PostOp_LeftEye_SnellenChartResult, PostOp_RightEye_IOP, PostOp_LeftEye_IOP, 
    PostOp_RightEye_LensOpacity, PostOp_LeftEye_LensOpacity, 
    PostOp_RightEye_PupilReactionTime, PostOp_LeftEye_PupilReactionTime, 
    PostOp_blood_pressure, Medications, NextVisitDate, ScansToBeTaken
) VALUES 
(18, 11, 18, '14:00:00', 1, 1, '2024-07-04', 'General check-up', '2024-07-04 13:30:00', '2024-07-04 14:00:00', '2024-07-04 14:30:00', '2024-07-04 15:00:00', NULL, 'Outpatient', NULL, '20/25', '20/30', 17.00, 17.50, 'Clear', 'Clear', 0.35, 0.35, 122.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-04', NULL),

(19, 12, 19, '14:00:00', 2, 2, '2024-07-05', 'General check-up', '2024-07-05 13:30:00', '2024-07-05 14:00:00', '2024-07-05 14:30:00', '2024-07-05 15:00:00', NULL, 'Outpatient', NULL, '20/40', '20/40', 18.50, 18.00, 'Mild', 'Mild', 0.40, 0.40, 128.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Lubricating eye drops', '2025-01-05', 'OCT'),

(20, 13, 20, '14:00:00', 3, 3, '2024-07-06', 'General check-up', '2024-07-06 13:30:00', '2024-07-06 14:00:00', '2024-07-06 14:30:00', '2024-07-06 15:00:00', NULL, 'Outpatient', NULL, '20/30', '20/25', 16.50, 16.00, 'Clear', 'Clear', 0.30, 0.30, 118.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-06', NULL),
(21, 14, 21, '14:00:00', 4, 4, '2024-07-07', 'General check-up', '2024-07-07 13:30:00', '2024-07-07 14:00:00', '2024-07-07 14:30:00', '2024-07-07 15:00:00', NULL, 'Outpatient', NULL, '20/50', '20/40', 19.00, 18.50, 'Mild', 'Clear', 0.45, 0.40, 130.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Artificial tears', '2025-01-07', 'Visual Field Test'),
(22, 15, 22, '09:00:00', 5, 5, '2024-07-07', 'General check-up', '2024-07-07 08:30:00', '2024-07-07 09:00:00', '2024-07-07 09:30:00', '2024-07-07 10:00:00', NULL, 'Outpatient', NULL, '20/20', '20/25', 15.50, 16.00, 'Clear', 'Clear', 0.35, 0.35, 120.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-07', NULL),
(23, 16, 23, '10:00:00', 1, 1, '2024-07-07', 'General check-up', '2024-07-07 09:30:00', '2024-07-07 10:00:00', '2024-07-07 10:30:00', '2024-07-07 11:00:00', NULL, 'Outpatient', NULL, '20/30', '20/30', 17.50, 17.00, 'Clear', 'Clear', 0.40, 0.40, 125.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-07', NULL),
(24, 17, 24, '11:00:00', 2, 2, '2024-07-07', 'General check-up', '2024-07-07 10:30:00', '2024-07-07 11:00:00', '2024-07-07 11:30:00', '2024-07-07 12:00:00', NULL, 'Outpatient', NULL, '20/40', '20/50', 18.00, 18.50, 'Mild', 'Mild', 0.45, 0.45, 132.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Lubricating eye drops', '2025-01-07', 'OCT'),
(25, 18, 25, '13:00:00', 3, 3, '2024-07-07', 'General check-up', '2024-07-07 12:30:00', '2024-07-07 13:00:00', '2024-07-07 13:30:00', '2024-07-07 14:00:00', NULL, 'Outpatient', NULL, '20/25', '20/30', 16.50, 17.00, 'Clear', 'Clear', 0.35, 0.35, 118.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-07', NULL),
(26, 19, 26, '14:00:00', 4, 4, '2024-07-07', 'General check-up', '2024-07-07 13:30:00', '2024-07-07 14:00:00', '2024-07-07 14:30:00', '2024-07-07 15:00:00', NULL, 'Outpatient', NULL, '20/30', '20/40', 17.50, 18.00, 'Clear', 'Mild', 0.40, 0.45, 126.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Artificial tears', '2025-01-07', 'Visual Field Test'),
(27, 21, 27, '09:00:00', 5, 5, '2024-07-09', 'General check-up', '2024-07-09 08:30:00', '2024-07-09 09:00:00', '2024-07-09 09:30:00', '2024-07-09 10:00:00', NULL, 'Outpatient', NULL, '20/20', '20/20', 15.00, 15.50, 'Clear', 'Clear', 0.30, 0.30, 120.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-09', NULL),
(28, 22, 28, '10:00:00', 1, 1, '2024-07-09', 'General check-up', '2024-07-09 09:30:00', '2024-07-09 10:00:00', '2024-07-09 10:30:00', '2024-07-09 11:00:00', NULL, 'Outpatient', NULL, '20/30', '20/25', 17.00, 16.50, 'Clear', 'Clear', 0.35, 0.35, 122.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-09', NULL),
(29, 23, 29, '11:00:00', 2, 2, '2024-07-09', 'General check-up', '2024-07-09 10:30:00', '2024-07-09 11:00:00', '2024-07-09 11:30:00', '2024-07-09 12:00:00', NULL, 'Outpatient', NULL, '20/40', '20/30', 18.00, 17.50, 'Mild', 'Clear', 0.40, 0.35, 126.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Lubricating eye drops', '2025-01-09', 'OCT'),
(30, 24, 30, '13:00:00', 3, 3, '2024-07-09', 'General check-up', '2024-07-09 12:30:00', '2024-07-09 13:00:00', '2024-07-09 13:30:00', '2024-07-09 14:00:00', NULL, 'Outpatient', NULL, '20/25', '20/25', 16.50, 16.50, 'Clear', 'Clear', 0.35, 0.35, 118.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-09', NULL),
(31, 25, 31, '14:00:00', 4, 4, '2024-07-09', 'General check-up', '2024-07-09 13:30:00', '2024-07-09 14:00:00', '2024-07-09 14:30:00', '2024-07-09 15:00:00', NULL, 'Outpatient', NULL, '20/30', '20/40', 17.50, 18.00, 'Clear', 'Mild', 0.40, 0.45, 130.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Artificial tears', '2025-01-09', 'Visual Field Test'),
(32, 25, 32, '09:00:00', 5, 5, '2024-07-10', 'General check-up', '2024-07-10 08:30:00', '2024-07-10 09:00:00', '2024-07-10 09:30:00', '2024-07-10 10:00:00', NULL, 'Outpatient', NULL, '20/20', '20/25', 15.50, 16.00, 'Clear', 'Clear', 0.30, 0.35, 122.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-10', NULL),
(33, 26, 33, '10:00:00', 1, 1, '2024-07-10', 'General check-up', '2024-07-10 09:30:00', '2024-07-10 10:00:00', '2024-07-10 10:30:00', '2024-07-10 11:00:00', NULL, 'Outpatient', NULL, '20/30', '20/30', 17.00, 17.00, 'Clear', 'Clear', 0.35, 0.35, 124.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-10', NULL),
(34, 27, 34, '11:00:00', 2, 2, '2024-07-10', 'General check-up', '2024-07-10 10:30:00', '2024-07-10 11:00:00', '2024-07-10 11:30:00', '2024-07-10 12:00:00', NULL, 'Outpatient', NULL, '20/40', '20/50', 18.50, 19.00, 'Mild', 'Mild', 0.45, 0.50, 128.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Lubricating eye drops', '2025-01-10', 'OCT'),
(35, 28, 35, '13:00:00', 3, 3, '2024-07-10', 'General check-up', '2024-07-10 12:30:00', '2024-07-10 13:00:00', '2024-07-10 13:30:00', '2024-07-10 14:00:00', NULL, 'Outpatient', NULL, '20/25', '20/30', 16.00, 16.50, 'Clear', 'Clear', 0.35, 0.40, 120.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-10', NULL),
(36, 29, 36, '14:00:00', 4, 4, '2024-07-10', 'General check-up', '2024-07-10 13:30:00', '2024-07-10 14:00:00', '2024-07-10 14:30:00', '2024-07-10 15:00:00', NULL, 'Outpatient', NULL, '20/30', '20/40', 17.50, 18.00, 'Clear', 'Mild', 0.40, 0.45, 126.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Artificial tears', '2025-01-10', 'Visual Field Test'),
(37, 30, 37, '09:00:00', 5, 5, '2024-07-11', 'General check-up', '2024-07-11 08:30:00', '2024-07-11 09:00:00', '2024-07-11 09:30:00', '2024-07-11 10:00:00', NULL, 'Outpatient', NULL, '20/20', '20/20', 15.00, 15.00, 'Clear', 'Clear', 0.30, 0.30, 118.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-11', NULL),
(38, 31, 38, '10:00:00', 1, 1, '2024-07-11', 'General check-up', '2024-07-11 09:30:00', '2024-07-11 10:00:00', '2024-07-11 10:30:00', '2024-07-11 11:00:00', NULL, 'Outpatient', NULL, '20/30', '20/25', 17.00, 16.50, 'Clear', 'Clear', 0.35, 0.35, 122.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-11', NULL),
(39, 32, 39, '11:00:00', 2, 2, '2024-07-11', 'General check-up', '2024-07-11 10:30:00', '2024-07-11 11:00:00', '2024-07-11 11:30:00', '2024-07-11 12:00:00', NULL, 'Outpatient', NULL, '20/40', '20/40', 18.00, 18.00, 'Mild', 'Mild', 0.40, 0.40, 124.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Lubricating eye drops', '2025-01-11', 'OCT'),
(40, 33, 40, '13:00:00', 3, 3, '2024-07-11', 'General check-up', '2024-07-11 12:30:00', '2024-07-11 13:00:00', '2024-07-11 13:30:00', '2024-07-11 14:00:00', NULL, 'Outpatient', NULL, '20/25', '20/30', 16.50, 17.00, 'Clear', 'Clear', 0.35, 0.40, 120.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-11', NULL),
(41, 34, 41, '14:00:00', 4, 4, '2024-07-11', 'General check-up', '2024-07-11 13:30:00', '2024-07-11 14:00:00', '2024-07-11 14:30:00', '2024-07-11 15:00:00', NULL, 'Outpatient', NULL, '20/30', '20/40', 17.50, 18.00, 'Clear', 'Mild', 0.40, 0.45, 126.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Artificial tears', '2025-01-11', 'Visual Field Test'),
(42, 35, 42, '09:00:00', 5, 5, '2024-07-12', 'General check-up', '2024-07-12 08:30:00', '2024-07-12 09:00:00', '2024-07-12 09:30:00', '2024-07-12 10:00:00', NULL, 'Outpatient', NULL, '20/20', '20/25', 15.50, 16.00, 'Clear', 'Clear', 0.30, 0.35, 120.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-12', NULL),
(43, 36, 43, '10:00:00', 1, 1, '2024-07-12', 'General check-up', '2024-07-12 09:30:00', '2024-07-12 10:00:00', '2024-07-12 10:30:00', '2024-07-12 11:00:00', NULL, 'Outpatient', NULL, '20/30', '20/30', 17.00, 17.00, 'Clear', 'Clear', 0.35, 0.35, 122.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-12', NULL),
(44, 37, 44, '11:00:00', 2, 2, '2024-07-12', 'General check-up', '2024-07-12 10:30:00', '2024-07-12 11:00:00', '2024-07-12 11:30:00', '2024-07-12 12:00:00', NULL, 'Outpatient', NULL, '20/40', '20/50', 18.50, 19.00, 'Mild', 'Mild', 0.45, 0.50, 128.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Lubricating eye drops', '2025-01-12', 'OCT'),
(45, 38, 45, '13:00:00', 3, 3, '2024-07-12', 'General check-up', '2024-07-12 12:30:00', '2024-07-12 13:00:00', '2024-07-12 13:30:00', '2024-07-12 14:00:00', NULL, 'Outpatient', NULL, '20/25', '20/30', 16.00, 16.50, 'Clear', 'Clear', 0.35, 0.40, 118.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-12', NULL),
(46, 39, 46, '14:00:00', 4, 4, '2024-07-12', 'General check-up', '2024-07-12 13:30:00', '2024-07-12 14:00:00', '2024-07-12 14:30:00', '2024-07-12 15:00:00', NULL, 'Outpatient', NULL, '20/30', '20/40', 17.50, 18.00, 'Clear', 'Mild', 0.40, 0.45, 124.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Artificial tears', '2025-01-12', 'Visual Field Test'),
(47, 40, 47, '09:00:00', 5, 5, '2024-07-15', 'General check-up', '2024-07-15 08:30:00', '2024-07-15 09:00:00', '2024-07-15 09:30:00', '2024-07-15 10:00:00', NULL, 'Outpatient', NULL, '20/20', '20/20', 15.00, 15.00, 'Clear', 'Clear', 0.30, 0.30, 120.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-15', NULL),
(48, 41, 48, '10:00:00', 1, 1, '2024-07-15', 'General check-up', '2024-07-15 09:30:00', '2024-07-15 10:00:00', '2024-07-15 10:30:00', '2024-07-15 11:00:00', NULL, 'Outpatient', NULL, '20/30', '20/25', 17.00, 16.50, 'Clear', 'Clear', 0.35, 0.35, 122.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-15', NULL),
(49, 42, 49, '11:00:00', 2, 2, '2024-07-15', 'General check-up', '2024-07-15 10:30:00', '2024-07-15 11:00:00', '2024-07-15 11:30:00', '2024-07-15 12:00:00', NULL, 'Outpatient', NULL, '20/40', '20/40', 18.00, 18.00, 'Mild', 'Mild', 0.40, 0.40, 126.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Lubricating eye drops', '2025-01-15', 'OCT'),
(50, 43, 50, '13:00:00', 3, 3, '2024-07-15', 'General check-up', '2024-07-15 12:30:00', '2024-07-15 13:00:00', '2024-07-15 13:30:00', '2024-07-15 14:00:00', NULL, 'Outpatient', NULL, '20/25', '20/30', 16.50, 17.00, 'Clear', 'Clear', 0.35, 0.40, 118.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'None', '2025-07-15', NULL);



INSERT INTO Billing (BillingID, PatientID, AppointmentID, AppointmentTime, Amount, BillingDate, PaymentStatus)
VALUES 
(1, 1, 1, '09:00:00', 150.00, '2024-07-01', 'Paid'),
(2, 2, 2, '10:00:00', 200.00, '2024-07-01', 'Pending'),
(3, 3, 3, '11:00:00', 175.00, '2024-07-01', 'Paid'),
(4, 4, 4, '13:00:00', 300.00, '2024-07-01', 'Paid'),
(5, 5, 5, '14:00:00', 250.00, '2024-07-01', 'Pending'),
(6, 1, 6, '09:00:00', 100.00, '2024-07-02', 'Paid'),
(7, 2, 7, '10:00:00', 150.00, '2024-07-02', 'Paid'),
(8, 3, 8, '11:00:00', 125.00, '2024-07-02', 'Pending'),
(9, 6, 9, '13:00:00', 200.00, '2024-07-02', 'Paid'),
(10, 7, 10, '14:00:00', 175.00, '2024-07-02', 'Paid'),
(11, 8, 11, '15:00:00', 180.00, '2024-07-02', 'Paid'),
(12, 4, 12, '09:00:00', 120.00, '2024-07-03', 'Pending'),
(13, 5, 13, '10:00:00', 200.00, '2024-07-03', 'Paid'),
(14, 6, 14, '11:00:00', 150.00, '2024-07-03', 'Paid'),
(15, 1, 15, '13:00:00', 100.00, '2024-07-03', 'Paid'),
(16, 9, 16, '14:00:00', 220.00, '2024-07-03', 'Pending'),
(17, 10, 17, '15:00:00', 190.00, '2024-07-03', 'Paid'),
(18, 11, 18, '14:00:00', 160.00, '2024-07-04', 'Paid'),
(19, 12, 19, '14:00:00', 175.00, '2024-07-05', 'Pending'),
(20, 13, 20, '14:00:00', 140.00, '2024-07-06', 'Paid'),
(21, 14, 21, '14:00:00', 165.00, '2024-07-07', 'Paid'),
(22, 15, 22, '09:00:00', 130.00, '2024-07-07', 'Pending'),
(23, 16, 23, '10:00:00', 180.00, '2024-07-07', 'Paid'),
(24, 17, 24, '11:00:00', 195.00, '2024-07-07', 'Paid'),
(25, 18, 25, '13:00:00', 140.00, '2024-07-07', 'Pending'),
(26, 19, 26, '14:00:00', 210.00, '2024-07-07', 'Paid'),
(27, 21, 27, '09:00:00', 155.00, '2024-07-09', 'Paid'),
(28, 22, 28, '10:00:00', 170.00, '2024-07-09', 'Pending'),
(29, 23, 29, '11:00:00', 185.00, '2024-07-09', 'Paid'),
(30, 24, 30, '13:00:00', 145.00, '2024-07-09', 'Paid'),
(31, 25, 31, '14:00:00', 200.00, '2024-07-09', 'Pending'),
(32, 25, 32, '09:00:00', 160.00, '2024-07-10', 'Paid'),
(33, 26, 33, '10:00:00', 175.00, '2024-07-10', 'Paid'),
(34, 27, 34, '11:00:00', 190.00, '2024-07-10', 'Pending'),
(35, 28, 35, '13:00:00', 150.00, '2024-07-10', 'Paid'),
(36, 29, 36, '14:00:00', 205.00, '2024-07-10', 'Paid'),
(37, 30, 37, '09:00:00', 135.00, '2024-07-11', 'Pending'),
(38, 31, 38, '10:00:00', 180.00, '2024-07-11', 'Paid'),
(39, 32, 39, '11:00:00', 195.00, '2024-07-11', 'Paid'),
(40, 33, 40, '13:00:00', 155.00, '2024-07-11', 'Pending'),
(41, 34, 41, '14:00:00', 210.00, '2024-07-11', 'Paid'),
(42, 35, 42, '09:00:00', 140.00, '2024-07-12', 'Pending'),
(43, 36, 43, '10:00:00', 185.00, '2024-07-12', 'Paid'),
(44, 37, 44, '11:00:00', 200.00, '2024-07-12', 'Paid'),
(45, 38, 45, '13:00:00', 160.00, '2024-07-12', 'Pending'),
(46, 39, 46, '14:00:00', 215.00, '2024-07-12', 'Paid'),
(47, 40, 47, '09:00:00', 145.00, '2024-07-15', 'Paid'),
(48, 41, 48, '10:00:00', 190.00, '2024-07-15', 'Pending'),
(49, 42, 49, '11:00:00', 205.00, '2024-07-15', 'Paid'),
(50, 43, 50, '13:00:00', 165.00, '2024-07-15', 'Paid');


--------------------------------------------------------------------------------------------------------


-- Insert into Appointments
INSERT INTO Appointments (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentTime, Status, NurseID, Reason, Patient_status) VALUES
-- July 1 (New patients)

(51, 1, 2, '2024-07-04', '14:00:00', 'Completed', 2, 'Follow-up', 'Returning'),
(52, 1, 2, '2024-07-05', '14:00:00', 'Completed', 2, 'Follow-up', 'Returning'),
(53, 1, 2, '2024-07-06', '14:00:00', 'Completed', 2, 'Follow-up', 'Returning'),
(54, 1, 2, '2024-07-07', '14:00:00', 'Completed', 2, 'Follow-up', 'Returning');




INSERT INTO Medical_History (
    HistoryID, PatientID, AppointmentID, AppointmentTime, SymptomID, TreatmentID, 
    DiagnosisDate, Notes, registered_time, doctor_visited_time, treatment_time, 
    counseling_time, patient_type, RightEye_SnellenChartResult, RightEye_IOP, 
    RightEye_LensOpacity, RightEye_PupilReactionTime, LeftEye_SnellenChartResult, 
    LeftEye_IOP, LeftEye_LensOpacity, LeftEye_PupilReactionTime, Medications, 
    NextVisitDate, ScansToBeTaken, waiting_time_for_bed, days_stayed, 
    PostOp_RightEye_SnellenChartResult, PostOp_RightEye_IOP, PostOp_RightEye_LensOpacity, 
    PostOp_RightEye_PupilReactionTime, PostOp_LeftEye_SnellenChartResult, PostOp_LeftEye_IOP, 
    PostOp_LeftEye_LensOpacity, PostOp_LeftEye_PupilReactionTime, blood_pressure
) VALUES
	
(51, 1, 18, '14:00:00', 2, 2, '2024-07-04', 'Follow-up after observation', '2024-07-03 13:30:00', '2024-07-03 14:15:00', '2024-07-03 15:00:00', '2024-07-03 15:30:00', 'Outpatient', '6/18', 16.8, 'Clear', 0.2, '6/7.5', 16, 'Clear', 0.5, 'Continued eye drops', '2024-07-31', 'Visual field test', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 140.0),
(52, 1, 19, '14:00:00', 2, 2, '2024-07-05', 'Follow-up after observation', '2024-07-03 13:30:00', '2024-07-03 14:15:00', '2024-07-03 15:00:00', '2024-07-03 15:30:00', 'Outpatient', '6/15', 15.8, 'Clear', 0.5, '6/12', 16.5, 'Clear', 0.4, 'Continued eye drops', '2024-07-31', 'Visual field test', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 165.0),
(53, 1, 20, '14:00:00', 2, 2, '2024-07-06', 'Follow-up after observation', '2024-07-03 13:30:00', '2024-07-03 14:15:00', '2024-07-03 15:00:00', '2024-07-03 15:30:00', 'Outpatient', '6/6', 16, 'Clear', 0.35, '6/6', 17, 'Clear', 0.3, 'Continued eye drops', '2024-07-31', 'Visual field test', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 160.0),
(54, 1, 21, '14:00:00', 2, 2, '2024-07-07', 'Follow-up after observation', '2024-07-03 13:30:00', '2024-07-03 14:15:00', '2024-07-03 15:00:00', '2024-07-03 15:30:00', 'Outpatient', '6/6', 17, 'Clear', 0.4, '6/6', 18, 'Clear', 0.4, 'Continued eye drops', '2024-07-31', 'Visual field test', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 170.0);












-- Insert into Appointments
INSERT INTO Appointments (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentTime, Status, NurseID, Reason, Patient_status) VALUES
-- July 1 (New patients)

(55, 2, 2, '2024-07-03', '14:00:00', 'Completed', 2, 'Follow-up', 'Returning');



INSERT INTO Medical_History (
    HistoryID, PatientID, AppointmentID, AppointmentTime, SymptomID, TreatmentID, 
    DiagnosisDate, Notes, registered_time, doctor_visited_time, treatment_time, 
    counseling_time, patient_type, RightEye_SnellenChartResult, RightEye_IOP, 
    RightEye_LensOpacity, RightEye_PupilReactionTime, LeftEye_SnellenChartResult, 
    LeftEye_IOP, LeftEye_LensOpacity, LeftEye_PupilReactionTime, Medications, 
    NextVisitDate, ScansToBeTaken, waiting_time_for_bed, days_stayed, 
    PostOp_RightEye_SnellenChartResult, PostOp_RightEye_IOP, PostOp_RightEye_LensOpacity, 
    PostOp_RightEye_PupilReactionTime, PostOp_LeftEye_SnellenChartResult, PostOp_LeftEye_IOP, 
    PostOp_LeftEye_LensOpacity, PostOp_LeftEye_PupilReactionTime, blood_pressure
) VALUES
	
(55, 2, 55, '13:00:00', 5, 5, '2024-07-03', 'Follow-up after discharge', '2024-07-03 12:30:00', '2024-07-03 13:00:00', '2024-07-03 13:30:00', '2024-07-03 14:00:00', NULL, 'Outpatient', NULL, '20/25', '20/20', 16.50, 16.00, 'Clear', 'Clear', 0.30, 0.30, 116.00, '20/20', '20/20', 16.00, 16.00, 'Clear', 'Clear', 0.30, 0.30, 115.00, 'Eyedrops', '2024-07-17', 'OCT');




INSERT INTO Medical_History (historyid, patientid, appointmentid, appointmenttime, symptomid, treatmentid, diagnosisdate, notes, registered_time, doctor_visited_time, treatment_time, counseling_time, waiting_time_for_bed, patient_type, days_stayed, righteye_snellenchartresult, lefteye_snellenchartresult, righteye_iop, lefteye_iop, righteye_lensopacity, lefteye_lensopacity, righteye_pupilreactiontime, lefteye_pupilreactiontime, blood_pressure, operatedeye, postop_righteye_snellenchartresult, postop_lefteye_snellenchartresult, postop_righteye_iop, postop_lefteye_iop, postop_righteye_lensopacity, postop_lefteye_lensopacity, postop_righteye_pupilreactiontime, postop_lefteye_pupilreactiontime, postop_blood_pressure, medications, nextvisitdate, scanstobetaken)
VALUES (55, 2, 55, '14:00:00', 5, 5, '2024-07-03', 'Follow-up after discharge', '2024-07-03 12:30', '2024-07-03 13:00', '2024-07-03 13:30', '2024-07-03 14:00', NULL, 'Outpatient', NULL, '20/25', '20/20', 16.5, 16, 'Clear', 'Mild', 0.3, 0.3, 116, 'LEFT EYE', '6/15', '6/96', 16, 16, 'Clear', 'Clear', 0.3, 0.3, 115, 'Eyedrops', '2024-07-17', 'OCT');





-- Insert into Appointments
INSERT INTO Appointments (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentTime, Status, NurseID, Reason, Patient_status) VALUES
-- July 1 (New patients)

(56, 2, 5, '2024-07-04', '13:00:00', 'Completed', 2, 'Follow-up', 'Returning');


INSERT INTO Medical_History (historyid, patientid, appointmentid, appointmenttime, symptomid, treatmentid, diagnosisdate, notes, registered_time, doctor_visited_time, treatment_time, counseling_time, waiting_time_for_bed, patient_type, days_stayed, righteye_snellenchartresult, lefteye_snellenchartresult, righteye_iop, lefteye_iop, righteye_lensopacity, lefteye_lensopacity, righteye_pupilreactiontime, lefteye_pupilreactiontime, blood_pressure, operatedeye, postop_righteye_snellenchartresult, postop_lefteye_snellenchartresult, postop_righteye_iop, postop_lefteye_iop, postop_righteye_lensopacity, postop_lefteye_lensopacity, postop_righteye_pupilreactiontime, postop_lefteye_pupilreactiontime, postop_blood_pressure, medications, nextvisitdate, scanstobetaken)
VALUES (56, 2, 56, '13:00:00', 5, 5, '2024-07-04', 'Follow-up after discharge', '2024-07-04 12:30', '2024-07-04 13:00', '2024-07-04 13:30', '2024-07-04 14:00', NULL, 'Inpatient', NULL, '6/6', '6/9', 15.5, 17, 'Clear', 'Clear', 0.2, 0.3, 116, 'RIGHT EYE', '6/6', '20/20', 16, 16, 'Clear', 'Clear', 0.3, 0.3, 115, 'Eyedrops', '2024-07-26', 'OCT');

