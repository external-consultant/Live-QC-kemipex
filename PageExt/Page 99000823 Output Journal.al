PageExtension 75417 Output_Journal_75417 extends "Output Journal"
{
    layout
    {
        addafter("Output Quantity")
        {
            field("Accepted Quantity"; Rec."Accepted Quantity")
            {
                ApplicationArea = Basic;
                Editable = false;
            }
            field("Qty Accepted with Deviation"; Rec."Qty Accepted with Deviation")
            {
                ApplicationArea = Basic;
                Editable = false;
            }
            field("QC No."; Rec."QC No.")
            {
                ApplicationArea = Basic;
            }
        }
    }
    actions
    {

        addafter("Bin Contents")
        {
            action("Create QC Rcpt")
            {
                ApplicationArea = Basic;
                Image = QualificationOverview;

                trigger OnAction()
                var
                    QCProduction_lCdu: Codeunit "Quality Control - Production";
                    ItemJnlLineReserve_lCdu: Codeunit "Item Jnl. Line-Reserve";
                    ReservationEntry: Record "Reservation Entry";
                    Text006Err: Label 'You cannot define item tracking on %1 %2', Comment = '%1 - Operation No. caption, %2 - Operation No. value';
                    NextFlag_lBol: Boolean;
                begin
                    //I-C0009-1001310-04-NS
                    Clear(QCProduction_lCdu);
                    //ItemJnlLineReserve_lCdu.CallItemTracking(Rec, false);
                    if not rec.ItemPosting() then begin
                        ReservationEntry.InitSortingAndFilters(false);
                        rec.SetReservationFilters(ReservationEntry);
                        ReservationEntry.ClearTrackingFilter();
                        if ReservationEntry.IsEmpty() then
                            NextFlag_lBol := true;
                    end;
                    if not NextFlag_lBol then
                        QCProduction_lCdu.CheckItemTrackingLines_ForOutput(rec);//T12212-ABA-N
                    QCProduction_lCdu.CreateQC_gFnc(Rec);
                    //I-C0009-1001310-04-NE
                end;
            }
            action("Go to QC Rcpt")
            {
                ApplicationArea = Basic;
                Image = Questionaire;

                trigger OnAction()
                var
                    QCProduction_lCdu: Codeunit "Quality Control - Production";
                begin
                    //I-C0009-1001310-04-NS
                    Clear(QCProduction_lCdu);
                    QCProduction_lCdu.ShowQCRcpt_gFnc(Rec);
                    //I-C0009-1001310-04-NE
                end;
            }
            // action("ISPL-QC Creation")
            // {
            //     ApplicationArea = Basic;
            //     Image = QualificationOverview;

            //     trigger OnAction()
            //     var
            //         QCProduction_lCdu: Codeunit "Quality Control - ProdISPL";
            //         ItemJnlLineReserve_lCdu: Codeunit "Item Jnl. Line-Reserve";
            //         ReservationEntry: Record "Reservation Entry";
            //         Text006Err: Label 'You cannot define item tracking on %1 %2', Comment = '%1 - Operation No. caption, %2 - Operation No. value';
            //         NextFlag_lBol: Boolean;
            //     begin
            //         //I-C0009-1001310-04-NS
            //         Clear(QCProduction_lCdu);
            //         //ItemJnlLineReserve_lCdu.CallItemTracking(Rec, false);
            //         if not rec.ItemPosting() then begin
            //             ReservationEntry.InitSortingAndFilters(false);
            //             rec.SetReservationFilters(ReservationEntry);
            //             ReservationEntry.ClearTrackingFilter();
            //             if ReservationEntry.IsEmpty() then
            //                 NextFlag_lBol := true;
            //         end;
            //         if not NextFlag_lBol then
            //             QCProduction_lCdu.CheckItemTrackingLines_ForOutput(rec);//T12212-ABA-N
            //         QCProduction_lCdu.CreateQC_gFnc(Rec);
            //         //I-C0009-1001310-04-NE
            //     end;
            // }
        }
    }
}

