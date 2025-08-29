Page 75404 "Reverse Output Journal"
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
    // I-I026-301010-01       15/10/15     Nilesh Gajjar
    //                        New Fields:  50089 - "Shift Manager"
    //                                     50090 - "Shift In Charge"
    //                                     50091 - "Resource/Team Code"
    // I-I026-301010-02       29/01/15     Nishant Upadhyay
    //                        Added Code For :-
    //                                     If "Qty. per Unit of Measure" has decimal values then it must restrict to open Item
    //                                     Tracking Lines Action page.
    // I-I035-500009-01       10/07/15       RaviShah
    //                        User wise Batch setup functionality
    //                        Added code to setup user wise Batch
    // ------------------------------------------------------------------------------------------------------------------------------

    AutoSplitKey = true;
    Caption = 'Reverse Output Journal';
    DataCaptionFields = "Journal Batch Name";
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Item Journal Line";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                ApplicationArea = Basic;
                Caption = 'Batch Name';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord;
                    ItemJnlMgt.LookupName(CurrentJnlBatchName, Rec);
                    CurrPage.Update(false);
                    ItemJnlMgt.CheckName(CurrentJnlBatchName, Rec);
                end;

                trigger OnValidate()
                begin
                    ItemJnlMgt.CheckName(CurrentJnlBatchName, Rec);
                    CurrentJnlBatchNameOnAfterVali;
                end;
            }
            repeater(RepeaterControl)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = Basic;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        IJB_lRec: Record "Item Journal Batch";
                        ProdOrder_lRec: Record "Production Order";
                        ProdOrderList_lPge: Page "Production Order List";
                    begin
                        //NG-NS
                        Rec.TestField("Journal Template Name");
                        Rec.TestField("Journal Batch Name");
                        IJB_lRec.Get(Rec."Journal Template Name", Rec."Journal Batch Name");

                        ProdOrder_lRec.Reset;
                        ProdOrder_lRec.FilterGroup(2);
                        ProdOrder_lRec.SetRange(Status, ProdOrder_lRec.Status::Released);

                        ProdOrder_lRec.FilterGroup(0);

                        Clear(ProdOrderList_lPge);
                        ProdOrderList_lPge.SetTableview(ProdOrder_lRec);
                        ProdOrderList_lPge.LookupMode(true);
                        if ProdOrderList_lPge.RunModal = Action::LookupOK then begin
                            ProdOrderList_lPge.GetRecord(ProdOrder_lRec);
                            Rec."Order No." := ProdOrder_lRec."No.";
                            ItemJnlMgt.GetOutput(Rec, ProdOrderDescription, OperationName);
                            Rec.Validate("Order No.");
                        end;
                        //NG-NE
                    end;

                    trigger OnValidate()
                    begin
                        ItemJnlMgt.GetOutput(Rec, ProdOrderDescription, OperationName);
                    end;
                }
                field("Order Line No."; Rec."Order Line No.")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupItemNo;
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field("Prod. Order Remaining Qty."; ProdOrderLineRemQty_gDec)
                {
                    ApplicationArea = Basic;
                    BlankZero = true;
                    Caption = 'Prod. Order Remaining Qty.';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
                }
                field("Operation No."; Rec."Operation No.")
                {
                    ApplicationArea = Basic;

                    trigger OnValidate()
                    begin
                        ItemJnlMgt.GetOutput(Rec, ProdOrderDescription, OperationName);
                    end;
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
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Work Shift Code"; Rec."Work Shift Code")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    ApplicationArea = Basic;
                    CaptionClass = '1,2,3';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(3, ShortcutDimCode[3]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    ApplicationArea = Basic;
                    CaptionClass = '1,2,4';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(4, ShortcutDimCode[4]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    ApplicationArea = Basic;
                    CaptionClass = '1,2,5';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(5, ShortcutDimCode[5]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    ApplicationArea = Basic;
                    CaptionClass = '1,2,6';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(6, ShortcutDimCode[6]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    ApplicationArea = Basic;
                    CaptionClass = '1,2,7';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(7, ShortcutDimCode[7]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    ApplicationArea = Basic;
                    CaptionClass = '1,2,8';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(8, ShortcutDimCode[8]);
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("Starting Time"; Rec."Starting Time")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Ending Time"; Rec."Ending Time")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Run Time"; Rec."Run Time")
                {
                    ApplicationArea = Basic;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = Basic;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                field("Output Quantity"; Rec."Output Quantity")
                {
                    ApplicationArea = Basic;
                    MaxValue = 0;
                    Style = Unfavorable;
                    StyleExpr = true;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Applies-to Entry"; Rec."Applies-to Entry")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Output Quantity (Base)"; Rec."Output Quantity (Base)")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    MinValue = 0;
                    Style = Unfavorable;
                    StyleExpr = true;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
            }
            group(Control73)
            {
                ShowCaption = false;
                fixed(FixedLayoutControl)
                {
                    group("Prod. Order Name")
                    {
                        Caption = 'Prod. Order Name';
                        field(ProdOrderDescription; ProdOrderDescription)
                        {
                            ApplicationArea = Basic;
                            Editable = false;
                        }
                    }
                    group(Operation)
                    {
                        Caption = 'Operation';
                        field(OperationName; OperationName)
                        {
                            ApplicationArea = Basic;
                            Caption = 'Operation';
                            Editable = false;
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(RecordLinks; Links)
            {
                Visible = false;
                ApplicationArea = All;
            }
            systempart(Notes; Notes)
            {
                Visible = false;
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    ApplicationArea = Basic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions;
                        CurrPage.SaveRecord;
                    end;
                }
                action("Item Tracking Lines")
                {
                    ApplicationArea = Basic;
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    ShortCutKey = 'Shift+Ctrl+I';

                    trigger OnAction()
                    var
                        ManuSetup_lRec: Record "Manufacturing Setup";
                        QtyPerUnitOfMeasure_lTxt: Text;
                        Text001_lCtx: label 'Value of Qty per Unit Of Measure cant be in Decimals';
                    begin
                        //I-I026-301010-02-NS
                        if (Evaluate(QtyPerUnitOfMeasure_lTxt, Format(Rec."Qty. per Unit of Measure"))) and (StrPos(QtyPerUnitOfMeasure_lTxt, '.') <> 0) then
                            Error(Text001_lCtx);
                        //I-I026-301010-02-NE

                        //NG-NS
                        Rec.TestField("Posting Date");

                        Rec.TestField("Item No.");
                        Rec.TestField("Work Center No.");
                        Rec.TestField("Work Shift Code");
                        Rec.TestField("Starting Time");
                        Rec.TestField("Ending Time");

                        if Rec."Output Quantity" >= 0 then begin
                        end;
                        //NG-NE

                        Rec.OpenItemTrackingLines(false);
                    end;
                }
                action("Bin Contents")
                {
                    ApplicationArea = Basic;
                    Caption = 'Bin Contents';
                    Image = BinContent;
                    RunObject = Page "Bin Contents List";
                    RunPageLink = "Location Code" = field("Location Code"),
                                  "Item No." = field("Item No."),
                                  "Variant Code" = field("Variant Code");
                    RunPageView = sorting("Location Code", "Bin Code", "Item No.", "Variant Code");
                }
            }
            group("Pro&d. Order")
            {
                Caption = 'Pro&d. Order';
                Image = "Order";
                action(Card)
                {
                    ApplicationArea = Basic;
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Released Production Order";
                    RunPageLink = "No." = field("Order No.");
                    ShortCutKey = 'Shift+F7';
                }
                group("Ledger E&ntries")
                {
                    Caption = 'Ledger E&ntries';
                    Image = Entries;
                    action("Item Ledger E&ntries")
                    {
                        ApplicationArea = Basic;
                        Caption = 'Item Ledger E&ntries';
                        Image = ItemLedger;
                        RunObject = Page "Item Ledger Entries";
                        RunPageLink = "Order Type" = const(Production),
                                      "Order No." = field("Order No.");
                        RunPageView = sorting("Order Type", "Order No.");
                        ShortCutKey = 'Ctrl+F7';
                    }
                    action("Capacity Ledger Entries")
                    {
                        ApplicationArea = Basic;
                        Caption = 'Capacity Ledger Entries';
                        Image = CapacityLedger;
                        Promoted = false;
                        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedCategory = Process;
                        RunObject = Page "Capacity Ledger Entries";
                        RunPageLink = "Order Type" = const(Production),
                                      "Order No." = field("Order No.");
                        RunPageView = sorting("Order Type", "Order No.");
                    }
                    action("Value Entries")
                    {
                        ApplicationArea = Basic;
                        Caption = 'Value Entries';
                        Image = ValueLedger;
                        RunObject = Page "Value Entries";
                        RunPageLink = "Order Type" = const(Production),
                                      "Order No." = field("Order No.");
                        RunPageView = sorting("Order Type", "Order No.");
                    }
                }
            }
        }
        area(processing)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action("Test Report")
                {
                    ApplicationArea = Basic;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;

                    trigger OnAction()
                    begin
                        ReportPrint.PrintItemJnlLine(Rec);
                    end;
                }
                action(Post)
                {
                    ApplicationArea = Basic;
                    Caption = 'P&ost';
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        IJL_lRec: Record "Item Journal Line";
                    begin
                        IJL_lRec.Copy(Rec);

                        TrySetApplyToEntries;
                        Rec.PostingItemJnlFromProduction(false);
                        CurrentJnlBatchName := Rec.GetRangemax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = Basic;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';

                    trigger OnAction()
                    var
                        IJL_lRec: Record "Item Journal Line";
                    begin
                        IJL_lRec.Copy(Rec);

                        TrySetApplyToEntries;
                        Rec.PostingItemJnlFromProduction(true);
                        CurrentJnlBatchName := Rec.GetRangemax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
                /*
                action("BarCode (Tag) Printing")
                {
                    ApplicationArea = Basic;
                    Caption = 'BarCode (Tag) Printing';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report UnknownReport50020;
                }
                */
            }
            action("&Print")
            {
                ApplicationArea = Basic;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ItemJnlLine: Record "Item Journal Line";
                begin
                    ItemJnlLine.Copy(Rec);
                    ItemJnlLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                    ItemJnlLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    Report.RunModal(Report::"Inventory Movement", true, true, ItemJnlLine);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        ItemJnlMgt.GetOutput(Rec, ProdOrderDescription, OperationName);
    end;

    trigger OnAfterGetRecord()
    var
        Item_lRec: Record Item;
        ProdOrderLine_lRec: Record "Prod. Order Line";
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);

        //NG-NS
        ProdOrderLineRemQty_gDec := 0;
        ProdOrderLine_lRec.Reset;
        ProdOrderLine_lRec.SetRange("Prod. Order No.", Rec."Order No.");
        ProdOrderLine_lRec.SetRange("Line No.", Rec."Order Line No.");
        if ProdOrderLine_lRec.FindFirst then begin
            ProdOrderLineRemQty_gDec := ProdOrderLine_lRec."Remaining Quantity";
        end;
        //NG-NE
    end;

    trigger OnDeleteRecord(): Boolean
    var
        ReserveItemJnlLine: Codeunit "Item Jnl. Line-Reserve";
        ReservationEntry_lRec: Record "Reservation Entry";
        UserSetup_lRec: Record "User Setup";
    begin
        //VoidTagDel-NS
        ReservationEntry_lRec.Reset;
        ReservationEntry_lRec.SetRange("Source Type", 83);
        ReservationEntry_lRec.SetRange("Source ID", Rec."Journal Template Name");
        ReservationEntry_lRec.SetRange("Source Batch Name", Rec."Journal Batch Name");
        ReservationEntry_lRec.SetRange("Source Ref. No.", Rec."Line No.");
        ReservationEntry_lRec.SetRange("Item No.", Rec."Item No.");
        if ReservationEntry_lRec.FindFirst then begin
            UserSetup_lRec.Get(UserId);
        end;
        //VoidTagDel-NE

        Commit;
        //ReserveItemJnlLine.SkipConfirmBox_gFnc(TRUE);  //LotEntry-N
        if not ReserveItemJnlLine.DeleteLineConfirm(Rec) then
            exit(false);
        ReserveItemJnlLine.DeleteLine(Rec);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetUpNewLine(xRec);
        Rec.Validate("Entry Type", Rec."entry type"::Output);
        Clear(ShortcutDimCode);

        //NG-NS
        ProdOrderLineRemQty_gDec := 0;
        //NG-NE
    end;

    trigger OnOpenPage()
    var
        JnlSelected: Boolean;
        QualityControlSetup_lRec: Record "Quality Control Setup";
    begin

        OpenedFromBatch := (Rec."Journal Batch Name" <> '') and (Rec."Journal Template Name" = '');
        if OpenedFromBatch then begin
            CurrentJnlBatchName := Rec."Journal Batch Name";
            ItemJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);
            exit;
        end;
        ItemJnlMgt.TemplateSelection(Page::"Output Journal", 5, false, Rec, JnlSelected);
        if not JnlSelected then
            Error('');

        ItemJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);
    end;

    var
        ItemJnlMgt: Codeunit ItemJnlManagement;
        ReportPrint: Codeunit "Test Report-Print";
        ProdOrderDescription: Text[50];
        OperationName: Text[50];
        CurrentJnlBatchName: Code[10];
        ShortcutDimCode: array[8] of Code[20];
        OpenedFromBatch: Boolean;
        CurrentSet: Record "Item Journal Line";
        QCNo: Code[20];
        QCRcpt: Record "QC Rcpt. Header";
        Item: Record Item;
        OutQty: Decimal;
        First: Boolean;
        CapLedgEntry: Record "Capacity Ledger Entry";
        ProdOrderRtngLine: Record "Prod. Order Routing Line";
        ItemCat: Record "Item Category";
        QCHead: Record "QC Rcpt. Header";
        QCPage: Page "QC Rcpt.";
        ItemTrackingPage: Page "Item Tracking Lines";
        ProdOrdr: Record "Production Order";
        SrcID: Code[20];
        QCProduction_gCdu: Codeunit "Quality Control - Production";
        ProdOrderLineRemQty_gDec: Decimal;

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SaveRecord;
        ItemJnlMgt.SetName(CurrentJnlBatchName, Rec);
        CurrPage.Update(false);
    end;

    procedure TrySetApplyToEntries()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemJournalLine2: Record "Item Journal Line";
        ReservationEntry: Record "Reservation Entry";
    begin
        ItemJournalLine2.Copy(Rec);
        if ItemJournalLine2.FindSet then
            repeat
                if FindReservationsReverseOutput(ReservationEntry, ItemJournalLine2) then
                    repeat
                        if FindILEFromReservation(ItemLedgerEntry, ItemJournalLine2, ReservationEntry, Rec."Order No.") then begin
                            ReservationEntry.Validate("Appl.-to Item Entry", ItemLedgerEntry."Entry No.");
                            ReservationEntry.Modify(true);
                        end;
                    until ReservationEntry.Next = 0;

            until ItemJournalLine2.Next = 0;
    end;

    local procedure FindReservationsReverseOutput(var ReservationEntry: Record "Reservation Entry"; ItemJnlLine: Record "Item Journal Line"): Boolean
    begin
        if ItemJnlLine.Quantity >= 0 then
            exit(false);

        ReservationEntry.SetCurrentkey(
          "Source ID", "Source Ref. No.", "Source Type", "Source Subtype",
          "Source Batch Name", "Source Prod. Order Line");
        ReservationEntry.SetRange("Source ID", ItemJnlLine."Journal Template Name");
        ReservationEntry.SetRange("Source Ref. No.", ItemJnlLine."Line No.");
        ReservationEntry.SetRange("Source Type", Database::"Item Journal Line");
        ReservationEntry.SetRange("Source Subtype", ItemJnlLine."Entry Type");
        ReservationEntry.SetRange("Source Batch Name", ItemJnlLine."Journal Batch Name");

        ReservationEntry.SetFilter("Serial No.", '<>%1', '');
        ReservationEntry.SetRange("Qty. to Handle (Base)", -1);
        ReservationEntry.SetRange("Appl.-to Item Entry", 0);

        exit(ReservationEntry.FindSet);
    end;

    local procedure FindILEFromReservation(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemJnlLine: Record "Item Journal Line"; ReservationEntry: Record "Reservation Entry"; ProductionOrderNo: Code[20]): Boolean
    begin
        ItemLedgerEntry.SetCurrentkey("Item No.", Open, "Variant Code", Positive,
          "Location Code", "Posting Date", "Expiration Date", "Lot No.", "Serial No.");

        ItemLedgerEntry.SetRange("Item No.", ItemJnlLine."Item No.");
        ItemLedgerEntry.SetRange(Open, true);
        ItemLedgerEntry.SetRange("Variant Code", ItemJnlLine."Variant Code");
        ItemLedgerEntry.SetRange(Positive, true);
        ItemLedgerEntry.SetRange("Location Code", ItemJnlLine."Location Code");
        ItemLedgerEntry.SetRange("Serial No.", ReservationEntry."Lot No.");
        ItemLedgerEntry.SetRange("Serial No.", ReservationEntry."Serial No.");
        ItemLedgerEntry.SetRange("Document No.", ProductionOrderNo);

        exit(ItemLedgerEntry.FindSet);
    end;
}

