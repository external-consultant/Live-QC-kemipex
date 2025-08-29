pageextension 75381 Psted_Transf_Rcpt_Subfrm_75381 extends "Posted Transfer Rcpt. Subform"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter("&Line")
        {
            group(Functions)
            {
                action(CreateQCReceipt)
                {
                    ApplicationArea = All;
                    Caption = 'Create QC Receipt';
                    Image = QualificationOverview;

                    trigger OnAction()
                    begin
                        QCTransferRcpt_gCdu.CreateQCRcpt_gFnc(Rec, TRUE); //I-C0009-1001310-06-N
                    end;
                }
                action(QCReceipt)
                {
                    ApplicationArea = All;
                    Caption = 'QC Receipt';
                    Image = QuestionaireSetup;

                    trigger OnAction()
                    begin
                        QCTransferRcpt_gCdu.ShowQCRcpt_gFnc(Rec); //I-C0009-1001310-06-N
                    end;
                }
                action(PostQCReceipt)
                {
                    ApplicationArea = All;
                    Caption = 'Post QC Receipt';
                    Image = PostedDeposit;

                    trigger OnAction()
                    begin
                        QCTransferRcpt_gCdu.ShowPostedQCRcpt_gFnc(Rec); //I-C0009-1001310-06-N
                    end;
                }
            }
        }
    }

    var
        QCTransferRcpt_gCdu: Codeunit "Quality Control -Transfer Rcpt";
}