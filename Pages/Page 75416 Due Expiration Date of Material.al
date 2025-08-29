// page 75416 "Due Expiration Date of Mat"//T12113-ABA-N  Move to Other Extension
// {
//     ApplicationArea = All;
//     Caption = 'Due Expiration Date of Material';
//     PageType = List;
//     SourceTable = "Item Ledger Entry";
//     SourceTableView = WHERE(Open = const(true), "Remaining Quantity" = filter(> 0),
//                             "Location Code" = filter(<> ''),
//                             "Location QC Category" = const(false));
//     UsageCategory = Lists;

//     layout
//     {
//         area(Content)
//         {
//             repeater(General)
//             {
//                 // field("Posting Date"; Rec."Posting Date")
//                 // {
//                 //     ApplicationArea = All;
//                 //     ToolTip = 'Specifies the entry''s posting date.';
//                 //     Editable = false;
//                 // }
//                 // field("Entry Type"; Rec."Entry Type")
//                 // {
//                 //     ApplicationArea = All;
//                 //     ToolTip = 'Specifies which type of transaction that the entry is created from.';
//                 // }
//                 // field("Order Type"; Rec."Order Type")
//                 // {
//                 //     ApplicationArea = All;
//                 //     ToolTip = 'Specifies which type of order that the entry was created in.';
//                 // }
//                 // field("Document Type"; Rec."Document Type")
//                 // {
//                 //     ApplicationArea = All;
//                 //     ToolTip = 'Specifies what type of document was posted to create the item ledger entry.';
//                 // }
//                 // field("Document No."; Rec."Document No.")
//                 // {
//                 //     ApplicationArea = All;
//                 //     ToolTip = 'Specifies the document number on the entry. The document is the voucher that the entry was based on, for example, a receipt.';
//                 // }
//                 field("Item No."; Rec."Item No.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the number of the item in the entry.';
//                 }


//                 field(Description; Rec.Description)
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies a description of the entry.';
//                 }
//                 field(ItemNo2_gCde; ItemNo2_gCde)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Item No.2';

//                 }
//                 field("Location Code"; Rec."Location Code")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the code for the location that the entry is linked to.';
//                 }
//                 field("Lot No."; Rec."Lot No.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies a lot number if the posted item carries such a number.';
//                 }
//                 field("Expiration Date"; Rec."Expiration Date")
//                 {
//                     ToolTip = 'Specifies the last date that the item on the line can be used.';
//                 }

//                 field(Quantity; Rec.Quantity)
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the number of units of the item in the item entry.';
//                 }
//                 field("Remaining Quantity"; Rec."Remaining Quantity")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies the quantity in the Quantity field that remains to be processed.';
//                 }
//                 field("Reserved Quantity"; Rec."Reserved Quantity")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specifies how many units of the item on the line have been reserved.';
//                 }
//             }

//         }


//     }
//     actions
//     {
//         area(Processing)
//         {
//             action("&Create QC Receipt")
//             {
//                 ApplicationArea = Basic;
//                 Caption = '&Create QC Receipt';

//                 trigger OnAction()
//                 begin
//                     QCIle_gCdu.CreateQCRcpt_gFnc(Rec, true);
//                 end;
//             }
//         }

//     }
//     var
//         QCIle_gCdu: Codeunit "Quality Control Retest";
//         ItemNo2_gCde: Code[20];

//         trigger OnOpenPage()
//         var
//             myInt: Integer;
//         begin

//         end;
//         trigger OnAfterGetCurrRecord()
//         var
//             myInt: Integer;
//         begin

//         end;
//         trigger OnAfterGetRecord()
//         var
//             myInt: Integer;
//         begin

//         end;

//  procedure ItemNo2_gFnc()
//  var
//  ILE_lrec:Record "Item Ledger Entry";
//  begin 
//     // if ILE_lrec.Get(rec."Entry No.") then 
//     // ItemNo2_gCde := ILE_lrec.item

//  end;

// }



