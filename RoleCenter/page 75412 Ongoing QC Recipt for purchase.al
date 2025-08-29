// page 75412 "Ongoing QC Recipt for purchase"  Move to Other Extension
// {
//     Caption = 'Ongoing QC';
//     PageType = CardPart;
//     RefreshOnActivate = true;
//     ShowFilter = false;

//     layout
//     {
//         area(Content)
//         {
//             cuegroup("Ongoing-QC")
//             {
//                 ShowCaption = false;
//                 field(OpenQCRCforPurchase_gInt; OpenQCRCforPurchase_gInt)
//                 {
//                     ApplicationArea = Basic, Suite;
//                     ToolTip = 'Specifies the Count of the Open Purchase QC Receipt';
//                     Caption = 'Purchase QC Receipt';

//                     trigger OnDrillDown()
//                     var
//                         QCRecptlist_lPage: Page "QC Rcpt. List";
//                         QcRecptHeader_lRec: Record "QC Rcpt. Header";
//                     begin
//                         Clear(QCRecptlist_lPage);
//                         QcRecptHeader_lRec.Reset();
//                         QcRecptHeader_lRec.SetRange("Document Type", QcRecptHeader_lRec."Document Type"::Purchase);
//                         QCRecptlist_lPage.SetTableView(QcRecptHeader_lRec);
//                         QCRecptlist_lPage.Editable(false);
//                         QCRecptlist_lPage.RunModal();
//                     end;
//                 }

//                 field(OpenQCProductiongInt; OpenQCRCforProduction_gInt)
//                 {
//                     ApplicationArea = Basic, Suite;
//                     ToolTip = 'Specifies the Count of the Open Production QC Receipt';
//                     Caption = 'Production QC Receipt';

//                     trigger OnDrillDown()
//                     var
//                         QCRecptlist_lPage: Page "QC Rcpt. List";
//                         QcRecptHeader_lRec: Record "QC Rcpt. Header";
//                     begin
//                         Clear(QCRecptlist_lPage);
//                         QcRecptHeader_lRec.Reset();
//                         QcRecptHeader_lRec.SetRange("Document Type", QcRecptHeader_lRec."Document Type"::Production);
//                         QCRecptlist_lPage.SetTableView(QcRecptHeader_lRec);
//                         QCRecptlist_lPage.Editable(false);
//                         QCRecptlist_lPage.RunModal();
//                     end;
//                 }
//                 field(OpenQCRCforSR_gInt; OpenQCRCforSR_gInt)
//                 {
//                     ApplicationArea = Basic, Suite;
//                     ToolTip = 'Specifies the Count of the Open Sales Return QC Receipt';
//                     Caption = 'Sales Return QC Receipt';

//                     trigger OnDrillDown()
//                     var
//                         QCRecptlist_lPage: Page "QC Rcpt. List";
//                         QcRecptHeader_lRec: Record "QC Rcpt. Header";
//                     begin
//                         Clear(QCRecptlist_lPage);
//                         QcRecptHeader_lRec.Reset();
//                         QcRecptHeader_lRec.SetRange("Document Type", QcRecptHeader_lRec."Document Type"::"Sales Return");
//                         QCRecptlist_lPage.SetTableView(QcRecptHeader_lRec);
//                         QCRecptlist_lPage.Editable(false);
//                         QCRecptlist_lPage.RunModal();
//                     end;
//                 }
//                 field(OpenQCRCforSO_gInt; OpenQCRCforSO_gInt)
//                 {
//                     ApplicationArea = Basic, Suite;
//                     ToolTip = 'Specifies the Count of the Open Sales Order QC Receipt';
//                     Caption = 'Sales Order QC Receipt';

//                     trigger OnDrillDown()
//                     var
//                         QCRecptlist_lPage: Page "QC Rcpt. List";
//                         QcRecptHeader_lRec: Record "QC Rcpt. Header";
//                     begin
//                         Clear(QCRecptlist_lPage);
//                         QcRecptHeader_lRec.Reset();
//                         QcRecptHeader_lRec.SetRange("Document Type", QcRecptHeader_lRec."Document Type"::"Sales Order");
//                         QCRecptlist_lPage.SetTableView(QcRecptHeader_lRec);
//                         QCRecptlist_lPage.Editable(false);
//                         QCRecptlist_lPage.RunModal();
//                     end;
//                 }

//                 field(OpenQCRCforTO_gInt; OpenQCRCforTO_gInt)
//                 {
//                     ApplicationArea = Basic, Suite;
//                     ToolTip = 'Specifies the Count of the Open Transfer Receipt QC Receipt';
//                     Caption = 'Transfer Receipt QC Receipt';

//                     trigger OnDrillDown()
//                     var
//                         QCRecptlist_lPage: Page "QC Rcpt. List";
//                         QcRecptHeader_lRec: Record "QC Rcpt. Header";
//                     begin
//                         Clear(QCRecptlist_lPage);
//                         QcRecptHeader_lRec.Reset();
//                         QcRecptHeader_lRec.SetRange("Document Type", QcRecptHeader_lRec."Document Type"::"Transfer Receipt");
//                         QCRecptlist_lPage.SetTableView(QcRecptHeader_lRec);
//                         QCRecptlist_lPage.Editable(false);
//                         QCRecptlist_lPage.RunModal();
//                     end;
//                 }
//                 field(OpenQCRCforILE_gInt; OpenQCRCforILE_gInt)
//                 {
//                     ApplicationArea = Basic, Suite;
//                     ToolTip = 'Specifies the Count of the Open Retest QC Receipt.';
//                     Caption = 'Retest QC Receipt';

//                     trigger OnDrillDown()
//                     var
//                         QCRecptlist_lPage: Page "QC Rcpt. List";
//                         QcRecptHeader_lRec: Record "QC Rcpt. Header";
//                     begin
//                         Clear(QCRecptlist_lPage);
//                         QcRecptHeader_lRec.Reset();
//                         QcRecptHeader_lRec.SetRange("Document Type", QcRecptHeader_lRec."Document Type"::Ile);
//                         QCRecptlist_lPage.SetTableView(QcRecptHeader_lRec);
//                         QCRecptlist_lPage.Editable(false);
//                         QCRecptlist_lPage.RunModal();
//                     end;
//                 }
//             }

//         }
//     }

//     var
//         OpenQCRCforPurchase_gInt: Integer;
//         OpenQCRCforProduction_gInt: Integer;
//         OpenQCRCforSR_gInt: Integer;
//         OpenQCRCforTO_gInt: Integer;

//         OpenQCRCforSO_gInt: Integer;
//         OpenQCRCforILE_gInt: Integer;


//     trigger OnOpenPage()
//     var
//         QcRctheader_lRec: Record "QC Rcpt. Header";
//     begin
//         QcRctheader_lRec.Reset();
//         QcRctheader_lRec.SetRange("Document Type", QcRctheader_lRec."Document Type"::Purchase);
//         if QcRctheader_lRec.FindSet() then
//             OpenQCRCforPurchase_gInt := QcRctheader_lRec.Count;

//         QcRctheader_lRec.Reset();
//         QcRctheader_lRec.SetRange("Document Type", QcRctheader_lRec."Document Type"::Production);
//         if QcRctheader_lRec.FindSet() then
//             OpenQCRCforProduction_gInt := QcRctheader_lRec.Count;

//         QcRctheader_lRec.Reset();
//         QcRctheader_lRec.SetRange("Document Type", QcRctheader_lRec."Document Type"::"Sales Return");
//         if QcRctheader_lRec.FindSet() then
//             OpenQCRCforSR_gInt := QcRctheader_lRec.Count;

//         QcRctheader_lRec.Reset();
//         QcRctheader_lRec.SetRange("Document Type", QcRctheader_lRec."Document Type"::"Transfer Receipt");
//         if QcRctheader_lRec.FindSet() then
//             OpenQCRCforTO_gInt := QcRctheader_lRec.Count;

//         QcRctheader_lRec.Reset();
//         QcRctheader_lRec.SetRange("Document Type", QcRctheader_lRec."Document Type"::"Sales Order");
//         if QcRctheader_lRec.FindSet() then
//             OpenQCRCforSO_gInt := QcRctheader_lRec.Count;

//         QcRctheader_lRec.Reset();
//         QcRctheader_lRec.SetRange("Document Type", QcRctheader_lRec."Document Type"::Ile);
//         if QcRctheader_lRec.FindSet() then
//             OpenQCRCforILE_gInt := QcRctheader_lRec.Count;
//     end;

// }
