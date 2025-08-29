PageExtension 75409 Location_Card_75409 extends "Location Card"
{
    layout
    {
        addafter("Pick According to FEFO")
        {
            group("Quality Control")
            {
                Caption = 'Quality Control';

                field("Purchase QC Nos."; Rec."Purchase QC Nos.")
                {
                    ApplicationArea = Basic;
                    Visible = Visible_gBln;

                }
                field("Posted Purchase  QC Nos."; Rec."Posted Purchase  QC Nos.")
                {
                    ApplicationArea = Basic;
                    Visible = Visible_gBln;
                }
                field("Prodution QC Nos."; Rec."Prodution QC Nos.")
                {
                    ApplicationArea = Basic;
                    Visible = Visible_gBln;
                }
                field("Post Productiuon QC Nos."; Rec."Post Productiuon QC Nos.")
                {
                    ApplicationArea = Basic;
                    Visible = Visible_gBln;
                }
                field("QC Location"; Rec."QC Location")
                {
                    ApplicationArea = Basic;
                    Visible = Visible_gBln;
                }
                field("Rework Location"; Rec."Rework Location")
                {
                    ApplicationArea = Basic;


                }
                field("Accept Bin Code"; Rec."Accept Bin Code")
                {
                    ApplicationArea = Basic;
                    Visible = Visible_gBln;
                }
                field("QC Category"; Rec."QC Category")
                {
                    ApplicationArea = Basic;
                    Visible = Visible_gBln;
                }
                field("Rejection Category"; Rec."Rejection Category")
                {
                    ApplicationArea = Basic;


                    trigger OnValidate()
                    begin
                        //I-C0009-1001310-04-NS
                        if Rec."Rejection Category" then begin
                            Rec."Rejection Location" := '';
                            Editable_gBln := false;
                        end
                        else begin
                            Editable_gBln := true;
                        end;
                        //I-C0009-1001310-04-NE
                    end;
                }
                field("Rejection Location"; Rec."Rejection Location")
                {
                    ApplicationArea = Basic;

                }
                field("Is Main Location"; Rec."Is Main Location")
                {
                    ApplicationArea = Basic;

                }
                field("Main Location"; Rec."Main Location")
                {
                    ApplicationArea = Basic;

                }
                field("Allow QC in Sales Return"; Rec."Allow QC in Sales Return")
                {
                    ApplicationArea = Basic;
                    Visible = Visible_gBln;
                }
                field("Sales Return QC No."; Rec."Sales Return QC No.")
                {
                    ApplicationArea = Basic;
                    Visible = Visible_gBln;
                }
                field("Posted Sales Return QC No."; Rec."Posted Sales Return QC No.")
                {
                    ApplicationArea = Basic;
                    Visible = Visible_gBln;
                }
                field("Allow QC in Transfer Receipt"; Rec."Allow QC in Transfer Receipt")
                {
                    ApplicationArea = Basic;

                    Visible = Visible_gBln;
                }
                field("Transfer Receipt QC No."; Rec."Transfer Receipt QC No.")
                {
                    ApplicationArea = Basic;
                    Visible = Visible_gBln;
                }
                field("Posted Transfer Receipt QC No."; Rec."Posted Transfer Receipt QC No.")
                {
                    ApplicationArea = Basic;
                    Visible = Visible_gBln;
                }
            }
        }
    }

    //T12971-NS 02122024
    local procedure QCBlockwithoutLocControl_lFun()
    var
        QCSetup_lRec: Record "Quality Control Setup";
    begin

        QCSetup_lRec.Get;
        if QCSetup_lRec."QC Block without Location" then
            Visible_gBln := false
        else
            Visible_gBln := true;
    end;

    trigger OnOpenPage()
    begin
        QCBlockwithoutLocControl_lFun;
    end;

    //T12971-NE 02122024

    var
        Editable_gBln: Boolean;
        Visible_gBln: Boolean;

}

