// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Hospital {
    address payable public owner;  
    address[] public admins; 

    struct Patient {
        uint patient_id;
        string name;
        uint age;
        string gender;
        uint height;
        uint weight;
        string med_problem;
        uint total_payment;
    }

    Patient[] private patients;
    uint public patient_count = 0;

    constructor() {
        owner = payable(msg.sender); 
        admins.push(owner); 
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can access!");
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "Only admins can access!");
        _;
    }

    function isAdmin(address _address) public view returns (bool) {
        for (uint i = 0; i < admins.length; i++) {
            if (admins[i] == _address) {
                return true;
            }
        }
        return false;
    }

    function addAdmin(address newAdmin) public onlyOwner {
        require(newAdmin != address(0), "Invalid address");
        require(!isAdmin(newAdmin), "Address is already an admin");
        admins.push(newAdmin);
    }

    function removeAdmin(address adminAddress) public onlyOwner {
        require(adminAddress != address(0), "Invalid address");
        require(isAdmin(adminAddress), "Address is not an admin");
        
        for (uint i = 0; i < admins.length; i++) {
            if (admins[i] == adminAddress) {
                admins[i] = admins[admins.length - 1];
                admins.pop();
                break;
            }
        }
    }


    function addPatient(string memory name, uint age, string memory gender, uint height, uint weight, string memory med_problem) public onlyAdmin {
        patient_count++;
        patients.push(Patient(patient_count, name, age, gender, height, weight, med_problem, 0));
    }

    function getPatientRecord(string memory _name, uint patientId) public view returns (uint, string memory, uint, string memory, uint, uint, string memory, uint) {
        require(patientId > 0 && patientId <= patient_count, "Invalid patient ID");
        require(keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked(patients[patientId].name)), "Invalid Credentials");
        Patient memory patientInfo = patients[patientId - 1];
        return ( patientInfo.patient_id, patientInfo.name, patientInfo.age, patientInfo.gender, patientInfo.height, patientInfo.weight, patientInfo.med_problem, patientInfo.total_payment);
    }

    function payToHospital(string memory _name, uint patientId) public payable {
        require(msg.value > 0, "The transfer amount can't be 0");
        require(patientId > 0 && patientId <= patient_count, "Invalid patient ID");
        require(keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked(patients[patientId].name)), "Invalid Credentials");
        owner.transfer(msg.value);
        patients[patientId - 1].total_payment += msg.value;
    }
}
