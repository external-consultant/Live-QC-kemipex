codeunit 75407 "Table_Subscribe_5405"
{
    [EventSubscriber(ObjectType::Table, Database::"Production Order", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertEvent(var Rec: Record "Production Order");
    begin
        if Rec.IsTemporary then
            exit;
        Rec."QC Status" := Rec."QC Status"::Blank;//T12542-N
    end;


}