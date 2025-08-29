PageExtension 75411 Purchase_Rtn_Ord_Subform_75411 extends "Purchase Return Order Subform"
{
    actions
    {
        addafter("Order &Tracking")
        {
            action("Get Rejected QC Lines")
            {
                ApplicationArea = Basic;
                Caption = 'Get Rejected QC Lines';

                trigger OnAction()
                var
                    PostedQCRcpt_lRec: Record "Posted QC Rcpt. Header";
                    PostedQCRcpt_lPag: Page "Posted QC Rcpt. List";
                    PurchHeader_lRec: Record "Purchase Header";
                begin
                    //I-C0009-1001310-05-NS
                    Clear(PurchHeader_lRec);
                    PurchHeader_lRec.Get(Rec."Document Type", Rec."Document No.");
                    Clear(PostedQCRcpt_lPag);
                    PostedQCRcpt_lRec.Reset;
                    Rec.FilterGroup(2);
                    PostedQCRcpt_lRec.SetRange("Document Type", PostedQCRcpt_lRec."document type"::Purchase);
                    PostedQCRcpt_lRec.SetRange("Buy-from Vendor No.", PurchHeader_lRec."Buy-from Vendor No.");
                    PostedQCRcpt_lRec.SetFilter("Rejected Quantity", '>%1', 0);
                    PostedQCRcpt_lRec.SetFilter("Outstanding Returned Qty.", '<>%1', 0);
                    Rec.FilterGroup(0);
                    PostedQCRcpt_lPag.Editable(false);
                    PostedQCRcpt_lPag.LookupMode(true);
                    PostedQCRcpt_lPag.SetTableview(PostedQCRcpt_lRec);
                    if PostedQCRcpt_lPag.RunModal = Action::LookupOK then begin
                        PostedQCRcpt_lPag.SetSelection(PostedQCRcpt_lRec);
                        Rec.InsertRejQCLines_gFnc(PostedQCRcpt_lRec, PurchHeader_lRec);
                    end;
                    //I-C0009-1001310-05-NE
                end;
            }
        }
    }

    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";


    //Unsupported feature: Code Modification on "OnAfterGetCurrRecord".

    //trigger OnAfterGetCurrRecord()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    CLEAR(DocumentTotals);
    UpdateEditableOnRow;
    IF PurchHeader.GET("Document Type","Document No.") THEN;

    DocumentTotals.PurchaseUpdateTotalsControls(Rec,TotalPurchaseHeader,TotalPurchaseLine,RefreshMessageEnabled,
      TotalAmountStyle,RefreshMessageText,InvDiscAmountEditable,VATAmount);
    UpdateCurrency;
    UpdateTypeText;
    SetItemChargeFieldsStyle;
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    #2..4
    DocumentTotals.PurchaseRedistributeInvoiceDiscountAmounts(Rec,VATAmount,TotalPurchaseLine);
    #5..9
    */
    //end;


    //Unsupported feature: Code Modification on "OnAfterGetRecord".

    //trigger OnAfterGetRecord()
    //>>>> ORIGINAL CODE:
    //begin
    /*
    ShowShortcutDimCode(ShortcutDimCode);
    UpdateTypeText;
    SetItemChargeFieldsStyle;
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    ShowShortcutDimCode(ShortcutDimCode);
    CLEAR(DocumentTotals);
    UpdateTypeText;
    SetItemChargeFieldsStyle;
    */
    //end;
}

