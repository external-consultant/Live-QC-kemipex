
Codeunit 75406 Subscribe_Page_9326
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Page, Page::"Released Production Orders", 'OnOpenPageEvent', '', true, true)]
    local procedure MyProcedure(var Rec: Record "Production Order")
    begin
        Rec.Setrange("Rework Order", false);
    end;





}