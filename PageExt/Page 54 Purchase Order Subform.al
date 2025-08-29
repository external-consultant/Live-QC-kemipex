pageextension 75396 PurchaseOrderSubformExt extends "Purchase Order Subform"
{
    //T12547-NS
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
                    rec.TestField("Pre-Receipt Inspection", false);
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


        addafter("Qty. to Invoice")
        {
            field("Pre-Receipt Inspection Req"; rec."Pre-Receipt Inspection")
            {
                ApplicationArea = all;
                Editable = PreReceiptEditable_Bln;
                Visible = ViewPurchaseOrderQC_gBln;
                trigger OnValidate()
                var
                    Vendor_lRec: Record Vendor;
                begin

                    if Rec."Pre-Receipt Inspection" then begin
                        Rec.TestField("Drop Shipment", false);
                        Vendor_lRec.get(Rec."Buy-from Vendor No.");
                        if Vendor_lRec."IC Partner Code" <> '' then
                            Error('system not allow to create the QC for Pre-Receipt.');

                    end;
                end;

            }
            field("Total No. of QC"; rec."Total No. of QC")
            {
                ApplicationArea = All;
                Visible = ViewPurchaseOrderQC_gBln;
            }
            field("Total No. of Posted QC"; rec."Total No. of Posted QC")
            {
                ApplicationArea = All;
                Visible = ViewPurchaseOrderQC_gBln;
            }
            field("QC Accepted Qty"; Rec."QC Accepted Qty")
            {
                ApplicationArea = All;
                Visible = ViewPurchaseOrderQC_gBln;
            }
            field("QC Rejected Qty"; Rec."QC Rejected Qty")
            {
                ApplicationArea = All;
                Visible = ViewPurchaseOrderQC_gBln;
            }
            //Hypercare-06-03-2025-NS
            field(Inspection; Rec.Inspection)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Inspection field.', Comment = '%';
            }
            //Hypercare-06-03-2025-NE
        }
    }

    actions
    {

        addafter("Item Availability by")
        {
            group("Pre-Receipt QC")
            {
                Caption = 'Pre-Receipt QC';
                Image = QualificationOverview;

                action("QC Creation")
                {
                    ApplicationArea = All;
                    Caption = 'QC Creation';
                    Image = Create;
                    Visible = ViewPurchaseOrderQC_gBln;
                    trigger OnAction()
                    var
                        SalesHeader_lRec: Record "Sales Header";
                        SalesLine_lRec: Record "Sales Line";
                        DocumentNo_lCod: Code[20];
                        Result_lBln: Boolean;
                        QuualityControlMgmt_lCdu: Codeunit "Quality Control Pre-Receipt";
                    begin
                        QuualityControlMgmt_lCdu.CreateQCRcpt_gFnc(Rec, True, False);
                    end;
                }
                action("QC for Rejection")
                {
                    ApplicationArea = All;
                    Caption = 'QC for Rejection';
                    Visible = RejectionVisible_Bln;
                    trigger OnAction()
                    var
                        SalesHeader_lRec: Record "Sales Header";
                        SalesLine_lRec: Record "Sales Line";
                        DocumentNo_lCod: Code[20];
                        Result_lBln: Boolean;
                        QuualityControlMgmt_lCdu: Codeunit "Quality Control Pre-Receipt";
                    begin
                        QuualityControlMgmt_lCdu.CreateQCRcpt_gFnc(Rec, True, true);//Third Parameter for Rejection
                    end;
                }



            }
        }
    }
    var
        QCSetup_gRec: Record "Quality Control Setup";
        //[InDataSet]
        PreReceiptEditable_Bln: Boolean;
        RejectionVisible_Bln: Boolean;
        ViewPurchaseOrderQC_gBln: Boolean;


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
        ActivateRejctionButton_lFnc;
    end;


    local procedure Activate_lFnc()
    var
    begin

        QCSetup_gRec.get;
        if QCSetup_gRec."Allow QC in Purchase Order" then
            ViewPurchaseOrderQC_gBln := true
        else
            ViewPurchaseOrderQC_gBln := false;


        if (Rec.Type = Rec.Type::Item) and (Rec."No." <> '') and (Rec."Outstanding Quantity" > 0) and (Rec."Drop Shipment" = false) then
            PreReceiptEditable_Bln := true
        else
            PreReceiptEditable_Bln := false;
        if rec."QC Created" then
            PreReceiptEditable_Bln := false;
    end;

    local procedure ActivateRejctionButton_lFnc()
    var

    begin
        if (Rec."Pre-Receipt Inspection") and (rec."QC Created") and (Rec."QC Rejected Qty" > 0) then
            RejectionVisible_Bln := true
        else
            RejectionVisible_Bln := false;
    end;
    //T12547-ABA-NE

}