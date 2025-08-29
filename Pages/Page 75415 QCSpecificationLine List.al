page 75415 "QCSpecificationLine List" //T51170-N
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "QC Specification Line";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {

                field("Quality Parameter Code"; Rec."Quality Parameter Code")
                {
                    ToolTip = 'Specifies the value of the Quality Parameter Code field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("Item Specifiction Code"; Rec."Item Specifiction Code")
                {
                    ToolTip = 'Specifies the value of the Item Specifiction Code field.', Comment = '%';
                }
                field("Min.Value"; Rec."Min.Value")
                {
                    ToolTip = 'Specifies the value of the Min.Value field.', Comment = '%';
                }
                field("Max.Value"; Rec."Max.Value")
                {
                    ToolTip = 'Specifies the value of the Max.Value field.', Comment = '%';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}