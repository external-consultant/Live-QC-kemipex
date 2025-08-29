codeunit 75394 "QC Email Notification"//T12113-ABA-N
{
    trigger OnRun()
    begin

    end;

    procedure QCCreationEmail_gFnc(QCRcpt_iRec: Record "QC Rcpt. Header")
    var
        receipent: List of [Text];
        Cc_lTxt: Text[250];
        Subject_lTxt: Text[100];
        Sender_lTxt: Text[50];
        Bcc_lTxt: Text[100];
        Tittle_lTxt: Text[50];
        UserSetup_lRec: Record "User Setup";
        Text001_gCtx: label 'FixedAssetDisposal %1.pdf';

        CompanyInfo_lRec: Record "Company Information";
        WebURL_lTxt: Text;
        WindowsURL_lTxt: Text;
        DynaEquipSetup_lRec: Record "Inventory Setup";

        ExtraBody_lTxt: Text;
        LastPurchasePriceUnit_lDec: Decimal;
        Totals_lDec: Decimal;
        Item_lRec: Record Item;
        PurchaIndTotals_lDec: Decimal;
        DocumentAttachment: Record "Document Attachment";
        i: Integer;
        TempBlobAtc: Array[10] of Codeunit "Temp Blob";
        outStreamReportAtc: Array[10] of OutStream;
        inStreamReportAtc: Array[10] of InStream;
        FullFileName: Text;
        QCRcpt_lRec: Record "QC Rcpt. Header";
    begin
        clear(QCRcpt_lRec);
        QCRcpt_lRec.copy(QCRcpt_iRec);
        QCSetup_gRec.Get;
        if not QCSetup_gRec."Enable Not. On QCRcpt Creation" then
            exit;

        Clear(receipent);
        GetListOfEmail_gFnc(QCSetup_gRec."Email To", receipent);
        CompanyInfo_lRec.Get;
        Tittle_lTxt := 'QC Receipt';
        Subject_lTxt := StrSubstNo('QC Receipt No. %1', QCRcpt_lRec."No.");
        EmailBody_gFnc;

        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += '<table width="100%"><tr><td>';
        EmailBody_lTxt += '<table cellpadding="0" cellspacing="0" style="border:0.3px solid black;" align="left" width="100%">';
        TableBodyAppend_gFnc(EmailBody_lTxt, 'Document Type', Format(QCRcpt_lRec."Document Type"));
        TableBodyAppend_gFnc(EmailBody_lTxt, 'Document No.', QCRcpt_lRec."No.");
        TableBodyAppend_gFnc(EmailBody_lTxt, 'Document Line No.', Format(QCRcpt_lRec."Document Line No."));
        TableBodyAppend_gFnc(EmailBody_lTxt, 'Item No', QCRcpt_lRec."Item No.");
        TableBodyAppend_gFnc(EmailBody_lTxt, 'Item Description', QCRcpt_lRec."Item Description");
        TableBodyAppend_gFnc(EmailBody_lTxt, 'Created Date Time', Format(CurrentDateTime));

        WebURL_lTxt := '';
        //WebURL_lTxt := GetUrl(Clienttype::Web, COMPANYNAME, Objecttype::Page, Page::"Approval Entry", ApproveAppEntryEmail_lRec, true);

        //HyperLinkBodyAppend_gFnc(EmailBody_lTxt, 'Web Link', WebURL_lTxt);

        EmailBody_lTxt += '</table>';
        EmailBody_lTxt += '</table>';


        EmailBody_lTxt += '<BR/>';
        //EmailBody_lTxt += '<B>Remarks : </B>' + Format(QCRcpt_lRec."Document Type");
        EmailBody_lTxt += '<BR/>';


        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += 'Thanks & Regards,';
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += CompanyInfo_lRec.Name;
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += '<BR/>';
        EmailBody_lTxt += 'This is System Generated Email.';
        EmailBody_lTxt += '<BR/>';

        EmailMessage.Create(receipent, Subject_lTxt, EmailBody_lTxt, true, CC, BCC);
        i := 1;
        DocumentAttachment.Reset();
        DocumentAttachment.setrange("Table ID", 75382);
        DocumentAttachment.setrange("No.", QCRcpt_lRec."No.");
        if DocumentAttachment.FindSet() then begin
            repeat
                if DocumentAttachment."Document Reference ID".HasValue then begin
                    TempBlobAtc[i].CreateOutStream(outStreamReportAtc[i]);
                    TempBlobAtc[i].CreateInStream(inStreamReportAtc[i]);
                    FullFileName := DocumentAttachment."File Name" + '.' + DocumentAttachment."File Extension";
                    if DocumentAttachment."Document Reference ID".ExportStream(outStreamReportAtc[i]) then begin
                        //Mail Attachments
                        EmailMessage.AddAttachment(FullFileName, 'PDF,', inStreamReportAtc[i]);
                    end;
                    i += 1;
                end;
            until DocumentAttachment.NEXT = 0;
        end;
        if Email.Send(EmailMessage, Enum::"Email Scenario"::Default) then;
    end;


    local procedure EmailBody_gFnc()
    Var
        CC: List of [Text];
        BCC: List of [Text];
    begin

        if QCSetup_gRec."Email CC" <> '' then begin
            Clear(CC);
            GetListOfEmail_gFnc(QCSetup_gRec."Email CC", CC);

        end;

        if QCSetup_gRec."Email BCC" <> '' then begin
            Clear(BCC);
            GetListOfEmail_gFnc(QCSetup_gRec."Email BCC", BCC);

        end;

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

    var

    var
        QCSetup_gRec: Record "Quality Control Setup";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailBody_lTxt: Text;
        receipent: List of [Text];
        CC: List of [Text];
        BCC: List of [Text];


    procedure GetListOfEmail_gFnc(EmailText_iTxt: Text; Var EmailListVar: List of [Text])
    var
        LastChr: Text;
        TmpRecipients: Text;
    begin
        IF EmailText_iTxt = '' then
            Exit;

        IF STRPOS(EmailText_iTxt, ';') <> 0 THEN BEGIN  //System doesn't work if the email address end with semi colon  /ex: xyz@abc.com;
            LastChr := COPYSTR(EmailText_iTxt, STRLEN(EmailText_iTxt));
            IF LastChr = ';' THEN
                EmailText_iTxt := COPYSTR(EmailText_iTxt, 1, STRPOS(EmailText_iTxt, ';') - 1);
        END;

        IF STRPOS(EmailText_iTxt, ',') <> 0 THEN BEGIN  //System doesn't work if the email address end with Comma  /ex: xyz@abc.com,
            LastChr := COPYSTR(EmailText_iTxt, STRLEN(EmailText_iTxt));
            IF LastChr = ',' THEN
                EmailText_iTxt := COPYSTR(EmailText_iTxt, 1, STRPOS(EmailText_iTxt, ',') - 1);
        END;

        TmpRecipients := DELCHR(EmailText_iTxt, '<>', ';');
        WHILE STRPOS(TmpRecipients, ';') > 1 DO BEGIN
            EmailListVar.Add((COPYSTR(TmpRecipients, 1, STRPOS(TmpRecipients, ';') - 1)));
            TmpRecipients := COPYSTR(TmpRecipients, STRPOS(TmpRecipients, ';') + 1);
        END;
        EmailListVar.Add(TmpRecipients);
    end;
}