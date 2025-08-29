Page 75391 "QC Specification"
{
    // ------------------------------------------------------------------------------------------------------------------------------
    // Intech-Systems-info@intech-systems.com
    // ------------------------------------------------------------------------------------------------------------------------------
    // ID                     DATE        AUTHOR
    // ------------------------------------------------------------------------------------------------------------------------------
    // I-C0009-1001310-04     27/08/12    Dipak Patel/Nilesh Gajjar
    //                        QC Module - Redesign Released.
    // I-C0009-1400405-01     05/08/14    Chintan Panchal
    //                        Upgrade to NAV 2013 R2
    // ------------------------------------------------------------------------------------------------------------------------------

    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "QC Specification Header";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic;
                    Editable = true;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                    Caption = 'Description';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = Basic;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic;
                }
                field("Prepared By"; Rec."Prepared By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Revision Date"; Rec."Revision Date")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ApplicationArea = Basic;
                }
            }
            part("Qc Line"; "QC Specification Subform")
            {
                SubPageLink = "Item Specifiction Code" = field("No.");
                SubPageView = sorting("Item Specifiction Code", "Line No.")
                              order(ascending);
                UpdatePropagation = SubPart;
                Visible = true;
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Copy &Item Specification")
                {
                    ApplicationArea = Basic;
                    Caption = 'Copy &Item Specification';
                    Ellipsis = true;

                    trigger OnAction()
                    var
                        QCSpecifiHeader_gRec: Record "QC Specification Header";
                        QualityControl_gCdu: Codeunit "Quality Control - General";
                    begin
                        //I-C0009-1001310-02 NS
                        Rec.TestField("No.");
                        if Page.RunModal(0, QCSpecifiHeader_gRec) = Action::LookupOK then
                            QualityControl_gCdu.CopyQCSpecification_gRec(QCSpecifiHeader_gRec."No.", Rec);
                        //I-C0009-1001310-02 NE
                    end;
                }
            }
        }
    }
}

