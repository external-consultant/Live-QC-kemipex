pageextension 75393 PgeExt_75393 extends "Sales Return Order Subform"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter("Order &Tracking")
        {
            action("Reservation Notification")
            {
                ApplicationArea = Basic;
                Caption = '&Reservation Notification';
                Image = OneNote;

                trigger OnAction()
                begin
                    QCReservationMsg_gFnc(Rec);
                end;

            }
        }
    }

    procedure QCReservationMsg_gFnc(var SalesReturnRcptLine_iRec: Record "Sales Line")
    var
        QCSetup_lRec: Record "Quality Control Setup";
        SalesReturnRcptHeader_lRec: Record "Return Receipt Header";
        SalesReturnRcptLine_lRec: Record "Return Receipt Line";
        ReservEntry: Record "Reservation Entry";
        NewReservEntry: Record "Reservation Entry";
        DocNo_lTxt: Text;
    begin
        //T12113-NS
        QCSetup_lRec.Get;
        Clear(DocNo_lTxt);
        ReservEntry.reset;
        ReservEntry.SetRange("Source ID", SalesReturnRcptLine_iRec."Document No.");//filter
        ReservEntry.SETRANGE("Item No.", SalesReturnRcptLine_iRec."No.");//filter
        ReservEntry.Setrange("Source Subtype", ReservEntry."Source Subtype"::"5");
        ReservEntry.SETRANGE("Reservation Status", "Reservation Status"::Reservation);
        if ReservEntry.FindSet() then
            repeat
                NewReservEntry.reset;
                NewReservEntry.SetRange("Entry No.", ReservEntry."Entry No.");//filter
                NewReservEntry.SetFilter("Source ID", '<>%1', ReservEntry."Source ID");
                NewReservEntry.SETRANGE("Item No.", ReservEntry."Item No.");//filter
                NewReservEntry.Setfilter("Source Subtype", '<>%1', ReservEntry."Source Subtype"::"5");
                NewReservEntry.SETRANGE("Reservation Status", "Reservation Status"::Reservation);
                if NewReservEntry.FindSet() then begin
                    IF DocNo_lTxt <> '' THEN
                        DocNo_lTxt := DocNo_lTxt + '|' + TextCaption_lFnc(NewReservEntry) + ',' + NewReservEntry."Source ID"
                    ELSE
                        DocNo_lTxt := TextCaption_lFnc(NewReservEntry) + ',' + NewReservEntry."Source ID";
                end;
            until ReservEntry.Next() = 0;
        if DocNo_lTxt <> '' then
            Message(Text0005_gCtx, SalesReturnRcptLine_iRec."No.", DocNo_lTxt);
        //T12113-NE
    end;

    procedure TextCaption_lFnc(ReservEntry_iRec: Record "Reservation Entry"): Text
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        ReqLine: Record "Requisition Line";
        PurchLine: Record "Purchase Line";
        ItemJnlLine: Record "Item Journal Line";
        JobJnlLine: Record "Job Journal Line";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        TransLine: Record "Transfer Line";
        ServLine: Record "Service Line";
        AppDelChallan: Record "Applied Delivery Challan Entry";


    begin
        //TextCaption() : Text[255]
        CASE ReservEntry_iRec."Source Type" OF
            DATABASE::"Item Ledger Entry":
                EXIT(ItemLedgEntry.TABLECAPTION);
            DATABASE::"Sales Line":
                EXIT(SalesLine.TABLECAPTION);
            DATABASE::"Requisition Line":
                EXIT(ReqLine.TABLECAPTION);
            DATABASE::"Purchase Line":
                EXIT(PurchLine.TABLECAPTION);
            DATABASE::"Item Journal Line":
                EXIT(ItemJnlLine.TABLECAPTION);
            DATABASE::"Job Journal Line":
                EXIT(JobJnlLine.TABLECAPTION);
            DATABASE::"Prod. Order Line":
                EXIT(ProdOrderLine.TABLECAPTION);
            DATABASE::"Prod. Order Component":
                EXIT(ProdOrderComp.TABLECAPTION);
            DATABASE::"Assembly Header":
                EXIT(AssemblyHeader.TABLECAPTION);
            DATABASE::"Assembly Line":
                EXIT(AssemblyLine.TABLECAPTION);
            DATABASE::"Transfer Line":
                EXIT(TransLine.TABLECAPTION);
            DATABASE::"Service Line":
                EXIT(ServLine.TABLECAPTION);
            DATABASE::"Applied Delivery Challan Entry":
                EXIT(AppDelChallan.TABLECAPTION);

        END;
    end;

    var
        myInt: Integer;
        Text0005_gCtx: label 'Please be informed that due to Quality Control requirements for Item No: %1, the system will halt Reservation entries associated with Document Type and Document No. %2. \This is an acknowledgment message for your attention.';//T12113-N
}