pageextension 75397 "Purchase Order Ext" extends "Purchase Order"
{
    //T12547-NS
    actions
    {
        addlast("F&unctions")
        {

            group("Pre-Receipt QC")
            {
                Caption = 'Pre-Receipt QC';
                Image = QualificationOverview;
                Visible = ViewPurchasesOrderQC_gBln;

                action("Pre-Receipt QCs")
                {
                    ApplicationArea = All;
                    Image = View;

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
                    Caption = 'Posted Pre-Receipt QCs';
                    Image = View;
                    trigger OnAction()
                    var
                        PostedQCReceiptHeader_lRec: Record "Posted QC Rcpt. Header";
                        PostedQCReceiptList_lPag: page "Posted QC Rcpt. List";
                    begin
                        PostedQCReceiptHeader_lRec.Reset();
                        PostedQCReceiptHeader_lRec.SetRange("Document Type", PostedQCReceiptHeader_lRec."Document Type"::Purchase);
                        PostedQCReceiptHeader_lRec.SetRange("Document No.", rec."No.");
                        PostedQCReceiptList_lPag.SetTableView(PostedQCReceiptHeader_lRec);
                        PostedQCReceiptList_lPag.Run();
                    end;
                }
                action("Create Pre-Receipt")
                {
                    ApplicationArea = All;
                    Caption = 'Create Pre-Receipt';
                    Image = Create;


                    trigger OnAction()
                    var
                        PurchHeader_lRec: Record "Purchase Header";
                        PurchLine_lRec: Record "Purchase Line";
                        DocumentNo_lCod: Text;
                        Result_lBln: Boolean;
                        QualityControlPurchase_lCdu: Codeunit "Quality Control Pre-Receipt";
                    begin
                        if not Confirm('Would you like to create Pre-Receipt with associated PO?') then
                            exit;
                        Clear(Result_lBln);
                        PurchLine_lRec.Reset();
                        PurchLine_lRec.SetRange("Document Type", rec."Document Type");
                        PurchLine_lRec.SetRange("Document No.", rec."No.");
                        PurchLine_lRec.SetRange(type, PurchLine_lRec.Type::Item);
                        PurchLine_lRec.SetRange("Pre-Receipt Inspection", true);
                        PurchLine_lRec.SetRange("QC Created", false);
                        PurchLine_lRec.SetFilter("Outstanding Quantity", '<>%1', 0);
                        if PurchLine_lRec.FindSet() then begin
                            repeat
                                DocumentNo_lCod := QualityControlPurchase_lCdu.CreateQCRcpt_gFnc(PurchLine_lRec, false, false);
                            until PurchLine_lRec.Next() = 0;
                            if DocumentNo_lCod <> '' then
                                Message('Pre-QC Receipts %1 Created Successfully.', DocumentNo_lCod);
                        end else
                            Error('Pre-Receipt Inspection Required Line is not found in Purchase Line.');

                    end;
                }
            }
        }
    }
    var
        QCControlSetup_gRec: Record "Quality Control Setup";
        //[InDataSet]
        ViewPurchasesOrderQC_gBln: Boolean;

    trigger OnAfterGetRecord()
    var
        myInt: Integer;
    begin
        Activate_lFnc;
    end;

    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        Activate_lFnc;
    end;

    trigger OnAfterGetCurrRecord()
    var
        myInt: Integer;
    begin
        Activate_lFnc;
    end;


    local procedure Activate_lFnc()
    var

    begin

        QCControlSetup_gRec.get;
        if QCControlSetup_gRec."Allow QC in Purchase Order" then
            ViewPurchasesOrderQC_gBln := true
        else
            ViewPurchasesOrderQC_gBln := false;

    end;



    procedure GetQCControlSetup_gFnc()
    begin
        QCControlSetup_gRec.Get();
        QCControlSetup_gRec.TestField("PreDispatch QC Nos");
    end;



    //T12547-NE

}