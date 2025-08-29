PageExtension 75407 User_Setup_75407 extends "User Setup"
{
    //T51170-NS
    layout
    {
        addafter(Email)
        {
            field("QC Line Modify Allowed"; Rec."QC Line Modify Allowed")
            {
                ApplicationArea = All;
            }
        }
    }
    //T51170-NE
    actions
    {

        addfirst(processing)
        {
            group("Document Approver")
            {
                Caption = 'Document Approver';
                Image = AnalysisView;
                group(ActionGroup1170000000)
                {
                    Caption = 'Document Approver';
                    Image = AnalysisView;
                    action("QC Rcpt. Approver")
                    {
                        ApplicationArea = Basic;
                        Image = Agreement;
                        RunObject = Page "QC User Approval Level";
                        RunPageLink = "Source UserID" = field("User ID");
                        RunPageView = sorting(Type, "Source UserID", "Approver UserID")
                                      where(Type = const('QC _RCPT_APPROVER'));
                    }

                    action("Run Error Info Button")
                    {
                        ApplicationArea = All;

                        trigger OnAction()
                        var

                        begin
                            TestErrorAction();

                        end;
                    }

                }
            }
        }
    }

    procedure GetSelectionFilter_gFnc(var UserSetup_vRec: Record "User Setup")
    begin
        CurrPage.SetSelectionFilter(UserSetup_vRec);
    end;

    local Procedure TestErrorAction()
    var
        IN_ErrorInfor: ErrorInfo;
        PostingDateNotification: Notification;
        PostingDateNotificationLbl: Label 'Posting Date is different from the current date.';
        CheckWorkDate: Label 'Check Work Date?';
    begin
        // //Syntax-begin 
        IN_ErrorInfor.DataClassification(DataClassification::SystemMetadata);
        IN_ErrorInfor.ErrorType(ErrorType::Client);
        IN_ErrorInfor.Verbosity(Verbosity::Error);
        IN_ErrorInfor.Title('This is New Error Title');
        IN_ErrorInfor.Message('This is Error Message');
        IN_ErrorInfor.AddAction('Second', Codeunit::"Error Action Test", 'Test02');
        IN_ErrorInfor.PageNo := Page::"Item List";
        IN_ErrorInfor.AddNavigationAction('Open Item List');
        Error(IN_ErrorInfor);
        // //Syntax-end

        if Today <> rec."Allow Posting To" then begin
            PostingDateNotification.Message(PostingDateNotificationLbl);
            PostingDateNotification.Scope := NotificationScope::LocalScope;
            PostingDateNotification.AddAction(CheckWorkDate, Codeunit::"Error Action Test", 'OpenMySettings', 'This is Notification tooltip');
            PostingDateNotification.Send();
        end;
    end;

}

