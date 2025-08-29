Page 75394 "Posted Item QC Tracking Lines"
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
    // ------------------------------------------------------------------------------------------------------------------------------

    Caption = 'Posted Item Tracking Lines';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    Editable = true;
    RefreshOnActivate = true;
    SourceTable = "Item Ledger Entry";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(RepeaterControl)
            {

                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Shipped Qty. Not Returned"; Rec."Shipped Qty. Not Returned")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                //T12545-NS
                field("Warranty Date"; Rec."Warranty Date")
                {
                    ApplicationArea = All;
                    Caption = 'Manufacturing Date';
                    ToolTip = 'Specifies the Manufacturing Date for the item on the line.';
                }
                //T12545-NE
                /* field("Warranty Date"; Rec."Warranty Date")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                } */
                field("QC No."; Rec."QC No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Posted QC No."; Rec."Posted QC No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Accepted Quantity"; Rec."Accepted Quantity")
                {
                    ApplicationArea = Basic;
                    Style = Favorable;
                    StyleExpr = true;

                    trigger OnValidate()
                    begin
                        CheckModifyAllow_lFnc;
                    end;
                }
                field("Accepted with Deviation Qty"; Rec."Accepted with Deviation Qty")
                {
                    ApplicationArea = Basic;
                    Style = Strong;
                    StyleExpr = true;

                    trigger OnValidate()
                    begin
                        CheckModifyAllow_lFnc;
                    end;
                }
                field("Rejected Quantity"; Rec."Rejected Quantity")
                {
                    ApplicationArea = Basic;
                    Style = Unfavorable;
                    StyleExpr = true;

                    trigger OnValidate()
                    begin
                        CheckModifyAllow_lFnc;
                    end;
                }
                field("Rework Quantity"; Rec."Rework Quantity")
                {
                    ApplicationArea = Basic;
                    Editable = EditableRework_gBln;
                    Style = StrongAccent;
                    StyleExpr = true;

                    trigger OnValidate()
                    begin
                        CheckModifyAllow_lFnc;
                    end;
                }
                field("Rejection Reason"; Rec."Rejection Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rejection Reason field.', Comment = '%';
                    Description = 'T12113';
                }
                field("Rejection Reason Description"; Rec."Rejection Reason Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rejection Reason Description field.', Comment = '%';
                    Description = 'T12113';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("QC Result")
            {
                ApplicationArea = Basic;
                Caption = 'QC Result';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "QC Result";
                RunPageLink = "QC No." = field("QC No."),
                              "Lot No." = field("Lot No."),
                              "Serial No." = field("Serial No.");
            }
            action("Select Update All")
            {
                ApplicationArea = Basic;
                Image = MapDimensions;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //QCV3-NS 24-01-18
                    CheckModifyAllow_lFnc;
                    if Rec."Entry Type" = Rec."entry type"::Output then
                        Selection := StrMenu(Text0002_gCxt, 1)
                    else
                        Selection := StrMenu(Text0003_gCxt, 1);

                    if Selection = 0 then
                        exit;

                    if Rec.FindSet then begin
                        repeat
                            Rec."Accepted Quantity" := 0;
                            Rec."Accepted with Deviation Qty" := 0;
                            Rec."Rejected Quantity" := 0;
                            Rec."Rework Quantity" := 0;

                            case Selection of
                                1:
                                    Rec."Accepted Quantity" := Abs(Rec."Remaining Quantity");
                                2:
                                    Rec."Accepted with Deviation Qty" := Abs(Rec."Remaining Quantity");
                                3:
                                    Rec."Rejected Quantity" := Abs(Rec."Remaining Quantity");
                                4:
                                    Rec."Rework Quantity" := Abs(Rec."Remaining Quantity");
                            end;

                            Rec.Modify;
                        until Rec.Next = 0;
                    end;
                    //QCV3-NE 24-01-18
                end;
            }
            action("UnSelect Update All")
            {
                ApplicationArea = Basic;
                Image = DeleteQtyToHandle;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //QCV3-NS 24-01-18
                    CheckModifyAllow_lFnc;
                    if Rec.FindSet then begin
                        repeat
                            Rec."Accepted Quantity" := 0;
                            Rec."Accepted with Deviation Qty" := 0;
                            Rec."Rejected Quantity" := 0;
                            Rec."Rework Quantity" := 0;
                            Rec.Modify;
                        until Rec.Next = 0;
                    end;
                    //QCV3-NE 24-01-18
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        //I-C0009-1001310-02 NS
        if Rec."Posted QC No." <> '' then
            ResultEditable := false
        else
            ResultEditable := true;
        //I-C0009-1001310-02 NE

        if Rec."Entry Type" = Rec."entry type"::Output then
            EditableRework_gBln := true
        else
            EditableRework_gBln := false;
    end;

    trigger OnInit()
    begin
        ResultEditable := true; //I-C0009-1001310-02 N
    end;

    trigger OnOpenPage()
    var
        CaptionText1: Text[100];
        CaptionText2: Text[100];
    begin
        //I-C0009-1001310-02 NS
        CaptionText1 := Rec."Item No.";
        if CaptionText1 <> '' then begin
            CaptionText2 := CurrPage.Caption;
            CurrPage.Caption := StrSubstNo(Text0001_gCtx, CaptionText1, CaptionText2);
        end;
        //I-C0009-1001310-02 NE
    end;
    //T12113-NS
    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        CheckRejectedReason;
    end;
    //T12113-NE
    var
        Text0001_gCtx: label '%1 - %2';
        //[InDataSet]
        ResultEditable: Boolean;
        Text0002_gCxt: label '&Accept,&AcceptWithDeviation,&Reject,Rework';
        Selection: Integer;
        //[InDataSet]
        EditableRework_gBln: Boolean;
        Text0003_gCxt: label '&Accept,&AcceptWithDeviation,&Reject';

    local procedure CheckModifyAllow_lFnc()
    var
        QCRcptHeader_lRec: Record "QC Rcpt. Header";
        PostedQCRcptHeader_lRec: Record "Posted QC Rcpt. Header";
    begin
        if Rec."Job No." <> '' then begin
            if QCRcptHeader_lRec.Get(Rec."Job No.") then begin
                QCRcptHeader_lRec.TestField(Approve, false);
                QCRcptHeader_lRec.TestField("Approval Status", QCRcptHeader_lRec."approval status"::Open);
            end;

            if PostedQCRcptHeader_lRec.Get(Rec."Job No.") then
                Error('You cannot do modification in Posted QC');
        end;
    end;
    //T12113-NS

    local procedure CheckRejectedReason()
    var
    begin
        if Rec."Rejected Quantity" > 0 then
            Rec.TestField("Rejection Reason");
    end;
    //T12113-NE
}

