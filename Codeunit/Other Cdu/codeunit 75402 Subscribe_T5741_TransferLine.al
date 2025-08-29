// codeunit 75402 Subscribe_T5741_TransferLine
// {
//     trigger OnRun()
//     begin

//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Transfer Line", OnAfterAssignItemValues, '', false, false)]
//     local procedure "Transfer Line_OnAfterAssignItemValues"(var TransferLine: Record "Transfer Line"; Item: Record Item; TransferHeader: Record "Transfer Header")
//     var
//         Location_lRec: Record Location;
//         QCSetup_lRec: Record "Quality Control Setup";
//         Item_lRec: Record Item;
//     begin
//         if (TransferLine."Item No." <> '') then begin

//             Item_lRec.Get(TransferLine."Item No.");
//             if Item_lRec."Allow QC in Transfer Receipt" then begin//T12113-ABA
//                 // if Item_lRec.CheckItemVendorCatelogueForQC(PurchaseHeader_lRec."Buy-from Vendor No.") then begin //T12115-N
//                 //     PurchaseHeader_lRec.TestField("Location Code");
//                 //     if Location_lRec.Get(PurchaseHeader_lRec."Location Code") then begin
//                 //         Location_lRec.TestField("QC Location");
//                 //         Rec.Validate("Location Code", Location_lRec."QC Location");
//                 //     end;
//                 // end;
//             end;
//         end;
//     end;

//     var
//         myInt: Integer;
// }