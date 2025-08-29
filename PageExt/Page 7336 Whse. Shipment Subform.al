pageextension 75389 WhseShipmentSubform extends "Whse. Shipment Subform"
{
    layout
    {
        addlast(Control1)
        {
            //T12113-NB-NS
            field("PreDispatch Inspection Req"; rec."PreDispatch Inspection Req")
            {
                ApplicationArea = all;
                Caption = 'Predispatch Inspection Required';
                Visible = ViewSalesOrderQC_gBln;
            }

            //T12113-NB-NE
        }
    }
    actions
    {
    }

    var
        QCControlSetup_gRec: Record "Quality Control Setup";
        //[InDataSet]
        ViewSalesOrderQC_gBln: Boolean;//T12166

    // trigger OnAfterGetRecord()
    // var
    //     myInt: Integer;
    // begin
    //     Activate_lFnc;//T12166-N
    // end;

    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        Activate_lFnc;//T12166-N
    end;

    // trigger OnAfterGetCurrRecord()
    // var
    //     myInt: Integer;
    // begin
    //     Activate_lFnc;//T12166-N
    // end;


    local procedure Activate_lFnc()
    var

    begin
        //T12166-NS
        QCControlSetup_gRec.get;
        if QCControlSetup_gRec."Allow QC in Sales Order" then
            ViewSalesOrderQC_gBln := true
        else
            ViewSalesOrderQC_gBln := false;
        CurrPage.Update();
        //T12166-NE       
    end;


}