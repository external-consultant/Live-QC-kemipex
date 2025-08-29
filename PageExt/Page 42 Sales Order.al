pageextension 75387 "Sales Order Ext" extends "Sales Order"
{

    actions
    {
        addlast("F&unctions")
        {
            //T12113-NB-NS

            group("Predispatch QC")
            {
                Caption = 'Predispatch QC';
                Image = QualificationOverview;

                action("PreDispatch QCs")
                {
                    ApplicationArea = All;
                    Image = View;
                    Visible = ViewSalesOrderQC_gBln;//T12166-N

                    trigger OnAction()
                    var
                        QCReceiptHeader_lRec: Record "QC Rcpt. Header";
                        QCReceiptList_lPag: page "QC Rcpt. List";
                    begin
                        QCReceiptHeader_lRec.Reset();
                        QCReceiptHeader_lRec.SetRange("Document Type", QCReceiptHeader_lRec."Document Type"::"Sales Order");
                        QCReceiptHeader_lRec.SetRange("Document No.", rec."No.");
                        QCReceiptList_lPag.SetTableView(QCReceiptHeader_lRec);
                        QCReceiptList_lPag.Run();
                    end;
                }
                action("Posted PreDispatch QCs")
                {
                    ApplicationArea = All;
                    Caption = 'Posted PreDispatch QCs';
                    Image = View;
                    Visible = ViewSalesOrderQC_gBln;//T12166-N
                    trigger OnAction()
                    var
                        PostedQCReceiptHeader_lRec: Record "Posted QC Rcpt. Header";
                        PostedQCReceiptList_lPag: page "Posted QC Rcpt. List";
                    begin
                        PostedQCReceiptHeader_lRec.Reset();
                        PostedQCReceiptHeader_lRec.SetRange("Document Type", PostedQCReceiptHeader_lRec."Document Type"::"Sales Order");
                        PostedQCReceiptHeader_lRec.SetRange("Document No.", rec."No.");
                        PostedQCReceiptList_lPag.SetTableView(PostedQCReceiptHeader_lRec);
                        PostedQCReceiptList_lPag.Run();
                    end;
                }
                action("Create PreDispatch")
                {
                    ApplicationArea = All;
                    Caption = 'Create PreDispatch';
                    Image = Create;
                    Visible = ViewSalesOrderQC_gBln;//T12166-N


                    trigger OnAction()
                    var
                        SalesHeader_lRec: Record "Sales Header";
                        SalesLine_lRec: Record "Sales Line";
                        DocumentNo_lCod: Text;
                        Result_lBln: Boolean;
                        QualityControlSales_lCdu: Codeunit "Quality Control - Sales";
                    begin
                        if not Confirm('Would you like to create Predispatch with associated SO?') then
                            exit;
                        Clear(Result_lBln);
                        SalesLine_lRec.Reset();
                        SalesLine_lRec.SetRange("Document Type", rec."Document Type");
                        SalesLine_lRec.SetRange("Document No.", rec."No.");
                        SalesLine_lRec.SetRange(type, SalesLine_lRec.Type::Item);
                        SalesLine_lRec.SetRange("PreDispatch Inspection Req", true);
                        SalesLine_lRec.SetRange("QC Created", false);
                        SalesLine_lRec.SetFilter("Outstanding Quantity", '<>%1', 0);
                        if SalesLine_lRec.FindSet() then begin
                            repeat
                                DocumentNo_lCod := QualityControlSales_lCdu.CreateQCRcpt_gFnc(SalesLine_lRec, false, false);
                            until SalesLine_lRec.Next() = 0;
                            if DocumentNo_lCod <> '' then
                                Message('Predispatch QC Receipts %1 Created Successfully.', DocumentNo_lCod);
                        end else
                            Error('PreDispatch Inspection Required Line is not found in Sales Line.');

                    end;
                }
            }
        }
    }
    var
        QCControlSetup_gRec: Record "Quality Control Setup";
        //[InDataSet]
        ViewSalesOrderQC_gBln: Boolean;//T12166

    trigger OnAfterGetRecord()
    var
        myInt: Integer;
    begin
        Activate_lFnc;//T12166-N
    end;

    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        Activate_lFnc;//T12166-N
    end;

    trigger OnAfterGetCurrRecord()
    var
        myInt: Integer;
    begin
        Activate_lFnc;//T12166-N
    end;


    local procedure Activate_lFnc()
    var

    begin
        //T12166-NS
        QCControlSetup_gRec.get;
        if QCControlSetup_gRec."Allow QC in Sales Order" then
            ViewSalesOrderQC_gBln := true
        else
            ViewSalesOrderQC_gBln := false;
        // CurrPage.Update();
        //T12166-NE       
    end;



    procedure GetQCControlSetup_gFnc()
    begin
        QCControlSetup_gRec.Get();
        QCControlSetup_gRec.TestField("PreDispatch QC Nos");
    end;
    //T12113-NB-NE




}