// page 75417 "Posted QC Recipt for Purchase"   Move to Other Extension
// {
//     Caption = 'Posted QC';
//     PageType = CardPart;
//     RefreshOnActivate = true;
//     ShowFilter = false;

//     layout
//     {
//         area(Content)
//         {
//             cuegroup("Posted -QC")
//             {
//                 ShowCaption = false;
//                 field(OpenQCRCforPurchase_gInt; PostedQCRCforPurchase_gInt)
//                 {
//                     ApplicationArea = Basic, Suite;
//                     ToolTip = 'Specifies the Count of the Posted Purchase QC Receipt';
//                     Caption = 'Purchase QC Receipt';

//                     trigger OnDrillDown()
//                     var
//                         QCRecptlist_lPage: Page "Posted QC Rcpt. List";
//                         QcRecptHeader_lRec: Record "Posted QC Rcpt. Header";
//                     begin
//                         Clear(QCRecptlist_lPage);
//                         QcRecptHeader_lRec.Reset();
//                         QcRecptHeader_lRec.SetRange("Document Type", QcRecptHeader_lRec."Document Type"::Purchase);
//                         QCRecptlist_lPage.SetTableView(QcRecptHeader_lRec);
//                         QCRecptlist_lPage.Editable(false);
//                         QCRecptlist_lPage.RunModal();
//                     end;
//                 }
//                 field(OpenQCRCforPro_gInt; PostedQCRCforPro_gInt)
//                 {
//                     ApplicationArea = Basic, Suite;
//                     ToolTip = 'Specifies the Count of the Posted Production QC Receipt';
//                     Caption = 'Production QC Receipt';

//                     trigger OnDrillDown()
//                     var
//                         QCRecptlist_lPage: Page "Posted QC Rcpt. List";
//                         QcRecptHeader_lRec: Record "Posted QC Rcpt. Header";
//                     begin
//                         Clear(QCRecptlist_lPage);
//                         QcRecptHeader_lRec.Reset();
//                         QcRecptHeader_lRec.SetRange("Document Type", QcRecptHeader_lRec."Document Type"::Production);
//                         QCRecptlist_lPage.SetTableView(QcRecptHeader_lRec);
//                         QCRecptlist_lPage.Editable(false);
//                         QCRecptlist_lPage.RunModal();
//                     end;
//                 }
//                 field(OpenQCRCforSR_gInt; PostedQCRCforSR_gInt)
//                 {
//                     ApplicationArea = Basic, Suite;
//                     ToolTip = 'Specifies the Count of the Posted Sales Return QC Receipt';
//                     Caption = 'Sales Return QC Receipt';

//                     trigger OnDrillDown()
//                     var
//                         QCRecptlist_lPage: Page "Posted QC Rcpt. List";
//                         QcRecptHeader_lRec: Record "Posted QC Rcpt. Header";
//                     begin
//                         Clear(QCRecptlist_lPage);
//                         QcRecptHeader_lRec.Reset();
//                         QcRecptHeader_lRec.SetRange("Document Type", QcRecptHeader_lRec."Document Type"::"Sales Return");
//                         QCRecptlist_lPage.SetTableView(QcRecptHeader_lRec);
//                         QCRecptlist_lPage.Editable(false);
//                         QCRecptlist_lPage.RunModal();
//                     end;
//                 }
//                 field(OpenQCRCforSo_gInt; PostedQCRCforSo_gInt)
//                 {
//                     ApplicationArea = Basic, Suite;
//                     ToolTip = 'Specifies the Count of the Posted Sales Order QC Receipt';
//                     Caption = 'Sales Order QC Receipt';

//                     trigger OnDrillDown()
//                     var
//                         QCRecptlist_lPage: Page "Posted QC Rcpt. List";
//                         QcRecptHeader_lRec: Record "Posted QC Rcpt. Header";
//                     begin
//                         Clear(QCRecptlist_lPage);
//                         QcRecptHeader_lRec.Reset();
//                         QcRecptHeader_lRec.SetRange("Document Type", QcRecptHeader_lRec."Document Type"::"Sales Order");
//                         QCRecptlist_lPage.SetTableView(QcRecptHeader_lRec);
//                         QCRecptlist_lPage.Editable(false);
//                         QCRecptlist_lPage.RunModal();
//                     end;
//                 }
//                 field(OpenQCRCforTR_gInt; PostedQCRCforTR_gInt)
//                 {
//                     ApplicationArea = Basic, Suite;
//                     ToolTip = 'Specifies the Count of the Posted Transfer Receipt QC Receipt';
//                     Caption = 'Transfer Receipt QC Receipt';

//                     trigger OnDrillDown()
//                     var
//                         QCRecptlist_lPage: Page "Posted QC Rcpt. List";
//                         QcRecptHeader_lRec: Record "Posted QC Rcpt. Header";
//                     begin
//                         Clear(QCRecptlist_lPage);
//                         QcRecptHeader_lRec.Reset();
//                         QcRecptHeader_lRec.SetRange("Document Type", QcRecptHeader_lRec."Document Type"::"Transfer Receipt");
//                         QCRecptlist_lPage.SetTableView(QcRecptHeader_lRec);
//                         QCRecptlist_lPage.Editable(false);
//                         QCRecptlist_lPage.RunModal();
//                     end;
//                 }


//             }
//         }
//     }


//     var
//         PostedQCRCforPurchase_gInt: Integer;
//         PostedQCRCforSo_gInt: Integer;
//         PostedQCRCforTR_gInt: Integer;
//         PostedQCRCforPro_gInt: Integer;
//         PostedQCRCforSR_gInt: Integer;
//         PostedQCRCforILE_gInt: Integer;

//     trigger OnOpenPage()
//     var
//         QcRctheader_lRec: Record "Posted QC Rcpt. Header";

//     begin
//         QcRctheader_lRec.Reset();
//         QcRctheader_lRec.SetRange("Document Type", QcRctheader_lRec."Document Type"::Purchase);
//         if QcRctheader_lRec.FindSet() then
//             PostedQCRCforPurchase_gInt := QcRctheader_lRec.Count;

//         QcRctheader_lRec.Reset();
//         QcRctheader_lRec.SetRange("Document Type", QcRctheader_lRec."Document Type"::"Sales Order");
//         if QcRctheader_lRec.FindSet() then
//             PostedQCRCforSo_gInt := QcRctheader_lRec.Count;

//         QcRctheader_lRec.Reset();
//         QcRctheader_lRec.SetRange("Document Type", QcRctheader_lRec."Document Type"::"Transfer Receipt");
//         if QcRctheader_lRec.FindSet() then
//             PostedQCRCforTR_gInt := QcRctheader_lRec.Count;

//         QcRctheader_lRec.Reset();
//         QcRctheader_lRec.SetRange("Document Type", QcRctheader_lRec."Document Type"::Production);
//         if QcRctheader_lRec.FindSet() then
//             PostedQCRCforPro_gInt := QcRctheader_lRec.Count;

//         QcRctheader_lRec.Reset();
//         QcRctheader_lRec.SetRange("Document Type", QcRctheader_lRec."Document Type"::"Sales Return");
//         if QcRctheader_lRec.FindSet() then
//             PostedQCRCforSR_gInt := QcRctheader_lRec.Count;

//     end;

//     // trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
//     // var
//     //     QcRctheader_lRec: Record "Posted QC Rcpt. Header";

//     // begin
//     //     QcRctheader_lRec.Reset();
//     //     QcRctheader_lRec.SetRange("Document Type", QcRctheader_lRec."Document Type"::Purchase);
//     //     if QcRctheader_lRec.FindSet() then
//     //         PostedQCRCforPurchase_gInt := QcRctheader_lRec.Count;

//     //     QcRctheader_lRec.Reset();
//     //     QcRctheader_lRec.SetRange("Document Type", QcRctheader_lRec."Document Type"::"Sales Order");
//     //     if QcRctheader_lRec.FindSet() then
//     //         PostedQCRCforSo_gInt := QcRctheader_lRec.Count;

//     //     QcRctheader_lRec.Reset();
//     //     QcRctheader_lRec.SetRange("Document Type", QcRctheader_lRec."Document Type"::"Transfer Receipt");
//     //     if QcRctheader_lRec.FindSet() then
//     //         PostedQCRCforTR_gInt := QcRctheader_lRec.Count;

//     //     QcRctheader_lRec.Reset();
//     //     QcRctheader_lRec.SetRange("Document Type", QcRctheader_lRec."Document Type"::Production);
//     //     if QcRctheader_lRec.FindSet() then
//     //         PostedQCRCforPro_gInt := QcRctheader_lRec.Count;

//     //     QcRctheader_lRec.Reset();
//     //     QcRctheader_lRec.SetRange("Document Type", QcRctheader_lRec."Document Type"::"Sales Return");
//     //     if QcRctheader_lRec.FindSet() then
//     //         PostedQCRCforSR_gInt := QcRctheader_lRec.Count;
//     // end;

// }

