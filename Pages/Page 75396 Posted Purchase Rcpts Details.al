Page 75396 "Posted Purchase Rcpts Details"
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
    // ------------------------------------------------------------------------------------------------------------------------------

    AutoSplitKey = true;
    Caption = 'Lines';
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Purch. Rcpt. Line";
    SourceTableView = where(Type = filter(Item),
                            Quantity = filter(<> 0),
                            "QC Required" = filter(true));
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(RepeaterControl)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = Basic;
                }
                field("TC Remarks"; Rec."TC Remarks")
                {
                    ApplicationArea = Basic;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = true;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic;
                    BlankZero = true;
                    Editable = false;
                }
                field("Under Inspection Quantity"; Rec."Under Inspection Quantity")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Accepted Quantity"; Rec."Accepted Quantity")
                {
                    ApplicationArea = Basic;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        if Rec."Accepted Quantity" > 0 then;
                    end;
                }
                field("Accepted with Deviation Qty"; Rec."Accepted with Deviation Qty")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Rejected Quantity"; Rec."Rejected Quantity")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                field("Quantity Invoiced"; Rec."Quantity Invoiced")
                {
                    ApplicationArea = Basic;
                    BlankZero = true;
                    Editable = false;
                }
                field("Qty. Rcd. Not Invoiced"; Rec."Qty. Rcd. Not Invoiced")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = true;
                }
                field("TC Received"; Rec."TC Received")
                {
                    ApplicationArea = Basic;
                }
                field("TC Remark"; Rec."TC Remarks")
                {
                    ApplicationArea = Basic;
                    Caption = 'TC Remarks';
                }
                field("QC Pending"; Rec."QC Pending")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Purchase Receipt")
            {
                ApplicationArea = Basic;
                RunObject = Page "Posted Purchase Receipt";
                RunPageLink = "No." = field("Document No.");
                RunPageView = sorting("No.");
                ShortCutKey = 'Shift+F7';
            }
            action(Dimensions)
            {
                ApplicationArea = Basic;
                Caption = 'Dimensions';
                Image = Dimensions;
                ShortCutKey = 'Shift+Ctrl+D';

                trigger OnAction()
                begin
                    //This functionality was copied from page #136. Unsupported part was commented. Please check it.
                    /*CurrPage.PurchReceiptLines.FORM.*/
                    Rec.ShowDimensions;

                end;
            }
            action("Co&mments")
            {
                ApplicationArea = Basic;
                Caption = 'Co&mments';
                Image = ViewComments;

                trigger OnAction()
                begin
                    //This functionality was copied from page #136. Unsupported part was commented. Please check it.
                    /*CurrPage.PurchReceiptLines.FORM.*/
                    Rec.ShowLineComments;

                end;
            }
            action("Item &Tracking Entries")
            {
                ApplicationArea = Basic;
                Caption = 'Item &Tracking Entries';
                Image = ItemTrackingLedger;

                trigger OnAction()
                begin
                    //This functionality was copied from page #136. Unsupported part was commented. Please check it.
                    /*CurrPage.PurchReceiptLines.FORM.*/
                    Rec.ShowItemTrackingLines;

                end;
            }
            action("Item Invoice &Lines")
            {
                ApplicationArea = Basic;
                Caption = 'Item Invoice &Lines';

                trigger OnAction()
                begin
                    //This functionality was copied from page #136. Unsupported part was commented. Please check it.
                    /*CurrPage.PurchReceiptLines.FORM.*/
                    _ShowItemPurchInvLines;

                end;
            }
            action("&Create QC Receipt")
            {
                ApplicationArea = Basic;
                Caption = '&Create QC Receipt';

                trigger OnAction()
                begin
                    QCPurchase_gCdu.CreateQCRcpt_gFnc(Rec, true); //I-C0009-1001310-04 N
                end;
            }
            action("QC &Receipt")
            {
                ApplicationArea = Basic;
                Caption = 'QC &Receipt';

                trigger OnAction()
                begin
                    QCPurchase_gCdu.ShowQCRcpt_gFnc(Rec); //I-C0009-1001310-04 N
                end;
            }
            action("&Posted QC Receipt")
            {
                ApplicationArea = Basic;
                Caption = '&Posted QC Receipt';

                trigger OnAction()
                begin
                    QCPurchase_gCdu.ShowPostedQCRcpt_gFnc(Rec); //I-C0009-1001310-04 N
                end;
            }
        }
    }

    var
        QCPurchase_gCdu: Codeunit "Quality Control - Purchase";

    procedure ShowTracking()
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        TrackingPage: Page "Order Tracking";
    begin
        Rec.TestField(Type, Rec.Type::Item);
        if Rec."Item Rcpt. Entry No." <> 0 then begin
            ItemLedgEntry.Get(Rec."Item Rcpt. Entry No.");
            TrackingPage.SetItemLedgEntry(ItemLedgEntry);
        end else
            TrackingPage.SetMultipleItemLedgEntries(TempItemLedgEntry,
              Database::"Purch. Rcpt. Line", 0, Rec."Document No.", '', 0, Rec."Line No.");

        TrackingPage.RunModal;
    end;



    procedure UndoReceiptLine()
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        PurchRcptLine.Copy(Rec);
        CurrPage.SetSelectionFilter(PurchRcptLine);
        Codeunit.Run(Codeunit::"Undo Purchase Receipt Line", PurchRcptLine);
    end;

    procedure _ShowItemPurchInvLines()
    begin
        Rec.TestField(Type, Rec.Type::Item);
        Rec.ShowItemPurchInvLines;
    end;


}

