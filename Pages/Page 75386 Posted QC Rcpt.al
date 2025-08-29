Page 75386 "Posted QC Rcpt"
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
    // I-C0009-1001310-05     24/11/14    RaviShah
    //                        Return Order from QC Rej. Qty Functionality
    //                        Added New Fields 1) Return Quantity 2) Outstanding Returned Quantity
    // I-C0009-1001310-08     31/12/14    Chintan Panchal
    //                        QC Enhancement
    // ------------------------------------------------------------------------------------------------------------------------------

    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "Posted QC Rcpt. Header";
    Caption = 'Posted QC Receipt';//T12971-N
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = Basic;
                }
                field("Item Description 2"; Rec."Item Description 2")
                {
                    ApplicationArea = Basic;
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
                }
                field("Item Tracking"; Rec."Item Tracking")
                {
                    ApplicationArea = Basic;
                }
                field("PreAssigned No."; Rec."PreAssigned No.")
                {
                    ApplicationArea = Basic;
                }
                field("QC Date"; Rec."QC Date")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Receipt Date"; Rec."Receipt Date")
                {
                    ApplicationArea = Basic;
                    Caption = 'Posting Date';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic;
                }
                field("Inspection Quantity"; Rec."Inspection Quantity")
                {
                    ApplicationArea = Basic;
                }
                field("Accepted Quantity"; Rec."Accepted Quantity")
                {
                    ApplicationArea = Basic;
                    Style = Favorable;
                    StyleExpr = true;

                    trigger OnDrillDown()
                    begin
                        if Rec."Accepted Quantity" > 0 then
                            Rec.OpenAccpItemLedgerEntries_gFnc;
                    end;
                }
                field("Accepted with Deviation Qty"; Rec."Accepted with Deviation Qty")
                {
                    ApplicationArea = Basic;
                    Style = Strong;
                    StyleExpr = true;

                    trigger OnDrillDown()
                    begin
                        if Rec."Accepted with Deviation Qty" > 0 then
                            Rec.OpenAccpItemLedgerEntries_gFnc;
                    end;
                }
                field("Rejected Quantity"; Rec."Rejected Quantity")
                {
                    ApplicationArea = Basic;
                    Style = Unfavorable;
                    StyleExpr = true;

                    trigger OnDrillDown()
                    begin
                        if Rec."Rejected Quantity" > 0 then
                            Rec.OpenRejeItemLedgerEntries_gFnc;
                    end;
                }
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

                    trigger OnDrillDown()
                    begin
                        //I-C0009-1001310-08-NS
                        if Rec."Rejected Quantity" > 0 then
                            Rec.OpenReworkItemLedgerEntries_gFnc;
                        //I-C0009-1001310-08-NE
                    end;
                }
                field("Returned Quantity"; Rec."Returned Quantity")
                {
                    ApplicationArea = Basic;
                    Style = StrongAccent;
                    StyleExpr = true;
                }
                field("Outstanding Returned Qty."; Rec."Outstanding Returned Qty.")
                {
                    ApplicationArea = Basic;
                }
                field("Checked By"; Rec."Checked By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Approve; Rec.Approve)
                {
                    ApplicationArea = Basic;
                }
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
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
                field("COA AutoPost"; Rec."COA AutoPost")
                {
                    ToolTip = 'Specifies the value of the COA AutoPost field.', Comment = '%';
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

                field("Exp. Date"; Rec."Exp. Date")
                {
                    ApplicationArea = Basic;
                }
                field("Mfg. Date"; Rec."Mfg. Date")
                {
                    ApplicationArea = Basic;
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
                }
                field("Store Bin Code"; Rec."Store Bin Code")
                {
                    ApplicationArea = Basic;
                }
                field("Rejection Location"; Rec."Rejection Location")
                {
                    ApplicationArea = Basic;
                }
                field("Reject Bin Code"; Rec."Reject Bin Code")
                {
                    ApplicationArea = Basic;
                }
                field("Rework Location"; Rec."Rework Location")
                {
                    ApplicationArea = Basic;
                }
                field("Rework Bin Code"; Rec."Rework Bin Code")
                {
                    ApplicationArea = Basic;
                }
            }
            group("Rejection Details")
            {

                field("Rejection Reason"; Rec."Rejection Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rejection Reason field.', Comment = '%';
                }
                field("Rejection Reason Description"; Rec."Rejection Reason Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rejection Reason Description field.', Comment = '%';
                }
            }
            part("Posted QC Subform"; "Posted QC Rcpt. Subform")
            {
                Editable = false;
                SubPageLink = "No." = field("No.");
                SubPageView = sorting("No.", "Line No.")
                              order(ascending);
                ApplicationArea = all;
            }
            group("Sample Collection History")
            {
                Caption = 'Sample Collection History';
                field("Sample Qty."; Rec."Sample Quantity")
                {
                    ApplicationArea = Basic;
                    Caption = 'Sample Quantity';
                    Editable = false;
                }

                field("Sample Collector ID"; Rec."Sample Collector ID")
                {
                    ApplicationArea = All;
                    Editable = false;
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
                    Editable = false;
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
                Editable = false;
                Visible = ShowPurchaseTab_gBln;
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LooupDocument_lFnc;
                    end;
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = Basic;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = Basic;
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = Basic;
                }
                field("Vendor DC No"; Rec."Vendor DC No")
                {
                    ApplicationArea = Basic;
                }
                field("Vendor Lot No."; Rec."Vendor Lot No.")
                {
                    ApplicationArea = Basic;
                    Caption = 'Lot No';//T12113-N
                }
            }
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

            }
            //T12113-NB-NE
            group(Production)
            {
                Caption = 'Production';
                Editable = false;
                Visible = ShowProductionTab_gBln;
                field("Doc Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic;
                    Caption = 'Document Type';
                }
                field("Doc No."; Rec."Document No.")
                {
                    ApplicationArea = Basic;
                    Caption = 'Document No.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LooupDocument_lFnc;
                    end;
                }
                field("Doc. Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = Basic;
                    Caption = 'Document Line No.';
                }
                field("Item Journal Template Name"; Rec."Item Journal Template Name")
                {
                    ApplicationArea = Basic;
                }
                field("Item General Batch Name"; Rec."Item General Batch Name")
                {
                    ApplicationArea = Basic;
                }
                field("Center Type"; Rec."Center Type")
                {
                    ApplicationArea = Basic;
                }
                field("Center No."; Rec."Center No.")
                {
                    ApplicationArea = Basic;
                    Lookup = true;
                }
                field("Operation No."; Rec."Operation No.")
                {
                    ApplicationArea = Basic;
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

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LooupDocument_lFnc;
                    end;
                }
                field("Doc. Line No. for Sales Return"; Rec."Document Line No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = Basic;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = Basic;
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

                    trigger OnLookup(var Text: Text): Boolean
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
            // group(Sample) T12204-NS
            // {
            //     Caption = 'Sample';
            //     Editable = false;
            //     field("Party Type"; Rec."Party Type")
            //     {
            //         ApplicationArea = Basic;
            //     }
            //     field("Party No."; Rec."Party No.")
            //     {
            //         ApplicationArea = Basic;
            //     }
            //     field("Party Name"; Rec."Party Name")
            //     {
            //         ApplicationArea = Basic;
            //     }
            //     field(Address; Rec.Address)
            //     {
            //         ApplicationArea = Basic;
            //     }
            //     field("Phone no."; Rec."Phone no.")
            //     {
            //         ApplicationArea = Basic;
            //     }
            //     field("Sample QC"; Rec."Sample QC")
            //     {
            //         ApplicationArea = Basic;
            //     }
            // }T12204-NE
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
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(75384),
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
            group("Posted &QC Rcpt")
            {
                Caption = 'Posted &QC Rcpt';
                action("Item Tracking Purchase")
                {
                    ApplicationArea = Basic;
                    Caption = 'Item Tracking';
                    Image = GetEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = not ViewProductionTracking_gBln;

                    trigger OnAction()
                    begin
                        Rec.ShowItemTrackingLines;
                    end;
                }
                action("Item Tracking Production QC")
                {
                    ApplicationArea = Basic;
                    Caption = 'Item Tracking';
                    Ellipsis = true;
                    Image = MakeDiskette;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "QC Reservation Entry";
                    RunPageLink = "Posted QC No." = field("No.");
                    RunPageView = sorting("Entry No.", Positive, "Posted QC No.");
                    Visible = ViewProductionTracking_gBln;
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
                //T12113-ABA-NS
                action("View Finished Quality Orders")
                {
                    ApplicationArea = Basic;
                    Caption = '&View Finished Quality Orders';
                    Image = Order;
                    RunObject = page "Finished Production Orders";
                    RunPageLink = "Posted QC Receipt No" = field("No.");
                    RunPageView = where("Quality Order" = filter(true));
                    Visible = ViewQualityOrderApplicable_gBln;//T12479-N
                    trigger OnAction()
                    begin

                    end;
                }
                action("Create Rework Production Order")
                {
                    ApplicationArea = Basic;
                    Caption = 'Create Rework Production Order';
                    Image = MakeOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = ShowProductionTab_gBln;

                    trigger OnAction()
                    var
                        ReworkPrdOrder_lCdu: Codeunit "Create Rework ProdOdr PostQC";
                    begin
                        ReworkPrdOrder_lCdu.ReworkProductionOrder_gFnc(Rec);
                    end;
                }
                //T12113-ABA-NE
            }
        }
        area(processing)
        {
            action(Print)
            {
                ApplicationArea = Basic;
                Caption = '&Print';
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                //T52538-NS
                Visible = false;
                Enabled = false;
                //T52538-NE
                trigger OnAction()
                var
                    PostedQCReport: Report "Posted QC Receipt";
                begin
                    PostedQCRcpt.SetRange(PostedQCRcpt."No.", Rec."No.");
                    PostedQCRcpt.SetRange(PostedQCRcpt."No Series", Rec."No Series");
                    PostedQCReport.SetTableView(PostedQCRcpt);
                    PostedQCReport.RunModal();
                end;
            }
            //T52538-NS
            action(Print_QC_Rcpt)
            {
                ApplicationArea = Basic;
                Caption = '&Print';
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    PostedQCReport: Report "Posted QC Receipt_Copy";
                begin
                    PostedQCRcpt.SetRange(PostedQCRcpt."No.", Rec."No.");
                    PostedQCRcpt.SetRange(PostedQCRcpt."No Series", Rec."No Series");
                    PostedQCReport.SetTableView(PostedQCRcpt);
                    PostedQCReport.RunModal();
                end;
            }
            //T52538-NE
        }
    }

    trigger OnAfterGetRecord()
    begin
        //QCV4-NS
        if Rec."Document Type" in [Rec."document type"::Production, Rec."document type"::"Sales Order", rec."Document Type"::"Purchase Pre-Receipt"] then//T12547-N
            ViewProductionTracking_gBln := true
        else
            ViewProductionTracking_gBln := false;

        QCSetup_gRec.get;
        if QCSetup_gRec."Quality Order Applicable" then
            ViewQualityOrderApplicable_gBln := true
        else
            ViewQualityOrderApplicable_gBln := false;
        //T12479-NE
        //QCV4-NE
    end;

    trigger OnInit()

    begin
        //I-C0009-1001310-07-NS
        ShowPurchaseTab_gBln := true;
        ShowSalesReturnTab_gBln := true;
        ShowProductionTab_gBln := true;
        ShowTransferTab_gBln := true;
        ShowSalesTab_gBln := true;
        //I-C0009-1001310-07-NE
        ReworkEdit_gBln := true;//T12204-ABA-N        
        ShowSalesTab_gBln := true;
        ShowPreReceiptTab_gBln := true;//T12547-N
        ShowRetesttab_gBln := true;



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
                            end else//T12547-NS
                                if rec."Document Type" = rec."Document Type"::Ile then begin
                                    ShowPurchaseTab_gBln := false;
                                    ShowSalesReturnTab_gBln := false;
                                    ShowProductionTab_gBln := false;
                                    ShowTransferTab_gBln := false;
                                    ShowSalesTab_gBln := false;//T12547-NE
                                    ShowPreReceiptTab_gBln := false;//T12547-N
                                    ReworkEdit_gBln := false;
                                end;

        //I-C0009-1001310-07-NE
        // if Item.get(rec."Item No.") then begin
        //     if not Item."Allow to Retest Material" then
        //         ShowRetesttab_gBln := false;
        // end;
        QCSetup_gRec.get;
        if QCSetup_gRec."Quality Order Applicable" then
            ViewQualityOrderApplicable_gBln := true
        else
            ViewQualityOrderApplicable_gBln := false;

    end;

    var
        UID: Code[20];
        PostedQCRcpt: Record "Posted QC Rcpt. Header";
        QCTypeFilter: Option Standard,Customer;
        qclineno: Integer;
        QcRcptLine2: Record "Posted QC Rcpt. Line";
        Item: Record Item;
        ItemSpecificLine: Record "QC Specification Line";
        QCRcptLine1: Record "Posted QC Rcpt. Line";
        QcRcptLine3: Record "Posted QC Rcpt. Line";
        ShowPurchaseTab_gBln: Boolean;
        ShowRetesttab_gBln: Boolean;
        ShowSalesTab_gBln: Boolean;
        ShowProductionTab_gBln: Boolean;
        ShowSalesReturnTab_gBln: Boolean;
        ShowTransferTab_gBln: Boolean;
        ReworkEdit_gBln: Boolean;
        //[InDataSet]
        ViewProductionTracking_gBln: Boolean;
        ViewQualityOrderApplicable_gBln: Boolean;//T12479-N
        Ile_gRec: Record "Item Ledger Entry";
        ShowPreReceiptTab_gBln: Boolean;//T12547-N
        QCSetup_gRec: Record "Quality Control Setup";


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

