// pageextension 75400 MyExtension456 extends Reservation
// {
//     layout
//     {
//         // Add changes to page layout here
//     }

//     actions
//     {
//         modify("Reserve from Current Line")
//         {
//             trigger OnBeforeAction()
//             var
//                 myInt: Integer;
//             begin
//                 myInt += 1;
//             end;
//         }
//     }
//     trigger OnOpenPage()
//     var
//         myInt: Integer;
//     begin
//         Message('Debug Start');
//     end;

//     var
//         myInt: Integer;
// }