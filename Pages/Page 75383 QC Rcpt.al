Page 75383 "QC Rcpt."
{
    // ------------------------------------------------------------------------------------------------------------------------------
    // Intech-Systems-info@intech-systems.com
    // ------------------------------------------------------------------------------------------------------------------------------
    // ID                     DATE        AUTHOR
    // ------------------------------------------------------------------------------------------------------------------------------
    // I-C0009-1001310-04     27/08/12    Dipak Patel/Nilesh Gajjar
    //                        QC Module - Redesign Released.
    // I-C0009-1400405-01     05/08/14    Chintan Panchal
    //                        Upgrade to NAV 2013 R2
    // I-C0009-1001310-05     22/10/14    Chintan Panchal
    //                        QC Module - Redesign Released(Sales Return Receipt QC).
    //                        Added New Tab "QC Detail" and "Sales Return"
    // I-C0009-1001310-06     31/10/14    Chintan Panchal
    //                        QC Module - Redesign Released(Transfer Receipt QC).
    //                        Added New Tab "Transfer"
    // I-C0009-1001310-07     21/11/14    Chintan Panchal
    //                        Added code to Hide FastTab on the basis of QC Document Type
    // ------------------------------------------------------------------------------------------------------------------------------

    DelayedInsert = false;
    InsertAllowed = false;
    PageType = Card;
    Permissions = TableData "Item Ledger Entry" = rimd,
                  TableData "Purch. Rcpt. Line" = rimd;
    PopulateAllFields = false;
    PromotedActionCategories = 'New,Process,Report,Sample Qty.';
    SourceTable = "QC Rcpt. Header";
    Caption = 'QC Receipt';//T12971-N
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Visible = true;
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    NotBlank = true;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic;
                    Editable = "Item No.Editable";

                    trigger OnValidate()
                    begin
                        Rec.TestStatus_lFnc; //I-C0009-1001310-01 N
                    end;
                }
                field("Item Name"; Rec."Item Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Variant Description"; Rec."Variant Description")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Basic;
                    Editable = "Unit of MeasureEditable";

                    trigger OnValidate()
                    begin
                        Rec.TestStatus_lFnc; //I-C0009-1001310-01 NS
                    end;
                }
                field("Item Tracking"; Rec."Item Tracking")
                {
                    ApplicationArea = Basic;
                }
                field("QC Date"; Rec."QC Date")
                {
                    ApplicationArea = Basic;
                    Editable = ApproveEdit_gBln;//T12204-N
                }
                field("Receipt Date"; Rec."Receipt Date")
                {
                    ApplicationArea = Basic;
                    Editable = false;//T12204-N
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic;
                }
                field("Inspection Quantity"; Rec."Inspection Quantity")
                {
                    ApplicationArea = Basic;
                    Editable = "Inspection QuantityEditable";
                    Style = Strong;
                    StyleExpr = true;

                    trigger OnValidate()
                    begin
                        //I-C0009-1001310-01 NS
                        Rec.TestStatus_lFnc;

                        if (Rec."Inspection Quantity" < 0) then
                            Message('Inspection Qty. must be Positive');
                        //I-C0009-1001310-01 NE
                    end;
                }
                field("Sample Quantity"; Rec."Sample Quantity")
                {
                    ApplicationArea = Basic;
                }
                field("Quantity to Accept"; Rec."Quantity to Accept")
                {
                    ApplicationArea = Basic;
                    Editable = true;
                    Style = Favorable;
                    StyleExpr = true;
                }
                field("Qty to Accept with Deviation"; Rec."Qty to Accept with Deviation")
                {
                    ApplicationArea = Basic;
                    Style = Strong;
                    StyleExpr = true;
                }
                field("Quantity to Reject"; Rec."Quantity to Reject")
                {
                    ApplicationArea = Basic;
                    Editable = true;
                    Style = Unfavorable;
                    StyleExpr = true;
                }
                //T12113-NS
                field("Rejection Reason"; Rec."Rejection Reason")
                {
                    ApplicationArea = All;
                    Editable = RejectionEditable_gBln;
                    ToolTip = 'Specifies the value of the Rejection Reason field.', Comment = '%';
                }
                field("Rejection Reason Description"; Rec."Rejection Reason Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rejection Reason Description field.', Comment = '%';
                }
                //T12113-NE
                //T12204-ABA-NS
                field("Rework Reason"; Rec."Rework Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rework Reason field.', Comment = '%';
                    Editable = ReworkEdit_gBln;
                }
                field("Rework Reason Description"; Rec."Rework Reason Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rework Reason Description field.', Comment = '%';

                }
                //T12204-ABA-NE

                field("Quantity to Rework"; Rec."Quantity to Rework")
                {
                    ApplicationArea = Basic;
                    Style = StrongAccent;
                    StyleExpr = true;
                }

                field("Checked By"; Rec."Checked By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Approve; Rec.Approve)
                {
                    ApplicationArea = Basic;
                    //Editable = ApproveEdit_gBln;
                    Editable = false;
                    //T12113-NS
                    trigger OnValidate()
                    begin
                        if Rec.Approve then begin
                            if Rec."Item Tracking" = Rec."Item Tracking"::None then
                                Rec.CheckQCCheck_gfnc()
                            else
                                QCSetup_gRec.Get();
                            QCSetup_gRec.TestField("Enable QC Approval", false);
                            if Rec."Quantity to Reject" > 0 then
                                Error('You are not allowed approve the document no. %1. Please Follow the approval Process', Rec."No.");
                        end;
                        //T12113-NE
                    end;
                }
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Approval Status"; Rec."Approval Status")
                {
                    ApplicationArea = Basic;
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = Basic;
                    MultiLine = true;
                }
                field("Previous Posted QC No."; Rec."Previous Posted QC No.")
                {
                    ToolTip = 'Specifies the value of the Previous Posted QC No. field.', Comment = '%';
                }
                field("COA QC"; rec."COA QC")
                {
                    ApplicationArea = basic;
                }
                //T52538-NS
                field("QC Remarks"; Rec."QC Remarks")
                {
                    ToolTip = 'Specifies the value of the QC Remarks field.', Comment = '%';
                }
                //T52538-NE
                field("Total Test Cost"; Rec."Total Test Cost")
                {
                    Description = 'T53755';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Total Test Cost field.', Comment = '%';
                }


            }
            group("QC Detail")
            {
                Caption = 'QC Detail';
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Item Description 2"; Rec."Item Description 2")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }

                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Exp. Date"; Rec."Exp. Date")
                {
                    ApplicationArea = Basic;
                    // Editable = false;//T12204-N //T51170-N
                }
                field("Mfg. Date"; Rec."Mfg. Date")
                {
                    ApplicationArea = Basic;
                    // Editable = false;//T12204-N//T51170-N
                }
                field("No. of Container"; Rec."No. of Container")
                {
                    ApplicationArea = Basic;
                }
                field("QC Location"; Rec."QC Location")
                {
                    ApplicationArea = Basic;
                }
                field("QC Bin Code"; Rec."QC Bin Code")
                {
                    ApplicationArea = Basic;
                }
                field("Store Location Code"; Rec."Store Location Code")
                {
                    ApplicationArea = Basic;
                    Editable = EnableField_gBln;
                }
                field("Store Bin Code"; Rec."Store Bin Code")
                {
                    ApplicationArea = Basic;
                }
                field("Rejection Location"; Rec."Rejection Location")
                {
                    ApplicationArea = Basic;
                    Editable = EnableField_gBln;
                }
                field("Reject Bin Code"; Rec."Reject Bin Code")
                {
                    ApplicationArea = Basic;
                }
                field("Rework Location"; Rec."Rework Location")
                {
                    ApplicationArea = Basic;
                    Editable = EnableField_gBln;
                }
                field("Rework Bin Code"; Rec."Rework Bin Code")
                {
                    ApplicationArea = Basic;
                }
            }

            part("QC Subform"; "QC Rcpt. Subform")
            {
                SubPageLink = "No." = field("No.");
                SubPageView = sorting("No.", "Line No.")
                              order(ascending);
                ApplicationArea = all;
            }
            group("Sample Collection History")
            {
                Caption = 'Sample Collection History';
                Editable = ApproveEdit_gBln;//T12204-N
                field("Sample Qty."; Rec."Sample Quantity")
                {
                    ApplicationArea = Basic;
                    Caption = 'Sample Quantity';
                    Editable = false;
                }
                field("Sample Collector ID"; Rec."Sample Collector ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sample Collector ID field.', Comment = '%';
                }
                //T52538-OS
                // field("Date of Sample Collection"; Rec."Date of Sample Collection")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the value of the Date of Sample Collection field.', Comment = '%';
                // }
                //T52538-OE
                field("Sample Provider ID"; Rec."Sample Provider ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sample Provider ID field.', Comment = '%';
                }
                //T52538-NS
                field("Sample Date and Time"; Rec."Sample Date and Time")
                {
                    ToolTip = 'Specifies the value of the Sample Date and Time field.', Comment = '%';
                }
                //T52538-NE
            }
            group(Purchase)
            {
                Caption = 'Purchase';
                Visible = ShowPurchaseTab_gBln;
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PurchRcptHeader_lRec: Record "Purch. Rcpt. Header";
                    begin
                        LooupDocument_lFnc;
                    end;
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Vendor Shipment No."; Rec."Vendor Shipment No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Vendor Lot No."; Rec."Vendor Lot No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Caption = 'Lot No';//T12113-N
                }
            }
            //T12113-NB-NS
            //T12547-NS
            group("Pre-Receipt")
            {
                Caption = 'Pre-Receipt';
                Visible = ShowPreReceiptTab_gBln;
                field("Document Type for Pre-Receipt"; Rec."Document Type")
                {
                    ApplicationArea = Basic;
                }
                field("Document No for Pre-Receipt"; Rec."Document No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PurchRcptHeader_lRec: Record "Purch. Rcpt. Header";
                    begin
                        LooupDocument_lFnc;
                    end;
                }
                field("Document Line No. for Pre-Receipt"; Rec."Document Line No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Buy-from Vendor No. for Pre-Receipt"; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Buy-from Vendor Name for Pre-Receipt"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }

                field("Vendor Lot No. for Pre-Receipt"; Rec."Vendor Lot No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Caption = 'Lot No';
                }
            }
            //T12547-NE
            group("Sales Order")
            {
                Caption = 'Sales Order';
                Visible = ShowSalesTab_gBln;
                field("DocumentType"; Rec."Document Type")
                {
                    ApplicationArea = Basic;
                    Caption = 'Document Type';
                }
                field("DocumentNo."; Rec."Document No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LooupDocument_lFnc;
                    end;
                }
                field("DocumentLineNo."; Rec."Document Line No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Sell-to Customer No."; rec."Sell-to Customer No.")
                {
                    ApplicationArea = all;
                    Caption = 'Sell-to Customer No.';
                    Editable = false;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = Basic;
                    Caption = 'Sell-to Customer Name';
                    Editable = false;
                }
            }
            //T12113-NB-NE
            group(" Production")
            {
                Caption = ' Production';
                Visible = ShowProductionTab_gBln;
                field("Doc. Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic;
                    Caption = 'Document Type';
                }
                field("Doc. No."; Rec."Document No.")
                {
                    ApplicationArea = Basic;
                    Caption = 'Document No.';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        LooupDocument_lFnc;
                    end;
                }
                field("Doc. Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = Basic;
                    Caption = 'Document Line No.';
                    Editable = false;
                }
                field("Item Journal Template Name"; Rec."Item Journal Template Name")
                {
                    ApplicationArea = Basic;
                }
                field("Item General Batch Name"; Rec."Item General Batch Name")
                {
                    ApplicationArea = Basic;
                }
                field("Item Journal Line No."; Rec."Item Journal Line No.")
                {
                    ApplicationArea = Basic;
                }
                field("Center Type"; Rec."Center Type")
                {
                    ApplicationArea = Basic;
                    Caption = 'Center Type';
                    Editable = false;
                }
                field("Center No."; Rec."Center No.")
                {
                    ApplicationArea = Basic;
                    Caption = 'Center No.';
                    Editable = false;
                    Enabled = true;
                }
                field("Operation No."; Rec."Operation No.")
                {
                    ApplicationArea = Basic;
                    Caption = 'Operation No.';
                    Editable = false;
                }
                field("Operation Name"; Rec."Operation Name")
                {
                    ApplicationArea = Basic;
                }
                field("Vendor Lot No. Production"; Rec."Vendor Lot No.")
                {
                    ApplicationArea = Basic;
                    Caption = 'Lot No';//T12113-N
                }
            }
            group("Sales Return")
            {
                Caption = 'Sales Return';
                Visible = ShowSalesReturnTab_gBln;
                field("Doc. Type for Sales Return"; Rec."Document Type")
                {
                    ApplicationArea = Basic;
                }
                field("Doc. No. for Sales Return"; Rec."Document No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        LooupDocument_lFnc;
                    end;
                }
                field("Doc. Line No. for Sales Return"; Rec."Document Line No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Sell-to Customer No.1"; rec."Sell-to Customer No.")
                {
                    ApplicationArea = basic;
                    Editable = false;
                    Caption = 'Sell-to Customer No.';
                }
                field("Sell-to Customer Name1"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = Basic;
                    Caption = 'Sell-to Customer Name';
                    Editable = false;
                }


            }
            group(Transfer)
            {
                Caption = 'Transfer';
                Visible = ShowTransferTab_gBln;
                field("Doc. Type for Transfer"; Rec."Document Type")
                {
                    ApplicationArea = Basic;
                }
                field("Doc. No. for Transfer"; Rec."Document No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        LooupDocument_lFnc;
                    end;
                }
                field("Doc. Line No. for Transfer"; Rec."Document Line No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
            }
            // group(" Sample") //T12204-NS
            // {
            //     Caption = ' Sample';
            //     Visible = true;
            //     field("Party Type"; Rec."Party Type")
            //     {
            //         ApplicationArea = Basic;
            //         Editable = false;

            //         trigger OnValidate()
            //         begin
            //             Rec.TestStatus_lFnc; //I-C0009-1001310-01 N
            //         end;
            //     }
            //     field("Party No."; Rec."Party No.")
            //     {
            //         ApplicationArea = Basic;
            //         Editable = false;

            //         trigger OnValidate()
            //         begin
            //             Rec.TestStatus_lFnc; //I-C0009-1001310-01 N
            //         end;
            //     }
            //     field("Party Name"; Rec."Party Name")
            //     {
            //         ApplicationArea = Basic;
            //         Caption = 'Name';
            //         Editable = false;
            //     }
            //     field(Address; Rec.Address)
            //     {
            //         ApplicationArea = Basic;
            //         Editable = false;
            //     }
            //     field("Phone no."; Rec."Phone no.")
            //     {
            //         ApplicationArea = Basic;
            //         Editable = false;
            //     }
            //     field("Sample QC"; Rec."Sample QC")
            //     {
            //         ApplicationArea = Basic;
            //         Editable = false;

            //         trigger OnValidate()
            //         begin
            //             //I-C0009-1001310-01 NS
            //             if (Rec."Sample QC" = true) then begin
            //                 "Item No.Editable" := true;
            //                 "Inspection QuantityEditable" := true;
            //                 "Unit of MeasureEditable" := true;
            //                 "Decide MethodsVisible" := true;
            //             end else begin
            //                 "Item No.Editable" := false;
            //                 "Inspection QuantityEditable" := false;
            //                 "Unit of MeasureEditable" := false;
            //                 "Decide MethodsVisible" := false;
            //             end;
            //             //I-C0009-1001310-01 NE
            //         end;
            //     }
            // }//T12204-NE
            //T12113-ABA-NS
            group("Retest Group")
            {
                Caption = 'Retest';
                Visible = ShowRetesttab_gBln;
                field(Retest; Rec.Retest)
                {
                    ApplicationArea = Basic;
                }
                field("ILE No."; Rec."ILE No.")
                {
                    ApplicationArea = Basic;
                }

            }
            //T12113-ABA-NE
            group(History)
            {
                Caption = 'History';
                field("Inspection Qty."; Rec."Inspection Quantity")
                {
                    ApplicationArea = Basic;
                    Caption = 'Inspection Quantity';
                    Editable = false;
                }
                field("Remaining Qty."; Rec."Remaining Quantity")
                {
                    ApplicationArea = Basic;
                    Caption = 'Remaining Quantity';
                    Editable = false;
                }
                field("Previously Posted QC"; PastPostedQCRecipt_gInt)
                {
                    ApplicationArea = Basic;
                    AssistEdit = false;
                    Caption = 'Previously Posted QC';
                    DrillDown = true;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        //I-C0009-1001310-04-NS
                        if PastPostedQCRecipt_gInt > 0 then
                            Rec.OpenPreviouslyPostedQC_gFnc;
                        //I-C0009-1001310-04-NE
                    end;
                }
                field("Total Accepted Quantity"; Rec."Total Accepted Quantity")
                {
                    ApplicationArea = Basic;
                    Editable = false;

                    // trigger OnDrillDown()
                    // begin
                    //     if Rec."Total Accepted Quantity" > 0 then
                    //         Rec.OpenAccpItemLedgerEntries_gFnc;
                    // end;
                }
                field("Total Under Deviation Acc. Qty"; Rec."Total Under Deviation Acc. Qty")
                {
                    ApplicationArea = Basic;
                    Editable = false;

                    // trigger OnDrillDown()
                    // begin
                    //     if Rec."Total Under Deviation Acc. Qty" > 0 then
                    //         Rec.OpenAccpItemLedgerEntries_gFnc;
                    // end;
                }
                field("Total Rejected Quantity"; Rec."Total Rejected Quantity")
                {
                    ApplicationArea = Basic;
                    Editable = false;

                    // trigger OnDrillDown()
                    // begin
                    //     if Rec."Total Rejected Quantity" > 0 then
                    //         Rec.OpenRejeItemLedgerEntries_gFnc;
                    // end;
                }
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")//T12530-N
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(75382),
                              "No." = FIELD("No.");
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Qlty Receipt")
            {
                Caption = '&Qlty Receipt';
                action(Post)
                {
                    ApplicationArea = Basic;
                    Caption = 'Post';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    Visible = false;

                    trigger OnAction()
                    var
                        QCRcptHeader_lRec: Record "QC Rcpt. Header";
                    begin
                        Rec.CheckQCCheck_gfnc(); //T12113-N                        
                        Rec.PostQCRcpt_gFnc(true); //I-C0009-1001310-02 N  T13919-N
                        //I-C0009-1001310-04-NS
                        if QCRcptHeader_lRec.Get(Rec."No.") then
                            CurrPage.Update(false)
                        else
                            CurrPage.Close;
                        //I-C0009-1001310-04-NE
                    end;
                }
                action("Item Tracking for Purchase")
                {
                    ApplicationArea = Basic;
                    Caption = 'Item &Tracking';
                    Image = TaxPayment;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = not ViewProductionTracking_gBln;

                    trigger OnAction()
                    begin
                        Rec.ShowItemTrackingLines_gFnc; //I-C0009-1001310-02 N                       
                    end;
                }
                action("Item Tracking for Production")
                {
                    ApplicationArea = Basic;
                    Caption = 'Item &Tracking';
                    Image = ItemTrackingLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = ViewProductionTracking_gBln;

                    trigger OnAction()
                    var
                        ProductionQC_lCdu: Codeunit "Quality Control - Production";
                    begin
                        ProductionQC_lCdu.ItemTrackingLine_gFnc(Rec);
                    end;
                }
                action("View Source Document ")
                {
                    ApplicationArea = Basic;
                    Image = VendorPayment;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F8';

                    trigger OnAction()
                    begin
                        LooupDocument_lFnc;
                    end;
                }
            }
            group(Approval)
            {
                Caption = 'Approval';
                // group(ActionGroup33027964)
                // {
                //     Caption = 'Approval';
                //     Image = Departments;
                //  Visible = ApproveEdit_gBln;
                action("Send Approval Request")
                {
                    ApplicationArea = Basic;
                    Image = SendApprovalRequest;

                    trigger OnAction()
                    var
                        QCApprovalManagement_lCdu: Codeunit "QC Approval Management";
                    begin
                        //T12113- NS
                        Rec.CheckQCCheck_gfnc();

                        if not Rec.Approve then begin
                            QCSetup_gRec.Get();
                            if (QCSetup_gRec."Enable QC Approval") Then//T12113-C and (Rec."Quantity to Reject" > 0) then
                                                                       //T12113- NE
                                QCApprovalManagement_lCdu.SendForApproval_gFnc(Rec);    //TOApproval-N
                        end;
                    end;
                }
                action("Cancel Approval Re&quest")
                {
                    ApplicationArea = Basic;
                    Image = Cancel;

                    trigger OnAction()
                    var
                        QCApprovalManagement_lCdu: Codeunit "QC Approval Management";
                    begin
                        //T12113- NS
                        QCSetup_gRec.Get();
                        if (QCSetup_gRec."Enable QC Approval") then
                            //T12113- NE
                            QCApprovalManagement_lCdu.CancelApprovalRequest_gFnc(Rec);    //TOApproval-N
                    end;
                }
                action("Reopen Approval Entry")
                {
                    ApplicationArea = Basic;
                    Caption = 'Reopen Approval Entry';
                    Image = ReOpen;

                    trigger OnAction()
                    var
                        QCApprovalManagement_lCdu: Codeunit "QC Approval Management";
                    begin
                        //T12113- NS
                        if Rec."Approval Status" = Rec."Approval Status"::Approved then begin
                            QCSetup_gRec.Get();
                            if (QCSetup_gRec."Enable QC Approval") then
                                //T12113- NE
                                QCApprovalManagement_lCdu.ReOpenRequest_gFnc(Rec);    //TOApproval-N
                        end;
                    end;
                }
                action("Approval Entries")
                {
                    ApplicationArea = Basic;
                    Image = Approvals;
                    RunObject = Page "QC Approval All App. Entry";
                    RunPageLink = "Document No." = field("No.");
                    RunPageView = sorting(Type, "Entry No.");
                }
                //}
            }
        }
        area(processing)
        {
            //T12113-ABA-NS
            action("View Quality Orders")
            {
                ApplicationArea = Basic;
                Caption = '&View Quality Orders';
                Image = Order;
                RunObject = page "Quality Order";
                RunPageLink = "QC Receipt No" = field("No.");
                RunPageView = where("Quality Order" = filter(true));
                Visible = ViewQualityOrderApplicable_gBln;//T12479-N
                trigger OnAction()
                begin

                end;
            }
            action("View Finished Quality Orders")
            {
                ;
                ApplicationArea = Basic;
                Caption = '&View Finished Quality Orders';
                Image = Order;
                RunObject = page "Qulaity Finished Order";
                RunPageLink = "QC Receipt No" = field("No.");
                RunPageView = where("Quality Order" = filter(true));
                Visible = ViewQualityOrderApplicable_gBln;//T12479-N
                trigger OnAction()
                begin

                end;
            }
            //T12113-NB-NS
            action("View Source Document")
            {
                ApplicationArea = All;
                Caption = 'View Source Document';
                Image = View;
                trigger OnAction()
                var
                    SalesHeader_lRec: Record "Sales Header";
                    SalesOrder_lPag: page "Sales Order";
                begin
                    SalesHeader_lRec.Reset();
                    SalesHeader_lRec.SetRange("Document Type", SalesHeader_lRec."Document Type"::Order);
                    SalesHeader_lRec.SetRange("No.", rec."Document No.");
                    SalesOrder_lPag.SetTableView(SalesHeader_lRec);
                    SalesOrder_lPag.Run();
                end;
            }
            //T12113-NB-NE
            //T12113-ABA-NE
            action("Decide Methods")
            {
                ApplicationArea = Basic;
                Caption = '&Decide Methods';
                Image = GiroPlus;
                Promoted = true;
                PromotedCategory = Process;
                Visible = "Decide MethodsVisible";

                trigger OnAction()
                begin
                    if not (Rec.Approve = true) then begin
                        QCRcptLine1.Reset;
                        QCRcptLine1.SetRange("No.", Rec."No.");
                        if QCRcptLine1.Find('-') then begin
                            repeat
                                QCRcptLine1.Delete;
                            until QCRcptLine1.Next = 0;

                            Rec."Inspection Quantity" := 0;
                            Rec."Quantity to Accept" := 0;
                            Rec."Qty to Accept with Deviation" := 0;
                            Rec."Quantity to Reject" := 0;
                            Rec.Approve := false;
                            Rec.Modify;
                        end;

                        Item.Reset;
                        Item.SetRange("No.", Rec."Item No.");
                        Item.FindFirst;
                        if (Item."Allow QC in GRN") then begin//T12113-ABA
                            ItemSpecificHead.Reset;
                            ItemSpecificHead.SetRange("No.", Item."Item Specification Code");
                            if ItemSpecificHead.FindFirst then begin
                                if not (ItemSpecificHead.Status = ItemSpecificHead.Status::Certified) then
                                    ItemSpecificHead.FieldError(Status);
                                ItemSpecificLine.Reset;
                                ItemSpecificLine.SetRange("Item Specifiction Code", Item."Item Specification Code");
                                ItemSpecificLine.FindFirst;
                                repeat
                                    QCRcptLine1.Init;
                                    QCRcptLine1."No." := Rec."No.";
                                    QCRcptLine1."Line No." := ItemSpecificLine."Line No.";
                                    QCRcptLine1.Validate("Quality Parameter Code", ItemSpecificLine."Quality Parameter Code");
                                    QCRcptLine1.Type := ItemSpecificLine.Type;
                                    QCRcptLine1."Min.Value" := ItemSpecificLine."Min.Value";
                                    QCRcptLine1."Max.Value" := ItemSpecificLine."Max.Value";
                                    //T13827-NS
                                    QCRcptLine1."COA Min.Value" := ItemSpecificLine."COA Min.Value";
                                    QCRcptLine1."COA Max.Value" := ItemSpecificLine."COA Max.Value";
                                    //T13827-NE
                                    QCRcptLine1.Mandatory := ItemSpecificLine.Mandatory;
                                    QCRcptLine1.Method := ItemSpecificLine.Method;
                                    QCRcptLine1.Code := ItemSpecificLine."Document Code";
                                    QCRcptLine1.Insert;
                                until ItemSpecificLine.Next = 0;
                            end else
                                Error('Item Specification:%1 Code must be exist', ItemSpecificHead."No.");
                        end else
                            Error('QC is not Required for Item No.%1', Item."No.")
                    end else
                        Rec.FieldError(Approve);
                end;
            }
            //T51170-NS
            action("Update QC Receipt Parameters from QC Specification") //T51170-NS
            {
                ApplicationArea = Basic;
                Caption = '&Update QC Receipt Parameters from QC Specification';
                Image = Order;
                trigger OnAction()
                var
                    QCSpecificationLine_lRec: Record "QC Specification Line";
                    Item_lRec: Record Item;
                    QCRcptLine_lRec: Record "QC Rcpt. Line";
                    QCLineDetail_lRec: Record "QC Line Detail";
                    QCLineDetail2_lRec: Record "QC Line Detail";
                    Cnt_lInt: Integer;
                    UserSetuo_lRec: Record "User Setup";
                begin
                    UserSetuo_lRec.get(UserId);
                    UserSetuo_lRec.TestField("QC Line Modify Allowed");
                    if not Confirm('Do you want to Update QC Receipt Parameters from QC Specification.', False) then
                        exit;
                    QCRcptLine_lRec.reset;
                    QCRcptLine_lRec.SetRange("No.", rec."No.");
                    if QCRcptLine_lRec.FindFirst() then
                        QCRcptLine_lRec.Deleteall;

                    QCLineDetail_lRec.Reset();
                    QCLineDetail_lRec.SetRange("QC Rcpt No.", rec."No.");
                    if QCLineDetail_lRec.FindFirst() then
                        QCLineDetail_lRec.DeleteAll();

                    Item_lRec.get(rec."Item No.");
                    QCSpecificationLine_lRec.Reset;
                    QCSpecificationLine_lRec.SetRange("Item Specifiction Code", Item_lRec."Item Specification Code");
                    if QCSpecificationLine_lRec.FindSet() then begin
                        repeat
                            QCRcptLine_lRec.Required := true;//T12544-N
                            QCRcptLine_lRec.Print := QCSpecificationLine_lRec.Print;  //T13242-N 03-01-2025
                            QCRcptLine_lRec."No." := Rec."No.";
                            QCRcptLine_lRec."Line No." := QCSpecificationLine_lRec."Line No.";
                            QCRcptLine_lRec.Validate("Quality Parameter Code", QCSpecificationLine_lRec."Quality Parameter Code");
                            QCRcptLine_lRec.Validate("Unit of Measure Code", QCSpecificationLine_lRec."Unit of Measure Code");
                            QCRcptLine_lRec.Type := QCSpecificationLine_lRec.Type;
                            QCSpecificationLine_lRec.CalcFields(Method);
                            QCRcptLine_lRec.Method := QCSpecificationLine_lRec.Method;
                            QCRcptLine_lRec.Type := QCSpecificationLine_lRec.Type;
                            QCRcptLine_lRec."Min.Value" := QCSpecificationLine_lRec."Min.Value";
                            //T13827-NS
                            QCRcptLine_lRec."COA Min.Value" := QCSpecificationLine_lRec."COA Min.Value";
                            QCRcptLine_lRec."COA Max.Value" := QCSpecificationLine_lRec."COA Max.Value";
                            //T13827-NE    
                            //T51170-NS            
                            QCRcptLine_lRec."Rounding Precision" := QCSpecificationLine_lRec."Rounding Precision";//T51170-N
                            QCRcptLine_lRec."Show in COA" := QCSpecificationLine_lRec."Show in COA";
                            QCRcptLine_lRec."Default Value" := QCSpecificationLine_lRec."Default Value";
                            //T51170-NE
                            QCRcptLine_lRec."Decimal Places" := QCSpecificationLine_lRec."Decimal Places"; //T52614-N
                            QCRcptLine_lRec."Max.Value" := QCSpecificationLine_lRec."Max.Value";
                            QCRcptLine_lRec.Code := QCSpecificationLine_lRec."Document Code";
                            QCRcptLine_lRec.Mandatory := QCSpecificationLine_lRec.Mandatory;
                            QCRcptLine_lRec."Text Value" := QCSpecificationLine_lRec."Text Value";
                            //T12113-ABA-NS
                            QCRcptLine_lRec."Item Code" := QCSpecificationLine_lRec."Item Code";
                            QCRcptLine_lRec."Item Description" := QCSpecificationLine_lRec."Item Description";
                            //T12113-ABA-NE
                            //28042025-NS
                            QCRcptLine_lRec.Description := QCSpecificationLine_lRec.Description;
                            QCRcptLine_lRec."Method Description" := QCSpecificationLine_lRec."Method Description";
                            //28042025-NE
                            QCRcptLine_lRec.Insert;

                            if (Item_lRec."Entry for each Sample") and
                               (Rec."Item Tracking" <> Rec."item tracking"::"Lot and Serial No.") and
                               (rec."Item Tracking" <> rec."item tracking"::"Serial No.")
                            then begin
                                for Cnt_lInt := 1 to Rec."Sample Quantity" do begin
                                    QCLineDetail_lRec.Init;
                                    QCLineDetail_lRec."QC Rcpt No." := rec."No.";
                                    QCLineDetail_lRec."QC Rcpt Line No." := QCRcptLine_lRec."Line No.";
                                    QCLineDetail2_lRec.Reset;
                                    QCLineDetail2_lRec.SetRange("QC Rcpt No.", QCLineDetail_lRec."QC Rcpt No.");
                                    QCLineDetail2_lRec.SetRange("QC Rcpt Line No.", QCLineDetail_lRec."QC Rcpt Line No.");

                                    if QCLineDetail2_lRec.FindLast then
                                        QCLineDetail_lRec."Line No." := QCLineDetail2_lRec."Line No." + 10000
                                    else
                                        QCLineDetail_lRec."Line No." := 10000;

                                    QCLineDetail_lRec.Validate("Quality Parameter Code", QCRcptLine_lRec."Quality Parameter Code");
                                    QCLineDetail_lRec.Type := QCRcptLine_lRec.Type;
                                    QCLineDetail_lRec.Validate("Quality Parameter Code", QCRcptLine_lRec."Quality Parameter Code");

                                    QCLineDetail_lRec."Min.Value" := QCRcptLine_lRec."Min.Value";
                                    QCLineDetail_lRec."Max.Value" := QCRcptLine_lRec."Max.Value";
                                    QCLineDetail_lRec."Text Value" := QCRcptLine_lRec."Text Value";
                                    QCLineDetail_lRec."Lot No." := rec."Vendor Lot No.";
                                    QCLineDetail_lRec."Unit of Measure Code" := QCRcptLine_lRec."Unit of Measure Code";

                                    QCLineDetail_lRec.Insert;
                                end;
                            end;
                        until QCSpecificationLine_lRec.Next = 0;
                        Message('All QC parameters updated from QC Specification');
                    end;
                End;
            }
            //T51170-NE

            group("P&osting")
            {
                Caption = 'P&osting';
                action("&Post")
                {
                    ApplicationArea = Basic;
                    Caption = '&Post';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        QCRcptHeader_lRec: Record "QC Rcpt. Header";
                    begin
                        //T12113-NB-NS
                        Rec.PostQCRcpt_gFnc(true);  //I-C0009-1001310-02 N  T13919-N
                        //I-C0009-1001310-04-NS
                        if QCRcptHeader_lRec.Get(Rec."No.") then
                            CurrPage.Update(false)
                        else
                            CurrPage.Close;
                        //I-C0009-1001310-04-NE
                        //T12113-NB-NE

                    end;
                }
                action("&Test Report")
                {
                    ApplicationArea = Basic;
                    Caption = '&Test Report';
                    Image = TestReport;

                    trigger OnAction()
                    begin
                        //I-C0009-1001310-01 NS
                        QCRcpt_gRec.SetRange("No.", Rec."No.");
                        if QCRcpt_gRec.FindFirst then
                            Report.Run(33029230, true, false, QCRcpt_gRec);
                        //I-C0009-1001310-01 NE
                    end;
                }
            }
            group("Function")
            {
                Caption = 'Function';
                action("Calculate Averge Value for Sample Qty.")
                {
                    ApplicationArea = Basic;
                    Image = Calculate;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        QualityControlGeneral_lCdu: Codeunit "Quality Control - General";
                    begin
                        QualityControlGeneral_lCdu.CalculateAverge_gFnc(Rec);  //QCV3-NS  24-01-18
                    end;
                }
                action("Var")
                {
                    ApplicationArea = Basic;
                    Image = Calculate;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        QualityControlGeneral_lCdu: Codeunit "Error Action Test";
                        Value_lDec: Decimal;
                    begin
                        Value_lDec := 50.00;
                        QualityControlGeneral_lCdu.First_gFnc(Value_lDec);
                    end;
                }
                action("Without Var")
                {
                    ApplicationArea = Basic;
                    Image = Calculate;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        QualityControlGeneral_lCdu: Codeunit "Error Action Test";
                        Value_lDec: Decimal;
                    begin
                        Value_lDec := 50.00;
                        QualityControlGeneral_lCdu.Second_gFnc(Value_lDec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        PostedQCRecptHeader_lRec: Record "Posted QC Rcpt. Header";

    begin
        //I-C0009-1001310-01 NS
        if (Rec."Sample QC" = true) then begin
            "Item No.Editable" := true;
            "Inspection QuantityEditable" := true;
            "Unit of MeasureEditable" := true;
            "Decide MethodsVisible" := true;
        end else begin
            "Item No.Editable" := false;
            "Inspection QuantityEditable" := false;
            "Unit of MeasureEditable" := false;
            "Decide MethodsVisible" := false;
            //I-C0009-1001310-04-NS
            PostedQCRecptHeader_lRec.Reset;
            PostedQCRecptHeader_lRec.SetRange("PreAssigned No.", Rec."No.");
            if PostedQCRecptHeader_lRec.FindFirst then
                PastPostedQCRecipt_gInt := PostedQCRecptHeader_lRec.Count
            else
                PastPostedQCRecipt_gInt := 0;
            //I-C0009-1001310-04-NE
        end;
        //I-C0009-1001310-01 NE
        //T12113-NS        
        if Rec."Item Tracking" = rec."Item Tracking"::None then
            RejectionEditable_gBln := true;
        //T12113-NE

        //QCApproval-NS
        QCSetup_gRec.Get;
        if (QCSetup_gRec."Enable QC Approval") and rec.approve then//T12113-C and (rec."Quantity to Reject" > 0) then
            ApproveEdit_gBln := false
        else
            ApproveEdit_gBln := true;
        //QCApproval-NE
        //T12479-NS
        if QCSetup_gRec."Quality Order Applicable" then
            ViewQualityOrderApplicable_gBln := true
        else
            ViewQualityOrderApplicable_gBln := false;
        //T12479-NE

        //QCV4-NS   
        if Rec."Document Type" = Rec."document type"::Production then
            ViewProductionTracking_gBln := true
        else
            ViewProductionTracking_gBln := false;
        //QCV4-NE
    end;

    trigger OnInit()
    begin
        //I-C0009-1001310-01 NS
        "Decide MethodsVisible" := true;
        //I-C0009-1001310-01 NE
        //I-C0009-1001310-07-NS
        ShowPurchaseTab_gBln := true;
        ShowSalesReturnTab_gBln := true;
        ShowProductionTab_gBln := true;
        ShowTransferTab_gBln := true;
        ApproveEdit_gBln := true;  //QCApproval-N//T12113-C
        ReworkEdit_gBln := true;//T12204-ABA-N
        ShowRetesttab_gBln := true;
        ShowSalesTab_gBln := true;
        ShowPreReceiptTab_gBln := true;//T12547-N
        RejectionEditable_gBln := false;//T12113-N
        //I-C0009-1001310-07-NE
    end;

    trigger OnOpenPage()


    begin
        //I-C0009-1001310-07-NS
        if Rec."Document Type" = Rec."document type"::Purchase then begin
            ShowSalesReturnTab_gBln := false;
            ShowProductionTab_gBln := false;
            ShowTransferTab_gBln := false;
            ShowSalesTab_gBln := false;//T12113-NB-N
            ShowPreReceiptTab_gBln := false;//T12547-N
            ReworkEdit_gBln := false;
            ShowRetesttab_gBln := false;
        end else
            if Rec."Document Type" = Rec."document type"::"Sales Return" then begin
                ShowPurchaseTab_gBln := false;
                ShowProductionTab_gBln := false;
                ShowTransferTab_gBln := false;
                ShowSalesTab_gBln := false;//T12113-NB-N
                ShowPreReceiptTab_gBln := false;//T12547-N
                ReworkEdit_gBln := false;
                ShowRetesttab_gBln := false;
            end else
                if Rec."Document Type" = Rec."document type"::Production then begin
                    ShowPurchaseTab_gBln := false;
                    ShowSalesReturnTab_gBln := false;
                    ShowTransferTab_gBln := false;
                    ShowSalesTab_gBln := false;//T12113-NB-N
                    ShowPreReceiptTab_gBln := false;//T12547-N
                    ShowRetesttab_gBln := false;
                end else
                    if Rec."Document Type" = Rec."document type"::"Transfer Receipt" then begin
                        ShowPurchaseTab_gBln := false;
                        ShowSalesReturnTab_gBln := false;
                        ShowProductionTab_gBln := false;
                        ShowSalesTab_gBln := false;//T12113-NB-N
                        ShowPreReceiptTab_gBln := false;//T12547-N
                        ReworkEdit_gBln := false;
                        ShowRetesttab_gBln := false;
                    end else//T12113-NB-NS
                        if rec."Document Type" = rec."Document Type"::"Sales Order" then begin
                            ShowPurchaseTab_gBln := false;
                            ShowSalesReturnTab_gBln := false;
                            ShowProductionTab_gBln := false;
                            ShowTransferTab_gBln := false;
                            ReworkEdit_gBln := false;
                            ShowPreReceiptTab_gBln := false;//T12547-N
                            ShowRetesttab_gBln := false;
                        end else//T12547-NS
                            if rec."Document Type" = rec."Document Type"::"Purchase Pre-Receipt" then begin
                                ShowPurchaseTab_gBln := false;
                                ShowSalesReturnTab_gBln := false;
                                ShowProductionTab_gBln := false;
                                ShowTransferTab_gBln := false;
                                ReworkEdit_gBln := false;
                                ShowSalesTab_gBln := false;//T12547-NE
                                ShowRetesttab_gBln := false;
                            end else
                                if rec."Document Type" = rec."Document Type"::Ile then begin
                                    ShowPurchaseTab_gBln := false;
                                    ShowSalesReturnTab_gBln := false;
                                    ShowProductionTab_gBln := false;
                                    ShowTransferTab_gBln := false;
                                    ShowSalesTab_gBln := false;//T12547-NE
                                    ShowPreReceiptTab_gBln := false;//T12547-N
                                    ReworkEdit_gBln := false;
                                end;
        //T12113-NB-NE
        //I-C0009-1001310-07-NE
        // if Item.get(rec."Item No.") then begin
        //     if not Item."Allow to Retest Material" then
        //         ShowRetesttab_gBln := false;
        // end;
        //T12113-NS        
        if Rec."Item Tracking" = rec."Item Tracking"::None then
            RejectionEditable_gBln := true;
        //T12113-NE

        //QCApproval-NS
        QCSetup_gRec.Get;
        if (QCSetup_gRec."Enable QC Approval") Then //T12113-C and (Rec."Quantity to Reject" > 0) then
            ApproveEdit_gBln := false
        else
            ApproveEdit_gBln := true;
        //QCApproval-NE
        //T12479-NS

        if QCSetup_gRec."Quality Order Applicable" then
            ViewQualityOrderApplicable_gBln := true
        else
            ViewQualityOrderApplicable_gBln := false;
        //T12479-NE

        if QCSetup_gRec."QC Block without Location" then
            EnableField_gBln := false
        else
            EnableField_gBln := true;
    end;




    var
        RejectionEditable_gBln: Boolean;
        RemainQty: Decimal;
        Flag: Boolean;
        FlagFail: Boolean;
        PurchaseLine: Record "Purchase Line";
        PostedQCRcptHeadLast: Record "Posted QC Rcpt. Header";
        QCcode: Integer;
        ItemJournal: Record "Item Journal Line";
        SampleQC: Boolean;
        Item: Record Item;
        ItemSpecificLine: Record "QC Specification Line";
        QCRcptLine1: Record "QC Rcpt. Line";
        sample: Boolean;
        QCRcpt_gRec: Record "QC Rcpt. Header";
        QCTypeFilter: Option Standard,Customer;
        qclineno: Integer;
        QcRcptLine2: Record "QC Rcpt. Line";
        QcRcptLine3: Record "QC Rcpt. Line";
        PurchRcptHead: Record "Purch. Rcpt. Header";
        LedgeEnt: Record "Item Ledger Entry";
        Item1: Record Item;
        RoutLine: Record "Routing Line";
        ItemSpecificHead: Record "QC Specification Header";
        RejQty: Decimal;
        QCSetup_gRec: Record "Quality Control Setup";//T12113-N
        QCRcptLine: Record "QC Rcpt. Line";
        //[InDataSet]
        "Decide MethodsVisible": Boolean;
        //[InDataSet]
        "Item No.Editable": Boolean;
        //[InDataSet]
        "Inspection QuantityEditable": Boolean;
        //[InDataSet]
        "Unit of MeasureEditable": Boolean;
        PastPostedQCRecipt_gInt: Integer;
        ShowPurchaseTab_gBln: Boolean;
        ShowRetesttab_gBln: Boolean;
        ShowSalesTab_gBln: Boolean;
        ShowProductionTab_gBln: Boolean;
        ShowSalesReturnTab_gBln: Boolean;
        ShowTransferTab_gBln: Boolean;
        ApproveEdit_gBln: Boolean;
        ReworkEdit_gBln: Boolean;
        //[InDataSet]
        ViewProductionTracking_gBln: Boolean;
        ViewQualityOrderApplicable_gBln: Boolean;//T12479-N 
        Ile_gRec: Record "Item Ledger Entry";
        ShowPreReceiptTab_gBln: Boolean;//T12547-N
        EnableField_gBln: Boolean;


    local procedure LooupDocument_lFnc()
    var
        TransferReceiptHeader_lRec: Record "Transfer Receipt Header";
        PurchRcptHeader_lRec: Record "Purch. Rcpt. Header";
        ReturnReceiptHeader_lRec: Record "Return Receipt Header";
        ProductionOrder_lRec: Record "Production Order";
        SalesHeader_lRec: Record "Sales Header";
        PurchHeader_lRec: Record "Purchase Header";
    begin
        case Rec."Document Type" of
            Rec."document type"::"Transfer Receipt":
                begin
                    TransferReceiptHeader_lRec.Reset;
                    TransferReceiptHeader_lRec.SetRange("No.", Rec."Document No.");
                    Page.RunModal(5745, TransferReceiptHeader_lRec);
                end;
            Rec."document type"::Purchase:
                begin
                    PurchRcptHeader_lRec.Reset;
                    PurchRcptHeader_lRec.SetRange("No.", Rec."Document No.");
                    Page.RunModal(136, PurchRcptHeader_lRec);
                end;
            Rec."document type"::"Sales Return":
                begin
                    ReturnReceiptHeader_lRec.Reset;
                    ReturnReceiptHeader_lRec.SetRange("No.", Rec."Document No.");
                    Page.RunModal(6660, ReturnReceiptHeader_lRec);
                end;
            Rec."document type"::Production:
                begin
                    ProductionOrder_lRec.Reset;
                    ProductionOrder_lRec.SetRange(Status, ProductionOrder_lRec.Status::Released);
                    ProductionOrder_lRec.SetRange("No.", Rec."Document No.");
                    Page.RunModal(99000831, ProductionOrder_lRec);
                end;
            //T12113-ABA-NS
            Rec."document type"::ile:
                begin
                    Clear(Ile_gRec);
                    Ile_gRec.SetRange("Entry No.", Rec."ILE No.");
                    Page.RunModal(75409, Ile_gRec);
                end;
            //T12113-ABA-NE
            //T12113-NB-NS
            Rec."Document Type"::"Sales Order":
                begin
                    SalesHeader_lRec.Reset();
                    SalesHeader_lRec.SetRange("No.", Rec."Document No.");
                    page.RunModal(page::"Sales Order List", SalesHeader_lRec);
                end;
            //T12113-NB-NE
            Rec."Document Type"::"Purchase Pre-Receipt":
                begin
                    PurchHeader_lRec.Reset();
                    PurchHeader_lRec.SetRange("No.", Rec."Document No.");
                    page.RunModal(page::"Purchase List", PurchHeader_lRec);
                end;
            else
                Error('Cash not define for Document Type %1', Rec."Document Type");
        end;
    end;
}

