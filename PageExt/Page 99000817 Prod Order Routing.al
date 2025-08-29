PageExtension 75416 Prod_Order_Routing_75416 extends "Prod. Order Routing"
{
    layout
    {
        addafter(Description)
        {
            field("QC Required"; Rec."QC Required")
            {
                ApplicationArea = Basic;
            }
            field("Standard Task Code"; Rec."Standard Task Code")
            {
                ApplicationArea = All;//T12113-N
            }
            field("Finished Quantity"; Rec."Finished Quantity QC")
            {
                ApplicationArea = Basic;
            }
            field("Finished Accepted Quantity"; Rec."Finished Accepted Quantity")
            {
                ApplicationArea = Basic;

                trigger OnDrillDown()
                begin
                    //QCProduction_lCdu.DrillDownFinishAccpQty_gFnc(Rec);  //I-C0009-1001310-04-N
                end;
            }
            field("Finished Acc with Deviation"; Rec."Finished Acc with Deviation")
            {
                ApplicationArea = Basic;

                trigger OnDrillDown()
                begin
                    //QCProduction_lCdu.DrillDownFinishAccpDevQty_gFnc(Rec);  //I-C0009-1001310-04-N
                end;
            }
            field("Finished Rejected Quantity"; Rec."Finished Rejected Quantity")
            {
                ApplicationArea = Basic;

                trigger OnDrillDown()
                begin
                    //QCProduction_lCdu.DrillDownFinishAccpRejQty_gFnc(Rec);  //I-C0009-1001310-04-N
                end;
            }
        }
    }
}

