PageExtension 75419 Item_Card_75419 extends "Item Card"
{
    layout
    {

        addafter(Warehouse)
        {

            group("Quality Control")
            {

                Caption = 'Quality Control';
                field("Item Specification Code"; Rec."Item Specification Code")
                {
                    ApplicationArea = Basic;
                }
                // field("QC Required"; Rec."QC Required")
                // {
                //     ApplicationArea = Basic;//T12113-ABA-O
                // }
                field("Sampling Plan"; Rec."Sampling Plan")
                {
                    ApplicationArea = Basic;
                }
                field(Sample; Rec.Sample)
                {
                    ApplicationArea = Basic;
                }
                field("Entry for each Sample"; Rec."Entry for each Sample")
                {
                    ApplicationArea = Basic;
                }
                //T12113-ABA-NS
                field("QC Parameter Item"; Rec."QC Parameter Item")
                {
                    ApplicationArea = All;
                    Visible = QualityOrderVisible_gBol;//T12479-N
                }
                field("Allow QC in GRN"; Rec."Allow QC in GRN")
                {
                    ApplicationArea = All;
                }
                field("Allow QC in Production"; rec."Allow QC in Production")
                {
                    ApplicationArea = All;
                }
                field("Allow QC in Sales Return"; Rec."Allow QC in Sales Return")
                {
                    ApplicationArea = All;
                }
                field("Allow QC in Transfer Receipt"; Rec."Allow QC in Transfer Receipt")
                {
                    ApplicationArea = All;
                }
                field("Allow to Retest Material"; Rec."Allow to Retest Material")
                {
                    ApplicationArea = All;
                    Visible = QCRetestVisible_gBol;
                }
                //T12113-ABA-NE
                field("COA Applicable"; Rec."COA Applicable")
                {
                    ApplicationArea = All;
                    Description = 'T51170';
                }


            }
        }
        addafter("Qty. on Component Lines")
        {
            //T12971-NS 02122024
            field("Item on QC Location"; Rec."Item on QC Location")
            {
                ApplicationArea = All;
            }
            //T12971-NE 02122024
        }
    }
    actions
    {

        //Unsupported feature: Property Modification (RunPageLink) on "Action 80".


        //Unsupported feature: Property Modification (RunPageView) on "Action 105".


        //Unsupported feature: Property Modification (RunPageLink) on "Action 75".


        //Unsupported feature: Property Modification (RunPageLink) on "Action 184".


        //Unsupported feature: Property Modification (RunPageLink) on "Action 117".


        //Unsupported feature: Property Modification (RunPageLink) on "Action 158".


        //Unsupported feature: Property Modification (RunPageLink) on "Action 110".


        //Unsupported feature: Property Modification (RunPageLink) on "Action 77".


        //Unsupported feature: Property Modification (RunPageLink) on "Action 69".


        //Unsupported feature: Property Modification (RunPageLink) on "Action 108".


        //Unsupported feature: Property Modification (RunPageLink) on "Action 111".


        //Unsupported feature: Property Modification (RunPageLink) on "Action 106".


        //Unsupported feature: Property Modification (RunPageLink) on "Action 87".


        //Unsupported feature: Property Modification (RunPageLink) on "Action 191".


        //Unsupported feature: Property Modification (RunPageLink) on "Action 83".


        //Unsupported feature: Property Modification (RunPageLink) on "Action 163".


        //Unsupported feature: Property Modification (RunPageLink) on "Action 96".


        //Unsupported feature: Property Modification (RunPageLink) on "Action 185".


        //Unsupported feature: Property Modification (RunPageLink) on "Action 187".

    }
    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        QualityOrderVisible_lFnc //T12479
    end;

    var
        QualityOrderVisible_gBol: Boolean;//T12479-N
        QCRetestVisible_gBol: Boolean;

    local procedure QualityOrderVisible_lFnc()//T12479-N
    Var
        QCSetup_lRec: Record "Quality Control Setup";
    begin
        QCSetup_lRec.get;
        if QCSetup_lRec."Quality Order with QC Item" then
            QualityOrderVisible_gBol := true
        else
            QualityOrderVisible_gBol := false;

        if QCSetup_lRec."Allow Retest QC" then
            QCRetestVisible_gBol := true
        else
            QCRetestVisible_gBol := false;



    end;


}

