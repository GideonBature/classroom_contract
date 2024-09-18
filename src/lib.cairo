// #[starknet::interface]
// trait IHelloStarknet<TContractState> {
//     fn increase_balance(ref self: TContractState, amount: felt252);
//     fn get_balance(self: @TContractState) -> felt252;
// }

// #[starknet::contract]
// mod HelloStarknet {
//     #[storage]
//     struct Storage {
//         balance: felt252,
//     }

//     #[external(v0)]
//     impl HelloStarknetImpl of super::IHelloStarknet<ContractState> {
//         fn increase_balance(ref self: ContractState, amount: felt252) {
//             assert(amount != 0, 'Amount cannot be 0');
//             self.balance.write(self.balance.read() + amount);
//         }

//         fn get_balance(self: @ContractState) -> felt252 {
//             self.balance.read()
//         }
//     }
// }

// CLASSROOM CONTRACT WILL HAVE THE FOLLOWING
// add student
// update grade
// get students
#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct Student {
    // student_id: felt252,
    name: felt252,
    grade: u8,
}

#[starknet::interface]
pub trait IClassroom<TContractState> {
    fn add_student(ref self: TContractState, student_id: felt252, name: felt252, grade: u8);
    fn update_grade(ref self: TContractState, student_id: felt252, grade: u8);
    fn get_student(self: @TContractState, student_id: felt252) -> Student;
}

#[starknet::contract]
pub mod Classroom {
    ///use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use super::{Student};
    //use core::starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};
    //use core::starknet::{ContractAddress, get_caller_address};

    use core::starknet::{ContractAddress, get_caller_address, storage::{StoragePointerReadAccess, StoragePointerWriteAccess, Map, StorageMapReadAccess, StorageMapWriteAccess}};

    #[storage]
    struct Storage {
        students: Map<felt252, Student>, // map student_id => student Struct
        teacher_address: ContractAddress,
    }


    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        StudentAdded: StudentAdded,
        StudentGradeUpdated: StudentGradeUpdated,
    }

    #[derive(Drop, starknet::Event)]
    struct StudentAdded {
        name: felt252,
        student_id: felt252,
        grade: u8,
    }

    #[derive(Drop, starknet::Event)]
    struct StudentGradeUpdated {
        name: felt252,
        student_id: felt252,
        grade: u8,
    }

    #[constructor]
    fn constructor(ref self: ContractState, teacher_address: ContractAddress) {
        self.teacher_address.write(teacher_address);
    }

    #[abi(embed_v0)]
    impl ClassroomImpl of super::IClassroom<ContractState> {
        fn add_student(ref self: ContractState, student_id: felt252, name: felt252, grade: u8) {
            let teacher_address = self.teacher_address.read();

            assert(get_caller_address() == teacher_address, 'Only Teacher can add students');

            let student = Student { name: name, grade: grade, };

            self.students.write(student_id, student);

            self.emit(StudentAdded { name, student_id, grade, })
        }

        fn update_grade(ref self: ContractState, student_id: felt252, grade: u8) {
            let teacher_address = self.teacher_address.read();

            assert(get_caller_address() == teacher_address, 'Cannot update student records');
            let mut student = self.students.read(student_id);

            student.grade = grade;

            self.students.write(student_id, student);

            self.emit(StudentGradeUpdated { name: student.name, student_id, grade, })
        }

        fn get_student(self: @ContractState, student_id: felt252) -> Student {
            self.students.read(student_id)
        }
    }
}
