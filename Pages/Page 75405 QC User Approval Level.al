Page 75405 "QC User Approval Level"
{
    // --------------------------------------------------------------------------------------------------
    // Intech Systems Pvt. Ltd.
    // --------------------------------------------------------------------------------------------------
    // No.                    Date        Author
    // --------------------------------------------------------------------------------------------------
    // I-I046-300031-01       18/06/16    Chintan Panchal
    //                        Purchase Indent Approval Functionality
    //                        Created New Page
    // --------------------------------------------------------------------------------------------------

    DelayedInsert = true;
    PageType = List;
    SourceTable = "QC User Approver Sequence";
    SourceTableView = sorting(Type, "Source UserID", Sequence);
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Approver UserID"; Rec."Approver UserID")
                {
                    ApplicationArea = Basic;
                }
                field(Sequence; Rec.Sequence)
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Select User")
            {
                ApplicationArea = Basic;
                Caption = 'Select User';
                Image = Absence;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    UserSetup_lRec: Record "User Setup";
                    UserSetup_lPge: Page "User Setup";
                    SelectedUser_lRec: Record "User Setup";
                    UserAppLevel_lRec: Record "QC User Approver Sequence";
                    Type_lTxt: Text[50];
                begin
                    Clear(UserSetup_lPge);
                    UserSetup_lRec.Reset;
                    UserSetup_lRec.FilterGroup(2);
                    UserSetup_lRec.SetFilter("User ID", '<>%1', UserId);
                    UserSetup_lRec.FilterGroup(0);
                    UserSetup_lPge.SetTableview(UserSetup_lRec);
                    UserSetup_lPge.Editable(false);
                    UserSetup_lPge.LookupMode(true);
                    if UserSetup_lPge.RunModal <> Action::LookupOK then
                        exit;

                    Rec.FilterGroup(3);
                    Type_lTxt := Rec.GetFilter(Type);
                    Rec.FilterGroup(0);

                    SelectedUser_lRec.Reset;
                    UserSetup_lPge.GetSelectionFilter_gFnc(SelectedUser_lRec);
                    if SelectedUser_lRec.FindSet then begin
                        repeat
                            UserAppLevel_lRec.Reset;
                            if not UserAppLevel_lRec.Get(Type_lTxt, Rec.GetFilter("Source UserID"), SelectedUser_lRec."User ID") then begin
                                UserAppLevel_lRec.Init;
                                UserAppLevel_lRec.Type := Type_lTxt;
                                UserAppLevel_lRec."Source UserID" := Rec.GetFilter("Source UserID");
                                UserAppLevel_lRec."Approver UserID" := SelectedUser_lRec."User ID";
                                UserAppLevel_lRec.Sequence := 0;
                                UserAppLevel_lRec.Insert;
                            end;

                        until SelectedUser_lRec.Next = 0;
                    end;
                end;
            }
        }
    }
}

