Page 75403 "QC Approval All App. Entry"
{
    PageType = List;
    SourceTable = "QC User Approval Entry";
    SourceTableView = sorting(Type, "Entry No.")
                      where(Status = filter(Open),
                            Type = const('QC _RCPT_APPROVER'));
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic;
                }
                field("Proposal Raised By"; Rec."Proposal Raised By")
                {
                    ApplicationArea = Basic;
                }
                field("Proposal Raised Date"; Rec."Proposal Raised Date")
                {
                    ApplicationArea = Basic;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic;
                }
                field("Approver ID"; Rec."Approver ID")
                {
                    ApplicationArea = Basic;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = Basic;
                }
                field(Select; Rec.Select)
                {
                    ApplicationArea = Basic;
                }
                field("Requester ID"; Rec."Requester ID")
                {
                    ApplicationArea = Basic;
                }
                field("Approval Request Send On"; Rec."Approval Request Send On")
                {
                    ApplicationArea = Basic;
                }
                field("Approver Response Receive On"; Rec."Approver Response Receive On")
                {
                    ApplicationArea = Basic;
                }
                field("Approval level"; Rec."Approval level")
                {
                    ApplicationArea = Basic;
                }
                field("Rejection Comment"; Rec."Rejection Comment")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Delegate)
            {
                ApplicationArea = Basic;
                Image = Delegate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;

                trigger OnAction()
                var
                    QCApprovalManagement_lCdu: Codeunit "QC Approval Management";
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    QCApprovalManagement_lCdu.DelegateApprovalRequests_gFnc(Rec);
                end;
            }
            action("Show Document")
            {
                ApplicationArea = Basic;
                Caption = 'Show Document';
                Image = Customer;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    QCRcptHeader_lRec: Record "QC Rcpt. Header";
                    QCRcpt_lPge: Page "QC Rcpt.";
                begin
                    Clear(QCRcpt_lPge);
                    QCRcptHeader_lRec.Reset;
                    QCRcptHeader_lRec.SetRange("No.", Rec."Document No.");
                    QCRcpt_lPge.SetTableview(QCRcptHeader_lRec);
                    QCRcpt_lPge.Editable(false);
                    QCRcpt_lPge.RunModal;
                end;
            }
        }
    }
}

