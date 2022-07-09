namespace com.training;

using {cuid, Country} from '@sap/cds/common';

entity Orders {
    key ClientEmail : String(65);
        FirstName   : String(30);
        LastName    : String(30);
        CreatedOn   : Date;
        Reviewed    : Boolean;
        Approved    : Boolean;
        Country     : Country;
        Status      : String(1);
};

// entity Course {
//     key ID      : UUID;
//         Student : Association to many StudentCourse
//                       on Student.Course = $self;
// };

// entity Student {
//     key ID     : UUID;
//         Course : Association to many StudentCourse
//                      on Course.Student = $self;
// };

// entity StudentCourse {
//     key ID      : UUID;
//         Course  : Association to Student;
//         Student : Association to Course;
// };


// type EmailAddresses_01 : many {
//     Kind  : String;
//     Email : String;
// };

// type EmailAddresses_02 {
//     kind  : String;
//     Email : String;
// };

// entity Email {
//     email_01  :      EmailAddresses_01;
//     email_02  : many EmailAddresses_02;
//     email_03  : many {
//         Kind  :      String;
//         Email :      String;
//     };
// };

// type Gender : String enum {
//     male;
//     female;
// };

// entity Order {
//     ClientGender : Gender;
//     Status       : Integer enum {
//         Submitted = 1;
//         Fulfiller = 2;
//         Shipped   = 3;
//         cancel    = -1;
//     };
//     Priority     : String @assert:range enum {
//         high;
//         madium;
//         low;
//     };
// };


// entity Car {
//     key ID                 : UUID;
//         Name               : String;
//         virtual Discount_1 : Decimal;
//         @Core.Computed : false
//         virtual Discount_2 : Decimal;
// }

// entity ParamProducts(pName : String)     as
//     select from Products {
//         Name,
//         Price,
//         Quantity
//     }
//     where
//         Name = : pName;

// entity ProjParamProducts(pName : String) as projection on Products {
//     *
// } where Name = : pName;
