Page 75381 "Quality Control Setup"
{
    // ------------------------------------------------------------------------------------------------------------------------------
    // Intech-Systems-info@intech-systems.com
    // ------------------------------------------------------------------------------------------------------------------------------
    // ID                     DATE        AUTHOR
    // ------------------------------------------------------------------------------------------------------------------------------
    // I-C0009-1001310-04     27/08/12    Dipak Patel/Nilesh Gajjar
    //                        QC Module - Redesign Released.
    // I-C0009-1400405-01     05/08/14    Chintan Panchal
    //                        Upgrade to NAV 2013 R2
    // I-C0009-1001310-05     22/10/14    Chintan Panchal
    //                        QC Module - Redesign Released(Sales Return Receipt QC).
    //                        Added new Tab "Sales Return Receipt" for Sales Return Rcpt QC
    // I-C0009-1001310-06     31/10/14    Chintan Panchal
    //                        QC Module - Redesign Released(Transfer Receipt QC).
    //                        Added new Tab "Transfer Receipt"
    // I-C0009-1001310-08     29/11/14    Chintan Panchal
    //                        QC Enhancement.
    //                        Added Fields "Allow QC in GRN","Allow QC in Production","Allow QC in Sales Return","Allow QC in Transfer Receipt"
    // ------------------------------------------------------------------------------------------------------------------------------

    PageType = Card;
    SourceTable = "Quality Control Setup";
    UsageCategory = Lists;
    ApplicationArea = all;
    RefreshOnActivate = true;
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("QC Specification Nos."; Rec."QC Specification Nos.")
                {
                    ApplicationArea = Basic;
                }
                field("Word Doc Nos."; Rec."Word Doc Nos.")
                {
                    ApplicationArea = Basic;
                }
                field("Automatic QC Bin Selection"; Rec."Automatic QC Bin Selection")
                {
                    ApplicationArea = Basic;
                }
                field("QC Block without Location"; Rec."QC Block without Location")
                {
                    ToolTip = 'Specifies the value of the QC Block without Location field.', Comment = '%';
                    Description = 'T12750';
                }
                // field("Pur.Receipt QC itemVendor Cat."; rec."Pur.Rcpt QC itemVenCat.")
                // {
                //     ToolTip = 'Specifies the value of the Pur.Rcpt QC itemVenCat. field.', Comment = '%';
                //     Description = 'T13134';
                // }
                field("QC Journal Template Name"; Rec."QC Journal Template Name")
                {
                    ApplicationArea = Basic;
                }
                field("QC General Batch Name"; Rec."QC General Batch Name")
                {
                    ApplicationArea = Basic;
                }
                field("QA Manager"; Rec."QA Manager")
                {
                    ApplicationArea = Basic;
                }
                field("QA Mobile number"; Rec."QA Mobile number")
                {
                    ApplicationArea = Basic;
                }
            }
            group(Purchase)
            {
                Caption = 'Purchase';
                // field("Allow QC in GRN"; Rec."Allow QC in GRN")
                // {
                //     ApplicationArea = Basic;//T12113-ABA-O
                // }
                field("Auto Create QC on GRN"; Rec."Auto Create QC on GRN")
                {
                    ApplicationArea = Basic;
                }
                field("Purchase QC Nos."; Rec."Purchase QC Nos.")
                {
                    ApplicationArea = Basic;
                }
                field("Posted Purchase  QC Nos."; Rec."Posted Purchase  QC Nos.")
                {
                    ApplicationArea = Basic;
                }
                field("Allow QC in Purchase Order"; Rec."Allow QC in Purchase Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow QC for  Pre-receipt Verification on Purchase Order.';
                }
                field("Pre-Receipt QC Nos"; Rec."Pre-Receipt QC Nos")
                {
                    ToolTip = 'Specifies the value of the Pre-Receipt QC Nos field.', Comment = '%';
                }
                field("Posted Pre-Receipt QC Nos"; Rec."Posted Pre-Receipt QC Nos")
                {
                    ToolTip = 'Specifies the value of the Posted Pre-Receipt QC Nos field.', Comment = '%';
                }
            }
            group(Production)
            {
                Caption = 'Production';
                // field("Allow QC in Production"; Rec."Allow QC in Production")
                // {
                //     ApplicationArea = Basic;//T12113-O
                // }
                field("Automatic Posting of Prod QC"; Rec."Automatic Posting of Prod QC")
                {
                    ApplicationArea = Basic;
                }
                field("Prodution QC Nos."; Rec."Prodution QC Nos.")
                {
                    ApplicationArea = Basic;
                }
                field("Post Productiuon QC Nos."; Rec."Post Productiuon QC Nos.")
                {
                    ApplicationArea = Basic;
                }
                field("Book Out for RejQty Production"; Rec."Book Out for RejQty Production")
                {
                    ApplicationArea = Basic;
                }
                field("Book Out for RewQty Production"; Rec."Book Out for RewQty Production")
                {
                    ApplicationArea = Basic;
                }
                //T07638-NS
                field("Rework Location Pro. Order"; Rec."Rework Location Pro. Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rework Location Pro. Order field.';
                }
                field("Rework Order Nos."; Rec."Rework Order Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rework Order Nos. field.';
                }
                field("Restrict Excess Qty. Output"; Rec."Restrict Excess Qty. Output")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Restrict Excess Quantity Output field.';
                }

                //T07638-NE
            }
            group("Sales Return Receipt")
            {
                Caption = 'Sales Return Receipt';
                // field("Allow QC in Sales Return"; Rec."Allow QC in Sales Return")
                // {
                //     ApplicationArea = Basic;//T12113-O
                // }
                field("Auto Create QC on Sales Return"; Rec."Auto Create QC on Sales Return")
                {
                    ApplicationArea = Basic;
                }
                field("Sales Return QC Nos."; Rec."Sales Return QC Nos.")
                {
                    ApplicationArea = Basic;
                }
                field("Posted Sales Return QC Nos."; Rec."Posted Sales Return QC Nos.")
                {
                    ApplicationArea = Basic;
                }
            }
            group("Transfer Receipt")
            {
                Caption = 'Transfer Receipt';
                // field("Allow QC in Transfer Receipt"; Rec."Allow QC in Transfer Receipt")
                // {
                //     ApplicationArea = Basic;//T12113-ABA-O
                // }
                field("Auto CreateQC on Transfer Rcpt"; Rec."Auto CreateQC on Transfer Rcpt")
                {
                    ApplicationArea = Basic;
                    Caption = '<Auto Create QC on Transfer Receipt>';
                }
                field("Transfer Receipt QC No."; Rec."Transfer Receipt QC No.")
                {
                    ApplicationArea = Basic;
                }
                field("Posted Transfer Receipt QC No."; Rec."Posted Transfer Receipt QC No.")
                {
                    ApplicationArea = Basic;
                }
            }
            group("QC Receipt Approval")
            {
                Caption = 'QC Receipt Approval';
                field("Enable QC Approval"; Rec."Enable QC Approval")
                {
                    ApplicationArea = Basic;
                    trigger OnValidate()
                    var
                        myInt: Integer;
                    begin

                        if Rec."Enable QC Approval" then
                            Specific_lEditible := true
                        else
                            Specific_lEditible := false;
                        CurrPage.Update();
                    end;
                }
                field("Specific for Rejection"; rec."Specific for Rejection")
                {
                    ApplicationArea = Basic;
                    caption = 'Specific for Rejection';
                    Editable = Specific_lEditible;

                }
                field("Send Mail on QC Approval"; Rec."Send Mail on QC Approval")
                {
                    ApplicationArea = Basic;
                }
            }
            //T12113-ABA-NS
            group("Retest QC Receipt")
            {
                Caption = 'Retest QC Receipt';
                field("Allow Retest QC"; Rec."Allow Retest QC")
                {
                    ApplicationArea = All;
                }
                field("Retest QC Nos"; Rec."Retest QC Nos")
                {
                    ApplicationArea = Basic;
                }
                field("Posted Retest QC Nos"; Rec."Posted Retest QC Nos")
                {
                    ApplicationArea = Basic;
                }

            }
            group("Sales Order")
            {
                Caption = 'Sales Order';
                field("Allow QC in Sales Order"; Rec."Allow QC in Sales Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow QC for Pre-dispatch Verification on Sales Order.';
                }
                field("PreDispatch QC Nos"; Rec."PreDispatch QC Nos")
                {
                    ApplicationArea = Basic;
                }
                field("Posted PreDispatch QC Nos"; Rec."Posted PreDispatch QC Nos")
                {
                    ApplicationArea = basic;
                }
            }

            //T12479-NS
            group("Quality Order")
            {
                Caption = 'Quality Order';
                field("Quality Order Applicable"; Rec."Quality Order Applicable")
                {
                    ToolTip = 'Specifies the value of the Quality Order Applicable field.', Comment = '%';
                }
                field("Quality Order with QC Item"; Rec."Quality Order with QC Item")
                {
                    ToolTip = 'Specifies the value of the Quality Order with QC Item field.', Comment = '%';
                }
            }
            //T12479-NE
            group("Expiration Alert")
            {
                Caption = 'Expiration Alert';

                field("Expiration Due Alert"; Rec."Expiration Due Alert")
                {
                    ApplicationArea = basic;
                }
                field("Expiration Alert Mail To"; Rec."Expiration Alert Mail To")
                {
                    ApplicationArea = Basic;
                }
                field("Expiration Alert Mail CC"; Rec."Expiration Alert Mail CC")
                {
                    ApplicationArea = Basic;
                }
                field("Expiration Alert Mail BCC"; Rec."Expiration Alert Mail BCC")
                {
                    ApplicationArea = Basic;
                }
                field("Expiry Alert Notification"; Rec."Expiry Alert Notification")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Expiry Alert Notification field.', Comment = '%';
                    Description = 'T12113';
                }
            }
            group("Rejection Mail")
            {
                field("Enable Noti. QC Rcpt. Reject."; Rec."Enable Noti. QC Rcpt. Reject.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Enable Notification on QC Receipt Rejection field.', Comment = '%';
                    Description = 'T12113';
                    trigger OnValidate()
                    begin
                        Rec.TestField("Rejection Email To", '');
                        Rec.TestField("Rejection Email CC", '');
                        Rec.TestField("Rejection Email Bcc", '');
                        //T12113-NS
                        ExpiryRejectEdit_gBln := false;
                        if Rec."Enable Noti. QC Rcpt. Reject." then
                            ExpiryRejectEdit_gBln := true;
                        CurrPage.Update();
                        //T12113-NE
                    end;
                }
                field("Rejection Email To"; Rec."Rejection Email To")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Rejection Email To field.', Comment = '%';
                    Description = 'T12113';
                    Editable = ExpiryRejectEdit_gBln;
                }
                field("Rejection Email CC"; Rec."Rejection Email CC")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Rejection Email CC field.', Comment = '%';
                    Description = 'T12113';
                    Editable = ExpiryRejectEdit_gBln;
                }
                field("Rejection Email Bcc"; Rec."Rejection Email Bcc")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Rejection Email Bcc field.', Comment = '%';
                    Description = 'T12113';
                    Editable = ExpiryRejectEdit_gBln;
                }
            }
            //T12113-ABA-NE

        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        //I-C0009-1001310-02 NS
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
        //I-C0009-1001310-02 NE
        if Rec."Enable QC Approval" then
            Specific_lEditible := true
        else
            Specific_lEditible := false;
        CurrPage.Update();
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec."Enable QC Approval" then
            Specific_lEditible := true
        else
            Specific_lEditible := false;
        //T12113-NS
        ExpiryRejectEdit_gBln := false;
        if Rec."Enable Noti. QC Rcpt. Reject." then
            ExpiryRejectEdit_gBln := true;
        CurrPage.Update();
        //T12113-NE
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if Rec."Enable QC Approval" then
            Specific_lEditible := true
        else
            Specific_lEditible := false;
        //T12113-NS
        ExpiryRejectEdit_gBln := false;
        if Rec."Enable Noti. QC Rcpt. Reject." then
            ExpiryRejectEdit_gBln := true;
        CurrPage.Update();
        //T12113-NE
    end;

    var
        ExpiryRejectEdit_gBln: Boolean;//T12113-N
        Specific_lEditible: Boolean;
}

