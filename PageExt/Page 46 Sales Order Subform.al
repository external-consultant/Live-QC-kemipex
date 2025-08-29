pageextension 75385 SalesOrderSubformExt extends "Sales Order Subform"
{
    layout
    {
        modify(Type)
        {
            trigger OnAfterValidate()
            var
                myInt: Integer;
            begin
                Activate_lFnc;
            end;
        }
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                myInt: Integer;
            begin
                Activate_lFnc;
            end;
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            var
                myInt: Integer;
            begin
                Activate_lFnc;
            end;
        }
        modify("Drop Shipment")
        {
            trigger OnBeforeValidate()
            var
                myInt: Integer;
            begin
                if Rec."Drop Shipment" then
                    rec.TestField("PreDispatch Inspection Req", false);
            end;
        }
        // addlast(content)
        // {
        //     field("Outstanding Quantity"; rec."Outstanding Quantity")
        //     {


        //         trigger OnValidate()
        //         var
        //             myInt: Integer;
        //         begin
        //             Activate_lFnc;
        //         end;
        //     }
        // }


        addlast(Control1)
        {
            //T12113-ABA-NS
            field("PreDispatch Inspection Req"; rec."PreDispatch Inspection Req")
            {
                ApplicationArea = all;
                Editable = PredispatchEditable_Bln;
                Visible = ViewSalesOrderQC_gBln;//T12166-N
                trigger OnValidate()
                var
                    Customer_lRec: Record Customer;
                begin

                    if Rec."PreDispatch Inspection Req" then begin
                        Rec.TestField("Drop Shipment", false);
                        Customer_lRec.get(Rec."Sell-to Customer No.");
                        if Customer_lRec."IC Partner Code" <> '' then
                            Error('system not allow to create the QC for Predispatch for Intercompany Transactions.');

                    end;
                end;

            }
            field("Total No. of QC"; rec."Total No. of QC")
            {
                ApplicationArea = All;
                Visible = ViewSalesOrderQC_gBln;//T12166-N
            }
            field("Total No. of Posted QC"; rec."Total No. of Posted QC")
            {
                ApplicationArea = All;
                Visible = ViewSalesOrderQC_gBln;//T12166-N
            }
            field("QC Accepted Qty"; Rec."QC Accepted Qty")
            {
                ApplicationArea = All;
                Visible = ViewSalesOrderQC_gBln;//T12166-N
            }
            field("QC Rejected Qty"; Rec."QC Rejected Qty")
            {
                ApplicationArea = All;
                Visible = ViewSalesOrderQC_gBln;//T12166-N
            }


            //T12113-ABA-NE


        }
    }

    actions
    {

        addafter("Item Availability by")
        {


            group("Predispatch QC")
            {
                Caption = 'Predispatch QC';
                Image = QualificationOverview;

                action("QC Creation")
                {
                    ApplicationArea = All;
                    Caption = 'QC Creation';
                    Image = Create;
                    Visible = ViewSalesOrderQC_gBln;//T12166-N
                    trigger OnAction()
                    var
                        SalesHeader_lRec: Record "Sales Header";
                        SalesLine_lRec: Record "Sales Line";
                        DocumentNo_lCod: Code[20];
                        Result_lBln: Boolean;
                        QuualityControlMgmt_lCdu: Codeunit "Quality Control - Sales";
                    begin
                        QuualityControlMgmt_lCdu.CreateQCRcpt_gFnc(Rec, True, False);
                    end;
                }
                action("QC for Rejection")
                {
                    ApplicationArea = All;
                    Caption = 'QC for Rejection';
                    //Image = Reject;
                    Visible = RejectionVisible_Bln;
                    trigger OnAction()
                    var
                        SalesHeader_lRec: Record "Sales Header";
                        SalesLine_lRec: Record "Sales Line";
                        DocumentNo_lCod: Code[20];
                        Result_lBln: Boolean;
                        QuualityControlMgmt_lCdu: Codeunit "Quality Control - Sales";
                    begin
                        QuualityControlMgmt_lCdu.CreateQCRcpt_gFnc(Rec, True, true);//Third Parameter for Rejection
                    end;
                }



            }
        }
    }
    var
        QCSetup_gRec: Record "Quality Control Setup";//T12166
        //[InDataSet]
        PredispatchEditable_Bln: Boolean;
        RejectionVisible_Bln: Boolean;
        ViewSalesOrderQC_gBln: Boolean;//T12166


    trigger OnAfterGetRecord()
    begin
        Activate_lFnc;
        ActivateRejctionButton_lFnc;
    end;

    trigger OnAfterGetcurrRecord()
    begin
        Activate_lFnc;
        ActivateRejctionButton_lFnc;
    end;

    trigger OnOpenPage()
    begin
        // Activate_lFnc;
        ActivateRejctionButton_lFnc;
    end;

    //T12113-ABA-NS
    local procedure Activate_lFnc()
    var

    begin
        //T12166-NS
        QCSetup_gRec.get;
        if QCSetup_gRec."Allow QC in Sales Order" then
            ViewSalesOrderQC_gBln := true
        else
            ViewSalesOrderQC_gBln := false;
        //T12166-NE

        if (Rec.Type = Rec.Type::Item) and (Rec."No." <> '') and (Rec."Outstanding Quantity" > 0) and (Rec."Drop Shipment" = false) then
            PredispatchEditable_Bln := true
        else
            PredispatchEditable_Bln := false;
        if rec."QC Created" then
            PredispatchEditable_Bln := false;

    end;

    local procedure ActivateRejctionButton_lFnc()
    var

    begin
        if (Rec."PreDispatch Inspection Req") and (rec."QC Created") and (Rec."QC Rejected Qty" > 0) then
            RejectionVisible_Bln := true
        else
            RejectionVisible_Bln := false;
    end;
    //T12113-ABA-NE

}