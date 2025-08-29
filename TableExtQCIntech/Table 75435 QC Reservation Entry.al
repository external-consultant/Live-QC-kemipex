tableextension 75435 ExtQCReservationEntry extends "QC Reservation Entry"

{
    DrillDownPageID = "Posted Item QC Tracking Line2"; //P_ISPL-SPLIT_Q2025
    LookupPageID = "Posted Item QC Tracking Line2";

    fields
    {

        modify("Quantity (Base)")
        {


            trigger OnBeforeValidate()
            begin
                Quantity := CalcReservationQuantity();
                "Qty. to Handle (Base)" := "Quantity (Base)";
                "Qty. to Invoice (Base)" := "Quantity (Base)";
            end;
        }

        modify("Qty. per Unit of Measure")
        {
            trigger OnBeforeValidate()
            begin
                Quantity := ROUND("Quantity (Base)" / "Qty. per Unit of Measure", 0.00001);
            end;
        }

        modify("Rejection Reason")
        {

            trigger OnBeforeValidate()
            var
                Reason_lRec: Record "Reason Code";
            begin
                if Reason_lRec.Get(Rec."Rejection Reason") then
                    Rec."Rejection Reason Description" := Reason_lRec.Description
                else
                    Rec."Rejection Reason Description" := '';
            end;
        }

    }

    keys
    {

    }

    fieldgroups
    {

    }

    trigger OnAfterDelete()
    var
        ActionMessageEntry: Record "Action Message Entry";
    begin
        ActionMessageEntry.SetCurrentkey("Reservation Entry");
        ActionMessageEntry.SetRange("Reservation Entry", "Entry No.");
        ActionMessageEntry.DeleteAll;
    end;

    var
        Text001: label 'Line';

    procedure TextCaption(): Text[255]
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        ReqLine: Record "Requisition Line";
        PurchLine: Record "Purchase Line";
        ItemJnlLine: Record "Item Journal Line";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        TransLine: Record "Transfer Line";
        ServLine: Record "Service Line";
        JobJnlLine: Record "Job Journal Line";
    begin
        case "Source Type" of
            Database::"Item Ledger Entry":
                exit(ItemLedgEntry.TableCaption);
            Database::"Sales Line":
                exit(SalesLine.TableCaption);
            Database::"Requisition Line":
                exit(ReqLine.TableCaption);
            Database::"Purchase Line":
                exit(PurchLine.TableCaption);
            Database::"Item Journal Line":
                exit(ItemJnlLine.TableCaption);
            Database::"Job Journal Line":
                exit(JobJnlLine.TableCaption);
            Database::"Prod. Order Line":
                exit(ProdOrderLine.TableCaption);
            Database::"Prod. Order Component":
                exit(ProdOrderComp.TableCaption);
            Database::"Assembly Header":
                exit(AssemblyHeader.TableCaption);
            Database::"Assembly Line":
                exit(AssemblyLine.TableCaption);
            Database::"Transfer Line":
                exit(TransLine.TableCaption);
            Database::"Service Line":
                exit(ServLine.TableCaption);
            //DATABASE::"Applied Delivery Challan Entry":
            //  EXIT(AppDelChallan.TABLECAPTION);
            else
                exit(Text001);
        end;
    end;

    procedure SummEntryNo(): Integer
    begin
        case "Source Type" of
            Database::"Item Ledger Entry":
                exit(1);
            Database::"Purchase Line":
                exit(11 + "Source Subtype");
            Database::"Requisition Line":
                exit(21);
            Database::"Sales Line":
                exit(31 + "Source Subtype");
            Database::"Item Journal Line":
                exit(41 + "Source Subtype");
            Database::"Job Journal Line":
                exit(51 + "Source Subtype");
            Database::"Prod. Order Line":
                exit(61 + "Source Subtype");
            Database::"Prod. Order Component":
                exit(71 + "Source Subtype");
            Database::"Transfer Line":
                exit(101 + "Source Subtype");
            Database::"Service Line":
                exit(110);
            Database::"Assembly Header":
                exit(141 + "Source Subtype");
            Database::"Assembly Line":
                exit(151 + "Source Subtype");
            else
                exit(0);
        end;
    end;

    procedure SetPointer(RowID: Text[250])
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        StrArray: array[6] of Text[100];
    begin
        ItemTrackingMgt.DecomposeRowID(RowID, StrArray);
        Evaluate("Source Type", StrArray[1]);
        Evaluate("Source Subtype", StrArray[2]);
        "Source ID" := StrArray[3];
        "Source Batch Name" := StrArray[4];
        Evaluate("Source Prod. Order Line", StrArray[5]);
        Evaluate("Source Ref. No.", StrArray[6]);
    end;

    procedure Lock()
    var
        Rec2: Record "Reservation Entry";
    begin
        Rec2.SetCurrentkey("Item No.");
        if "Item No." <> '' then
            Rec2.SetRange("Item No.", "Item No.");
        Rec2.LockTable;
        if Rec2.FindLast then;
    end;

    procedure UpdateItemTracking()
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        //"Item Tracking" := ItemTrackingMgt.ItemTrackingOption("Lot No.", "Serial No.");
        "Item Tracking" := Rec.GetItemTrackingEntryType().AsInteger();
    end;

    procedure ClearItemTrackingFields()
    begin
        "Lot No." := '';
        "Serial No." := '';
        UpdateItemTracking;
    end;

    procedure FilterLinesWithItemToPlan(var Item: Record Item; IsReceipt: Boolean)
    begin
        Reset;
        SetCurrentkey(
          "Item No.", "Variant Code", "Location Code", "Reservation Status", "Shipment Date", "Expected Receipt Date");
        SetRange("Item No.", Item."No.");
        SetFilter("Variant Code", Item.GetFilter("Variant Filter"));
        SetFilter("Location Code", Item.GetFilter("Location Filter"));
        SetRange("Reservation Status", "reservation status"::Reservation);
        SetFilter(Binding, '<>%1', Binding::"Order-to-Order");
        if IsReceipt then
            SetFilter("Expected Receipt Date", Item.GetFilter("Date Filter"))
        else
            SetFilter("Shipment Date", Item.GetFilter("Date Filter"));
        SetFilter("Quantity (Base)", '<>0');
    end;

    procedure FindLinesWithItemToPlan(var Item: Record Item; IsReceipt: Boolean): Boolean
    begin
        FilterLinesWithItemToPlan(Item, IsReceipt);
        exit(Find('-'));
    end;

    procedure LinesWithItemToPlanExist(var Item: Record Item; IsReceipt: Boolean): Boolean
    begin
        FilterLinesWithItemToPlan(Item, IsReceipt);
        exit(not IsEmpty);
    end;

    local procedure CalcReservationQuantity(): Decimal
    var
        ReservEntry: Record "Reservation Entry";
    begin
        if "Qty. per Unit of Measure" = 1 then
            exit("Quantity (Base)");

        ReservEntry.SetFilter("Entry No.", '<>%1', "Entry No.");
        ReservEntry.SetRange("Source ID", "Source ID");
        ReservEntry.SetRange("Source Batch Name", "Source Batch Name");
        ReservEntry.SetRange("Source Ref. No.", "Source Ref. No.");
        ReservEntry.SetRange("Source Type", "Source Type");
        ReservEntry.SetRange("Source Subtype", "Source Subtype");
        ReservEntry.SetRange("Source Prod. Order Line", "Source Prod. Order Line");
        ReservEntry.SetRange("Reservation Status", "reservation status"::Reservation);
        ReservEntry.CalcSums("Quantity (Base)", Quantity);
        exit(
          ROUND((ReservEntry."Quantity (Base)" + "Quantity (Base)") / "Qty. per Unit of Measure", 0.00001) -
          ReservEntry.Quantity);
    end;

    procedure GetItemTrackingEntryType() TrackingEntryType: Enum "Item Tracking Entry Type"
    begin
        if "Lot No." <> '' then TrackingEntryType := "Item Tracking Entry Type"::"Lot No.";
        if "Serial No." <> '' then
            if "Lot No." <> '' then
                TrackingEntryType := "Item Tracking Entry Type"::"Lot and Serial No."
            else
                TrackingEntryType := "Item Tracking Entry Type"::"Serial No.";
    end;
}

