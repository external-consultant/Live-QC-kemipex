Codeunit 75386 "QC Approval Management"
{

    trigger OnRun()
    begin
    end;

    var
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailBody_lTxt: Text;
        receipent: List of [Text];
        CC: List of [Text];
        BCC: List of [Text];
        FixedAsset_gRec: Record "Fixed Asset";
        QualityControlSetup_gRec: Record "Quality Control Setup";
        Text000_gCtx: label 'There is nothing to approve.';
        Text003_gCtx: label 'Approval entry created successfully.';
        Text004_gCtx: label 'Do you want to create approval entries?';
        Text005_gCtx: label 'Do you want to cancel approval entries?';
        Text006_gCtx: label 'Approval entry cancelled successfully.';
        Text007_gCtx: label 'Do you want to approve request?';
        Text008_gCtx: label 'Do you want to reject request?';
        Text009_gCtx: label 'There is nothing to reject.';
        Text010_gCtx: label 'There is nothing to show.';
        Text011_gCtx: label 'Do you want to re-oepn approval entries?';
        Text012_gCtx: label 'Approval entry opened successfully.';
        Text013_gCtx: label 'Entry is auto-approved.';
        Text016_gCtx: label 'There is nothing to approve.';
        Text017_gCtx: label 'Do you want to approve selected request lines?';
        Text018_gCtx: label 'Do you want to reject selected request lines?';
        Text019_gCtx: label 'There is nothing to reject.';
        ApprovalsDelegatedMsg: label 'The selected approval requests have been delegated.';
        DelegateOnlyOpenRequestsErr: label 'You can only delegate open approval requests.';
        ApproverUserIdNotInSetupErr: label 'You must set up an approver for user ID %1 in the Approval User Setup window.', Comment = 'You must set up an approver for user ID NAVUser in the Approval User Setup window.';

    procedure SendForApproval_gFnc(var QCRcptHeader_vRec: Record "QC Rcpt. Header")
    var
        UserAppLevel_lRec: Record "QC User Approver Sequence";
        ReleaseTransferDocument_lCdu: Codeunit "Release Transfer Document";
        AutoApproveAppEntry_lRec: Record "QC User Approval Entry";
        ChkQCRcptHeader_lRec: Record "QC Rcpt. Header";
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
        ProdQCMgmt_lCdu: Codeunit "Quality Control - Production";
        SalesOrderQCMgmt_lCdu: Codeunit "Quality Control - Sales";//T12113-N
        Ile_lRec: Record "Item Ledger Entry";//T12113-N
    begin
        QualityControlSetup_gRec.Get;
        QualityControlSetup_gRec.TestField("Enable QC Approval", true);

        QCRcptHeader_vRec.TestField("No.");
        QCRcptHeader_vRec.TestField("Approval Status", QCRcptHeader_vRec."approval status"::Open);

        if not Confirm(Text004_gCtx, true) then
            exit;

        //Check Approve Validation
        ChkQCRcptHeader_lRec.Get(QCRcptHeader_vRec."No.");
        ChkQCRcptHeader_lRec.Validate(Approve, true);

        //QCV3-NS  30-01-18
        if ((QCRcptHeader_vRec."Item Tracking" = QCRcptHeader_vRec."item tracking"::"Serial No.") or (QCRcptHeader_vRec."Item Tracking" = QCRcptHeader_vRec."item tracking"::"Lot and Serial No."))
          and ((QCRcptHeader_vRec."Document Type" = QCRcptHeader_vRec."document type"::Purchase) or (QCRcptHeader_vRec."Document Type" = QCRcptHeader_vRec."document type"::"Sales Return") or
                                   (QCRcptHeader_vRec."Document Type" = QCRcptHeader_vRec."document type"::"Transfer Receipt"))
        then begin
            ItemLedgerEntry_lRec.Reset;
            ItemLedgerEntry_lRec.SetFilter("Document Type", '%1|%2|%3', ItemLedgerEntry_lRec."document type"::"Purchase Receipt", ItemLedgerEntry_lRec."document type"::"Sales Return Receipt",
                                                                   ItemLedgerEntry_lRec."document type"::"Transfer Receipt");
            ItemLedgerEntry_lRec.SetRange("Document No.", QCRcptHeader_vRec."Document No.");
            ItemLedgerEntry_lRec.SetRange("Document Line No.", QCRcptHeader_vRec."Document Line No.");
            if QCRcptHeader_vRec."Vendor Lot No." <> '' then
                ItemLedgerEntry_lRec.SetRange("Lot No.", QCRcptHeader_vRec."Vendor Lot No.");
            ItemLedgerEntry_lRec.SetRange("Item No.", QCRcptHeader_vRec."Item No.");//T12113-N filter is applied due to duplicate Document No.
            if ItemLedgerEntry_lRec.FindSet then begin
                //T12113-NS QC-Sales Return
                if ItemLedgerEntry_lRec."Document Type" = ItemLedgerEntry_lRec."Document Type"::"Sales Return Receipt" then begin
                    Ile_lRec.reset;
                    Ile_lRec.SetRange("Entry Type", Ile_lRec."Entry Type"::Transfer);
                    Ile_lRec.SetRange("Document No.", QCRcptHeader_vRec."Document No.");
                    Ile_lRec.SetRange("Document Line No.", QCRcptHeader_vRec."Document Line No.");
                    Ile_lRec.SetRange("Item No.", QCRcptHeader_vRec."Item No.");//T12113-N filter is applied due to duplicate Document No.
                    Ile_lRec.Setfilter("Remaining Quantity", '>%1', 0);
                    if Ile_lRec.FindSet() then
                        QCRcptHeader_vRec.CheckEnteredResult_lFnc(Ile_lRec);
                end else
                    //T12113-NE QC-Sales Return
                    QCRcptHeader_vRec.CheckEnteredResult_lFnc(ItemLedgerEntry_lRec);
            end;

        end;
        if QCRcptHeader_vRec."Document Type" = QCRcptHeader_vRec."document type"::Production then
            ProdQCMgmt_lCdu.CheckEnterResult_gFnc(QCRcptHeader_vRec);

        //QCV3-NE  30-01-18

        UserAppLevel_lRec.Reset;
        UserAppLevel_lRec.SetCurrentkey(Type, "Source UserID", Sequence);
        UserAppLevel_lRec.SetRange(Type, 'QC _RCPT_APPROVER');
        UserAppLevel_lRec.SetRange("Source UserID", UserId);
        UserAppLevel_lRec.SetFilter("Approver UserID", '<>%1', '');
        if UserAppLevel_lRec.IsEmpty then
            Error('QC Approver is not defined for User ID %1', UserId);

        if UserAppLevel_lRec.FindSet then begin
            repeat
                CreateApprovalEntry_lFnc(QCRcptHeader_vRec, UserAppLevel_lRec);
            until UserAppLevel_lRec.Next = 0;
        end;

        OpenFirstEntry_lFnc(QCRcptHeader_vRec);

        QCRcptHeader_vRec.Validate("Approval Status", QCRcptHeader_vRec."approval status"::"Pending for Approval");
        QCRcptHeader_vRec.Modify;

        AutoApproveAppEntry_lRec.Reset;
        AutoApproveAppEntry_lRec.SetRange(Type, 'QC _RCPT_APPROVER');
        AutoApproveAppEntry_lRec.SetRange("Document No.", QCRcptHeader_vRec."No.");
        AutoApproveAppEntry_lRec.SetRange(Status, AutoApproveAppEntry_lRec.Status::Open);
        AutoApproveAppEntry_lRec.SetRange("Approver ID", UserId);
        if AutoApproveAppEntry_lRec.FindFirst then begin
            if ApproveEntry_gFnc(AutoApproveAppEntry_lRec, false) then begin
                Message(Text013_gCtx);
                exit;
            end;
        end;

        SendForApprovalEmail_gFnc(QCRcptHeader_vRec);

        Message(Text003_gCtx);
    end;

    procedure CancelApprovalRequest_gFnc(var QCRcptHeader_vRec: Record "QC Rcpt. Header")
    begin
        QualityControlSetup_gRec.Get;
        QualityControlSetup_gRec.TestField("Enable QC Approval", true);

        QCRcptHeader_vRec.TestField("Approval Status", QCRcptHeader_vRec."approval status"::"Pending for Approval");
        if not Confirm(Text005_gCtx, false) then
            exit;

        CancelApprovalEntry_lFnc(QCRcptHeader_vRec);
        QCRcptHeader_vRec.Validate("Approval Status", QCRcptHeader_vRec."approval status"::Open);
        QCRcptHeader_vRec.Modify;

        Message(Text006_gCtx);
    end;

    procedure ReOpenRequest_gFnc(var QCRcptHeader_vRec: Record "QC Rcpt. Header")
    begin
        QualityControlSetup_gRec.Get;
        QualityControlSetup_gRec.TestField("Enable QC Approval", true);

        if QCRcptHeader_vRec."Approval Status" = QCRcptHeader_vRec."approval status"::Open then
            exit;

        if QCRcptHeader_vRec."Approval Status" in [QCRcptHeader_vRec."approval status"::Approved, QCRcptHeader_vRec."approval status"::"Pending for Approval", QCRcptHeader_vRec."approval status"::Rejected] then begin
            if not Confirm(Text011_gCtx, false) then
                exit;
        end else
            QCRcptHeader_vRec.FieldError("Approval Status");

        CancelApprovalEntry_lFnc(QCRcptHeader_vRec);
        QCRcptHeader_vRec.Validate("Approval Status", QCRcptHeader_vRec."approval status"::Open);
        QCRcptHeader_vRec.Approve := false;
        QCRcptHeader_vRec."Approved By" := '';
        QCRcptHeader_vRec.Modify;

        Message(Text012_gCtx);
    end;

    procedure ApproveSelectedEntry_gFnc(var UserAppEntry_vRec: Record "QC User Approval Entry"; ShowConfirm_iBln: Boolean)
    var
        UserAppEntry_lRec: Record "QC User Approval Entry";
    begin
        UserAppEntry_lRec.Copy(UserAppEntry_vRec);

        if not Confirm(Text017_gCtx, false) then
            exit;

        UserAppEntry_lRec.SetRange(Select, true);
        if UserAppEntry_lRec.FindSet then begin
            repeat
                ApproveEntry_gFnc(UserAppEntry_lRec, false);
            until UserAppEntry_lRec.Next = 0;
        end else begin
            Message(Text016_gCtx);
            exit;
        end;
    end;

    procedure ApproveEntry_gFnc(var UserAppEntry_vRec: Record "QC User Approval Entry"; ShowConfirm_iBln: Boolean): Boolean
    var
        FirstUserAppEntry_lRec: Record "QC User Approval Entry";
        QCRcptHeader_lRec: Record "QC Rcpt. Header";
        QualityControlSetup_lRec: Record "Quality Control Setup";
        ReleaseTransferDocument_lCdu: Codeunit "Release Transfer Document";
        SameLevelUserAppEntry_lRec: Record "QC User Approval Entry";
    begin
        if ShowConfirm_iBln then begin
            if not Confirm(Text007_gCtx, false) then
                exit;
        end;

        UserAppEntry_vRec.Status := UserAppEntry_vRec.Status::Approved;
        UserAppEntry_vRec."Approver Response Receive On" := CurrentDatetime;
        UserAppEntry_vRec.Modify(true);

        if UserAppEntry_vRec."Approval level" > 0 then begin
            SameLevelUserAppEntry_lRec.Reset;
            SameLevelUserAppEntry_lRec.SetRange(Type, UserAppEntry_vRec.Type);
            SameLevelUserAppEntry_lRec.SetRange("Document No.", UserAppEntry_vRec."Document No.");
            SameLevelUserAppEntry_lRec.SetRange(Status, SameLevelUserAppEntry_lRec.Status::Open);
            SameLevelUserAppEntry_lRec.SetRange("Approval level", UserAppEntry_vRec."Approval level");
            if SameLevelUserAppEntry_lRec.FindSet then begin
                repeat
                    SameLevelUserAppEntry_lRec.Status := SameLevelUserAppEntry_lRec.Status::Approved;
                    SameLevelUserAppEntry_lRec."Approver Response Receive On" := CurrentDatetime;
                    SameLevelUserAppEntry_lRec."Same Level Update" := true;
                    SameLevelUserAppEntry_lRec.Modify;
                until SameLevelUserAppEntry_lRec.Next = 0;
            end;
        end;

        FirstUserAppEntry_lRec.Reset;
        FirstUserAppEntry_lRec.SetRange(Type, 'QC _RCPT_APPROVER');
        FirstUserAppEntry_lRec.SetRange("Document Type", UserAppEntry_vRec."Document Type");
        FirstUserAppEntry_lRec.SetRange("Document No.", UserAppEntry_vRec."Document No.");
        FirstUserAppEntry_lRec.SetRange(Status, UserAppEntry_vRec.Status::Created);
        if FirstUserAppEntry_lRec.FindFirst then begin
            FirstUserAppEntry_lRec.Status := FirstUserAppEntry_lRec.Status::Open;
            FirstUserAppEntry_lRec.Modify;

            if FirstUserAppEntry_lRec."Approval level" > 0 then begin
                SameLevelUserAppEntry_lRec.Reset;
                SameLevelUserAppEntry_lRec.SetRange(Type, FirstUserAppEntry_lRec.Type);
                SameLevelUserAppEntry_lRec.SetRange("Document No.", FirstUserAppEntry_lRec."Document No.");
                SameLevelUserAppEntry_lRec.SetRange(Status, SameLevelUserAppEntry_lRec.Status::Created);
                SameLevelUserAppEntry_lRec.SetRange("Approval level", FirstUserAppEntry_lRec."Approval level");
                if SameLevelUserAppEntry_lRec.FindSet then begin
                    repeat
                        SameLevelUserAppEntry_lRec.Status := SameLevelUserAppEntry_lRec.Status::Open;
                        SameLevelUserAppEntry_lRec.Modify;
                    until SameLevelUserAppEntry_lRec.Next = 0;
                end;
            end;
            QCRcptHeader_lRec.Get(UserAppEntry_vRec."Document No.");
            SendForApprovalEmail_gFnc(QCRcptHeader_lRec);

            exit;
        end;

        QCRcptHeader_lRec.Get(UserAppEntry_vRec."Document No.");
        QCRcptHeader_lRec.Validate(Approve, true);
        QCRcptHeader_lRec."Approval Status" := QCRcptHeader_lRec."approval status"::Approved;
        QCRcptHeader_lRec.Modify;
        ApprveEmail_gFnc(UserAppEntry_vRec);
    end;

    procedure RejectSelectedEntry_gFnc(var SelUserAppEntry_vRec: Record "QC User Approval Entry"; ShowConfirm_iBln: Boolean)
    var
        UserAppEntry_lRec: Record "QC User Approval Entry";
        RejectionComments_lRpt: Report "QC Rejection Comments";
        RejComment_lTxt: Text;
    begin
        QualityControlSetup_gRec.Get;
        QualityControlSetup_gRec.TestField("Enable QC Approval", true);

        UserAppEntry_lRec.Copy(SelUserAppEntry_vRec);

        if not Confirm(Text018_gCtx, false) then
            exit;

        UserAppEntry_lRec.SetRange(Select, true);
        if UserAppEntry_lRec.FindSet then begin

            Clear(RejectionComments_lRpt);
            RejectionComments_lRpt.RunModal;
            RejComment_lTxt := RejectionComments_lRpt.GetRejComm_gFnc;
            if RejComment_lTxt = '' then
                Error('Please enter the Rejection Comments');

            repeat
                RejectEntry_gFnc(UserAppEntry_lRec, false, RejComment_lTxt);
            until UserAppEntry_lRec.Next = 0;
        end else begin
            Message(Text019_gCtx);
            exit;
        end;
    end;

    procedure RejectEntry_gFnc(var UserAppEntry_vRec: Record "QC User Approval Entry"; ShowConfirm_iBln: Boolean; RejComment_iTxt: Text[250])
    var
        FirstUserAppEntry_lRec: Record "QC User Approval Entry";
        QCRcptHeader_lRec: Record "QC Rcpt. Header";
        SameLevelUserAppEntry_lRec: Record "QC User Approval Entry";
    begin
        if ShowConfirm_iBln then begin
            if not Confirm(Text008_gCtx, false) then
                exit;
        end;

        UserAppEntry_vRec.TestField(Remarks);
        UserAppEntry_vRec.Status := UserAppEntry_vRec.Status::Rejected;
        UserAppEntry_vRec."Approver Response Receive On" := CurrentDatetime;
        UserAppEntry_vRec."Rejection Comment" := RejComment_iTxt;
        UserAppEntry_vRec.Modify(true);


        if UserAppEntry_vRec."Approval level" > 0 then begin
            SameLevelUserAppEntry_lRec.Reset;
            SameLevelUserAppEntry_lRec.SetRange(Type, UserAppEntry_vRec.Type);
            SameLevelUserAppEntry_lRec.SetRange("Document No.", UserAppEntry_vRec."Document No.");
            SameLevelUserAppEntry_lRec.SetRange(Status, SameLevelUserAppEntry_lRec.Status::Open);
            SameLevelUserAppEntry_lRec.SetRange("Approval level", UserAppEntry_vRec."Approval level");
            if SameLevelUserAppEntry_lRec.FindSet then begin
                repeat
                    SameLevelUserAppEntry_lRec.Status := SameLevelUserAppEntry_lRec.Status::Rejected;
                    SameLevelUserAppEntry_lRec."Approver Response Receive On" := CurrentDatetime;
                    SameLevelUserAppEntry_lRec."Same Level Update" := true;
                    SameLevelUserAppEntry_lRec.Modify;
                until SameLevelUserAppEntry_lRec.Next = 0;
            end;
        end;

        FirstUserAppEntry_lRec.Reset;
        FirstUserAppEntry_lRec.SetRange(Type, 'QC _RCPT_APPROVER');
        FirstUserAppEntry_lRec.SetRange("Document Type", UserAppEntry_vRec."Document Type");
        FirstUserAppEntry_lRec.SetRange("Document No.", UserAppEntry_vRec."Document No.");
        FirstUserAppEntry_lRec.SetRange(Status, UserAppEntry_vRec.Status::Created);
        if FirstUserAppEntry_lRec.FindSet then begin
            repeat
                FirstUserAppEntry_lRec.Status := FirstUserAppEntry_lRec.Status::Cancelled;
                FirstUserAppEntry_lRec.Modify;
            until FirstUserAppEntry_lRec.Next = 0;
        end;

        QCRcptHeader_lRec.Get(UserAppEntry_vRec."Document No.");
        QCRcptHeader_lRec.Validate("Approval Status", QCRcptHeader_lRec."approval status"::Rejected);
        QCRcptHeader_lRec.Modify;
        RejectEmail_gFnc(UserAppEntry_vRec);
    end;

    local procedure CreateApprovalEntry_lFnc(QCRcptHeader_iRec: Record "QC Rcpt. Header"; UserAppLevel_iRec: Record "QC User Approver Sequence")
    var
        UserAppEntry_lRec: Record "QC User Approval Entry";
    begin
        Clear(UserAppEntry_lRec);
        UserAppEntry_lRec.Init;
        UserAppEntry_lRec.Type := 'QC _RCPT_APPROVER';
        UserAppEntry_lRec."Entry No." := GetLastEntryNo_gFnc('QC _RCPT_APPROVER');
        UserAppEntry_lRec."Document No." := QCRcptHeader_iRec."No.";
        //T12114-NS
        UserAppEntry_lRec."Item No." := QCRcptHeader_iRec."Item No.";
        UserAppEntry_lRec."Item No. 2" := QCRcptHeader_iRec."Item No. 2";
        //T12114-NE
        UserAppEntry_lRec."Approver ID" := UserAppLevel_iRec."Approver UserID";
        UserAppEntry_lRec."Approval level" := UserAppLevel_iRec.Sequence;
        UserAppEntry_lRec."Requester ID" := UserId;
        UserAppEntry_lRec.Status := UserAppEntry_lRec.Status::Created;
        UserAppEntry_lRec."Approval Request Send On" := CurrentDatetime;
        UserAppEntry_lRec.Insert(true);
    end;

    local procedure OpenFirstEntry_lFnc(QCRcptHeader_iRec: Record "QC Rcpt. Header")
    var
        UserAppEntry_lRec: Record "QC User Approval Entry";
        SameLevelUserAppEntry_lRec: Record "QC User Approval Entry";
    begin
        UserAppEntry_lRec.Reset;
        UserAppEntry_lRec.SetRange(Type, 'QC _RCPT_APPROVER');
        UserAppEntry_lRec.SetRange("Document No.", QCRcptHeader_iRec."No.");
        UserAppEntry_lRec.SetRange(Status, UserAppEntry_lRec.Status::Created);
        UserAppEntry_lRec.FindFirst;
        UserAppEntry_lRec.Status := UserAppEntry_lRec.Status::Open;
        UserAppEntry_lRec.Modify;

        if UserAppEntry_lRec."Approval level" > 0 then begin
            SameLevelUserAppEntry_lRec.Reset;
            SameLevelUserAppEntry_lRec.SetRange(Type, 'QC _RCPT_APPROVER');
            SameLevelUserAppEntry_lRec.SetRange("Document No.", QCRcptHeader_iRec."No.");
            SameLevelUserAppEntry_lRec.SetRange(Status, SameLevelUserAppEntry_lRec.Status::Created);
            SameLevelUserAppEntry_lRec.SetRange("Approval level", UserAppEntry_lRec."Approval level");
            if SameLevelUserAppEntry_lRec.FindSet then begin
                repeat
                    SameLevelUserAppEntry_lRec.Status := SameLevelUserAppEntry_lRec.Status::Open;
                    SameLevelUserAppEntry_lRec.Modify;
                until SameLevelUserAppEntry_lRec.Next = 0;
            end;
        end;
    end;

    local procedure CancelApprovalEntry_lFnc(QCRcptHeader_iRec: Record "QC Rcpt. Header")
    var
        UserAppEntry_lRec: Record "QC User Approval Entry";
    begin
        //Cancel status=Created & Open entry
        UserAppEntry_lRec.Reset;
        UserAppEntry_lRec.SetRange(Type, 'QC _RCPT_APPROVER');
        UserAppEntry_lRec.SetRange("Document No.", QCRcptHeader_iRec."No.");
        UserAppEntry_lRec.SetRange(Status, UserAppEntry_lRec.Status::Created);
        UserAppEntry_lRec.SetFilter(Status, '%1|%2', UserAppEntry_lRec.Status::Created, UserAppEntry_lRec.Status::Open);
        UserAppEntry_lRec.ModifyAll(Status, UserAppEntry_lRec.Status::Cancelled, true);
    end;

    local procedure "<<<<Other>>>>"()
    begin
    end;

    procedure SetStyle_lFnc(UserAppEntry_iRec: Record "QC User Approval Entry"): Text
    begin
        case UserAppEntry_iRec.Status of
            UserAppEntry_iRec.Status::Open:
                exit('Favorable');
            UserAppEntry_iRec.Status::Cancelled:
                exit('Subordinate');
            UserAppEntry_iRec.Status::Rejected:
                exit('Unfavorable');
            else
                exit('Standard')
        end
    end;

    procedure GetLastEntryNo_gFnc(Type_iTxt: Text[50]): Integer
    var
        UserAppEntry_lRec: Record "QC User Approval Entry";
    begin
        UserAppEntry_lRec.Reset;
        UserAppEntry_lRec.SetRange(Type, Type_iTxt);
        if UserAppEntry_lRec.FindLast then
            exit(UserAppEntry_lRec."Entry No." + 1)
        else
            exit(1);
    end;

    local procedure "*******************Delegate*****************************"()
    begin
    end;

    procedure DelegateApprovalRequests_gFnc(var UserAppEntry_vRec: Record "QC User Approval Entry")
    begin
        if UserAppEntry_vRec.FindSet(true) then begin
            repeat
                DelegateSelectedApprovalRequest_gFnc(UserAppEntry_vRec, true);
            until UserAppEntry_vRec.Next = 0;
            Message(ApprovalsDelegatedMsg);
        end;
    end;

    procedure DelegateSelectedApprovalRequest_gFnc(var UserAppEntry_vRec: Record "QC User Approval Entry"; CheckCurrentUser: Boolean)
    begin
        if UserAppEntry_vRec.Status <> UserAppEntry_vRec.Status::Open then
            Error(DelegateOnlyOpenRequestsErr);

        if CheckCurrentUser then
            if not (UserId in [UserAppEntry_vRec."Requester ID", UserAppEntry_vRec."Approver ID"]) then
                CheckUserAsApprovalAdministrator_lFnc;

        SubstituteUserIdForApprovalEntry_lFnc(UserAppEntry_vRec)
    end;

    local procedure CheckUserAsApprovalAdministrator_lFnc()
    var
        UserSetup_lRec: Record "User Setup";
    begin
        UserSetup_lRec.Get(UserId);
        UserSetup_lRec.TestField("Approval Administrator");
    end;

    local procedure SubstituteUserIdForApprovalEntry_lFnc(var UserAppEntry_vRec: Record "QC User Approval Entry")
    var
        UserSetup_lRec: Record "User Setup";
        ApprovalAdminUserSetup: Record "User Setup";
    begin
        if not UserSetup_lRec.Get(UserAppEntry_vRec."Approver ID") then
            Error(ApproverUserIdNotInSetupErr, UserAppEntry_vRec."Requester ID");

        UserSetup_lRec.TestField(Substitute);

        UserAppEntry_vRec."Approver ID" := UserSetup_lRec.Substitute;
        UserAppEntry_vRec."Entry Substituted" := true;
        UserAppEntry_vRec.Modify(true);
    end;

    local procedure "======== Email =========="()
    begin
    end;

    procedure SendForApprovalEmail_gFnc(QCRcptHeader_iRec: Record "QC Rcpt. Header")
    var
        receipent: List of [Text];
        Subject_lTxt: Text[100];
        Bcc_lTxt: Text[100];
        Tittle_lTxt: Text[50];
        UserSetup_lRec: Record "User Setup";
        Text001_gCtx: label 'FixedAssetDisposal %1.pdf';
        ApproveAppEntryEmail_lRec: Record "QC User Approval Entry";
        CompanyInfo_lRec: Record "Company Information";
        WebURL_lTxt: Text;
        WindowsURL_lTxt: Text;
    begin
        QualityControlSetup_gRec.Get;
        if not QualityControlSetup_gRec."Send Mail on QC Approval" then
            exit;

        ApproveAppEntryEmail_lRec.Reset;
        ApproveAppEntryEmail_lRec.SetRange(Type, 'QC _RCPT_APPROVER');
        ApproveAppEntryEmail_lRec.SetRange("Document No.", QCRcptHeader_iRec."No.");
        ApproveAppEntryEmail_lRec.SetRange(Status, ApproveAppEntryEmail_lRec.Status::Open);
        if ApproveAppEntryEmail_lRec.IsEmpty then
            exit;

        Clear(receipent);
        if ApproveAppEntryEmail_lRec.FindSet then begin
            repeat
                UserSetup_lRec.Get(ApproveAppEntryEmail_lRec."Approver ID");
                UserSetup_lRec.TestField("E-Mail");
                receipent.add(UserSetup_lRec."E-Mail");
            until ApproveAppEntryEmail_lRec.Next = 0;
        end;

        CompanyInfo_lRec.Get;

        Clear(EmailMessage);

        Subject_lTxt := 'QC Receipt - Pending Approval';
        Tittle_lTxt := 'QC Approval';





        //if Cc_lTxt <> '' then
        //SMTPMail_lCdu.AddCC(Cc_lTxt);

        EmailBody_lTxt += 'Dear Sir/Madam';
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += '<BR/>';

        EmailBody_lTxt += '<table width="100%"><tr><td>';
        EmailBody_lTxt += '<table cellpadding="0" cellspacing="0" style="border:0.3px solid black;" align="left" width="100%">';
        TableBodyAppend_gFnc(EmailBody_lTxt, 'QC Receipt No.', QCRcptHeader_iRec."No.");
        TableBodyAppend_gFnc(EmailBody_lTxt, 'Sender ID', ApproveAppEntryEmail_lRec."Requester ID");
        TableBodyAppend_gFnc(EmailBody_lTxt, 'Request Date', FormatMailDate_gFnc(Dt2Date(ApproveAppEntryEmail_lRec."Approval Request Send On")));

        WebURL_lTxt := '';
        WindowsURL_lTxt := '';
        WebURL_lTxt := GetUrl(Clienttype::Web, COMPANYNAME, Objecttype::Page, 75402, ApproveAppEntryEmail_lRec, true);
        WindowsURL_lTxt := GetUrl(Clienttype::Windows, COMPANYNAME, Objecttype::Page, 75402, ApproveAppEntryEmail_lRec, true);

        HyperLinkBodyAppend_gFnc(EmailBody_lTxt, 'Web Link', WebURL_lTxt);
        HyperLinkBodyAppend_gFnc(EmailBody_lTxt, 'Windows Link', WindowsURL_lTxt);

        EmailBody_lTxt += '</table>';
        EmailBody_lTxt += '</table>';
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += 'Regards,';
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += CompanyInfo_lRec.Name;
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += 'This is System Generated Email.';
        EmailBody_lTxt += '<BR/>';

        EmailMessage.Create(receipent, Subject_lTxt, EmailBody_lTxt, true, CC, BCC);
        if Email.Send(EmailMessage, Enum::"Email Scenario"::Default) then;
    end;

    procedure ApprveEmail_gFnc(UserApprovalEntry_iRec: Record "QC User Approval Entry")
    var
        receipent: List of [Text];
        Subject_lTxt: Text[100];
        Bcc_lTxt: Text[100];
        Tittle_lTxt: Text[50];
        UserSetup_lRec: Record "User Setup";
        Text001_gCtx: label 'FixedAssetDisposal %1.pdf';
        CompanyInfo_lRec: Record "Company Information";
        QCRcptHeader_lRec: Record "QC Rcpt. Header";
    begin
        QualityControlSetup_gRec.Get;
        if not QualityControlSetup_gRec."Send Mail on QC Approval" then
            exit;

        UserApprovalEntry_iRec.TestField("Requester ID");
        UserSetup_lRec.Get(UserApprovalEntry_iRec."Requester ID");
        UserSetup_lRec.TestField("E-Mail");
        Clear(receipent);
        receipent.Add(UserSetup_lRec."E-Mail");

        QCRcptHeader_lRec.Get(UserApprovalEntry_iRec."Document No.");

        CompanyInfo_lRec.Get;

        Clear(EmailMessage);

        Subject_lTxt := 'QC Receipt - Approved';
        Tittle_lTxt := 'QC Approval';





        //if Cc_lTxt <> '' then
        //SMTPMail_lCdu.AddCC(Cc_lTxt);

        EmailBody_lTxt += 'Dear Sir/Madam';
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += '<BR/>';

        EmailBody_lTxt += '<table width="100%"><tr><td>';
        EmailBody_lTxt += '<table cellpadding="0" cellspacing="0" style="border:0.3px solid black;" align="left" width="100%">';
        TableBodyAppend_gFnc(EmailBody_lTxt, 'QC Receipt No.', UserApprovalEntry_iRec."Document No.");
        TableBodyAppend_gFnc(EmailBody_lTxt, 'Approved By', UserApprovalEntry_iRec."Approver ID");
        TableBodyAppend_gFnc(EmailBody_lTxt, 'Approved Date', FormatMailDate_gFnc(Dt2Date(UserApprovalEntry_iRec."Approver Response Receive On")));

        EmailBody_lTxt += '</table>';
        EmailBody_lTxt += '</table>';
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += 'Regards,';
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += CompanyInfo_lRec.Name;
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += 'This is System Generated Email.';
        EmailBody_lTxt += '<BR/>';

        EmailMessage.Create(receipent, Subject_lTxt, EmailBody_lTxt, true, CC, BCC);

        if Email.Send(EmailMessage, Enum::"Email Scenario"::Default) then;
    end;

    procedure RejectEmail_gFnc(UserApprovalEntry_iRec: Record "QC User Approval Entry")
    var
        receipent: List of [Text];
        Subject_lTxt: Text[100];
        Tittle_lTxt: Text[50];
        UserSetup_lRec: Record "User Setup";
        Text001_gCtx: label 'FixedAssetDisposal %1.pdf';
        CompanyInfo_lRec: Record "Company Information";
        QCRcptHeader_lRec: Record "QC Rcpt. Header";
    begin
        QualityControlSetup_gRec.Get;
        if not QualityControlSetup_gRec."Send Mail on QC Approval" then
            exit;

        UserApprovalEntry_iRec.TestField("Requester ID");
        UserSetup_lRec.Get(UserApprovalEntry_iRec."Requester ID");
        UserSetup_lRec.TestField("E-Mail");
        Clear(receipent);
        receipent.Add(UserSetup_lRec."E-Mail");

        QCRcptHeader_lRec.Get(UserApprovalEntry_iRec."Document No.");

        CompanyInfo_lRec.Get;

        Clear(EmailMessage);

        Subject_lTxt := 'QC Order - Rejected';
        Tittle_lTxt := 'QC Approval';




        //if Cc_lTxt <> '' then
        //SMTPMail_lCdu.AddCC(Cc_lTxt);

        EmailBody_lTxt += 'Dear Sir/Madam';
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += '<BR/>';

        EmailBody_lTxt += '<table width="100%"><tr><td>';
        EmailBody_lTxt += '<table cellpadding="0" cellspacing="0" style="border:0.3px solid black;" align="left" width="100%">';
        TableBodyAppend_gFnc(EmailBody_lTxt, 'QC Receipt No.', UserApprovalEntry_iRec."Document No.");
        TableBodyAppend_gFnc(EmailBody_lTxt, 'Rejected By', UserApprovalEntry_iRec."Approver ID");
        TableBodyAppend_gFnc(EmailBody_lTxt, 'Rejected Date', FormatMailDate_gFnc(Dt2Date(UserApprovalEntry_iRec."Approver Response Receive On")));
        TableBodyAppend_gFnc(EmailBody_lTxt, 'Remarks', UserApprovalEntry_iRec.Remarks);
        TableBodyAppend_gFnc(EmailBody_lTxt, 'Rejection Comment', UserApprovalEntry_iRec."Rejection Comment");
        EmailBody_lTxt += '</table>';
        EmailBody_lTxt += '</table>';

        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += 'Regards,';
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += CompanyInfo_lRec.Name;
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += 'This is System Generated Email.';
        EmailBody_lTxt += '<BR/>';

        EmailMessage.Create(receipent, Subject_lTxt, EmailBody_lTxt, true, CC, BCC);

        if Email.Send(EmailMessage, Enum::"Email Scenario"::Default) then;
    end;

    procedure FormatMailDate_gFnc(Date_iDte: Date): Text
    begin
        exit(Format(Date_iDte, 0, '<Day,2>/<Month,2>/<Year>'));
    end;

    procedure TableBodyAppend_gFnc(var Body_vTxt: Text; Caption_iTxt: Text; Value_iTxt: Text)
    begin
        Body_vTxt += '<tr><td align="left" Style="border:0.3px solid Black; font-weight:bold;padding:0px 5px 0px 5px;background-color: #DEF3F9"  Width="30%">' + Caption_iTxt + '</td>';
        Body_vTxt += '<td Style="border:0.3px solid Black;padding:0px 5px 0px 5px" align="left" Width="70%">' + Value_iTxt + '</td></TR>';
    end;

    procedure HyperLinkBodyAppend_gFnc(var Body_vTxt: Text; Caption_iTxt: Text; Value_iTxt: Text)
    begin
        Body_vTxt += '<tr><td align="left" Style="border:0.3px solid Black; font-weight:bold;padding:0px 5px 0px 5px;background-color: #DEF3F9"  Width="30%">' + Caption_iTxt + '</td>';
        Body_vTxt += '<td Style="border:0.3px solid Black;padding:0px 5px 0px 5px" align="left" Width="70%"> <a href=' + Value_iTxt + '> Click here </td></TR>';
    end;
}

