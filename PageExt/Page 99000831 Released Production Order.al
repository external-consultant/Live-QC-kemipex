PageExtension 75418 Released_Prod_Order_75418 extends "Released Production Order"
{
    layout
    {
        addafter("Last Date Modified")
        {

            // field("Rejected Quantity (QC)"; Rec."Rejected Quantity (QC)")
            // {
            //     ApplicationArea = Basic;

            //     trigger OnDrillDown()
            //     begin
            //         //QCProduction_lCdu.DrillDownRejProOrder_gFnc(Rec);  //I-C0009-1001310-04-N
            //     end;
            // }
            //12113-ABA-NS

            // field("QC Receipt No"; rec."QC Receipt No")
            // {
            //     ApplicationArea = All;
            // }
            // field("Posted QC Receipt No"; Rec."Posted QC Receipt No")
            // {
            //     ApplicationArea = All;
            // }
            field("Quality Order"; rec."Quality Order")
            {
                ApplicationArea = All;
            }

            field("Posted QC No,"; rec."Posted QC No,")
            {
                ApplicationArea = All;
            }
            //T12542-NS
            field("QC Status"; Rec."QC Status")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Type Of Transaction field.', Comment = '%';
            }
            //T12542-NE
            //12113-ABA-NE
        }
        addafter(Posting)
        {

            group("QC Details") //T12212
            {
                Caption = 'QC Details';
                field("Rework Order No."; rec."Rework Order No.")
                {
                    ApplicationArea = All;
                }
                field("Rework Quantity"; Rec."Rework Quantity")
                {
                    ApplicationArea = All;
                }
                field("QC Receipt No"; Rec."QC Receipt No")
                {
                    ApplicationArea = all;
                }
                field("Posted QC Receipt No"; Rec."Posted QC Receipt No")
                {
                    ApplicationArea = All;
                }
                field("Rejected Quantity (QC)"; Rec."Rejected Quantity (QC)")
                {
                    ApplicationArea = All;
                }
                field("Reject Reason"; rec."Reject Reason")
                {
                    ApplicationArea = All;
                }
                field("Rework Reason"; rec."Rework Reason")
                {
                    ApplicationArea = All;
                }

            }

            group("Rework Order Details") //T12212
            {
                Caption = 'Rework Order Details';

                field("Rework Order"; rec."Rework Order")
                {
                    ApplicationArea = All;

                }
                field("Source Order No."; rec."Source Order No.")
                {
                    ApplicationArea = All;
                }
                field("Source QC No."; rec."Source QC No.")
                {
                    ApplicationArea = All;
                }
                field("Source Posted QC No."; rec."Source Posted QC No.")
                {
                    ApplicationArea = All;
                }
            }

        }
    }

}



