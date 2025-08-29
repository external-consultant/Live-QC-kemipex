Report 75385 ExpirationAlertMail//T12113-ABA-N
{
    ProcessingOnly = true;
    UsageCategory = ReportsandAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem("Quality Control Setup"; "Quality Control Setup")
        {
            trigger OnAfterGetRecord()
            var

            begin
                clear(calculateDate_gVDte);
                Clear(WorkDate_gDte);
                Clear(EmailMessage);
                Clear(EmailBody_lTxt);
                Clear(Email);

                if "Quality Control Setup".IsEmpty then
                    exit;

                WorkDate_gDte := WorkDate();
                //WorkDate_gDte := 20240101D;
                calculateDate_gVDte := ((CALCDATE('-' + Format("Expiration Due Alert"), WorkDate_gDte)));

                if Not FindLedgerEntries_gFnc then
                    exit;

                if not ForTest_gBln then
                    Recipients_gTxt := "Expiration Alert Mail To"
                else
                    Recipients_gTxt := TestEmail_gTxt;

                GetListOfEmail_gFnc(Recipients_gTxt, Recipients_gList);
                Subject_gTxt := StrSubstNo('Expiration Alert- %1', "Expiration Due Alert");

                EmailBody_lTxt += StrSubstNo('Dear Dear Sir/Ma`am ,');
                EmailBody_lTxt += '<BR/>';
                EmailBody_lTxt += '<BR/>';


                EmailBody_lTxt += StrSubstNo('Please find the list of Material that will be Expired in Next - %1', "Expiration Due Alert");
                EmailBody_lTxt += '<table>';
                EmailBody_lTxt += '<BR/>';
                TableBodyAppend_lFnc(Text029_gTxt);
                TableBodyAppend_lFnc(StrSubstNo(Text030_gTxt, COMPANYNAME));
                EmailBody_lTxt += '</table>';
                if GuiAllowed then begin
                    Windows_gDlg.Update(1, "Expiration Alert Mail To");
                    Windows_gDlg.Update(2, 'Processing.....');
                end;
                EmailMessage.Create(Recipients_gList, Subject_gTxt, EmailBody_lTxt, true, CC, BCC);
                //
                //Generate blob from report
                TempBlob.CreateOutStream(outStreamReport);
                clear(Recordr);
                Recordr.GetTable(ItemRec_gRec);
                Report.SaveAs(75386, 'ItemSummary', ReportFormat::Pdf, outStreamReport, Recordr);
                TempBlob.CreateInStream(inStreamReport);
                txtB64 := cnv64.ToBase64(inStreamReport, true);
                EmailMessage.AddAttachment('ItemLedgerEntries.pdf', 'application/pdf', txtB64);

                Email.Send(EmailMessage, Enum::"Email Scenario"::Default);

                if GuiAllowed then
                    Windows_gDlg.Update(3, 'Mail sent successfully');

                TotalEmailSent_gInt += 1;
                Commit;
            end;

            trigger OnPreDataItem()
            begin
                TotalEmailSent_gInt := 0;

                if ForTest_gBln then
                    if TestEmail_gTxt = '' then
                        Error('Please enter test Email Id.');
            end;

        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group("***For Testing Only***")
                {
                    Caption = '***For Testing Only***';
                    field("For Test"; ForTest_gBln)
                    {
                        ApplicationArea = Basic;
                    }
                    field("Test Email ID"; TestEmail_gTxt)
                    {
                        ApplicationArea = Basic;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        if GuiAllowed then begin
            Windows_gDlg.Close;
            Message(Text002_gTxt, TotalEmailSent_gInt);
        end;
    end;

    trigger OnPreReport()
    begin
        CompanyInformation_gRec.Get;

        if GuiAllowed then
            Windows_gDlg.Open('No.: #1#############\Sending Email: #2#########\Email Sent : #3#########');

        // EximSetup_gRec.Get;
        // EximSetup_gRec.TestField("EPCG Expiry E-mail");

    end;

    Var
        TempBlob: Codeunit "Temp Blob";
        outStreamReport: OutStream;
        inStreamReport: InStream;
        cnv64: Codeunit "Base64 Convert";
        txtB64: text;
        Recordr: RecordRef;
        ItemRec_gRec: Record item;
        purchaser_gRec: Record "Salesperson/Purchaser";

        Recipients_gList: List of [Text];

        Recipients_gTxt: Text;
        Subject_gTxt: Text;
        Customer_gRec: Record Customer;
        ForTest_gBln: Boolean;
        TestEmail_gTxt: Text;
        Windows_gDlg: Dialog;
        ToEmail_gTxt: Text;
        TotalEmailSent_gInt: Integer;
        Text002_gTxt: label 'Total Email Sent - %1';
        SendEmail_gBln: Boolean;
        CompanyInformation_gRec: Record "Company Information";

        //EmailTemplate_gRec: Record "Advance Email Template";
        Text029_gTxt: label 'Thanks & Regards,';
        Text030_gTxt: label '%1 - System Auto E-Mail';
        Email_gTxt: Text;
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailBody_lTxt: Text;
        receipent: List of [Text];
        CC: List of [Text];
        BCC: List of [Text];
        EmailAct: Codeunit "Email Account";

        TotalCount_gInt: Integer;

        FirstReminder_gDte: Date;
        SecondReminder_gDate: Date;
        ThirdReminder_gDate: Date;

        WorkDate_gDte: date;


        Total_gDec: Decimal;
        FooterTotal_gDec: Decimal;
        calculateDate_gVDte: date;
        ImportCalculateDate_gDte: date;
        flag_gBol: Boolean;



    local procedure TableBodyAppend1_lFnc()

    begin

        // EmailBody_lTxt += '<tr>';
        // EmailBody_lTxt += '<td align="left" Style="font-size:12px; border:0.1px solid black;"  Width="10%">' + ForexEntry_iRec."Currency Code" + '</td>';
        // EmailBody_lTxt += '<td align="left" Style="font-size:12px; border:0.1px solid black;"  Width="20%">' + ForexEntry_iRec.Description + '</td>';
        // EmailBody_lTxt += '<td align="left" Style="font-size:12px; border:0.1px solid black;"  Width="10%">' + format(ForexEntry_iRec."Import Validity Expiry Date", 0, '<Day,2>-<Month,2>-<Year4>') + '</td>';
        // EmailBody_lTxt += '<td align="left" Style="font-size:12px; border:0.1px solid black;"  Width="20%">' + format(ForexEntry_iRec."Export Validity Expiry Date", 0, '<Day,2>-<Month,2>-<Year4>') + '</td>';
        // EmailBody_lTxt += '<td align="Right" Style="font-size:12px; border:0.1px solid black;"  Width="20%">' + Format(ForexEntry_iRec."CIF Value of Import (LCY)") + '</td>';
        // EmailBody_lTxt += '<td align="Right" Style="font-size:12px; border:0.1px solid black;"  Width="10%">' + Format(ForexEntry_iRec."Export Obligation FOB (FCY)") + '</td>';//
        // EmailBody_lTxt += '<td align="left" Style="font-size:12px; border:0.1px solid black;"  Width="10%">' + Format(ForexEntry_iRec."No.") + '</td>';
        // EmailBody_lTxt += '</tr>';

    end;


    local procedure TableHeaderAppend1_lFnc()
    begin

        EmailBody_lTxt += '<tr>';
        EmailBody_lTxt += '<th align="left" Style="border:0.1px solid black;"  Width="10%">' + 'Currency Code' + '</th>';
        EmailBody_lTxt += '<th align="left" Style="border:0.1px solid black;"  Width="20%">' + 'Description' + '</th>';
        EmailBody_lTxt += '<th align="left" Style="border:0.1px solid black;"  Width="10%">' + 'Import Expiry Validity Date' + '</th>';
        EmailBody_lTxt += '<th align="Center" Style="border:0.1px solid black;"  Width="20%">' + 'Export Expiry Validity Date' + '</th>';
        EmailBody_lTxt += '<th align="Center" Style="border:0.1px solid black;"  Width="20%">' + 'Import-FCY' + '</th>';
        EmailBody_lTxt += '<th align="Center" Style="border:0.1px solid black;"  Width="10%">' + 'FOB-FCY' + '</th>';
        EmailBody_lTxt += '<th align="Center" Style="border:0.1px solid black;"  Width="10%">' + 'EPCG No.' + '</th>';
        EmailBody_lTxt += '</tr>';

    end;

    local procedure TableBodyAppend_lFnc(Value_iTxt: Text)
    begin
        EmailBody_lTxt += '<tr>';
        EmailBody_lTxt += '<td align="left" padding:0px 10px 0px 5px"  Width="30%">' + Value_iTxt + '</td>';
        EmailBody_lTxt += '</tr>';
    end;

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

    local procedure FindLedgerEntries_gFnc(): Boolean
    var
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
    begin
        clear(ItemLedgerEntry_lRec);
        ItemLedgerEntry_lRec.SetRange(Open, True);
        ItemLedgerEntry_lRec.Setfilter("Remaining Quantity", '>%1', 0);
        ItemLedgerEntry_lRec.SetFilter("Expiration Date", '%1..%2', WorkDate_gDte, calculateDate_gVDte);
        if ItemLedgerEntry_lRec.FindFirst() then
            exit(true);


    end;



}