-- Patients
CREATE TABLE Patients (
    PatientID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    BirthDate DATE NOT NULL,
    Street VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(10),
    InsuranceInfo VARCHAR(100)
);

-- Phones for Patients (multi-valued attribute)
CREATE TABLE PatientPhones (
    PatientID INT,
    Phone VARCHAR(20),
    PRIMARY KEY (PatientID, Phone),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

-- Doctors
CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL
);

-- Doctor Specializations (multi-valued attribute)
CREATE TABLE DoctorSpecializations (
    DoctorID INT,
    Specialization VARCHAR(50),
    PRIMARY KEY (DoctorID, Specialization),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

-- Departments
CREATE TABLE Departments (
    DeptCode INT PRIMARY KEY,
    DeptName VARCHAR(100) NOT NULL,
    Location VARCHAR(100)
);

-- Hospital Rooms (weak entity, depends on Department)
CREATE TABLE HospitalRooms (
    DeptCode INT,
    RoomNumber INT,
    PRIMARY KEY (DeptCode, RoomNumber),
    FOREIGN KEY (DeptCode) REFERENCES Departments(DeptCode)
);

-- Appointments
CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY,
    PatientID INT,
    DoctorID INT,
    AppointmentDate TIMESTAMP NOT NULL,
    Purpose VARCHAR(200),
    Notes TEXT,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

-- Prescriptions
CREATE TABLE Prescriptions (
    PrescriptionID INT PRIMARY KEY,
    PatientID INT,
    DoctorID INT,
    Medication VARCHAR(100),
    Dosage VARCHAR(50),
    Instructions TEXT,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);