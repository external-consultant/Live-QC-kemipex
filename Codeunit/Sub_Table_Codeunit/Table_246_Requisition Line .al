codeunit 75391 "Table_Subscribe_246"
{

    //14-02-2023
    [EventSubscriber(ObjectType::Table, Database::"Requisition Line", 'OnGetLocationCodeOnBeforeUpdate', '', false, false)]
    local procedure OnGetLocationCodeOnBeforeUpdate(var RequisitionLine: Record "Requisition Line"; CurrentFieldNo: Integer; var IsHandled: Boolean);
    begin
        IsHandled := True;
    end;


}