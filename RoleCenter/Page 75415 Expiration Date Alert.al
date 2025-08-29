// page 75415 "Expiration Date Alert"  Move to Other Extension
// {
//     Caption = 'Expiration Date Alert';
//     PageType = CardPart;
//     RefreshOnActivate = true;
//     ShowFilter = false;

//     layout
//     {
//         area(Content)
//         {
//             cuegroup("Expiration Date Alert")
//             {
//                 ShowCaption = false;

//                 field(OpenQCRCforILE_gInt; OpenQCRCforILE_gInt)
//                 {
//                     ApplicationArea = Basic, Suite;
//                     ToolTip = 'Specifies the Count of the Due Expiration Date of Material.';
//                     Caption = 'Due Expiration Date of Material';

//                     trigger OnDrillDown()
//                     var
//                         ItemLedgerEntry_lPage: Page "Due Expiration Date of Mat";
//                         ItemLedgerEntry_lRec: Record "Item Ledger Entry";
//                     begin
//                         QCSetup_gRec.Get();
//                         if QCSetup_gRec.IsEmpty then
//                             exit;
//                         WorkDate_gDte := WorkDate();
//                         //WorkDate_gDte := 20240101D;
//                         calculateDate_gVDte := ((CALCDATE('+' + Format(QCSetup_gRec."Expiration Due Alert"), WorkDate_gDte)));
//                         Clear(ItemLedgerEntry_lPage);
//                         ItemLedgerEntry_lRec.SetRange(Open, True);
//                         ItemLedgerEntry_lRec.Setfilter("Remaining Quantity", '>%1', 0);
//                         ItemLedgerEntry_lRec.SetFilter("Expiration Date", '%1..%2', WorkDate_gDte, calculateDate_gVDte);
//                         ItemLedgerEntry_lPage.SetTableView(ItemLedgerEntry_lRec);
//                         ItemLedgerEntry_lPage.Editable(false);
//                         ItemLedgerEntry_lPage.RunModal();
//                     end;
//                 }
//             }

//         }
//     }

//     var

//         OpenQCRCforILE_gInt: Integer;
//         WorkDate_gDte: Date;
//         calculateDate_gVDte: Date;
//         QCSetup_gRec: Record "Quality Control Setup";



//     trigger OnOpenPage()
//     var
//         ItemLedgerEntry_lRec: Record "Item Ledger Entry";
//     begin
//         QCSetup_gRec.Get();
//         if QCSetup_gRec.IsEmpty then
//             exit;
//         WorkDate_gDte := WorkDate();
//         //WorkDate_gDte := 20240101D;
//         calculateDate_gVDte := ((CALCDATE('+' + Format(QCSetup_gRec."Expiration Due Alert"), WorkDate_gDte)));
//         ItemLedgerEntry_lRec.Reset();
//         ItemLedgerEntry_lRec.SetRange(Open, True);
//         ItemLedgerEntry_lRec.Setfilter("Remaining Quantity", '>%1', 0);
//         ItemLedgerEntry_lRec.SetRange("Location QC Category", false);
//         ItemLedgerEntry_lRec.SetFilter("Expiration Date", '%1..%2', WorkDate_gDte, calculateDate_gVDte);
//         if ItemLedgerEntry_lRec.FindSet() then
//             OpenQCRCforILE_gInt := ItemLedgerEntry_lRec.Count;
//     end;

// }
