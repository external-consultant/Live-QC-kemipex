// codeunit 75396 INT_Sample_ErrorInfo
// {


//     trigger OnRun()
//     var

//         GenJournalLine: Record "Gen. Journal Line";
//         ErrorInfo: ErrorInfo;
//         SameSourceCodeErr: Label 'Journal Source Code %1 is same as Source Code set for Purcase/Sales documents. This is not allowed when using deferrals. If you want to use this journal for deferrals, please update Source Codes on Gen Journal Template and generate line again.', Comment = '%1->Source Code';
//         OpenGenJournalTemplateDescTxt: Label 'Open Gen. Journal Template page to update Source code.';
//         OpenSourceCodeSetupDescTxt: Label 'Open Source Code Setup page to check Source code setup.';
//     begin

//         ErrorInfo.ErrorType(ErrorType::Client);
//         ErrorInfo.Verbosity(Verbosity::Error);
//         ErrorInfo.Message(StrSubstNo(SameSourceCodeErr, GenJournalLine."Source Code"));
//         ErrorInfo.TableId(GenJournalLine.RecordId.TableNo);
//         ErrorInfo.RecordId(GenJournalLine.RecordId);
//         ErrorInfo.AddAction('Open Gen. Journal Template', Codeunit::"INT_Sample_ErrorInfo", 'ShowGenJournalTemplate', OpenGenJournalTemplateDescTxt);
//         ErrorInfo.AddAction('Open Source Code Setup', Codeunit::"INT_Sample_ErrorInfo", 'ShowSourceCodeSetup', OpenSourceCodeSetupDescTxt);
//         Error(ErrorInfo);
//     end;


//     procedure ShowGenJournalTemplate(ErrorInfo: ErrorInfo)
//     var
//         GenJournalTemplate: Record "Gen. Journal Template";
//         GenJournalLine: Record "Gen. Journal Line";
//         GeneralJournalTemplates: Page "General Journal Templates";
//         RecordRef: RecordRef;
//     begin
//         RecordRef := ErrorInfo.RecordId.GetRecord();
//         RecordRef.SetTable(GenJournalLine);
//         GenJournalTemplate.SetRange(Name, GenJournalLine."Journal Template Name");
//         GeneralJournalTemplates.SetTableView(GenJournalTemplate);
//         GeneralJournalTemplates.RunModal();
//     end;

//     procedure ShowSourceCodeSetup(ErrorInfo: ErrorInfo)
//     var
//         SourceCodeSetup: Page "Source Code Setup";
//     begin
//         SourceCodeSetup.RunModal();
//     end;
// }